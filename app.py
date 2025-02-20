from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_mysqldb import MySQL
from werkzeug.security import generate_password_hash, check_password_hash
from utils.encryption import AESEncryption, RSAEncryption, DSASignature
from config import DB_CONFIG, AES_SECRET_KEY
import MySQLdb.cursors
import base64

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
        
        # Hash password
        hashed_password = generate_password_hash(password)

        cursor.execute("INSERT INTO patients (name, phone, email, dob, password, address) VALUES (%s, %s, %s, %s, %s, %s)",
                       (name, phone, email, dob, hashed_password, address))
        mysql.connection.commit()
        flash('Registration successful. Await activation.', 'success')
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
        cursor.execute('SELECT * FROM patients WHERE id = %s', (session['id'],))
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

        # Combine data into a single string
        data = f"{blood_group}|{blood_pressure}|{body_temp}|{pulse_rate}|{medications}"

        # Encrypt the combined data
        encrypted_data = aes.encrypt(data)  # Assuming aes.encrypt returns encrypted string

        # Store encrypted data in the database
        cursor = mysql.connection.cursor()
        cursor.execute("INSERT INTO medical_records (patient_id, encrypted_data) VALUES (%s, %s)",
                       (session['id'], encrypted_data))
        mysql.connection.commit()

        flash('Medical data uploaded and encrypted successfully.', 'success')
        return redirect(url_for('dashboard'))

    return render_template('upload_data.html')

# ------------------- Decrypt Key ------------------- #
@app.route('/decrypt_key', methods=['GET', 'POST'])
def decrypt_key():
    encrypted_keys = []
    decrypted_data = {}

    # Fetch all encrypted keys from the database
    if 'loggedin' in session:
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute('SELECT patient_id, encrypted_data FROM medical_records WHERE patient_id = %s', (session['id'],))
        encrypted_keys = cursor.fetchall()

    if request.method == 'POST':
        encrypted_key = request.form['encrypted_key']

        try:
            # Decrypt the key
            decrypted_data = aes.decrypt(encrypted_key)
            blood_group, blood_pressure, body_temp, pulse_rate, medications = decrypted_data.split('|')

            # Pass decrypted data to the template
            decrypted_data = {
                'Blood Group': blood_group,
                'Blood Pressure': blood_pressure,
                'Body Temperature': body_temp,
                'Pulse Rate': pulse_rate,
                'Medications': medications
            }
        except Exception as e:
            flash(f"Decryption failed: {str(e)}", 'danger')
            return redirect(url_for('decrypt_key'))

    return render_template('decrypt_form.html', encrypted_keys=encrypted_keys, decrypted_data=decrypted_data)

# ------------------- Logout ------------------- #
@app.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out.', 'success')
    return redirect(url_for('login'))

# ------------------- Run App ------------------- #
if __name__ == "__main__":
    app.run(debug=True)