from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_mysqldb import MySQL
from werkzeug.security import generate_password_hash, check_password_hash
from utils.encryption import AESEncryption, RSAEncryption, DSASignature
from config import DB_CONFIG, AES_SECRET_KEY
import MySQLdb.cursors
import base64
import random

app = Flask(__name__)
app.secret_key = '5e8e565836ec4ab43a22afe1d316f35f87bf7eeab2d0b80d862d31d6321b976e'

# ---------------- MySQL Configuration ---------------- #
app.config['MYSQL_HOST'] = DB_CONFIG['host']
app.config['MYSQL_USER'] = DB_CONFIG['user']
app.config['MYSQL_PASSWORD'] = DB_CONFIG['password']
app.config['MYSQL_DB'] = DB_CONFIG['database']

mysql = MySQL(app)

# ---------------- Initialize Encryption ---------------- #
aes = AESEncryption(AES_SECRET_KEY)
rsa = RSAEncryption()
dsa = DSASignature()

# ------------------- ROUTES ------------------- #

# Home Route
@app.route('/')
def home():
    return render_template('login.html')

# ------------------- Registration ------------------- #

def generate_patient_id():
    return f"PID{random.randint(100000, 999999)}"

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        name = request.form['name']
        phone = request.form['phone']
        email = request.form['email']
        dob = request.form['dob']
        password = request.form['password']
        address = request.form['address']

        # Check if user already exists
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT * FROM patients WHERE email = %s OR phone = %s", (email, phone))
        existing_user = cursor.fetchone()
        
        if existing_user:
            flash('User with this email or phone number already exists. Please try again with a different one.', 'danger')
            return redirect(url_for('register'))
        
        # Generate unique patient ID
        while True:
            patient_id = generate_patient_id()
            cursor.execute("SELECT * FROM patients WHERE patient_id = %s", (patient_id,))
            if not cursor.fetchone():
                break  # Unique ID found

        # Hash password
        hashed_password = generate_password_hash(password)

        # Insert new user with generated patient ID
        cursor.execute("INSERT INTO patients (patient_id, name, phone, email, dob, password, address) VALUES (%s, %s, %s, %s, %s, %s, %s)",
                       (patient_id, name, phone, email, dob, hashed_password, address))
        mysql.connection.commit()
        flash(f'Registration successful. Your Patient ID is {patient_id}. Await activation.', 'success')
        return redirect(url_for('login'))
    return render_template('register.html')

# ------------------- Login ------------------- #
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']

        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute('SELECT * FROM patients WHERE email = %s', (email,))
        account = cursor.fetchone()

        if account and check_password_hash(account['password'], password):
            if account['is_activated']:
                session['loggedin'] = True
                session['id'] = account['id']
                session['patient_id'] = account['patient_id']  # ✅ Store patient_id in session
                session['name'] = account['name']
                flash('Login successful!', 'success')
                return redirect(url_for('dashboard'))
            else:
                flash('Account not activated by cloud server.', 'warning')
        else:
            flash('Incorrect email/password.', 'danger')
    return render_template('login.html')

@app.route('/dashboard')
def dashboard():
    if 'loggedin' in session:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        # Using patient_id instead of id
        cursor.execute('SELECT * FROM patients WHERE patient_id = %s', (session['patient_id'],))
        patient = cursor.fetchone()
        return render_template('dashboard.html', patient=patient)
    return redirect(url_for('login'))


# ------------------- Upload Medical Data ------------------- #
@app.route('/upload', methods=['GET', 'POST'])
def upload():
    if 'loggedin' not in session:
        flash('Please login to upload medical data.', 'warning')
        return redirect(url_for('login'))

    if request.method == 'POST':
        blood_group = request.form['blood_group']
        blood_pressure = request.form['blood_pressure']
        body_temp = request.form['body_temp']
        pulse_rate = request.form['pulse_rate']
        medications = request.form['medications']

        # Verify patient exists in the patients table
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute("SELECT * FROM patients WHERE id = %s", (session['id'],))
        patient = cursor.fetchone()

        if not patient:
            flash('Patient not found. Please check your account.', 'danger')
            return redirect(url_for('upload'))

        # Combine medical data into a single string
        data = f"{blood_group}|{blood_pressure}|{body_temp}|{pulse_rate}|{medications}"

        # Encrypt the combined data
        encrypted_data = aes.encrypt(data)  # Assuming aes.encrypt returns encrypted string

        # Insert encrypted data into medical_records with the verified patient_id
        cursor.execute("""
            INSERT INTO medical_records (patient_id, encrypted_data)
            VALUES (%s, %s)
        """, (patient['patient_id'], encrypted_data))
        mysql.connection.commit()
        cursor.close()

        flash('Medical data uploaded and encrypted successfully.', 'success')
        return redirect(url_for('dashboard'))

    return render_template('upload_data.html')


# ------------------- Decrypt Key ------------------- #
import base64

