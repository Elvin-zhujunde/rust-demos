# ************************************************************
# Sequel Ace SQL dump
# 版本号： 20077
#
# https://sequel-ace.com/
# https://github.com/Sequel-Ace/Sequel-Ace
#
# 主机: 127.0.0.1 (MySQL 8.4.3)
# 数据库: TeachingManagementSystem
# 生成时间: 2024-12-16 07:07:25 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
SET NAMES utf8mb4;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE='NO_AUTO_VALUE_ON_ZERO', SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# 转储表 BackupStudent
# ------------------------------------------------------------

DROP TABLE IF EXISTS `BackupStudent`;

CREATE TABLE `BackupStudent` (
  `student_id` varchar(20) NOT NULL,
  `name` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `gender` enum('男','女') NOT NULL,
  `email` varchar(100) NOT NULL,
  `address` varchar(200) NOT NULL,
  `department_id` varchar(20) DEFAULT NULL,
  `degree` varchar(50) NOT NULL,
  `enrollment_date` date NOT NULL,
  `major_id` varchar(20) DEFAULT NULL,
  `class_id` varchar(20) DEFAULT NULL,
  `semester` int NOT NULL,
  `total_credits` decimal(5,2) DEFAULT '0.00',
  `gpa` decimal(4,2) DEFAULT '0.00',
  PRIMARY KEY (`student_id`),
  KEY `department_id` (`department_id`),
  KEY `major_id` (`major_id`),
  KEY `class_id` (`class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



# 转储表 Class
# ------------------------------------------------------------

DROP TABLE IF EXISTS `Class`;

CREATE TABLE `Class` (
  `class_id` varchar(20) NOT NULL,
  `class_name` varchar(100) NOT NULL,
  `major_id` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`class_id`),
  KEY `major_id` (`major_id`),
  CONSTRAINT `class_ibfk_1` FOREIGN KEY (`major_id`) REFERENCES `Major` (`major_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `Class` WRITE;
/*!40000 ALTER TABLE `Class` DISABLE KEYS */;

INSERT INTO `Class` (`class_id`, `class_name`, `major_id`)
VALUES
	('C001','计科2101班','M001'),
	('C002','计科2102班','M001'),
	('C003','软工2101班','M002'),
	('C004','电信2101班','M003'),
	('C005','国贸2101班','M004');

/*!40000 ALTER TABLE `Class` ENABLE KEYS */;
UNLOCK TABLES;


# 转储表 Course
# ------------------------------------------------------------

DROP TABLE IF EXISTS `Course`;

CREATE TABLE `Course` (
  `course_id` varchar(20) NOT NULL,
  `subject_id` varchar(20) NOT NULL,
  `teacher_id` varchar(20) DEFAULT NULL,
  `semester` int NOT NULL,
  `student_count` int DEFAULT '0',
  `max_students` int NOT NULL,
  `class_hours` enum('16','32','48','64') NOT NULL,
  `week_day` enum('1','2','3','4','5','6','7') NOT NULL COMMENT '周几上课',
  `start_section` int NOT NULL COMMENT '第几节开始上课 1-6',
  `section_count` int DEFAULT '1' COMMENT '连续上几节课',
  PRIMARY KEY (`course_id`),
  KEY `subject_id` (`subject_id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `course_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `Subject` (`subject_id`),
  CONSTRAINT `course_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `Teacher` (`teacher_id`),
  CONSTRAINT `valid_section` CHECK (((`start_section` between 1 and 6) and (`section_count` = 1)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `Course` WRITE;
/*!40000 ALTER TABLE `Course` DISABLE KEYS */;

INSERT INTO `Course` (`course_id`, `subject_id`, `teacher_id`, `semester`, `student_count`, `max_students`, `class_hours`, `week_day`, `start_section`, `section_count`)
VALUES
	('CRS001','S005','T001',2,1,70,'32','5',1,1),
	('CRS002','S006','T005',2,1,58,'32','5',2,1),
	('CRS003','S003','T009',1,0,38,'32','4',2,1),
	('CRS004','S001','T013',2,0,49,'32','2',4,1),
	('CRS005','S010','T010',1,0,72,'32','5',3,1),
	('CRS006','S002','T006',1,0,71,'32','5',4,1),
	('CRS007','S002','T003',1,0,46,'32','3',3,1),
	('CRS008','S006','T012',1,0,59,'32','4',2,1),
	('CRS009','S005','T006',1,0,74,'32','2',6,1),
	('CRS010','S007','T009',2,0,68,'32','4',4,1),
	('CRS011','S003','T003',2,0,78,'32','5',6,1),
	('CRS012','S001','T004',2,0,65,'32','2',4,1),
	('CRS013','S010','T013',1,0,42,'32','1',2,1),
	('CRS014','S003','T007',1,0,56,'32','4',4,1),
	('CRS015','S001','T007',1,0,55,'32','5',6,1),
	('CRS016','S010','T004',1,0,66,'32','2',6,1),
	('CRS017','S001','T002',1,0,53,'32','2',2,1),
	('CRS018','S007','T013',1,0,36,'32','1',4,1),
	('CRS019','S001','T013',1,0,62,'32','2',6,1),
	('CRS020','S006','T012',1,0,77,'32','1',3,1),
	('CRS021','S006','T011',2,0,53,'32','3',3,1),
	('CRS022','S004','T006',2,0,59,'32','3',6,1),
	('CRS023','S001','T007',2,0,45,'32','4',2,1),
	('CRS024','S009','T003',1,0,49,'32','3',4,1),
	('CRS025','S001','T003',2,0,75,'32','5',4,1),
	('CRS026','S010','T003',2,0,78,'32','3',4,1),
	('CRS027','S003','T002',2,0,75,'32','2',5,1),
	('CRS028','S003','T007',2,1,35,'32','4',3,1),
	('CRS029','S004','T004',1,0,79,'32','5',5,1),
	('CRS030','S006','T001',1,0,59,'32','4',2,1),
	('CRS031','S010','T004',1,0,62,'32','3',3,1),
	('CRS032','S010','T015',2,0,54,'32','5',5,1),
	('CRS033','S004','T005',1,0,62,'32','2',2,1),
	('CRS034','S003','T003',1,0,53,'32','5',4,1),
	('CRS035','S005','T011',1,0,58,'32','4',2,1),
	('CRS036','S009','T007',2,0,47,'32','1',4,1),
	('CRS037','S002','T011',1,0,52,'32','1',4,1),
	('CRS038','S006','T006',1,0,67,'32','4',5,1),
	('CRS039','S007','T012',2,0,68,'32','1',2,1),
	('CRS040','S001','T001',2,0,71,'32','1',2,1),
	('CRS041','S005','T008',1,0,39,'32','1',2,1),
	('CRS042','S002','T005',2,0,76,'32','4',1,1),
	('CRS043','S006','T012',1,0,50,'32','4',1,1),
	('CRS044','S009','T001',2,0,40,'32','4',1,1),
	('CRS045','S008','T001',1,0,50,'32','2',2,1),
	('CRS046','S003','T001',1,0,50,'32','4',4,1),
	('CRS047','S006','T008',2,0,33,'32','1',3,1),
	('CRS048','S010','T006',1,0,30,'32','4',4,1),
	('CRS049','S004','T010',1,0,79,'32','5',1,1),
	('CRS050','S005','T005',1,0,79,'32','4',5,1),
	('CRS051','S007','T005',1,0,48,'32','1',5,1),
	('CRS052','S005','T002',1,0,67,'32','5',1,1),
	('CRS053','S003','T004',1,0,43,'32','1',5,1),
	('CRS054','S001','T009',2,0,77,'32','4',2,1),
	('CRS055','S003','T005',2,0,67,'32','5',1,1),
	('CRS056','S006','T009',2,0,66,'32','2',6,1),
	('CRS057','S007','T003',2,0,74,'32','1',1,1),
	('CRS058','S002','T002',2,0,46,'32','3',4,1),
	('CRS059','S001','T003',2,0,37,'32','4',6,1),
	('CRS060','S001','T015',2,1,74,'32','1',6,1),
	('CRS061','S009','T009',1,0,40,'32','5',1,1),
	('CRS062','S007','T012',2,0,51,'32','2',2,1),
	('CRS063','S004','T009',2,0,38,'32','1',6,1),
	('CRS064','S003','T015',2,0,52,'32','5',4,1),
	('CRS065','S004','T008',1,0,40,'32','5',4,1),
	('CRS066','S004','T001',1,0,32,'32','5',6,1),
	('CRS067','S005','T013',1,0,34,'32','3',4,1),
	('CRS068','S009','T015',1,0,33,'32','3',5,1),
	('CRS069','S002','T010',2,0,77,'32','5',1,1),
	('CRS070','S005','T004',2,0,65,'32','3',2,1),
	('CRS071','S008','T008',1,0,33,'32','4',4,1),
	('CRS072','S006','T007',2,0,40,'32','1',1,1),
	('CRS073','S010','T015',1,0,61,'32','3',3,1),
	('CRS074','S008','T015',1,0,42,'32','2',6,1),
	('CRS075','S004','T013',1,0,35,'32','2',5,1),
	('CRS076','S003','T002',2,0,78,'32','3',1,1),
	('CRS077','S005','T003',2,0,69,'32','1',2,1),
	('CRS078','S003','T002',2,0,78,'32','5',5,1),
	('CRS079','S006','T014',2,0,46,'32','4',6,1),
	('CRS080','S010','T014',2,0,72,'32','1',4,1),
	('CRS081','S005','T012',1,0,36,'32','1',1,1),
	('CRS082','S004','T008',1,0,30,'32','2',1,1),
	('CRS083','S007','T003',2,0,46,'32','3',2,1),
	('CRS084','S002','T012',1,0,31,'32','5',2,1),
	('CRS085','S006','T010',2,0,50,'32','1',2,1),
	('CRS086','S002','T009',1,0,69,'32','5',2,1),
	('CRS087','S002','T009',1,0,49,'32','2',1,1),
	('CRS088','S008','T008',1,0,37,'32','5',2,1),
	('CRS089','S008','T006',1,0,78,'32','1',3,1),
	('CRS090','S004','T001',2,0,48,'32','4',3,1),
	('CRS091','S005','T014',1,0,50,'32','3',6,1),
	('CRS092','S002','T008',2,0,51,'32','3',4,1),
	('CRS093','S004','T009',2,0,67,'32','2',3,1),
	('CRS094','S006','T012',2,0,39,'32','3',5,1),
	('CRS095','S007','T014',1,0,34,'32','1',5,1),
	('CRS096','S004','T006',2,0,30,'32','5',6,1),
	('CRS097','S004','T008',2,0,58,'32','1',5,1),
	('CRS098','S004','T004',1,0,67,'32','3',6,1),
	('CRS099','S008','T009',2,0,65,'32','5',6,1),
	('CRS100','S010','T010',1,0,32,'32','2',4,1),
	('CRS901','S001','T001',1,1,60,'64','1',1,1),
	('CRS902','S002','T002',1,1,60,'48','2',3,1),
	('CRS903','S003','T003',1,1,60,'48','3',5,1),
	('CRS904','S001','T004',1,0,60,'64','1',2,1),
	('CRS905','S002','T005',1,0,60,'48','2',4,1),
	('CRS906','S003','T006',1,0,60,'48','3',6,1);

/*!40000 ALTER TABLE `Course` ENABLE KEYS */;
UNLOCK TABLES;


# 转储表 CourseClass
# ------------------------------------------------------------

DROP TABLE IF EXISTS `CourseClass`;

CREATE TABLE `CourseClass` (
  `course_id` varchar(20) NOT NULL,
  `class_id` varchar(20) NOT NULL,
  PRIMARY KEY (`course_id`,`class_id`),
  KEY `class_id` (`class_id`),
  CONSTRAINT `courseclass_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `Course` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `courseclass_ibfk_2` FOREIGN KEY (`class_id`) REFERENCES `Class` (`class_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `CourseClass` WRITE;
/*!40000 ALTER TABLE `CourseClass` DISABLE KEYS */;

INSERT INTO `CourseClass` (`course_id`, `class_id`)
VALUES
	('CRS001','C001'),
	('CRS002','C001'),
	('CRS901','C001'),
	('CRS902','C001'),
	('CRS903','C001'),
	('CRS001','C002'),
	('CRS904','C002'),
	('CRS905','C002'),
	('CRS906','C002'),
	('CRS003','C003');

/*!40000 ALTER TABLE `CourseClass` ENABLE KEYS */;
UNLOCK TABLES;


# 转储表 CourseSelection
# ------------------------------------------------------------

DROP TABLE IF EXISTS `CourseSelection`;

CREATE TABLE `CourseSelection` (
  `student_id` varchar(20) NOT NULL,
  `course_id` varchar(20) NOT NULL,
  `selection_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`student_id`,`course_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `courseselection_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `Student` (`student_id`),
  CONSTRAINT `courseselection_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `Course` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `CourseSelection` WRITE;
/*!40000 ALTER TABLE `CourseSelection` DISABLE KEYS */;

INSERT INTO `CourseSelection` (`student_id`, `course_id`, `selection_date`)
VALUES
	('S2021001','CRS001','2024-12-12 12:44:04'),
	('S2021001','CRS002','2024-12-12 12:44:04'),
	('S2021001','CRS028','2024-12-12 12:44:18'),
	('S2021001','CRS060','2024-12-12 12:43:58'),
	('S2021001','CRS901','2024-12-12 12:44:04'),
	('S2021001','CRS902','2024-12-12 12:44:04'),
	('S2021001','CRS903','2024-12-12 12:44:04');

/*!40000 ALTER TABLE `CourseSelection` ENABLE KEYS */;
UNLOCK TABLES;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `trg_CourseSelection_insert` AFTER INSERT ON `CourseSelection` FOR EACH ROW BEGIN
    DECLARE course_credits DECIMAL(3,1);
    SELECT credits INTO course_credits 
    FROM Subject 
    WHERE subject_id = (SELECT subject_id FROM Course WHERE course_id = NEW.course_id);
    UPDATE Student 
    SET total_credits = total_credits + course_credits 
    WHERE student_id = NEW.student_id;
END */;;
/*!50003 SET SESSION SQL_MODE="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `trg_CourseSelection_count_insert` AFTER INSERT ON `CourseSelection` FOR EACH ROW BEGIN
    UPDATE Course 
    SET student_count = student_count + 1
    WHERE course_id = NEW.course_id;
END */;;
/*!50003 SET SESSION SQL_MODE="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `trg_CourseSelection_delete` AFTER DELETE ON `CourseSelection` FOR EACH ROW BEGIN
    DECLARE course_credits DECIMAL(3,1);
    SELECT credits INTO course_credits 
    FROM Subject 
    WHERE subject_id = (SELECT subject_id FROM Course WHERE course_id = OLD.course_id);
    UPDATE Student 
    SET total_credits = total_credits - course_credits 
    WHERE student_id = OLD.student_id;
END */;;
/*!50003 SET SESSION SQL_MODE="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `trg_CourseSelection_count_delete` AFTER DELETE ON `CourseSelection` FOR EACH ROW BEGIN
    UPDATE Course 
    SET student_count = student_count - 1
    WHERE course_id = OLD.course_id;
END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# 转储表 Department
# ------------------------------------------------------------

DROP TABLE IF EXISTS `Department`;

CREATE TABLE `Department` (
  `department_id` varchar(20) NOT NULL,
  `department_name` varchar(100) NOT NULL,
  PRIMARY KEY (`department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `Department` WRITE;
/*!40000 ALTER TABLE `Department` DISABLE KEYS */;

INSERT INTO `Department` (`department_id`, `department_name`)
VALUES
	('D001','计算机学院'),
	('D002','电子信息学院'),
	('D003','经济管理学院');

/*!40000 ALTER TABLE `Department` ENABLE KEYS */;
UNLOCK TABLES;


# 转储表 Grades
# ------------------------------------------------------------

DROP TABLE IF EXISTS `Grades`;

CREATE TABLE `Grades` (
  `student_id` varchar(20) NOT NULL,
  `course_id` varchar(20) NOT NULL,
  `grade` decimal(5,2) NOT NULL,
  PRIMARY KEY (`student_id`,`course_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `grades_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `Student` (`student_id`),
  CONSTRAINT `grades_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `Course` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `Grades` WRITE;
/*!40000 ALTER TABLE `Grades` DISABLE KEYS */;

INSERT INTO `Grades` (`student_id`, `course_id`, `grade`)
VALUES
	('S2021001','CRS001',88.00),
	('S2021001','CRS901',99.00);

/*!40000 ALTER TABLE `Grades` ENABLE KEYS */;
UNLOCK TABLES;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `trg_Grades_insert` AFTER INSERT ON `Grades` FOR EACH ROW BEGIN
    DECLARE total_grade_points DECIMAL(10,2);
    DECLARE total_credits DECIMAL(10,2);
    SELECT SUM(G.grade * S.credits), SUM(S.credits)
    INTO total_grade_points, total_credits
    FROM Grades G
    JOIN Course C ON G.course_id = C.course_id
    JOIN Subject S ON C.subject_id = S.subject_id
    WHERE G.student_id = NEW.student_id;
    IF total_credits > 0 THEN
        UPDATE Student 
        SET gpa = total_grade_points / total_credits
        WHERE student_id = NEW.student_id;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# 转储表 Major
# ------------------------------------------------------------

DROP TABLE IF EXISTS `Major`;

CREATE TABLE `Major` (
  `major_id` varchar(20) NOT NULL,
  `major_name` varchar(100) NOT NULL,
  `department_id` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`major_id`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `major_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `Department` (`department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `Major` WRITE;
/*!40000 ALTER TABLE `Major` DISABLE KEYS */;

INSERT INTO `Major` (`major_id`, `major_name`, `department_id`)
VALUES
	('M001','计算机科学与技术','D001'),
	('M002','软件工程','D001'),
	('M003','电子信息工程','D002'),
	('M004','国际经济与贸易','D003');

/*!40000 ALTER TABLE `Major` ENABLE KEYS */;
UNLOCK TABLES;


# 转储表 OperationLog
# ------------------------------------------------------------

DROP TABLE IF EXISTS `OperationLog`;

CREATE TABLE `OperationLog` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(20) NOT NULL,
  `operation_type` varchar(10) NOT NULL,
  `operation_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `table_name` varchar(50) NOT NULL,
  `record_id` varchar(50) DEFAULT NULL,
  `description` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `OperationLog` WRITE;
/*!40000 ALTER TABLE `OperationLog` DISABLE KEYS */;

INSERT INTO `OperationLog` (`log_id`, `user_id`, `operation_type`, `operation_time`, `table_name`, `record_id`, `description`)
VALUES
	(1,'system','select','2024-12-12 12:43:51','student-courses','S2021001','select operation on student-courses'),
	(2,'system','select','2024-12-12 12:43:52','available-courses',NULL,'select operation on available-courses'),
	(3,'system','select','2024-12-12 12:43:55','available-courses',NULL,'select operation on available-courses'),
	(4,'system','create','2024-12-12 12:43:58','select-course',NULL,'create operation on select-course'),
	(5,'system','select','2024-12-12 12:43:58','available-courses',NULL,'select operation on available-courses'),
	(6,'system','select','2024-12-12 12:44:02','class-courses','S2021001','select operation on class-courses'),
	(7,'system','create','2024-12-12 12:44:04','apply-class-courses',NULL,'create operation on apply-class-courses'),
	(8,'system','select','2024-12-12 12:44:04','available-courses',NULL,'select operation on available-courses'),
	(9,'system','select','2024-12-12 12:44:05','student-courses','S2021001','select operation on student-courses'),
	(10,'system','select','2024-12-12 12:44:06','student-schedule','S2021001','select operation on student-schedule'),
	(11,'system','select','2024-12-12 12:44:11','available-courses',NULL,'select operation on available-courses'),
	(12,'system','select','2024-12-12 12:44:17','available-courses',NULL,'select operation on available-courses'),
	(13,'system','create','2024-12-12 12:44:18','select-course',NULL,'create operation on select-course'),
	(14,'system','select','2024-12-12 12:44:18','available-courses',NULL,'select operation on available-courses'),
	(15,'system','select','2024-12-12 12:44:20','student-courses','S2021001','select operation on student-courses'),
	(16,'system','select','2024-12-12 12:44:21','student-schedule','S2021001','select operation on student-schedule'),
	(17,'system','select','2024-12-12 12:48:31','student-courses','S2021001','select operation on student-courses'),
	(18,'system','select','2024-12-12 12:48:45','student-schedule','S2021001','select operation on student-schedule'),
	(19,'system','select','2024-12-12 12:48:48','available-courses',NULL,'select operation on available-courses'),
	(20,'system','select','2024-12-12 12:48:48','student-courses','S2021001','select operation on student-courses'),
	(21,'system','select','2024-12-12 12:48:49','student','S2021001','select operation on student'),
	(22,'system','select','2024-12-12 12:49:03','student-courses','S2021001','select operation on student-courses'),
	(23,'system','select','2024-12-12 12:49:04','student-schedule','S2021001','select operation on student-schedule'),
	(24,'system','select','2024-12-12 12:51:17','student-courses','S2021001','select operation on student-courses'),
	(25,'system','select','2024-12-12 13:37:09','student-schedule','S2021001','select operation on student-schedule'),
	(26,'system','select','2024-12-12 13:37:46','available-courses',NULL,'select operation on available-courses'),
	(27,'system','select','2024-12-12 13:37:49','class-courses','S2021001','select operation on class-courses'),
	(28,'system','select','2024-12-12 13:37:52','student-courses','S2021001','select operation on student-courses'),
	(29,'system','select','2024-12-12 13:37:56','student-schedule','S2021001','select operation on student-schedule'),
	(30,'system','select','2024-12-12 13:37:59','student','S2021001','select operation on student'),
	(31,'system','select','2024-12-12 13:38:00','available-courses',NULL,'select operation on available-courses'),
	(32,'system','create','2024-12-12 13:38:11','login',NULL,'create operation on login'),
	(33,'system','select','2024-12-12 13:38:15','teacher-courses','T001','select operation on teacher-courses'),
	(34,'system','select','2024-12-12 13:38:18','course','CRS001','select operation on course'),
	(35,'system','select','2024-12-12 13:38:18','course-grades','CRS001','select operation on course-grades'),
	(36,'system','select','2024-12-12 13:40:33','course','CRS001','select operation on course'),
	(37,'system','select','2024-12-12 13:40:33','course-grades','CRS001','select operation on course-grades'),
	(38,'system','create','2024-12-12 13:40:36','update-grade',NULL,'create operation on update-grade'),
	(39,'system','select','2024-12-12 13:40:39','teacher','T001','select operation on teacher'),
	(40,'system','select','2024-12-12 13:40:40','teacher-students','T001','select operation on teacher-students'),
	(41,'system','select','2024-12-12 13:40:45','teacher-courses','T001','select operation on teacher-courses'),
	(42,'system','select','2024-12-12 13:40:47','teacher-students','T001','select operation on teacher-students'),
	(43,'system','select','2024-12-12 13:40:48','departments',NULL,'select operation on departments'),
	(44,'system','select','2024-12-12 13:40:51','teacher-courses','T001','select operation on teacher-courses'),
	(45,'system','select','2024-12-12 13:40:52','course','CRS001','select operation on course'),
	(46,'system','select','2024-12-12 13:40:52','course-grades','CRS001','select operation on course-grades'),
	(47,'system','create','2024-12-12 13:40:56','update-grade',NULL,'create operation on update-grade'),
	(48,'system','select','2024-12-12 13:41:02','teacher-courses','T001','select operation on teacher-courses'),
	(49,'system','select','2024-12-12 13:41:05','course','CRS901','select operation on course'),
	(50,'system','select','2024-12-12 13:41:05','course-grades','CRS901','select operation on course-grades'),
	(51,'system','create','2024-12-12 13:41:09','update-grade',NULL,'create operation on update-grade'),
	(52,'system','select','2024-12-12 13:41:11','teacher-students','T001','select operation on teacher-students'),
	(53,'system','select','2024-12-12 13:41:14','teacher-courses','T001','select operation on teacher-courses'),
	(54,'system','select','2024-12-12 13:41:16','course','CRS001','select operation on course'),
	(55,'system','select','2024-12-12 13:41:16','course-grades','CRS001','select operation on course-grades'),
	(56,'system','select','2024-12-12 13:41:18','teacher-students','T001','select operation on teacher-students'),
	(57,'system','select','2024-12-12 13:41:39','teacher-courses','T001','select operation on teacher-courses'),
	(58,'system','select','2024-12-12 13:41:40','teacher-schedule','T001','select operation on teacher-schedule'),
	(59,'system','select','2024-12-12 13:42:59','teacher-courses','T001','select operation on teacher-courses'),
	(60,'system','select','2024-12-12 13:43:00','teacher-schedule','T001','select operation on teacher-schedule'),
	(61,'system','select','2024-12-12 13:43:25','teacher-students','T001','select operation on teacher-students'),
	(62,'system','create','2024-12-12 13:43:46','login',NULL,'create operation on login'),
	(63,'system','select','2024-12-12 13:43:48','available-courses',NULL,'select operation on available-courses'),
	(64,'system','select','2024-12-12 13:43:49','class-courses','S2021001','select operation on class-courses'),
	(65,'system','select','2024-12-12 13:43:53','student-courses','S2021001','select operation on student-courses'),
	(66,'system','select','2024-12-12 13:43:54','student-schedule','S2021001','select operation on student-schedule'),
	(67,'system','select','2024-12-12 13:44:08','student-schedule','S2021001','select operation on student-schedule'),
	(68,'system','select','2024-12-12 13:44:54','student-courses','S2021001','select operation on student-courses'),
	(69,'system','select','2024-12-12 13:44:55','student-schedule','S2021001','select operation on student-schedule'),
	(70,'system','select','2024-12-12 13:45:39','student-courses','S2021001','select operation on student-courses'),
	(71,'system','select','2024-12-12 13:45:42','student-schedule','S2021001','select operation on student-schedule'),
	(72,'system','select','2024-12-12 13:45:59','student-courses','S2021001','select operation on student-courses'),
	(73,'system','select','2024-12-12 13:46:01','student-schedule','S2021001','select operation on student-schedule'),
	(74,'system','select','2024-12-12 13:47:16','student-courses','S2021001','select operation on student-courses'),
	(75,'system','select','2024-12-12 14:52:34','student-courses','S2021001','select operation on student-courses'),
	(76,'system','select','2024-12-12 14:57:31','student-courses','S2021001','select operation on student-courses'),
	(77,'system','select','2024-12-12 15:05:11','student-courses','S2021001','select operation on student-courses'),
	(78,'system','select','2024-12-12 15:11:48','student-courses','S2021001','select operation on student-courses'),
	(79,'system','select','2024-12-14 10:01:08','available-courses',NULL,'select operation on available-courses'),
	(80,'system','select','2024-12-14 10:01:09','student-courses','S2021001','select operation on student-courses'),
	(81,'system','select','2024-12-14 10:01:09','student','S2021001','select operation on student'),
	(82,'system','select','2024-12-14 10:01:13','student-courses','S2021001','select operation on student-courses'),
	(83,'system','select','2024-12-14 10:01:14','available-courses',NULL,'select operation on available-courses'),
	(84,'system','select','2024-12-14 10:03:45','available-courses',NULL,'select operation on available-courses'),
	(85,'system','select','2024-12-14 10:04:04','student-courses','S2021001','select operation on student-courses'),
	(86,'system','select','2024-12-14 10:04:05','student','S2021001','select operation on student'),
	(87,'system','select','2024-12-14 10:06:21','student','S2021001','select operation on student'),
	(88,'system','select','2024-12-14 10:25:51','student','S2021001','select operation on student'),
	(89,'system','select','2024-12-14 10:29:23','student','S2021001','select operation on student'),
	(90,'system','select','2024-12-14 10:57:46','student','S2021001','select operation on student'),
	(91,'system','select','2024-12-14 11:02:19','available-courses',NULL,'select operation on available-courses'),
	(92,'system','select','2024-12-14 11:02:19','student-courses','S2021001','select operation on student-courses'),
	(93,'system','select','2024-12-14 11:03:03','student-schedule','S2021001','select operation on student-schedule'),
	(94,'system','select','2024-12-14 11:04:24','available-courses',NULL,'select operation on available-courses'),
	(95,'system','select','2024-12-14 11:04:26','student-courses','S2021001','select operation on student-courses'),
	(96,'system','select','2024-12-14 11:04:26','student','S2021001','select operation on student'),
	(97,'system','select','2024-12-14 11:04:27','student-courses','S2021001','select operation on student-courses'),
	(98,'system','select','2024-12-14 11:04:29','student','S2021001','select operation on student'),
	(99,'system','select','2024-12-14 11:06:40','student','S2021001','select operation on student'),
	(100,'system','select','2024-12-14 11:07:35','student-courses','S2021001','select operation on student-courses'),
	(101,'system','select','2024-12-14 11:07:35','available-courses',NULL,'select operation on available-courses'),
	(102,'system','select','2024-12-14 11:07:36','student','S2021001','select operation on student'),
	(103,'system','select','2024-12-14 11:07:37','available-courses',NULL,'select operation on available-courses'),
	(104,'system','create','2024-12-14 11:14:40','login',NULL,'create operation on login'),
	(105,'system','select','2024-12-14 11:14:42','teacher-courses','T001','select operation on teacher-courses'),
	(106,'system','select','2024-12-14 11:14:43','teacher-students','T001','select operation on teacher-students'),
	(107,'system','select','2024-12-14 11:14:44','teacher','T001','select operation on teacher'),
	(108,'system','select','2024-12-14 11:15:09','teacher-students','T001','select operation on teacher-students'),
	(109,'system','select','2024-12-14 11:15:11','departments',NULL,'select operation on departments'),
	(110,'system','select','2024-12-14 11:15:14','teacher-courses','T001','select operation on teacher-courses'),
	(111,'system','select','2024-12-14 11:15:15','teacher-courses','T001','select operation on teacher-courses'),
	(112,'system','select','2024-12-14 11:15:15','teacher-students','T001','select operation on teacher-students'),
	(113,'system','select','2024-12-14 11:15:16','teacher','T001','select operation on teacher'),
	(114,'system','select','2024-12-14 11:15:16','teacher-courses','T001','select operation on teacher-courses'),
	(115,'system','select','2024-12-14 11:15:16','teacher','T001','select operation on teacher'),
	(116,'system','select','2024-12-14 11:15:50','teacher-students','T001','select operation on teacher-students'),
	(117,'system','select','2024-12-14 11:15:51','teacher-courses','T001','select operation on teacher-courses'),
	(118,'system','select','2024-12-14 11:15:52','teacher-students','T001','select operation on teacher-students'),
	(119,'system','select','2024-12-14 11:15:55','teacher','T001','select operation on teacher'),
	(120,'system','select','2024-12-14 11:15:56','teacher-students','T001','select operation on teacher-students'),
	(121,'system','select','2024-12-14 11:15:56','teacher-courses','T001','select operation on teacher-courses'),
	(122,'system','select','2024-12-14 11:15:57','teacher-students','T001','select operation on teacher-students'),
	(123,'system','select','2024-12-14 11:15:57','teacher','T001','select operation on teacher'),
	(124,'system','select','2024-12-14 11:15:59','teacher-students','T001','select operation on teacher-students'),
	(125,'system','select','2024-12-14 11:16:00','teacher-courses','T001','select operation on teacher-courses'),
	(126,'system','select','2024-12-14 11:16:01','teacher-students','T001','select operation on teacher-students'),
	(127,'system','select','2024-12-14 11:16:02','teacher','T001','select operation on teacher'),
	(128,'system','select','2024-12-14 11:16:04','teacher-students','T001','select operation on teacher-students'),
	(129,'system','select','2024-12-14 11:16:04','teacher-courses','T001','select operation on teacher-courses'),
	(130,'system','select','2024-12-14 11:16:04','teacher','T001','select operation on teacher'),
	(131,'system','select','2024-12-14 11:16:05','teacher-courses','T001','select operation on teacher-courses'),
	(132,'system','select','2024-12-14 11:16:05','teacher-students','T001','select operation on teacher-students'),
	(133,'system','select','2024-12-14 11:17:03','teacher-student-courses','T001','select operation on teacher-student-courses'),
	(134,'system','select','2024-12-14 11:17:06','teacher','T001','select operation on teacher'),
	(135,'system','select','2024-12-14 11:17:06','teacher-students','T001','select operation on teacher-students'),
	(136,'system','select','2024-12-14 11:17:07','teacher-courses','T001','select operation on teacher-courses'),
	(137,'system','select','2024-12-14 11:18:33','teacher-students','T001','select operation on teacher-students'),
	(138,'system','select','2024-12-14 11:18:34','teacher','T001','select operation on teacher'),
	(139,'system','select','2024-12-14 11:49:57','teacher','T001','select operation on teacher'),
	(140,'system','select','2024-12-14 11:53:30','teacher','T001','select operation on teacher'),
	(141,'system','select','2024-12-14 12:00:02','teacher','T001','select operation on teacher'),
	(142,'system','select','2024-12-14 13:44:17','teacher-students','T001','select operation on teacher-students'),
	(143,'system','select','2024-12-14 13:44:17','teacher-courses','T001','select operation on teacher-courses'),
	(144,'system','select','2024-12-14 13:44:18','teacher-students','T001','select operation on teacher-students'),
	(145,'system','select','2024-12-14 13:44:19','teacher','T001','select operation on teacher'),
	(146,'system','select','2024-12-14 13:44:20','teacher-students','T001','select operation on teacher-students');

/*!40000 ALTER TABLE `OperationLog` ENABLE KEYS */;
UNLOCK TABLES;


# 转储表 Student
# ------------------------------------------------------------

DROP TABLE IF EXISTS `Student`;

CREATE TABLE `Student` (
  `student_id` varchar(20) NOT NULL,
  `name` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `gender` enum('男','女') NOT NULL,
  `email` varchar(100) NOT NULL,
  `address` varchar(200) NOT NULL,
  `department_id` varchar(20) DEFAULT NULL,
  `degree` varchar(50) NOT NULL,
  `enrollment_date` date NOT NULL,
  `major_id` varchar(20) DEFAULT NULL,
  `class_id` varchar(20) DEFAULT NULL,
  `semester` int NOT NULL,
  `total_credits` decimal(5,2) DEFAULT '0.00',
  `gpa` decimal(4,2) DEFAULT '0.00',
  PRIMARY KEY (`student_id`),
  KEY `department_id` (`department_id`),
  KEY `major_id` (`major_id`),
  KEY `class_id` (`class_id`),
  CONSTRAINT `student_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `Department` (`department_id`),
  CONSTRAINT `student_ibfk_2` FOREIGN KEY (`major_id`) REFERENCES `Major` (`major_id`),
  CONSTRAINT `student_ibfk_3` FOREIGN KEY (`class_id`) REFERENCES `Class` (`class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `Student` WRITE;
/*!40000 ALTER TABLE `Student` DISABLE KEYS */;

INSERT INTO `Student` (`student_id`, `name`, `password`, `gender`, `email`, `address`, `department_id`, `degree`, `enrollment_date`, `major_id`, `class_id`, `semester`, `total_credits`, `gpa`)
VALUES
	('S2021001','刘洋','123456','男','liuyang@example.com','北京市朝阳区','D001','本科','2021-09-01','M001','C001',1,24.00,94.29),
	('S2021002','王芳','123456','女','wangfang@example.com','上海市黄浦区','D001','本科','2021-09-01','M001','C002',1,0.00,0.00),
	('S2021003','陈杰','123456','男','chenjie@example.com','广州市越秀区','D001','本科','2021-09-01','M002','C003',1,0.00,0.00),
	('S2021004','赵丽','123456','女','zhaoli@example.com','深圳市罗湖区','D002','本科','2021-09-01','M003','C004',1,0.00,0.00),
	('S2021005','孙浩','123456','男','sunhao@example.com','杭州市西湖区','D003','本科','2021-09-01','M004','C005',1,0.00,0.00);

/*!40000 ALTER TABLE `Student` ENABLE KEYS */;
UNLOCK TABLES;

DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `trg_Student_delete` BEFORE DELETE ON `Student` FOR EACH ROW BEGIN
    INSERT INTO BackupStudent SELECT * FROM Student WHERE student_id = OLD.student_id;
END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# 转储表 Subject
# ------------------------------------------------------------

DROP TABLE IF EXISTS `Subject`;

CREATE TABLE `Subject` (
  `subject_id` varchar(20) NOT NULL,
  `subject_name` varchar(100) NOT NULL,
  `class_hours` int NOT NULL,
  `credits` decimal(3,1) NOT NULL,
  PRIMARY KEY (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `Subject` WRITE;
/*!40000 ALTER TABLE `Subject` DISABLE KEYS */;

INSERT INTO `Subject` (`subject_id`, `subject_name`, `class_hours`, `credits`)
VALUES
	('S001','高等数学',64,4.0),
	('S002','大学英语',48,3.0),
	('S003','数据结构',48,3.0),
	('S004','电路分析',48,3.0),
	('S005','国际贸易',48,3.0),
	('S006','程序设计基础',64,4.0),
	('S007','离散数学',48,3.0),
	('S008','计算机组成原理',64,4.0),
	('S009','操作系统',48,3.0),
	('S010','计算机网络',48,3.0);

/*!40000 ALTER TABLE `Subject` ENABLE KEYS */;
UNLOCK TABLES;


# 转储表 Teacher
# ------------------------------------------------------------

DROP TABLE IF EXISTS `Teacher`;

CREATE TABLE `Teacher` (
  `teacher_id` varchar(20) NOT NULL,
  `name` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `gender` enum('男','女') NOT NULL,
  `email` varchar(100) NOT NULL,
  `address` varchar(200) NOT NULL,
  `department_id` varchar(20) DEFAULT NULL,
  `title` varchar(50) NOT NULL,
  `entry_date` date NOT NULL,
  PRIMARY KEY (`teacher_id`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `teacher_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `Department` (`department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `Teacher` WRITE;
/*!40000 ALTER TABLE `Teacher` DISABLE KEYS */;

INSERT INTO `Teacher` (`teacher_id`, `name`, `password`, `gender`, `email`, `address`, `department_id`, `title`, `entry_date`)
VALUES
	('T001','张伟','123456','男','zhangwei@example.com','北京市海淀区','D001','教授','2010-09-01'),
	('T002','李娜','123456','女','lina@example.com','北京市朝阳区','D001','副教授','2012-08-15'),
	('T003','王强','123456','男','wangqiang@example.com','北京市西城区','D001','讲师','2015-07-01'),
	('T004','赵敏','123456','女','zhaomin@example.com','北京市东城区','D001','助教','2018-03-10'),
	('T005','刘洋','123456','男','liuyang@example.com','北京市海淀区','D001','教授','2009-09-01'),
	('T006','陈明','123456','男','chenming@example.com','上海市浦东新区','D002','教授','2008-09-01'),
	('T007','周红','123456','女','zhouhong@example.com','上海市黄浦区','D002','副教授','2011-08-15'),
	('T008','吴强','123456','男','wuqiang@example.com','上海市徐汇区','D002','讲师','2014-07-01'),
	('T009','郑丽','123456','女','zhengli@example.com','上海市长宁区','D002','助教','2017-03-10'),
	('T010','孙华','123456','男','sunhua@example.com','上海市静安区','D002','教授','2007-09-01'),
	('T011','杨波','123456','男','yangbo@example.com','广州市天河区','D003','教授','2006-09-01'),
	('T012','林芳','123456','女','linfang@example.com','广州市越秀区','D003','副教授','2010-08-15'),
	('T013','黄强','123456','男','huangqiang@example.com','广州市海珠区','D003','讲师','2013-07-01'),
	('T014','马丽','123456','女','mali@example.com','广州市荔湾区','D003','助教','2016-03-10'),
	('T015','朱华','123456','男','zhuhua@example.com','广州市白云区','D003','教授','2005-09-01');

/*!40000 ALTER TABLE `Teacher` ENABLE KEYS */;
UNLOCK TABLES;








# 导出视图 vw_course_teacher
# ------------------------------------------------------------

DROP TABLE IF EXISTS `vw_course_teacher`; DROP VIEW IF EXISTS `vw_course_teacher`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_course_teacher`
AS SELECT
   `C`.`course_id` AS `course_id`,
   `S`.`subject_name` AS `subject_name`,
   `C`.`semester` AS `semester`,
   `C`.`class_hours` AS `class_hours`,
   `C`.`student_count` AS `student_count`,
   `C`.`max_students` AS `max_students`,
   `C`.`week_day` AS `week_day`,
   `C`.`start_section` AS `start_section`,
   `C`.`section_count` AS `section_count`,
   `T`.`teacher_id` AS `teacher_id`,
   `T`.`name` AS `teacher_name`,
   `T`.`title` AS `title`,
   `T`.`department_id` AS `department_id`
FROM ((`course` `C` join `subject` `S` on((`C`.`subject_id` = `S`.`subject_id`))) join `teacher` `T` on((`C`.`teacher_id` = `T`.`teacher_id`)));

# 导出视图 vw_student_courseselection
# ------------------------------------------------------------

DROP TABLE IF EXISTS `vw_student_courseselection`; DROP VIEW IF EXISTS `vw_student_courseselection`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_student_courseselection`
AS SELECT
   `CS`.`student_id` AS `student_id`,
   `Stu`.`name` AS `student_name`,
   `CS`.`course_id` AS `course_id`,
   `S`.`subject_name` AS `subject_name`,
   `S`.`credits` AS `credits`,
   `C`.`semester` AS `semester`,
   `C`.`week_day` AS `week_day`,
   `C`.`start_section` AS `start_section`,
   `C`.`section_count` AS `section_count`
FROM (((`courseselection` `CS` join `student` `Stu` on((`CS`.`student_id` = `Stu`.`student_id`))) join `course` `C` on((`CS`.`course_id` = `C`.`course_id`))) join `subject` `S` on((`C`.`subject_id` = `S`.`subject_id`)));

# 导出视图 vw_student_grades_course_teacher
# ------------------------------------------------------------

DROP TABLE IF EXISTS `vw_student_grades_course_teacher`; DROP VIEW IF EXISTS `vw_student_grades_course_teacher`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_student_grades_course_teacher`
AS SELECT
   `G`.`student_id` AS `student_id`,
   `Stu`.`name` AS `student_name`,
   `G`.`course_id` AS `course_id`,
   `S`.`subject_name` AS `subject_name`,
   `G`.`grade` AS `grade`,
   `T`.`teacher_id` AS `teacher_id`,
   `T`.`name` AS `teacher_name`
FROM ((((`grades` `G` join `student` `Stu` on((`G`.`student_id` = `Stu`.`student_id`))) join `course` `C` on((`G`.`course_id` = `C`.`course_id`))) join `subject` `S` on((`C`.`subject_id` = `S`.`subject_id`))) join `teacher` `T` on((`C`.`teacher_id` = `T`.`teacher_id`)));


/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
