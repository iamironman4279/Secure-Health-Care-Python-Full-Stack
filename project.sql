-- MySQL dump 10.13  Distrib 8.0.36, for Linux (x86_64)
--
-- Host: localhost    Database: secure_patient_db
-- ------------------------------------------------------
-- Server version	8.0.41-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointments` (
  `appointment_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(50) DEFAULT NULL,
  `doctor_id` varchar(50) DEFAULT NULL,
  `appointment_date` date DEFAULT NULL,
  `appointment_time` time DEFAULT NULL,
  `reason` text,
  `status` enum('Pending','Confirmed','Cancelled','Accepted','Rejected') DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `video_call_url` varchar(255) DEFAULT NULL,
  `transaction_id` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`appointment_id`),
  KEY `patient_id` (`patient_id`),
  KEY `appointments_ibfk_2` (`doctor_id`),
  CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`),
  CONSTRAINT `appointments_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` VALUES (24,'PID660834','DD039523','2025-03-26','16:53:00','fever','Confirmed','2025-03-26 11:20:37','864e1e9690b2413bb358cb1235a28a67','f25c283021');
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctor_medicines`
--

DROP TABLE IF EXISTS `doctor_medicines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor_medicines` (
  `id` int NOT NULL AUTO_INCREMENT,
  `doctor_id` int NOT NULL,
  `patient_id` int NOT NULL,
  `medicine_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `doctor_id` (`doctor_id`),
  KEY `patient_id` (`patient_id`),
  KEY `medicine_id` (`medicine_id`),
  CONSTRAINT `doctor_medicines_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE CASCADE,
  CONSTRAINT `doctor_medicines_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `doctor_medicines_ibfk_3` FOREIGN KEY (`medicine_id`) REFERENCES `medicines` (`medicine_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor_medicines`
--

LOCK TABLES `doctor_medicines` WRITE;
/*!40000 ALTER TABLE `doctor_medicines` DISABLE KEYS */;
/*!40000 ALTER TABLE `doctor_medicines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctor_patient`
--

DROP TABLE IF EXISTS `doctor_patient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor_patient` (
  `doctor_id` varchar(50) NOT NULL,
  `patient_id` varchar(50) NOT NULL,
  `status` varchar(20) DEFAULT 'active',
  `signature` text,
  PRIMARY KEY (`doctor_id`,`patient_id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `doctor_patient_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`),
  CONSTRAINT `doctor_patient_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor_patient`
--

