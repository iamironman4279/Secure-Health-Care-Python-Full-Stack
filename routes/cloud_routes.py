import secrets
from flask import Blueprint, render_template, request, redirect, url_for, session, flash, make_response
from flask_mysqldb import MySQL
import MySQLdb.cursors
import pyotp
import qrcode
from io import BytesIO
import base64
import plotly.graph_objects as go
from config import AES_SECRET_KEY
from mail import send_activation_email
from utils.encryption import AESEncryption
import json
from datetime import datetime
import os
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad
import logging
from pymongo import MongoClient  # Added for MongoDB

# Set up logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

cloud_bp = Blueprint('cloud', __name__)

db = None
mongo_client = None
mongo_db = None
CLOUD_TOTP_SECRET = "JBSWY3DPEHPK3PXP"  # Unchanged as requested
aes = AESEncryption(AES_SECRET_KEY)  # Unchanged as requested
BACKUP_AES_KEY = bytes.fromhex('644763a252ff93d03e4c0f8cdec880f439c4c571d57fa229b3f45b0715aacb5e')  # Using your provided key
MONGO_URI = "mongodb+srv://hemanth42079:w09aOMeW5nAccwQ2@cluster0.cnduffa.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"  # Replace with your Atlas URL

def init_cloud(mysql):
    global db, mongo_client, mongo_db
    db = mysql
    mongo_client = MongoClient(MONGO_URI)
    mongo_db = mongo_client['backup']  # Database name: backup
    return cloud_bp

# Helper function to fetch common data
def fetch_common_data(cursor):
    cursor.execute("SELECT id, patient_id, name, email, phone, address, is_activated FROM patients")
    patients = cursor.fetchall()
    cursor.execute("SELECT doctor_id, name, email, phone, specialization, is_activated FROM doctors")
    doctors = cursor.fetchall()
    cursor.execute("""
        SELECT dr.id, dr.doctor_id, dr.patient_id, dr.status, dr.decryption_key,
               d.name as doctor_name, p.name as patient_name
        FROM doctor_requests dr
        JOIN doctors d ON dr.doctor_id = d.doctor_id
        JOIN patients p ON dr.patient_id = p.patient_id
    """)
    doctor_requests = cursor.fetchall()
    cursor.execute("""
        SELECT dp.doctor_id, dp.patient_id, d.name as doctor_name, p.name as patient_name
        FROM doctor_patient dp
        JOIN doctors d ON dp.doctor_id = d.doctor_id
        JOIN patients p ON dp.patient_id = p.patient_id
        WHERE dp.status = 'active'
    """)
    assignments = cursor.fetchall()
    cursor.execute("""
        SELECT DISTINCT mr.id, mr.patient_id, mr.encrypted_data, mr.updated_time
        FROM medical_records mr
        ORDER BY mr.updated_time DESC
    """)
    medical_records = cursor.fetchall()
    encrypted_records = []
    for record in medical_records:
        if record['encrypted_data']:
            record_bytes = record['encrypted_data'] if isinstance(record['encrypted_data'], bytes) else record['encrypted_data'].encode('utf-8')
            record['encrypted_data'] = base64.b64encode(record_bytes).decode('utf-8')
        encrypted_records.append(record)
    return patients, doctors, doctor_requests, assignments, encrypted_records

