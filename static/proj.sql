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
INSERT INTO `doctor_patient` VALUES ('DD039523','PID472377','active','CwPqsfbPdBoy2DHV4QtJVw02gPuOEOxX6g4jwLGbJwUD3hNavalG3YI9sIZXtBx0CMiSwhrHwn3KsA7NZDMv4Ff8AwcTLqZQNTkKGWaMv5awjpSguxSKQgfTiJh0KINljnwB8Zh+zLlaOhIBcpongjl0me5BM/KshETruVDwNPrKhKoUDSjSCrX1cGTvXCD0IiBW6TjkPtiBfi7Zb0jGLi46TPVvopA2Q5j+qumZvryz+jgo5vueMNXQLWVBIdUKPorwsEj76DQui6cyBi3J6tJCU0xMIZUJuRhb9su1khpR98l0nZ2+YM/VpUU5j1ztjbf1bN0NvEgZM9W7U65/oA=='),('DD678538','PID472377','active',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctor_requests`
--

LOCK TABLES `doctor_requests` WRITE;
/*!40000 ALTER TABLE `doctor_requests` DISABLE KEYS */;
INSERT INTO `doctor_requests` VALUES (7,'DD039523','PID472377','accepted','RzFFcEsvVENmMCt2dnRYK0YvRFUzVmNwWEpCdVlJU3dCWXE4bjEzRWFDZjNUQlFOWi9BNkdZeUhIelRkL1ZRUi9Jcy9JeUczSzBaOHdsaFo3OXdHOGJ4WTVlREh0OXY4OHlOZnd0cm5SVGpmYUlSTjNwYXNuL1lSeUd1T0ZGWWo4STV1bFVmQU9DS2Mxb2dSL1QwYlp3PT0=','2025-04-11 10:24:59');
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
  `reset_token` varchar(100) DEFAULT NULL,
  `token_expiry` datetime DEFAULT NULL,
  PRIMARY KEY (`doctor_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctors`
--

LOCK TABLES `doctors` WRITE;
/*!40000 ALTER TABLE `doctors` DISABLE KEYS */;
INSERT INTO `doctors` VALUES (28,'DD039523','guduru Hemanth kumar reddy','hemanth42079@gmail.com','9441861353','Cardiologist','1234567890',1,1,'-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDjRu+SVwd7O1ZB\n4T2fim83tVZ/rEjLb+lP24y2oXO+Q4TYg3amv2L+7rV7qf29Kgp7Rd3yGbvuqUTy\ng+ZU6LW0TpdNp7EGUpBL+bdmdqrow14L8xX2GexYzbVKl3MOQ6gkb4VF/hNKvUuK\nIISXInlnVPSGHUIp8SzeAlegaSlOzf82JxYPNGhCkNWGjysMQxYNZCcqfpLkMFCL\nDIIYLnXD1IfzdBRYRDA2qKNkvONldjhHPtNUGqmT6JGl2G6zE6y12yW8SYD5uhmU\n8CERWuQijjWhD9pQYol380DbuMEqKU5+xbznhTDmrTpnflbVHGpstD60uBrmX6Tr\n1lB0N28pAgMBAAECggEAEjUP/J1wocrg7Lz6bqCGRMrUyu+Zxh2i1EOJyn7oQp+U\n5RkX1UeGl71QPqYhbkxC5xmmxfFeOkItngjUPlmFZpQ+Ay0u8L6GhTLUVXOmQQ79\npsY3ksdq3rmQ3EPojLj9n5JrjwewTFyz0E7G/UPFJz9wEDQIPxhTq6MGZnkzCcP7\n2JIV+/BbbkziKaxvi4yx17AZfQFqAp+A961UODwtrDIFcpMl6nyvBG6ZBmNioFwF\nJdNxp1h6bv+z7mejPfIil2PWXvtqnrjBPI8YTjYpGJPPgtn1uKP/THfc7HI4mfuv\na6h7WfI8Lyr0OYdI47xvnLuFvGAPNRXszG8LfD5mbQKBgQD9hfteg2OuyCT04e1t\ndTbxlOzqbbjuT9IJPPA86ik2hQlF7R1ctnGrpvInhGRpwvfDJrtVqyOkhIVjlC4I\nf9AssDEfOaN8QTeVXXtYmkTqw+pZsYRkGOfp2SHgCxJug45WcvI0qmv3VPiQdXov\nDX1E1B4ponNRR8uIsqAD1MvKzwKBgQDlf1EHxlSLPbqkM8WZCktz8Md1XLgxsHfP\nTD47VP1XuV9FlZ2PrSn4AAGoy3dPbkUKzvBASoefoqzUnkqGYfeX8A1j+377JbRN\ncZxahA2DjIcgGWgcsXiKH67MRuBB2Q7aFL6QnUEGtljW2+6uOs5oWZ7nkFBLuUNr\nAxEb7TfEhwKBgEOgm98oWUzkYsdYBQevvspOmawnPK+FZ1fDg6ocJIZAkqquh6iV\nmljZnbrg3BBCS+koycwebNGT8CkR+/2UaqmhDllv/KZGl1cmqqKF9GBTho4KhnBV\nHHgKzbh/+5izSyLQYr+dvlMpvWx7ie5HQOU9WBZvGSfTaP27+GdNOleNAoGAMdAl\ntWtOFH8MkPGP1T0PzZWYpZe/f0GPb9Zbt6Ml7jGVRVRJQ9NRRbwyoAGx3vLPV549\nNac3suWrX+cPxAVlqXv4XBhNopO3hAvB5T++cyxAdC4vk/LNeCWSWlKUAJbti1Zv\nWpJXd+6Cb/iC4RxwiuPRAvAnDZij0oly4D3oGecCgYBRXix1B6DckPgFbdcZmCRd\nzbvyYWLYtCSRwxlIHt7i+mmY0tfRlywmr+o6IftF1spQ6F4yv+l5JBRseXDKnHFy\n7MtEc8qi0MAfNnpmrLSAb4UQICzEIWDAWMwmqTWGRTm2fPgc3H84OuesDEjLJDRj\n1AHMLZ3mHRyK3MVkfKfCIA==\n-----END PRIVATE KEY-----\n','-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA40bvklcHeztWQeE9n4pv\nN7VWf6xIy2/pT9uMtqFzvkOE2IN2pr9i/u61e6n9vSoKe0Xd8hm77qlE8oPmVOi1\ntE6XTaexBlKQS/m3Znaq6MNeC/MV9hnsWM21SpdzDkOoJG+FRf4TSr1LiiCElyJ5\nZ1T0hh1CKfEs3gJXoGkpTs3/NicWDzRoQpDVho8rDEMWDWQnKn6S5DBQiwyCGC51\nw9SH83QUWEQwNqijZLzjZXY4Rz7TVBqpk+iRpdhusxOstdslvEmA+boZlPAhEVrk\nIo41oQ/aUGKJd/NA27jBKilOfsW854Uw5q06Z35W1RxqbLQ+tLga5l+k69ZQdDdv\nKQIDAQAB\n-----END PUBLIC KEY-----\n','OtsCy0SBCL0Yt2jDbPgMFWIEkYjgzp0EYZaQnKmChKw','2025-04-11 00:04:31'),(29,'DD678538','hemanth','hemanthrdj@gmail.com','8125507026','Cardiologist','1234',1,1,'-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDQONPRn7FhqG3v\n25tyqiMTVbSNFb4g2cS8rZ3Bv0KrT7A+ldCGzMGfEDrp2gw+aNNrPeFw5y1diS0h\nUOQ6NeOkRj+QFw9OXRZHKugU6yixuNIQUC3ED7pRFlYxAA+5JI5CwKEC4BwNA586\nfoDAcwWwXmvDj8ZZ14szLVMbEMDd7R+cINP8pu4T/h8dUYTdPco1IhdQD/egp0RP\n3VNGnpeBAHnOGO1z9ZosZf4JU91eb96okPiBJekp5jNdW7vTWz173mjc2OpyAqzq\nJEuyVGXm9LUQ8xtiTfc3XAsSWKtghU0N5mWcHiq5FONYrxTHqqo0q0h1f6gGFhr9\nvCyBM0QxAgMBAAECggEAF3R0n9CuSYLl3LakfGEf5wX+JZpaZWxCa200hRDyBfF0\nYp27n0OiAonwfkvP70PISknugtT3rj6iinXd5OoRxNJznIaMdIEAiRm934VceyXc\n5nYxrDvdT/8FIdXmRNkSUVX44nsI4zUSPaORsJwEUF6tIu/8zD1Ucnpbjy6ZmyXu\nWsDf49PyDVjtt3F4daF3YmNDBVNICM6010PsKMbldPrZU76EMfOUqSWvd4W0tImE\n7GtJxdttpiXjZchdGMDXBSg8bVPnOkgQgRKBiNM1uyqiUsIcHbZkLBFNoh4SdcxR\nbg82KBkHFOjfHK6ZqljpStgGfrkaRxQgdWifp94nJQKBgQD4KtXPgDVdbvs3TWRA\nWpAbVZt+vdWra/Vzsr3TtNz+OeNvCFlLZIoa4OcDQwqQwBsD0dzt8nDsV+3poq+i\n5NzvltYITX4g0ZsZQ9AuutLdHjZlRwRfXoUsIS6MyTrlKv5GnhhRrNsxNR0wNjk5\nLNVdSuUtEXSSqzFMuC9JKPAWVwKBgQDWyzz8TQ6QtCqBPypWfjIySElvHIK57AgG\nBJXfRx31qaIB9JR8JEHaAkHGnNFXozCopq3ogsJpzYM1tWjZvtBtnO33qhpBwRJ2\neEDnadif5qJbNQk1jbmV4x25uDim/g0jRnV4O+dfuTXmDnYldTkRdiYAVvAI+AyY\nxN8MUP+UtwKBgCYULIqSWZ3kkZeCwIc/Xi1TjXB9IHQVNKx0GLyLW/2GVGeNGGaB\nHs/RAqF1gAGF+J81bHj2Ym1hcJgQ5nJQO7Znpp/PhDL09p+B0EfbUs+q+x2/L+SS\nVEzZKpNfrTHMzwd26rRdmaSLSddD+rPTNUoDW/b2XrTCn+XtvRO0vGIxAoGAIWWs\nb9ZTY3CAA2Sc4qHwkBzpPhuCwAHRJY5k9ziJkf70L7WluL+ydYFQVN9hNW0sTazM\n8ZATRnwr4Jf6W5Dtu31hCtcqCftJMZ51CQZOJl6n8+KFMgx9RK7xmkTomh56UHfO\nIAnAagPUO5cYC670VqC2O+tImzxmSQKjY7jcZHUCgYEAyeipHBZSBBb97/nLd2pc\n1+8nBkEkQDbYJdRSEtmk+iwyqimdQvoiQ0tRbpKNb94TJd1bKiDBPa4qWVnGLO+/\nywQEtkB3LhvtjYUbvjapAvT6gLV+Ig/WDS7icTMPaXOILCNuHnl2UOqYnhtxD8Rd\nCxYJA2rXam74+mX+TLAey20=\n-----END PRIVATE KEY-----\n','-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0DjT0Z+xYaht79ubcqoj\nE1W0jRW+INnEvK2dwb9Cq0+wPpXQhszBnxA66doMPmjTaz3hcOctXYktIVDkOjXj\npEY/kBcPTl0WRyroFOsosbjSEFAtxA+6URZWMQAPuSSOQsChAuAcDQOfOn6AwHMF\nsF5rw4/GWdeLMy1TGxDA3e0fnCDT/KbuE/4fHVGE3T3KNSIXUA/3oKdET91TRp6X\ngQB5zhjtc/WaLGX+CVPdXm/eqJD4gSXpKeYzXVu701s9e95o3NjqcgKs6iRLslRl\n5vS1EPMbYk33N1wLElirYIVNDeZlnB4quRTjWK8Ux6qqNKtIdX+oBhYa/bwsgTNE\nMQIDAQAB\n-----END PUBLIC KEY-----\n',NULL,NULL);
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
  `blood_group_token` varchar(100) DEFAULT NULL,
  `blood_pressure_token` varchar(100) DEFAULT NULL,
  `body_temp_token` varchar(100) DEFAULT NULL,
  `pulse_rate_token` varchar(100) DEFAULT NULL,
  `updated_time_token` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `medical_records_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medical_records`
--

LOCK TABLES `medical_records` WRITE;
/*!40000 ALTER TABLE `medical_records` DISABLE KEYS */;
INSERT INTO `medical_records` VALUES (1,'PID472377',NULL,NULL,NULL,NULL,NULL,'2025-04-11 10:39:37','z7QkvKYlKk1zYnL1fd/Fa6fowbFNXn0DxSTvD1/Kp6NccIKfzEFF9xZOZOJBh6x1uzGiWOwrI+V41ywKzLKlqwkzjdKV35o9fVzHpCES0gqqS5z7Im5eJtFQEHY1cSZEbrvRrS124WIBzcMHzNaTf2BdsfAclind8CAwgzR9nPKxggg/SuLIibzHHW03xNlC1jxQ+s3U7Rz3EMSBIrpPPb1QodYfyHuFOF2t7dxSFkMJMpMUGyaFZQ==',0,NULL,NULL,NULL,NULL,NULL),(2,'PID472377',NULL,NULL,NULL,NULL,NULL,'2025-04-11 11:45:43','nP2rpNF8suCZoCWwrkGaA2mH2fjr7mC36up+Rs7Oz+k=',0,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `medical_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medical_records1`
--

DROP TABLE IF EXISTS `medical_records1`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medical_records1` (
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
  `blood_group_token` varchar(100) DEFAULT NULL,
  `blood_pressure_token` varchar(100) DEFAULT NULL,
  `body_temp_token` varchar(100) DEFAULT NULL,
  `pulse_rate_token` varchar(100) DEFAULT NULL,
  `updated_time_token` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medical_records1`
--

LOCK TABLES `medical_records1` WRITE;
/*!40000 ALTER TABLE `medical_records1` DISABLE KEYS */;
INSERT INTO `medical_records1` VALUES (49,'PID660834',NULL,NULL,NULL,NULL,NULL,'2025-03-25 15:03:22','ztA/A2nYFjHcQzR/BhQJzta41De1SVF45/Btdwoh95E=',0,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `medical_records1` ENABLE KEYS */;
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
  `reset_token` varchar(100) DEFAULT NULL,
  `token_expiry` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `patient_id` (`patient_id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patients`
--

LOCK TABLES `patients` WRITE;
/*!40000 ALTER TABLE `patients` DISABLE KEYS */;
INSERT INTO `patients` VALUES (29,'Guduru Hemanth kumar reddy','9441861353','hemanth42079@gmail.com','2003-02-15','scrypt:32768:8:1$pOBnwgiUqYI8t1ks$5541b8653eb2becaab6cf72d7b7f64e5be0b5dd19c3b46c525c9556b315652880becced4470b072dbaf6820c924bb632ddd848220d1fa7e7692c321193c418a8','Mydukura',1,'PID660834',NULL,NULL),(30,'rdj','8074674722','hemanthrdj@gmail.com','2002-05-05','scrypt:32768:8:1$ld26DpMShKu98w5a$812ea0bd3229a677585e312dc7f7d0661c849ff50dd3f1e64dd7f5da32a226fd1f49daa62e4bc1cdcad51bc4feaec6918774134e166518a52500625417c83683','Mydukur',1,'PID472377',NULL,NULL);
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
  `reset_token` varchar(100) DEFAULT NULL,
  `token_expiry` datetime DEFAULT NULL,
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
INSERT INTO `pharmacies` VALUES (1,'guduru Hemanth kumar hemanth kumar reddy','n1234','Thotla palle\r\nB. Mattam','9441861353','hemanth42079@gmail.com',1,'2025-03-15 03:57:07','scrypt:32768:8:1$LbqBOvqQ306LwDZT$bc305d9e17df85b974a5c616b331e4d0fd570ac1ee170aa9fa8c51585c8c5677568e9cda422471429582837104d7c3350429952b2304f148fb174e3289a7339f',NULL,NULL);
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

-- Dump completed on 2025-04-11 18:38:03
