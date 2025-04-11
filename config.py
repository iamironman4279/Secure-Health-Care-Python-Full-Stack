DB_CONFIG = {
    'host': 'mysql.clmq8y0i6jx3.eu-north-1.rds.amazonaws.com',
    'user': 'admin',
    'password': 'Hemanth4279',
    'database': 'secure_patient_db'
}

# 🔑 AES Secret Key
AES_SECRET_KEY = bytes.fromhex('1c09e94c774261bad417ea8ac1d54226')

# 🔐 RSA Key Configurations
RSA_KEY_SIZE = 2048

# 📂 Paths to RSA Keys (Update if stored elsewhere)
RSA_PRIVATE_KEY_PATH = '/home/guduru-hemanth-kumar-reddy/private_key.pem'
RSA_PUBLIC_KEY_PATH = '/home/guduru-hemanth-kumar-reddy/public_key.pem'