def generate_graphs(cursor):
    # Existing Pie Chart
    cursor.execute('SELECT COUNT(*) as patient_count FROM patients')
    patient_count = cursor.fetchone()['patient_count']
    cursor.execute('SELECT COUNT(*) as doctor_count FROM doctors')
    doctor_count = cursor.fetchone()['doctor_count']
    pie_fig = go.Figure(data=[go.Pie(labels=['Patients', 'Doctors'], values=[patient_count, doctor_count], 
                                     hole=0.3, marker_colors=['#9333ea', '#3b82f6'], textinfo='label+percent', textposition='inside')])
    pie_fig.update_layout(title_text="Patients vs Doctors Distribution", paper_bgcolor='rgba(0,0,0,0)', 
                          plot_bgcolor='rgba(0,0,0,0)', font_color='white')
    pie_graph = pie_fig.to_html(full_html=False)

    # Existing Bar Chart (likely where line 79 starts)
    cursor.execute('SELECT DATE(updated_time) as date, COUNT(*) as count FROM medical_records GROUP BY DATE(updated_time)')
    records_data = cursor.fetchall()
    dates = [row['date'] for row in records_data]
    counts = [row['count'] for row in records_data]
    bar_fig = go.Figure(data=[go.Bar(x=dates, y=counts, marker_color='#9333ea', text=counts, textposition='auto')])
    bar_fig.update_layout(title_text="Medical Records Creation Over Time", xaxis_title="Date", yaxis_title="Number of Records", 
                          paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', font_color='white')
    bar_graph = bar_fig.to_html(full_html=False)

    # Existing Line Chart
    cursor.execute('SELECT updated_time, encrypted_data FROM medical_records WHERE patient_id = %s', 
                   (session.get('patient_id', 'default_patient_id'),))
    crypto_data = cursor.fetchall()
    times = [row['updated_time'] for row in crypto_data]
    encryption_times = [len(row['encrypted_data']) * 0.1 for row in crypto_data]
    line_fig = go.Figure(data=[go.Scatter(x=times, y=encryption_times, mode='lines+markers', line_color='#3b82f6', marker=dict(size=8))])
    line_fig.update_layout(title_text="Simulated Cryptographic Operation Times", xaxis_title="Record Creation Time", 
                           yaxis_title="Operation Time (ms)", paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', font_color='white')
    line_graph = line_fig.to_html(full_html=False)

    # Existing Bar Chart (Patients per Doctor)
    cursor.execute('SELECT d.name, COUNT(dp.patient_id) as patient_count FROM doctors d LEFT JOIN doctor_patient dp ON d.doctor_id = dp.doctor_id GROUP BY d.doctor_id, d.name')
    dp_data = cursor.fetchall()
    doctor_names = [row['name'] for row in dp_data]
    patient_counts = [row['patient_count'] for row in dp_data]
    dp_fig = go.Figure(data=[go.Bar(x=doctor_names, y=patient_counts, marker_color='#9333ea', text=patient_counts, textposition='auto')])
    dp_fig.update_layout(title_text="Patients per Doctor", xaxis_title="Doctor Name", yaxis_title="Number of Patients", 
                         paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', font_color='white')
    dp_graph = dp_fig.to_html(full_html=False)

    # Area Graph
    cursor.execute('SELECT DATE(updated_time) as date, COUNT(*) as count FROM medical_records GROUP BY DATE(updated_time) ORDER BY date')
    area_data = cursor.fetchall()
    area_dates = [row['date'] for row in area_data]
    area_counts = [sum(row['count'] for row in area_data[:i+1]) for i in range(len(area_data))]
    area_fig = go.Figure(data=[go.Scatter(x=area_dates, y=area_counts, fill='tozeroy', mode='lines', line_color='#9333ea')])
    area_fig.update_layout(title_text="Cumulative Medical Records Over Time", xaxis_title="Date", yaxis_title="Cumulative Records", 
                           paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', font_color='white')
    area_graph = area_fig.to_html(full_html=False)

    # Bubble Chart
    cursor.execute("""
        SELECT d.name, 
               COUNT(DISTINCT dp.patient_id) as patient_count, 
               COUNT(a.appointment_id) as appointment_count 
        FROM doctors d 
        LEFT JOIN doctor_patient dp ON d.doctor_id = dp.doctor_id 
        LEFT JOIN appointments a ON d.doctor_id = a.doctor_id 
        GROUP BY d.doctor_id, d.name
    """)
    bubble_data = cursor.fetchall()
    bubble_doctor_names = [row['name'] for row in bubble_data]
    bubble_patient_counts = [row['patient_count'] for row in bubble_data]
    bubble_appointment_counts = [row['appointment_count'] for row in bubble_data]
    bubble_fig = go.Figure(data=[go.Scatter(
        x=bubble_patient_counts, 
        y=bubble_appointment_counts, 
        text=bubble_doctor_names, 
        mode='markers', 
        marker=dict(size=[count * 10 for count in bubble_appointment_counts], color='#3b82f6', opacity=0.7)
    )])
    bubble_fig.update_layout(title_text="Doctors: Patients vs Appointments (Bubble Size = Appointments)", 
                             xaxis_title="Number of Patients", yaxis_title="Number of Appointments", 
                             paper_bgcolor='rgba(0,0,0,0)', plot_bgcolor='rgba(0,0,0,0)', font_color='white')
    bubble_graph = bubble_fig.to_html(full_html=False)

    return pie_graph, bar_graph, line_graph, dp_graph, area_graph, bubble_graph
   
# Encryption and decryption functions
def encrypt_backup(content):
    logger.debug("Encrypting backup")
    cipher = AES.new(BACKUP_AES_KEY, AES.MODE_CBC)
    ct_bytes = cipher.encrypt(pad(content.encode('utf-8'), AES.block_size))
    iv = base64.b64encode(cipher.iv).decode('utf-8')
    ct = base64.b64encode(ct_bytes).decode('utf-8')
    return iv, ct

def decrypt_backup(iv, ciphertext):
    logger.debug("Entering decrypt_backup function")
    logger.debug(f"IV received: {iv[:10]}...")
    logger.debug(f"Ciphertext received: {ciphertext[:10]}...")
    try:
        iv = base64.b64decode(iv)
        ct = base64.b64decode(ciphertext)
        cipher = AES.new(BACKUP_AES_KEY, AES.MODE_CBC, iv)
        pt = unpad(cipher.decrypt(ct), AES.block_size)
        logger.debug("Decryption successful")
        return pt.decode('utf-8')
    except Exception as e:
        logger.error(f"Decryption error: {str(e)}")
        return f"Decryption failed: {str(e)}"

def decrypt_backup_new(iv, ciphertext):
    logger.debug("Entering decrypt_backup_new function")
    logger.debug(f"IV received: {iv}")
    logger.debug(f"Ciphertext received: {ciphertext[:50]}...")
    try:
        iv = base64.b64decode(iv)
        ct = base64.b64decode(ciphertext)
        cipher = AES.new(BACKUP_AES_KEY, AES.MODE_CBC, iv)
        pt = unpad(cipher.decrypt(ct), AES.block_size)
        decrypted_text = pt.decode('utf-8')
        logger.debug("Decryption successful")
        logger.debug(f"Decrypted content: {decrypted_text[:100]}...")
        return decrypted_text
    except Exception as e:
        error_msg = f"Decryption failed: {str(e)}"
        logger.error(error_msg)
        raise Exception(error_msg)

# Routes
@cloud_bp.route('/index')
def index():
    if 'cloud_loggedin' not in session or not session['cloud_loggedin']:
        flash('Please log in to access the dashboard.', 'danger')
        return redirect(url_for('cloud.cloud_login'))
    return render_template('index.html')

@cloud_bp.route('/patients', methods=['GET', 'POST'])
def patients():
    if 'cloud_loggedin' not in session or not session['cloud_loggedin']:
        flash('Please log in to access the dashboard.', 'danger')
        return redirect(url_for('cloud.cloud_login'))

    cursor = db.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT id, patient_id, name, email, phone, address, is_activated FROM patients")
    patients = cursor.fetchall()

    if request.method == 'POST':
        action = request.form.get('action')
        entity = request.form.get('entity')
        if entity == 'patient':
            patient_id = request.form.get('patient_id')
            if not patient_id:
                flash("Patient ID is required.", "danger")
                return redirect(url_for('cloud.patients'))

            if action == 'update':
                name = request.form.get('name')
                email = request.form.get('email')
                phone = request.form.get('phone')
                address = request.form.get('address')
                cursor.execute("""
                    UPDATE patients 
                    SET name = %s, email = %s, phone = %s, address = %s 
                    WHERE patient_id = %s
                """, (name, email, phone, address, patient_id))
                db.connection.commit()
                flash(f"Patient {patient_id} updated successfully.", "success")

            elif action == 'delete':
                cursor.execute("DELETE FROM patients WHERE patient_id = %s", (patient_id,))
                db.connection.commit()
                flash(f"Patient {patient_id} deleted successfully.", "danger")

        cursor.close()
        return redirect(url_for('cloud.patients'))

    cursor.close()
    return render_template('patients_list.html', patients=patients)

@cloud_bp.route('/doctors', methods=['GET', 'POST'])
def doctors():
    if 'cloud_loggedin' not in session or not session['cloud_loggedin']:
        flash('Please log in to access the dashboard.', 'danger')
        return redirect(url_for('cloud.cloud_login'))

    cursor = db.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT doctor_id, name, email, phone, specialization, is_activated FROM doctors")
    doctors = cursor.fetchall()

    if request.method == 'POST':
        action = request.form.get('action')
        entity = request.form.get('entity')
        if entity == 'doctor':
            doctor_id = request.form.get('doctor_id')
            if not doctor_id:
                flash("Doctor ID is required.", "danger")
                return redirect(url_for('cloud.doctors'))

            if action == 'update':
                name = request.form.get('name')
                email = request.form.get('email')
                phone = request.form.get('phone')
                specialization = request.form.get('specialization')
                cursor.execute("""
                    UPDATE doctors
                    SET name = %s, email = %s, phone = %s, specialization = %s
                    WHERE doctor_id = %s
                """, (name, email, phone, specialization, doctor_id))
                db.connection.commit()
                flash(f"Doctor {doctor_id} updated successfully.", "success")

            elif action == 'delete':
                try:
                    cursor.execute("DELETE FROM doctor_patient WHERE doctor_id = %s", (doctor_id,))
                    cursor.execute("DELETE FROM doctors WHERE doctor_id = %s", (doctor_id,))
                    db.connection.commit()
                    flash(f"Doctor {doctor_id} and associated patient assignments deleted successfully.", "danger")
                except MySQLdb.IntegrityError as e:
                    db.connection.rollback()
                    flash(f"Error deleting doctor: {str(e)}", "danger")
                except Exception as e:
                    db.connection.rollback()
                    flash(f"Unexpected error: {str(e)}", "danger")

        cursor.close()
        return redirect(url_for('cloud.doctors'))

    cursor.close()
    return render_template('doctors_list.html', doctors=doctors)

@cloud_bp.route('/doctors_activation', methods=['GET', 'POST'])
def doctors_activation():
    if 'cloud_loggedin' not in session or not session['cloud_loggedin']:
        flash('Please log in to access the dashboard.', 'danger')
        return redirect(url_for('cloud.cloud_login'))

    cursor = db.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT doctor_id, name, email, phone, specialization, is_activated FROM doctors")
    doctors = cursor.fetchall()

    if request.method == 'POST':
        action = request.form.get('action')
        entity = request.form.get('entity')
        if entity == 'doctor' and action in ['activate', 'deactivate']:
            doctor_id = request.form.get('doctor_id')
            activation_status = '1' if action == 'activate' else '0'
            cursor.execute("""
                UPDATE doctors 
                SET is_activated = %s 
                WHERE doctor_id = %s
            """, (activation_status, doctor_id))
            db.connection.commit()
            
            cursor.execute("SELECT email, name FROM doctors WHERE doctor_id = %s", (doctor_id,))
            doctor = cursor.fetchone()
            send_activation_email(doctor['email'], doctor['name'], 'Doctor', action == 'activate')
            flash(f"Doctor {doctor_id} has been {'activated' if activation_status == '1' else 'deactivated'}.", "info")
            cursor.close()
            return redirect(url_for('cloud.doctors_activation'))

    cursor.close()
    return render_template('doctors_activation.html', doctors=doctors)

@cloud_bp.route('/patients_activation', methods=['GET', 'POST'])
def patients_activation():
    if 'cloud_loggedin' not in session or not session['cloud_loggedin']:
        flash('Please log in to access the dashboard.', 'danger')
        return redirect(url_for('cloud.cloud_login'))

    cursor = db.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT id, patient_id, name, email, phone, address, is_activated FROM patients")
    patients = cursor.fetchall()

    if request.method == 'POST':
        action = request.form.get('action')
        entity = request.form.get('entity')
        if entity == 'patient' and action in ['activate', 'deactivate']:
            patient_id = request.form.get('patient_id')
            activation_status = '1' if action == 'activate' else '0'
            cursor.execute("""
                UPDATE patients 
                SET is_activated = %s 
                WHERE patient_id = %s
            """, (activation_status, patient_id))
            db.connection.commit()
            
            cursor.execute("SELECT email, name FROM patients WHERE patient_id = %s", (patient_id,))
            patient = cursor.fetchone()
            send_activation_email(patient['email'], patient['name'], 'Patient', action == 'activate')
            flash(f"Patient {patient_id} has been {'activated' if activation_status == '1' else 'deactivated'}.", "info")
            cursor.close()
            return redirect(url_for('cloud.patients_activation'))

    cursor.close()
    return render_template('patients_activation.html', patients=patients)

@cloud_bp.route('/files', methods=['GET', 'POST'])
def files():
    if 'cloud_loggedin' not in session or not session['cloud_loggedin']:
        flash('Please log in to access the dashboard.', 'danger')
        return redirect(url_for('cloud.cloud_login'))

    cursor = db.connection.cursor(MySQLdb.cursors.DictCursor)
    encrypted_records = []
    decrypted_data = {}
    cursor.execute("""
        SELECT DISTINCT mr.id, mr.patient_id, mr.encrypted_data, mr.updated_time
        FROM medical_records mr
        ORDER BY mr.updated_time DESC
    """)
    medical_records = cursor.fetchall()
    for record in medical_records:
        if record['encrypted_data']:
            record_bytes = record['encrypted_data'] if isinstance(record['encrypted_data'], bytes) else record['encrypted_data'].encode('utf-8')
            record['encrypted_data'] = base64.b64encode(record_bytes).decode('utf-8')
        encrypted_records.append(record)

    if request.method == 'POST':
        action = request.form.get('action')
        entity = request.form.get('entity')
        if action == 'decrypt' and entity == 'medical_records':
            encrypted_key = request.form.get('encrypted_key')
            user_keys = [record['encrypted_data'] for record in encrypted_records]
            if encrypted_key not in user_keys:
                flash("Unauthorized attempt.", 'danger')
            else:
                try:
                    decrypted_text = aes.decrypt(base64.b64decode(encrypted_key))
                    decrypted_values = decrypted_text.split('|')
                    if len(decrypted_values) == 5:
                        blood_group, blood_pressure, body_temp, pulse_rate, medications = decrypted_values
                        decrypted_data = {
                            'Blood Group': blood_group,
                            'Blood Pressure': blood_pressure,
                            'Body Temperature': body_temp,
                            'Pulse Rate': pulse_rate,
                            'Previous Medications': medications,
                            'encrypted_key': encrypted_key
                        }
                        flash("Record decrypted successfully.", "success")
                    else:
                        flash("Decryption failed: Invalid data format", 'danger')
                except Exception as e:
                    flash(f"Decryption failed: {str(e)}", 'danger')
    cursor.close()
    return render_template('files.html', encrypted_records=encrypted_records, decrypted_data=decrypted_data)

@cloud_bp.route('/assign_doctors', methods=['GET', 'POST'])
def assign_doctors():
    if 'cloud_loggedin' not in session or not session['cloud_loggedin']:
        flash('Please log in to access the dashboard.', 'danger')
        return redirect(url_for('cloud.cloud_login'))

    cursor = db.connection.cursor(MySQLdb.cursors.DictCursor)
    patients, doctors, _, assignments, _ = fetch_common_data(cursor)

    if request.method == 'POST':
        action = request.form.get('action')
        entity = request.form.get('entity')
        if entity == 'assignment' and action == 'assign':
            patient_id = request.form.get('patient_id')
            doctor_id = request.form.get('doctor_id')
            if not patient_id or not doctor_id:
                flash("Both Patient ID and Doctor ID are required.", "danger")
                return redirect(url_for('cloud.assign_doctors'))
            cursor.execute("""
                INSERT INTO doctor_patient (doctor_id, patient_id, status)
                VALUES (%s, %s, 'active')
                ON DUPLICATE KEY UPDATE status = 'active'
            """, (doctor_id, patient_id))
            db.connection.commit()
            flash(f"Doctor {doctor_id} assigned to Patient {patient_id}", "success")
            cursor.close()
            return redirect(url_for('cloud.assign_doctors'))

    cursor.close()
    return render_template('assign_doctors.html', patients=patients, doctors=doctors, assignments=assignments)

@cloud_bp.route('/doctor_request', methods=['GET', 'POST'])
def doctor_request():
    if 'cloud_loggedin' not in session or not session['cloud_loggedin']:
        flash('Please log in to access the dashboard.', 'danger')
        return redirect(url_for('cloud.cloud_login'))

    cursor = db.connection.cursor(MySQLdb.cursors.DictCursor)
    _, _, doctor_requests, _, _ = fetch_common_data(cursor)

    if request.method == 'POST':
        entity = request.form.get('entity')
        action = request.form.get('action')
        if entity == 'doctor_request':
            request_id = request.form.get('request_id')
            if not request_id:
                flash("Request ID is required.", "danger")
                return redirect(url_for('cloud.doctor_request'))

            if action == 'accept':
                cursor.execute("""
                    SELECT encrypted_data 
                    FROM medical_records 
                    WHERE patient_id = (SELECT patient_id FROM doctor_requests WHERE id = %s)
                    LIMIT 1
                """, (request_id,))
                record = cursor.fetchone()
                if record and record['encrypted_data']:
                    encrypted_data_str = record['encrypted_data'] if isinstance(record['encrypted_data'], str) else record['encrypted_data'].decode('utf-8')
                    encrypted_data_base64 = base64.b64encode(encrypted_data_str.encode('utf-8')).decode('utf-8')
                    cursor.execute("""
                        UPDATE doctor_requests 
                        SET status = 'accepted', decryption_key = %s 
                        WHERE id = %s
                    """, (encrypted_data_base64, request_id))
                    db.connection.commit()
                    flash(f"Request {request_id} accepted. Decryption key assigned.", "success")
                else:
                    flash("No encrypted data found for this patient.", "danger")

            elif action == 'reject':
                cursor.execute("""
                    UPDATE doctor_requests 
                    SET status = 'rejected', decryption_key = NULL 
                    WHERE id = %s
                """, (request_id,))
                db.connection.commit()
                flash(f"Request {request_id} rejected.", "info")
            cursor.close()
            return redirect(url_for('cloud.doctor_request'))

    cursor.close()
    return render_template('doctor_request.html', doctor_requests=doctor_requests)

@cloud_bp.route('/graph')
def graph():
    if 'cloud_loggedin' not in session or not session['cloud_loggedin']:
        flash('Please log in to access the dashboard.', 'danger')
        return redirect(url_for('cloud.cloud_login'))

    cursor = db.connection.cursor(MySQLdb.cursors.DictCursor)
    pie_graph, bar_graph, line_graph, dp_graph, area_graph, bubble_graph = generate_graphs(cursor)
    cursor.close()
    return render_template('graph.html', 
                          pie_graph=pie_graph, 
                          bar_graph=bar_graph, 
                          line_graph=line_graph, 
                          dp_graph=dp_graph, 
                          area_graph=area_graph, 
                          bubble_graph=bubble_graph)

@cloud_bp.route('/cloud_login', methods=['GET', 'POST'])
def cloud_login():
    if 'cloud_loggedin' in session and session['cloud_loggedin']:
        return redirect(url_for('cloud.index'))

    totp = pyotp.TOTP(CLOUD_TOTP_SECRET)
    qr_uri = totp.provisioning_uri(name="Cloud Server Admin", issuer_name="YourApp")
    qr = qrcode.make(qr_uri)
    buffer = BytesIO()
    qr.save(buffer, format="PNG")
    qr_code = base64.b64encode(buffer.getvalue()).decode('utf-8')

    if request.method == 'POST':
        otp = request.form.get('otp')
        if not otp or len(otp) != 6 or not otp.isdigit():
            return redirect(url_for('cloud.cloud_login', status='error'))

        if totp.verify(otp):
            session['cloud_loggedin'] = True
            return redirect(url_for('cloud.index', status='success'))
        else:
            return redirect(url_for('cloud.cloud_login', status='error'))

    return render_template('cloud_login.html', qr_code=qr_code)

@cloud_bp.route('/backup_patient/<patient_id>')
def backup_patient(patient_id):
    if 'cloud_loggedin' not in session or not session['cloud_loggedin']:
        flash('Please log in to access this feature.', 'danger')
        return redirect(url_for('cloud.cloud_login'))

    cursor = db.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT * FROM patients WHERE patient_id = %s", (patient_id,))
    patient = cursor.fetchone()
    
    if not patient:
        flash('Patient not found.', 'danger')
        cursor.close()
        return redirect(url_for('cloud.patients'))

    cursor.execute("SELECT * FROM medical_records WHERE patient_id = %s", (patient_id,))
    medical_records = cursor.fetchall()
    cursor.execute("""
        SELECT dp.*, d.name as doctor_name 
        FROM doctor_patient dp 
        JOIN doctors d ON dp.doctor_id = d.doctor_id 
        WHERE dp.patient_id = %s
    """, (patient_id,))
    doctor_assignments = cursor.fetchall()
    cursor.execute("""
        SELECT a.*, d.name as doctor_name 
        FROM appointments a 
        JOIN doctors d ON a.doctor_id = d.doctor_id 
        WHERE a.patient_id = %s
    """, (patient_id,))
    appointments = cursor.fetchall()

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_content = f"Patient Backup - {patient_id} - {timestamp}\n\n"
    backup_content += "Basic Information:\n" + json.dumps(patient, default=str, indent=2) + "\n\n"
    backup_content += "Medical Records:\n" + json.dumps(medical_records, default=str, indent=2) + "\n\n"
    backup_content += "Doctor Assignments:\n" + json.dumps(doctor_assignments, default=str, indent=2) + "\n\n"
    backup_content += "Appointments:\n" + json.dumps(appointments, default=str, indent=2) + "\n"

    iv, encrypted_content = encrypt_backup(backup_content)
    backup_dir = os.path.join(os.getcwd(), 'backups', 'patients')
    os.makedirs(backup_dir, exist_ok=True)
    filename = f"{patient_id}backup{timestamp}.enc"
    filepath = os.path.join(backup_dir, filename)
    
    enc_file_content = f"IV:{iv}\nCT:{encrypted_content}"
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(enc_file_content)
    
    # Upload to MongoDB
    try:
        backup_collection = mongo_db['backup']  # Collection name: backup
        backup_doc = {
            'filename': filename,
            'type': 'patient',
            'patient_id': patient_id,
            'timestamp': timestamp,
            'content': enc_file_content,
            'created_at': datetime.utcnow()
        }
        backup_collection.insert_one(backup_doc)
        logger.debug(f"Backup for patient {patient_id} uploaded to MongoDB")
    except Exception as e:
        logger.error(f"Failed to upload backup to MongoDB: {str(e)}")
        flash(f"Backup created locally but failed to upload to database: {str(e)}", 'danger')

    cursor.close()
    flash(f'Encrypted backup created successfully: {filename}', 'success')
    return redirect(url_for('cloud.patients'))

@cloud_bp.route('/backup_doctor/<doctor_id>')
def backup_doctor(doctor_id):
    if 'cloud_loggedin' not in session or not session['cloud_loggedin']:
        flash('Please log in to access this feature.', 'danger')
        return redirect(url_for('cloud.cloud_login'))

    cursor = db.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("SELECT * FROM doctors WHERE doctor_id = %s", (doctor_id,))
    doctor = cursor.fetchone()
    
    if not doctor:
        flash('Doctor not found.', 'danger')
        cursor.close()
        return redirect(url_for('cloud.doctors'))

    cursor.execute("""
        SELECT dp.*, p.name as patient_name 
        FROM doctor_patient dp 
        JOIN patients p ON dp.patient_id = p.patient_id 
        WHERE dp.doctor_id = %s
    """, (doctor_id,))
    patient_assignments = cursor.fetchall()
    cursor.execute("""
        SELECT a.*, p.name as patient_name 
        FROM appointments a 
        JOIN patients p ON a.patient_id = p.patient_id 
        WHERE a.doctor_id = %s
    """, (doctor_id,))
    appointments = cursor.fetchall()
    cursor.execute("SELECT * FROM doctor_requests WHERE doctor_id = %s", (doctor_id,))
    requests = cursor.fetchall()

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_content = f"Doctor Backup - {doctor_id} - {timestamp}\n\n"
    backup_content += "Basic Information:\n" + json.dumps(doctor, default=str, indent=2) + "\n\n"
    backup_content += "Patient Assignments:\n" + json.dumps(patient_assignments, default=str, indent=2) + "\n\n"
    backup_content += "Appointments:\n" + json.dumps(appointments, default=str, indent=2) + "\n\n"
    backup_content += "Doctor Requests:\n" + json.dumps(requests, default=str, indent=2) + "\n"

    iv, encrypted_content = encrypt_backup(backup_content)
    backup_dir = os.path.join(os.getcwd(), 'backups', 'doctors')
    os.makedirs(backup_dir, exist_ok=True)
    filename = f"{doctor_id}backup{timestamp}.enc"
    filepath = os.path.join(backup_dir, filename)
    
    enc_file_content = f"IV:{iv}\nCT:{encrypted_content}"
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(enc_file_content)
    
    # Upload to MongoDB
    try:
        backup_collection = mongo_db['backup']  # Collection name: backup
        backup_doc = {
            'filename': filename,
            'type': 'doctor',
            'doctor_id': doctor_id,
            'timestamp': timestamp,
            'content': enc_file_content,
            'created_at': datetime.utcnow()
        }
        backup_collection.insert_one(backup_doc)
        logger.debug(f"Backup for doctor {doctor_id} uploaded to MongoDB")
    except Exception as e:
        logger.error(f"Failed to upload backup to MongoDB: {str(e)}")
        flash(f"Backup created locally but failed to upload to database: {str(e)}", 'danger')

    cursor.close()
    flash(f'Encrypted backup created successfully: {filename}', 'success')
    return redirect(url_for('cloud.doctors'))

@cloud_bp.route('/decrypt_backup', methods=['GET', 'POST'])
def decrypt_backup():
    if 'cloud_loggedin' not in session or not session['cloud_loggedin']:
        flash('Please log in to access this feature.', 'danger')
        return redirect(url_for('cloud.cloud_login'))

    decrypted_content = None
    filename = None
    
    if request.method == 'POST':
        if 'backup_file' not in request.files:
            flash('No file uploaded.', 'danger')
            return redirect(url_for('cloud.decrypt_backup'))
        
        file = request.files['backup_file']
        if file.filename == '':
            flash('No file selected.', 'danger')
            return redirect(url_for('cloud.decrypt_backup'))
        
        if file and file.filename.endswith('.enc'):
            try:
                content = file.read().decode('utf-8')
                logger.debug(f"File content: {content[:100]}...")
                iv_line, ct_line = content.split('\n', 1)
                iv = iv_line.replace('IV:', '')
                ct = ct_line.replace('CT:', '')
                logger.debug(f"Calling decrypt_backup_new with IV: {iv[:10]}... and CT: {ct[:10]}...")
                decrypted_content = decrypt_backup_new(iv, ct)
                filename = file.filename.rsplit('.', 1)[0] + '_decrypted.txt'
                flash('File decrypted successfully.', 'success')
            except Exception as e:
                flash(str(e), 'danger')
                logger.error(f"Route error: {str(e)}")
                decrypted_content = None

    return render_template('decrypt_backup.html', decrypted_content=decrypted_content, filename=filename)

@cloud_bp.route('/download_decrypted', methods=['POST'])
def download_decrypted():
    if 'cloud_loggedin' not in session or not session['cloud_loggedin']:
        flash('Please log in to access this feature.', 'danger')
        return redirect(url_for('cloud.cloud_login'))

    content = request.form.get('content')
    filename = request.form.get('filename')
    
    if not content or not filename:
        flash('No content to download.', 'danger')
        return redirect(url_for('cloud.decrypt_backup'))

    response = make_response(content)
    response.headers['Content-Disposition'] = f'attachment; filename={filename}'
    response.headers['Content-Type'] = 'text/plain'
    return response