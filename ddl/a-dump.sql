-- MySQL dump 10.13  Distrib 5.7.44, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: virtualyou
-- ------------------------------------------------------
-- Server version	5.5.5-10.5.23-MariaDB-1:10.5.23+maria~ubu2004

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `assets`
--

DROP TABLE IF EXISTS `assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `assets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `assetType` varchar(255) DEFAULT NULL,
  `accountNo` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `websiteUser` varchar(255) DEFAULT NULL,
  `websitePassword` varchar(255) DEFAULT NULL,
  `holdingCompany` varchar(255) DEFAULT NULL,
  `holdingCompanyAddress` varchar(255) DEFAULT NULL,
  `holdingCompanyPhone` varchar(255) DEFAULT NULL,
  `balance` varchar(255) DEFAULT NULL,
  `userKey` int(11) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assets`
--

LOCK TABLES `assets` WRITE;
/*!40000 ALTER TABLE `assets` DISABLE KEYS */;
INSERT INTO `assets` (`id`, `name`, `assetType`, `accountNo`, `website`, `websiteUser`, `websitePassword`, `holdingCompany`, `holdingCompanyAddress`, `holdingCompanyPhone`, `balance`, `userKey`, `createdAt`, `updatedAt`) VALUES (1,'Savings LFCU','Savings','AT-00-9999234','https://lfcu.com','popeye2','ssap123','Langley Federal Credit Union','45 Stagecoach Ln, Carson City, NV, 25289','800-429-2035','15000.00',10,'2023-11-23 02:31:05','2023-11-23 02:31:05'),(2,'Checking LFCU','Regular Checking','AT-00-9999235','https://lfcu.com','popeye2','ssap123','Langley Federal Credit Union','45 Stagecoach Ln, Carson City, NV, 25289','800-429-2035','3879.13',10,'2023-11-23 02:31:05','2023-11-23 02:31:05');
/*!40000 ALTER TABLE `assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `debts`
--

DROP TABLE IF EXISTS `debts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `debts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `debtType` varchar(255) DEFAULT NULL,
  `accountNo` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `websiteUser` varchar(255) DEFAULT NULL,
  `websitePassword` varchar(255) DEFAULT NULL,
  `holdingCompany` varchar(255) DEFAULT NULL,
  `holdingCompanyAddress` varchar(255) DEFAULT NULL,
  `holdingCompanyPhone` varchar(255) DEFAULT NULL,
  `balance` varchar(255) DEFAULT NULL,
  `frequency` varchar(255) DEFAULT NULL,
  `due` datetime DEFAULT NULL,
  `payment` varchar(255) DEFAULT NULL,
  `userKey` int(11) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `debts`
--

