from flask import Blueprint, render_template, request, redirect, url_for, session, flash
from werkzeug.security import generate_password_hash, check_password_hash
from flask_mysqldb import MySQL
import MySQLdb.cursors
import random
import pyotp
from mail import send_otp_email
from datetime import datetime, timedelta
import secrets

auth_bp = Blueprint('auth', __name__)

mysql = MySQL()

# Utility Functions
def generate_patient_id():
    return f"PID{random.randint(100000, 999999)}"

def generate_reset_token():
    return secrets.token_urlsafe(32)

# Home Route
@auth_bp.route('/')
def home():
    return render_template('main.html')

# Registration Route
@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        if 'otp' in request.form:
            otp_input = request.form['otp']
            secret = session.get('otp_secret')
            
            if not secret:
                flash("Session expired. Please register again.", 'danger')
                return redirect(url_for('auth.register'))
                
            totp = pyotp.TOTP(secret, interval=600)
            if totp.verify(otp_input, valid_window=1):
                patient_data = session.pop('patient_data')
                cursor = mysql.connection.cursor()
                cursor.execute("""
                    INSERT INTO patients (patient_id, name, phone, email, dob, password, address, is_activated) 
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """, (patient_data['patient_id'], patient_data['name'], patient_data['phone'],
                      patient_data['email'], patient_data['dob'], patient_data['password'],
                      patient_data['address'], 0))  # Changed '0' to 0 for tinyint
                mysql.connection.commit()
                cursor.close()
                flash(f"Registration successful. Your Patient ID is {patient_data['patient_id']}. Await activation.", 'success')
                session.pop('otp_secret', None)
                return redirect(url_for('auth.login'))
            else:
                flash("Invalid OTP. Please try again.", 'danger')
                return render_template('verify_otp.html', email=session['patient_data']['email'])

        name = request.form['name']
        phone = request.form['phone']
        email = request.form['email']
        dob = request.form['dob']
        password = request.form['password']
        address = request.form['address']

        cursor = mysql.connection.cursor()
        cursor.execute("SELECT * FROM patients WHERE email = %s OR phone = %s", (email, phone))
        existing_user = cursor.fetchone()
        
        if existing_user:
            cursor.close()
            flash('User with this email or phone number already exists.', 'danger')
            return redirect(url_for('auth.register'))
        
        while True:
            patient_id = generate_patient_id()
            cursor.execute("SELECT * FROM patients WHERE patient_id = %s", (patient_id,))
            if not cursor.fetchone():
                break

        secret = pyotp.random_base32()
        totp = pyotp.TOTP(secret, interval=600)
        otp = totp.now()
        
        if send_otp_email(email, otp):
            hashed_password = generate_password_hash(password)
            session['patient_data'] = {
                'patient_id': patient_id,
                'name': name,
                'phone': phone,
                'email': email,
                'dob': dob,
                'password': hashed_password,
                'address': address
            }
            session['otp_secret'] = secret
            
            cursor.close()
            flash('OTP has been sent to your email.', 'info')
            return render_template('verify_otp.html', email=email)
        else:
            cursor.close()
            flash('Failed to send OTP. Please try again.', 'danger')
            return redirect(url_for('auth.register'))
    
    return render_template('register.html')

# Login Route
@auth_bp.route('/login', methods=['GET', 'POST'])
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
                session['patient_id'] = account['patient_id']
                session['name'] = account['name']
                session['role'] = 'patient'
                flash('Login successful!', 'success')
                return redirect(url_for('patient.dashboard'))
            else:
                flash('Account not activated by cloud server.', 'warning')
        else:
            flash('Incorrect email/password.', 'danger')
        cursor.close()
    return render_template('login.html')

# Forgot Password Route
@auth_bp.route('/forgot-password', methods=['GET', 'POST'])
def forgot_password():
    if request.method == 'POST':
        email = request.form['email']
        
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        cursor.execute('SELECT * FROM patients WHERE email = %s', (email,))
        account = cursor.fetchone()
        
        if account:
            reset_token = generate_reset_token()
            expiry = datetime.now() + timedelta(hours=1)
            
            cursor.execute("""
                UPDATE patients 
                SET reset_token = %s, token_expiry = %s 
                WHERE email = %s
            """, (reset_token, expiry, email))
            mysql.connection.commit()
            
            reset_link = url_for('auth.reset_password', token=reset_token, _external=True)
            email_body = f"To reset your password, click this link: {reset_link}\nValid for 1 hour."
            
            if send_otp_email(email, email_body):  # Using your existing mail function
                flash('Password reset link sent to your email.', 'success')
            else:
                flash('Failed to send reset email. Please try again.', 'danger')
        else:
            flash('Email not found in our records.', 'danger')
        cursor.close()
        return redirect(url_for('auth.forgot_password'))
        
    return render_template('forgot_password.html')

# Reset Password Route
@auth_bp.route('/reset-password/<token>', methods=['GET', 'POST'])
def reset_password(token):
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    cursor.execute("""
        SELECT * FROM patients 
        WHERE reset_token = %s AND token_expiry > %s
    """, (token, datetime.now()))
    account = cursor.fetchone()
    
    if not account:
        flash('Invalid or expired reset link.', 'danger')
        cursor.close()
        return redirect(url_for('auth.login'))

    if request.method == 'POST':
        password = request.form['password']
        confirm_password = request.form['confirm_password']
        
        if password != confirm_password:
            flash('Passwords do not match.', 'danger')
            return render_template('reset_password.html', token=token)
            
        hashed_password = generate_password_hash(password)
        cursor.execute("""
            UPDATE patients 
            SET password = %s, reset_token = NULL, token_expiry = NULL 
            WHERE reset_token = %s
        """, (hashed_password, token))
        mysql.connection.commit()
        cursor.close()
        flash('Password reset successfully.', 'success')
        return redirect(url_for('auth.login'))
    
    cursor.close()
    return render_template('reset_password.html', token=token)

# Logout Route
@auth_bp.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out.', 'success')
    return redirect(url_for('auth.home'))