LOCK TABLES `doctor_patient` WRITE;
/*!40000 ALTER TABLE `doctor_patient` DISABLE KEYS */;
/*!40000 ALTER TABLE `doctor_patient` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctor_requests`
--

DROP TABLE IF EXISTS `doctor_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `doctor_id` varchar(50) DEFAULT NULL,
  `patient_id` varchar(50) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'pending',
  `decryption_key` text,
  `request_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `doctor_id` (`doctor_id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `doctor_requests_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`),
  CONSTRAINT `doctor_requests_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor_requests`
--

LOCK TABLES `doctor_requests` WRITE;
/*!40000 ALTER TABLE `doctor_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `doctor_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctors`
--

DROP TABLE IF EXISTS `doctors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `doctor_id` varchar(10) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `specialization` varchar(100) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_activated` tinyint(1) DEFAULT '0',
  `private_key` text NOT NULL,
  `public_key` text NOT NULL,
  PRIMARY KEY (`doctor_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctors`
--

LOCK TABLES `doctors` WRITE;
/*!40000 ALTER TABLE `doctors` DISABLE KEYS */;
INSERT INTO `doctors` VALUES (28,'DD039523','guduru Hemanth kumar reddy','hemanth42079@gmail.com','9441861353','Cardiologist','1234',1,1,'-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDjRu+SVwd7O1ZB\n4T2fim83tVZ/rEjLb+lP24y2oXO+Q4TYg3amv2L+7rV7qf29Kgp7Rd3yGbvuqUTy\ng+ZU6LW0TpdNp7EGUpBL+bdmdqrow14L8xX2GexYzbVKl3MOQ6gkb4VF/hNKvUuK\nIISXInlnVPSGHUIp8SzeAlegaSlOzf82JxYPNGhCkNWGjysMQxYNZCcqfpLkMFCL\nDIIYLnXD1IfzdBRYRDA2qKNkvONldjhHPtNUGqmT6JGl2G6zE6y12yW8SYD5uhmU\n8CERWuQijjWhD9pQYol380DbuMEqKU5+xbznhTDmrTpnflbVHGpstD60uBrmX6Tr\n1lB0N28pAgMBAAECggEAEjUP/J1wocrg7Lz6bqCGRMrUyu+Zxh2i1EOJyn7oQp+U\n5RkX1UeGl71QPqYhbkxC5xmmxfFeOkItngjUPlmFZpQ+Ay0u8L6GhTLUVXOmQQ79\npsY3ksdq3rmQ3EPojLj9n5JrjwewTFyz0E7G/UPFJz9wEDQIPxhTq6MGZnkzCcP7\n2JIV+/BbbkziKaxvi4yx17AZfQFqAp+A961UODwtrDIFcpMl6nyvBG6ZBmNioFwF\nJdNxp1h6bv+z7mejPfIil2PWXvtqnrjBPI8YTjYpGJPPgtn1uKP/THfc7HI4mfuv\na6h7WfI8Lyr0OYdI47xvnLuFvGAPNRXszG8LfD5mbQKBgQD9hfteg2OuyCT04e1t\ndTbxlOzqbbjuT9IJPPA86ik2hQlF7R1ctnGrpvInhGRpwvfDJrtVqyOkhIVjlC4I\nf9AssDEfOaN8QTeVXXtYmkTqw+pZsYRkGOfp2SHgCxJug45WcvI0qmv3VPiQdXov\nDX1E1B4ponNRR8uIsqAD1MvKzwKBgQDlf1EHxlSLPbqkM8WZCktz8Md1XLgxsHfP\nTD47VP1XuV9FlZ2PrSn4AAGoy3dPbkUKzvBASoefoqzUnkqGYfeX8A1j+377JbRN\ncZxahA2DjIcgGWgcsXiKH67MRuBB2Q7aFL6QnUEGtljW2+6uOs5oWZ7nkFBLuUNr\nAxEb7TfEhwKBgEOgm98oWUzkYsdYBQevvspOmawnPK+FZ1fDg6ocJIZAkqquh6iV\nmljZnbrg3BBCS+koycwebNGT8CkR+/2UaqmhDllv/KZGl1cmqqKF9GBTho4KhnBV\nHHgKzbh/+5izSyLQYr+dvlMpvWx7ie5HQOU9WBZvGSfTaP27+GdNOleNAoGAMdAl\ntWtOFH8MkPGP1T0PzZWYpZe/f0GPb9Zbt6Ml7jGVRVRJQ9NRRbwyoAGx3vLPV549\nNac3suWrX+cPxAVlqXv4XBhNopO3hAvB5T++cyxAdC4vk/LNeCWSWlKUAJbti1Zv\nWpJXd+6Cb/iC4RxwiuPRAvAnDZij0oly4D3oGecCgYBRXix1B6DckPgFbdcZmCRd\nzbvyYWLYtCSRwxlIHt7i+mmY0tfRlywmr+o6IftF1spQ6F4yv+l5JBRseXDKnHFy\n7MtEc8qi0MAfNnpmrLSAb4UQICzEIWDAWMwmqTWGRTm2fPgc3H84OuesDEjLJDRj\n1AHMLZ3mHRyK3MVkfKfCIA==\n-----END PRIVATE KEY-----\n','-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA40bvklcHeztWQeE9n4pv\nN7VWf6xIy2/pT9uMtqFzvkOE2IN2pr9i/u61e6n9vSoKe0Xd8hm77qlE8oPmVOi1\ntE6XTaexBlKQS/m3Znaq6MNeC/MV9hnsWM21SpdzDkOoJG+FRf4TSr1LiiCElyJ5\nZ1T0hh1CKfEs3gJXoGkpTs3/NicWDzRoQpDVho8rDEMWDWQnKn6S5DBQiwyCGC51\nw9SH83QUWEQwNqijZLzjZXY4Rz7TVBqpk+iRpdhusxOstdslvEmA+boZlPAhEVrk\nIo41oQ/aUGKJd/NA27jBKilOfsW854Uw5q06Z35W1RxqbLQ+tLga5l+k69ZQdDdv\nKQIDAQAB\n-----END PUBLIC KEY-----\n');
/*!40000 ALTER TABLE `doctors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `keys`
--

DROP TABLE IF EXISTS `keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `keys` (
  `id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int DEFAULT NULL,
  `aes_key` text,
  `rsa_public_key` text,
  `rsa_private_key` text,
  `dsa_signature` text,
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `keys_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `keys`
--

LOCK TABLES `keys` WRITE;
/*!40000 ALTER TABLE `keys` DISABLE KEYS */;
/*!40000 ALTER TABLE `keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medical_records`
--

DROP TABLE IF EXISTS `medical_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medical_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(20) DEFAULT NULL,
  `blood_group` varchar(5) DEFAULT NULL,
  `blood_pressure` varchar(10) DEFAULT NULL,
  `body_temp` varchar(10) DEFAULT NULL,
  `pulse_rate` varchar(10) DEFAULT NULL,
  `previous_medications` text,
  `updated_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `encrypted_data` text,
  `used` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medical_records`
--

LOCK TABLES `medical_records` WRITE;
/*!40000 ALTER TABLE `medical_records` DISABLE KEYS */;
INSERT INTO `medical_records` VALUES (49,'PID660834',NULL,NULL,NULL,NULL,NULL,'2025-03-25 15:03:22','ztA/A2nYFjHcQzR/BhQJzta41De1SVF45/Btdwoh95E=',0);
/*!40000 ALTER TABLE `medical_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medicines`
--

DROP TABLE IF EXISTS `medicines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medicines` (
  `medicine_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `brand` varchar(100) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `expiry_date` date DEFAULT NULL,
  `description` text,
  PRIMARY KEY (`medicine_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medicines`
--

LOCK TABLES `medicines` WRITE;
/*!40000 ALTER TABLE `medicines` DISABLE KEYS */;
INSERT INTO `medicines` VALUES (1,'Paracetamol','Cipla','Painkiller',50.00,'2026-12-31','Used for fever and pain relief'),(2,'Ibuprofen','Sun Pharma','Painkiller',80.00,'2025-08-15','Anti-inflammatory medicine'),(3,'Amoxicillin','GSK','Antibiotic',120.00,'2027-06-20','Used to treat bacterial infections'),(4,'Cetirizine','Ranbaxy','Antihistamine',30.00,'2025-03-10','Used for allergies'),(5,'Metformin','Dr. Reddy\'s','Diabetes',150.00,'2027-09-01','Used for type 2 diabetes management'),(6,'Dolo 650','dolo',NULL,12.00,NULL,NULL),(7,'Dolo','dolo',NULL,12.00,NULL,NULL);
/*!40000 ALTER TABLE `medicines` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int NOT NULL,
  `doctor_id` int NOT NULL,
  `order_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `total_price` decimal(10,2) DEFAULT NULL,
  `status` enum('Pending','Completed','Cancelled') DEFAULT 'Pending',
  PRIMARY KEY (`order_id`),
  KEY `patient_id` (`patient_id`),
  KEY `doctor_id` (`doctor_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patients`
--

DROP TABLE IF EXISTS `patients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `dob` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `address` text,
  `is_activated` tinyint(1) DEFAULT '0',
  `patient_id` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `patient_id` (`patient_id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patients`
--

LOCK TABLES `patients` WRITE;
/*!40000 ALTER TABLE `patients` DISABLE KEYS */;
INSERT INTO `patients` VALUES (29,'Guduru Hemanth kumar reddy','9441861353','hemanth42079@gmail.com','2003-02-15','scrypt:32768:8:1$n6ahX7FPGI3gbYmD$db0f1efded8aeec738c63d8854256ba6f5bb71fdbe19adece083cd1a1e862a79a6774ff73c1544dae15f32f20ebb8ee20e7f8121e7943eeaea754ba41c8e5db5','Mydukura',1,'PID660834');
/*!40000 ALTER TABLE `patients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacies`
--

DROP TABLE IF EXISTS `pharmacies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacies` (
  `pharmacy_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `license_number` varchar(50) NOT NULL,
  `address` text NOT NULL,
  `phone` varchar(15) NOT NULL,
  `email` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`pharmacy_id`),
  UNIQUE KEY `license_number` (`license_number`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacies`
--

LOCK TABLES `pharmacies` WRITE;
/*!40000 ALTER TABLE `pharmacies` DISABLE KEYS */;
INSERT INTO `pharmacies` VALUES (1,'guduru Hemanth kumar hemanth kumar reddy','n1234','Thotla palle\r\nB. Mattam','9441861353','hemanth42079@gmail.com',1,'2025-03-15 03:57:07','scrypt:32768:8:1$cHCfHltQQENgeunM$583909324acf62c93a56326a239e2bc8b8a368f0d33242eaa4d28f1813ef8c72388beaa512cbeaaccf75ce205c39dd797716ea80e5cbf17c54bd2a336658645d');
/*!40000 ALTER TABLE `pharmacies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacy_inventory`
--

DROP TABLE IF EXISTS `pharmacy_inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_inventory` (
  `inventory_id` int NOT NULL AUTO_INCREMENT,
  `pharmacy_id` int NOT NULL,
  `medicine_id` int NOT NULL,
  `stock_quantity` int NOT NULL DEFAULT '0',
  `last_updated` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`inventory_id`),
  UNIQUE KEY `pharmacy_medicine_unique` (`pharmacy_id`,`medicine_id`),
  KEY `medicine_id` (`medicine_id`),
  CONSTRAINT `pharmacy_inventory_ibfk_1` FOREIGN KEY (`pharmacy_id`) REFERENCES `pharmacies` (`pharmacy_id`) ON DELETE CASCADE,
  CONSTRAINT `pharmacy_inventory_ibfk_2` FOREIGN KEY (`medicine_id`) REFERENCES `medicines` (`medicine_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacy_inventory`
--

LOCK TABLES `pharmacy_inventory` WRITE;
/*!40000 ALTER TABLE `pharmacy_inventory` DISABLE KEYS */;
INSERT INTO `pharmacy_inventory` VALUES (1,1,3,0,'2025-03-25 16:05:03'),(3,1,4,3,'2025-03-15 04:30:09'),(7,1,1,10,'2025-03-16 04:20:53'),(8,1,2,0,'2025-03-25 15:56:20'),(9,1,5,4,'2025-03-15 13:21:07'),(12,1,6,0,'2025-03-25 16:29:53'),(13,1,7,1,'2025-03-26 11:22:17');
/*!40000 ALTER TABLE `pharmacy_inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pharmacy_orders`
--

DROP TABLE IF EXISTS `pharmacy_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_orders` (
  `pharmacy_order_id` int NOT NULL AUTO_INCREMENT,
  `prescription_id` int NOT NULL,
  `pharmacy_id` int NOT NULL,
  `patient_id` varchar(50) NOT NULL,
  `order_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `total_amount` decimal(10,2) NOT NULL,
  `status` enum('Pending','Verified','Delivered','Processing','Shipped') DEFAULT NULL,
  `delivery_address` text,
  PRIMARY KEY (`pharmacy_order_id`),
  KEY `prescription_id` (`prescription_id`),
  KEY `pharmacy_id` (`pharmacy_id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `pharmacy_orders_ibfk_1` FOREIGN KEY (`prescription_id`) REFERENCES `prescriptions` (`prescription_id`) ON DELETE CASCADE,
  CONSTRAINT `pharmacy_orders_ibfk_2` FOREIGN KEY (`pharmacy_id`) REFERENCES `pharmacies` (`pharmacy_id`) ON DELETE CASCADE,
  CONSTRAINT `pharmacy_orders_ibfk_3` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pharmacy_orders`
--

LOCK TABLES `pharmacy_orders` WRITE;
/*!40000 ALTER TABLE `pharmacy_orders` DISABLE KEYS */;
INSERT INTO `pharmacy_orders` VALUES (18,38,1,'PID660834','2025-03-26 11:22:17',12.00,'Verified','Default Address');
/*!40000 ALTER TABLE `pharmacy_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prescriptions`
--

DROP TABLE IF EXISTS `prescriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prescriptions` (
  `prescription_id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `doctor_id` varchar(50) NOT NULL,
  `patient_id` varchar(50) NOT NULL,
  `medicine_id` int NOT NULL,
  `dosage` varchar(50) NOT NULL,
  `duration` varchar(50) NOT NULL,
  `instructions` text,
  `signature` text NOT NULL,
  `prescribed_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('Pending','Filled','Cancelled','verified','delivered') DEFAULT 'Pending',
  PRIMARY KEY (`prescription_id`),
  KEY `appointment_id` (`appointment_id`),
  KEY `doctor_id` (`doctor_id`),
  KEY `patient_id` (`patient_id`),
  KEY `medicine_id` (`medicine_id`),
  CONSTRAINT `prescriptions_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`appointment_id`) ON DELETE CASCADE,
  CONSTRAINT `prescriptions_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `doctors` (`doctor_id`) ON DELETE CASCADE,
  CONSTRAINT `prescriptions_ibfk_3` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE,
  CONSTRAINT `prescriptions_ibfk_4` FOREIGN KEY (`medicine_id`) REFERENCES `medicines` (`medicine_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prescriptions`
--

LOCK TABLES `prescriptions` WRITE;
/*!40000 ALTER TABLE `prescriptions` DISABLE KEYS */;
INSERT INTO `prescriptions` VALUES (38,24,'DD039523','PID660834',7,'500','2','after meals','1u/e0vP+2EqrGe4DJUPeQS1/uzXD7KzG/8R1lYWzTHzCh99ytRaHc9Mpx/bVxba+eIDubzlI9byR0J2h9MqAWWfM4b8H16Qc4gkoaYgcvhtE4ruViPvBbTNBhhQ70RYLkZ1T+rOkkitdwcuoesHiJcxy9DPzC4T4qY5iHu0ou9+EgQ49HJC2kFeaVQydLjOsAwoEX8t9QuwNTRXggR0rnx5C99QSnMcDrB43G0Zt/8g9i0fbc8FkrL88I0QjCyY4iGBGY2Pkxa/tjW+lbKtsidzaAWw0uS8yyez3U2CzGwHJQr5pMOqGHYX430H7UQw3K9uJz/qkXQRS/TOnVCenlQ==','2025-03-26 11:21:43','verified');
/*!40000 ALTER TABLE `prescriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `upi_transactions`
--

DROP TABLE IF EXISTS `upi_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `upi_transactions` (
  `transaction_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `patient_id` int NOT NULL,
  `upi_id` varchar(50) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` enum('Pending','Success','Failed') DEFAULT 'Pending',
  `transaction_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transaction_id`),
  KEY `order_id` (`order_id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `upi_transactions_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `upi_transactions_ibfk_2` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `upi_transactions`
--

LOCK TABLES `upi_transactions` WRITE;
/*!40000 ALTER TABLE `upi_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `upi_transactions` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-04 21:46:08