LOCK TABLES `debts` WRITE;
/*!40000 ALTER TABLE `debts` DISABLE KEYS */;
INSERT INTO `debts` (`id`, `name`, `debtType`, `accountNo`, `website`, `websiteUser`, `websitePassword`, `holdingCompany`, `holdingCompanyAddress`, `holdingCompanyPhone`, `balance`, `frequency`, `due`, `payment`, `userKey`, `createdAt`, `updatedAt`) VALUES (1,'Water Utility','Utility','123456','https://vawater.gov','guitarman77','pass123','Virginia Water Utility','23 North Pike, Petersburg, VA 12345','800-123-4567','0.00','Monthly','2023-11-15 05:00:00','65.75',10,'2023-11-23 02:31:05','2023-11-23 02:31:05'),(2,'Rocket Mortgage','Mortgage','823-100009','https://rocket.com','dlw12999','pass123','Rocket Mortgage LLC','399 West Toll Road, Sterling, VA 28444','800-940-2309','0.00','Monthly','2023-12-01 05:00:00','1478.02',10,'2023-11-23 02:31:05','2023-11-23 02:31:05'),(3,'Dominion Power','Utility','123783','https://vadominion.com','consumerHog62','pass123','VA Dominion Power Inc.','2344 Taylor Ln, Richmond, VA 23799','800-877-1938','0.00','Monthly','2023-11-15 05:00:00','178.24',10,'2023-11-23 02:31:05','2023-11-23 02:31:05');
/*!40000 ALTER TABLE `debts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `peeps`
--

DROP TABLE IF EXISTS `peeps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `peeps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `phone1` varchar(255) DEFAULT NULL,
  `phone2` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `userKey` int(11) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `peeps`
--

LOCK TABLES `peeps` WRITE;
/*!40000 ALTER TABLE `peeps` DISABLE KEYS */;
INSERT INTO `peeps` (`id`, `name`, `phone1`, `phone2`, `email`, `address`, `note`, `userKey`, `createdAt`, `updatedAt`) VALUES (1,'David Knoxville','919-888-3000','','me@dlwhitehurst.com','123 Anywhere Ln, Sampleville, ND, 23045','Insurance Agent',10,'2023-11-23 04:40:59','2023-11-23 04:40:59'),(2,'Nancy Reynolds','800-825-9274','','nrey@acme.com','','Nurse',13,'2023-11-23 04:40:59','2023-11-23 04:40:59'),(3,'Patty Brown','722-310-1288','','pbrown@schwartz.com','4922 Clamstrip St, Middlebury, CT, 29300','Good friend',10,'2023-11-23 04:40:59','2023-11-23 04:40:59'),(4,'Robert Sandberg','877-655-2309','','rsandberg@gmail.com','','Jeweler',13,'2023-11-23 04:40:59','2023-11-23 04:40:59'),(5,'Peggy Smith','892-123-7702','','psmith@yahoo.com','3456 Jaybird Ct, Gloucester Pt. VA, 23062','Mother in Law',13,'2023-11-23 04:40:59','2023-11-23 04:40:59');
/*!40000 ALTER TABLE `peeps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prescriptions`
--

DROP TABLE IF EXISTS `prescriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prescriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `identNo` varchar(255) DEFAULT NULL,
  `size` varchar(255) DEFAULT NULL,
  `form` varchar(255) DEFAULT NULL,
  `rxUnit` varchar(255) DEFAULT NULL,
  `quantity` varchar(255) DEFAULT NULL,
  `pharmacy` varchar(255) DEFAULT NULL,
  `pharmacyPhone` varchar(255) DEFAULT NULL,
  `written` varchar(255) DEFAULT NULL,
  `writtenBy` varchar(255) DEFAULT NULL,
  `filled` varchar(255) DEFAULT NULL,
  `expired` varchar(255) DEFAULT NULL,
  `refillNote` varchar(255) DEFAULT NULL,
  `manufacturedBy` varchar(255) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `userKey` int(11) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prescriptions`
--

LOCK TABLES `prescriptions` WRITE;
/*!40000 ALTER TABLE `prescriptions` DISABLE KEYS */;
INSERT INTO `prescriptions` (`id`, `name`, `identNo`, `size`, `form`, `rxUnit`, `quantity`, `pharmacy`, `pharmacyPhone`, `written`, `writtenBy`, `filled`, `expired`, `refillNote`, `manufacturedBy`, `note`, `userKey`, `createdAt`, `updatedAt`) VALUES (1,'Metformin','6792303','','tablet','500mg','60','Kroger','919-567-5499','10/23/2023','Dr. Smith','10/23/2023','10/23/2025','2 refills by 02/07/2024','Mylan','Take with food',10,'2023-11-23 02:30:29','2023-11-23 02:30:29'),(2,'Amlodipine','6802323','','tablet','10mg','60','Kroger','919-567-5499','10/23/2023','Dr. Smith','10/23/2023','10/23/2025','2 refills by 02/07/2024','Eli Lily','Take as needed',10,'2023-11-23 02:30:29','2023-11-23 02:30:29'),(3,'Pravastatin','6733303','','tablet','20mg','60','Kroger','919-567-5499','10/23/2023','Dr. Smith','10/23/2023','10/23/2025','2 refills by 02/07/2024','Zocor','Take one tablet nightly',10,'2023-11-23 02:30:29','2023-11-23 02:30:29');
/*!40000 ALTER TABLE `prescriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` (`id`, `name`, `createdAt`, `updatedAt`) VALUES (1,'owner','2023-11-23 01:42:24','2023-11-23 01:42:24'),(2,'agent','2023-11-23 01:42:24','2023-11-23 01:42:24'),(3,'monitor','2023-11-23 01:42:24','2023-11-23 01:42:24'),(4,'admin','2023-11-23 01:42:24','2023-11-23 01:42:24');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `priority` varchar(255) DEFAULT NULL,
  `due` datetime DEFAULT NULL,
  `completed` datetime DEFAULT NULL,
  `trigger` varchar(255) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `userKey` int(11) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasks`
--

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;
INSERT INTO `tasks` (`id`, `name`, `type`, `priority`, `due`, `completed`, `trigger`, `note`, `userKey`, `createdAt`, `updatedAt`) VALUES (1,'Change Air Filters','Maintenance','Normal','2023-11-21 00:00:00',NULL,'','',10,'2023-11-23 02:31:58','2023-11-23 02:31:58'),(2,'Send Taxes','Obligation','High','2023-11-21 00:00:00',NULL,'Pending W-2','',10,'2023-11-23 02:31:58','2023-11-23 02:31:58'),(3,'Take Antibiotic','Health','High',NULL,NULL,'','',10,'2023-11-23 02:31:58','2023-11-23 02:31:58');
/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_roles` (
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `roleId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  PRIMARY KEY (`roleId`,`userId`),
  KEY `userId` (`userId`),
  CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`roleId`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` (`createdAt`, `updatedAt`, `roleId`, `userId`) VALUES ('2023-11-23 03:57:37','2023-11-23 03:57:37',1,7),('2023-11-23 03:57:37','2023-11-23 03:57:37',2,8),('2023-11-23 03:57:37','2023-11-23 03:57:37',3,9),('2023-11-23 03:57:37','2023-11-23 03:57:37',4,10);
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `ownerId` int(11) DEFAULT NULL,
  `agentMnemonic` varchar(255) DEFAULT NULL,
  `monitorMnemonic` varchar(255) DEFAULT NULL,
  `agentId` int(11) DEFAULT NULL,
  `monitorId` int(11) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`id`, `username`, `email`, `password`, `ownerId`, `agentMnemonic`, `monitorMnemonic`, `agentId`, `monitorId`, `createdAt`, `updatedAt`) VALUES (7,'owner','owner@yahoo.com','$2a$08$6qWmMI1ZSpDy5sPxs/PHFOY4BKpaTRgKYVppwxgD7tJ7hOAYtArWu',0,'transfer envelope spend pill twenty release calm cram rookie cream asset budget','emerge hip exhaust reason butter spend avoid spatial merit cry click civil',0,0,'2023-11-23 03:57:37','2023-11-23 03:57:37'),(8,'agent','agent@yahoo.com','$2a$08$kk7RbgWxAI0B1OHV.YPv2.PS1WEnlLXoJDwnFlwQw15ve9Iyob7SW',0,'prevent coyote sleep pond unknown wave question man panda there donor police','farm retire kidney open cave target discover guard motion repair evidence sun',0,0,'2023-11-23 03:57:37','2023-11-23 03:57:37'),(9,'monitor','monitor@yahoo.com','$2a$08$pr9c3LzD3C6l0O1CW9H6TO6hZmj951JDVwHbKLFfdprkMn3yoKDp.',0,'tuition spell champion advice disease zero effort prefer size demise lucky desk','pave when exhaust often common check dune legend idle social soda birth',0,0,'2023-11-23 03:57:37','2023-11-23 03:57:37'),(10,'admin','admin@yahoo.com','$2a$08$DSe8fvKWGQH3kG5zETAqnOSNmgSu1PTmQ6MYw20LHRyBRhv5mj0Xm',0,'edit broom adapt radio bag pitch sausage bamboo churn question enter garlic','still song organ lab method setup amount ancient kind swallow gold critic',0,0,'2023-11-23 03:57:37','2023-11-23 03:57:37');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2023-11-24 12:33:36