@app.route('/decrypt_key', methods=['GET', 'POST'])
def decrypt_key():
    encrypted_keys = []
    decrypted_data = {}

    # Fetch all medical records for the logged-in user
    if 'loggedin' in session:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute('''
            SELECT patient_id, blood_group, blood_pressure, body_temp, pulse_rate, previous_medications, updated_time, encrypted_data
            FROM medical_records
            WHERE patient_id = %s
        ''', (session['patient_id'],))
        records = cursor.fetchall()
        cursor.close()

        # Encode encrypted_data in Base64
        for record in records:
            if record['encrypted_data']:
                # Ensure the data is in bytes before encoding
                if isinstance(record['encrypted_data'], str):
                    record_bytes = record['encrypted_data'].encode('utf-8')
                else:
                    record_bytes = record['encrypted_data']

                record['encrypted_data'] = base64.b64encode(record_bytes).decode('utf-8')
            encrypted_keys.append(record)

        # Debugging: Print fetched and encoded records
        print("Fetched and Encoded Encrypted Records:", encrypted_keys)

    if request.method == 'POST':
        encrypted_key = request.form.get('encrypted_key', None)

        # Check if the entered encrypted key belongs to the logged-in user
        user_keys = [record['encrypted_data'] for record in encrypted_keys]
        if encrypted_key not in user_keys:
            flash("Unauthorized decryption attempt. You can only decrypt your own records.", 'danger')
            return redirect(url_for('decrypt_key'))

        try:
            # Decrypt the key
            decrypted_text = aes.decrypt(base64.b64decode(encrypted_key))
            decrypted_values = decrypted_text.split('|')

            if len(decrypted_values) == 5:
                blood_group, blood_pressure, body_temp, pulse_rate, medications = decrypted_values
                decrypted_data = {
                    'Blood Group': blood_group,
                    'Blood Pressure': blood_pressure,
                    'Body Temperature': body_temp,
                    'Pulse Rate': pulse_rate,
                    'Previous Medications': medications
                }
            else:
                flash("Decryption failed: Invalid data format", 'danger')
                return redirect(url_for('decrypt_key'))

        except Exception as e:
            flash(f"Decryption failed: {str(e)}", 'danger')
            return redirect(url_for('decrypt_key'))

    return render_template('decrypt_form.html', encrypted_keys=encrypted_keys, decrypted_data=decrypted_data)

# ------------------- Manage Patients (CRUD) ------------------- #
@app.route('/manage_patients', methods=['GET', 'POST'])
def manage_patients():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

    if request.method == 'POST':
        action = request.form['action']

        # ----------------- Create Patient ----------------- #
        if action == 'create':
            patient_id = request.form['patient_id']
            name = request.form['name']
            email = request.form['email']
            phone = request.form['phone']
            address = request.form['address']

            cursor.execute("""
                INSERT INTO patients (patient_id, name, email, phone, address, is_activated) 
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (patient_id, name, email, phone, address, '1'))  # Default to activated
            mysql.connection.commit()
            flash(f"Patient {name} added successfully.", 'success')

        # ----------------- Update Patient ----------------- #
        elif action == 'update':
            patient_id = request.form['patient_id']
            name = request.form['name']
            email = request.form['email']
            phone = request.form['phone']
            address = request.form['address']

            cursor.execute("""
                UPDATE patients 
                SET name = %s, email = %s, phone = %s, address = %s 
                WHERE patient_id = %s
            """, (name, email, phone, address, patient_id))
            mysql.connection.commit()
            flash(f"Patient {patient_id} updated successfully.", 'success')

        # ----------------- Delete Patient ----------------- #
        elif action == 'delete':
            patient_id = request.form['patient_id']
            cursor.execute("DELETE FROM patients WHERE patient_id = %s", (patient_id,))
            mysql.connection.commit()
            flash(f"Patient {patient_id} deleted successfully.", 'danger')

        # ----------------- Activate/Deactivate Patient ----------------- #
        elif action in ['activate', 'deactivate']:
            patient_id = request.form['patient_id']
            activation_status = '1' if action == 'activate' else '0'

            cursor.execute("""
                UPDATE patients 
                SET is_activated = %s 
                WHERE patient_id = %s
            """, (activation_status, patient_id))
            mysql.connection.commit()
            flash(f"Patient {patient_id} has been {'activated' if activation_status == '1' else 'deactivated'}.", 'info')

        return redirect(url_for('manage_patients'))

    # ----------------- Read: Fetch All Patients ----------------- #
    cursor.execute("SELECT id, patient_id, name, email, phone, address, is_activated FROM patients")
    patients = cursor.fetchall()
    cursor.close()

    return render_template('cloudserver.html', patients=patients)

# ------------------- Logout ------------------- #
@app.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out.', 'success')
    return redirect(url_for('login'))

# ------------------- Run App ------------------- #
if __name__ == "__main__":
    app.run(debug=True)