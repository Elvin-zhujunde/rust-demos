# ************************************************************
# Sequel Ace SQL dump
# 版本号： 20077
#
# https://sequel-ace.com/
# https://github.com/Sequel-Ace/Sequel-Ace
#
# 主机: 127.0.0.1 (MySQL 8.4.3)
# 数据库: TeachingManagementSystem
# 生成时间: 2024-12-27 03:29:17 +0000
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



# 转储表 ChatMessage
# ------------------------------------------------------------

DROP TABLE IF EXISTS `ChatMessage`;

CREATE TABLE `ChatMessage` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `course_id` varchar(20) NOT NULL,
  `sender_id` varchar(20) NOT NULL,
  `sender_type` enum('student','teacher') NOT NULL,
  `content` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `chatmessage_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `Course` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `ChatMessage` WRITE;
/*!40000 ALTER TABLE `ChatMessage` DISABLE KEYS */;

INSERT INTO `ChatMessage` (`message_id`, `course_id`, `sender_id`, `sender_type`, `content`, `created_at`)
VALUES
	(1,'CRS020','S2021001','student','123','2024-12-27 11:05:36'),
	(2,'CRS020','S2021001','student','哈哈哈','2024-12-27 11:08:23'),
	(3,'CRS020','T001','teacher','测下','2024-12-27 11:09:53'),
	(4,'CRS020','T001','teacher','哈哈哈','2024-12-27 11:10:03'),
	(5,'CRS058','T001','teacher','1','2024-12-27 11:13:03'),
	(6,'CRS020','S2021002','student','牛逼','2024-12-27 11:14:47'),
	(7,'CRS020','S2021001','student','哈哈哈哈','2024-12-27 11:14:59');

/*!40000 ALTER TABLE `ChatMessage` ENABLE KEYS */;
UNLOCK TABLES;


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


# 转储表 Classroom
# ------------------------------------------------------------

DROP TABLE IF EXISTS `Classroom`;

CREATE TABLE `Classroom` (
  `classroom_id` varchar(20) NOT NULL,
  `building` varchar(50) NOT NULL COMMENT '教学楼',
  `room_number` varchar(20) NOT NULL COMMENT '房间号',
  `capacity` int NOT NULL COMMENT '容纳人数',
  PRIMARY KEY (`classroom_id`),
  UNIQUE KEY `uk_building_room` (`building`,`room_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `Classroom` WRITE;
/*!40000 ALTER TABLE `Classroom` DISABLE KEYS */;

INSERT INTO `Classroom` (`classroom_id`, `building`, `room_number`, `capacity`)
VALUES
	('CR101','第一教学楼','101',120),
	('CR102','第一教学楼','102',80),
	('CR103','第一教学楼','103',80),
	('CR201','第一教学楼','201',60),
	('CR202','第一教学楼','202',60),
	('CR301','第二教学楼','301',100),
	('CR302','第二教学楼','302',100),
	('CR303','第二教学楼','303',80),
	('CR401','第二教学楼','401',60),
	('CR402','第二教学楼','402',60);

/*!40000 ALTER TABLE `Classroom` ENABLE KEYS */;
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
  `classroom_id` varchar(20) DEFAULT NULL,
  `class_hours` enum('16','32','48','64') NOT NULL,
  `week_day` enum('1','2','3','4','5','6','7') NOT NULL COMMENT '周几上课',
  `start_section` int NOT NULL COMMENT '第几节开始上课 1-6',
  `section_count` int DEFAULT '1' COMMENT '连续上几节课',
  PRIMARY KEY (`course_id`),
  KEY `subject_id` (`subject_id`),
  KEY `teacher_id` (`teacher_id`),
  KEY `classroom_id` (`classroom_id`),
  CONSTRAINT `course_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `Subject` (`subject_id`),
  CONSTRAINT `course_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `Teacher` (`teacher_id`),
  CONSTRAINT `course_ibfk_3` FOREIGN KEY (`classroom_id`) REFERENCES `Classroom` (`classroom_id`),
  CONSTRAINT `valid_section` CHECK (((`start_section` between 1 and 6) and (`section_count` = 1)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `Course` WRITE;
/*!40000 ALTER TABLE `Course` DISABLE KEYS */;

INSERT INTO `Course` (`course_id`, `subject_id`, `teacher_id`, `semester`, `student_count`, `max_students`, `classroom_id`, `class_hours`, `week_day`, `start_section`, `section_count`)
VALUES
	('CRS001','S006','T004',1,0,64,'CR101','32','1',5,1),
	('CRS002','S004','T008',1,0,51,'CR102','32','5',4,1),
	('CRS003','S006','T004',2,0,58,'CR102','32','3',4,1),
	('CRS004','S009','T008',1,0,65,'CR103','32','1',6,1),
	('CRS005','S003','T014',2,0,44,'CR303','32','5',4,1),
	('CRS006','S002','T014',1,0,77,'CR401','32','5',2,1),
	('CRS007','S010','T013',1,0,35,'CR101','32','4',5,1),
	('CRS008','S003','T012',1,1,58,'CR401','32','1',3,1),
	('CRS009','S005','T009',1,0,38,'CR101','32','1',3,1),
	('CRS010','S005','T014',1,0,78,'CR102','32','3',1,1),
	('CRS011','S007','T003',2,0,50,'CR103','32','1',3,1),
	('CRS012','S004','T012',2,0,62,'CR101','32','2',2,1),
	('CRS013','S003','T008',2,0,55,'CR303','32','2',1,1),
	('CRS014','S009','T007',2,0,38,'CR201','32','2',2,1),
	('CRS015','S003','T013',2,0,67,'CR402','32','5',2,1),
	('CRS016','S007','T013',1,0,55,'CR303','32','4',6,1),
	('CRS017','S002','T003',1,0,57,'CR401','32','4',6,1),
	('CRS018','S004','T002',1,0,53,'CR102','32','4',6,1),
	('CRS019','S002','T007',2,0,52,'CR101','32','1',2,1),
	('CRS020','S009','T001',1,2,51,'CR101','32','1',1,1),
	('CRS021','S006','T008',2,0,44,'CR401','32','3',2,1),
	('CRS022','S007','T009',2,0,56,'CR401','32','1',6,1),
	('CRS023','S010','T015',1,0,63,'CR301','32','4',6,1),
	('CRS024','S008','T011',1,0,59,'CR301','32','4',1,1),
	('CRS025','S003','T010',1,0,66,'CR302','32','3',3,1),
	('CRS026','S004','T007',1,0,57,'CR202','32','4',3,1),
	('CRS027','S001','T008',2,0,57,'CR102','32','5',3,1),
	('CRS028','S010','T003',2,0,65,'CR103','32','4',4,1),
	('CRS029','S007','T005',1,0,30,'CR401','32','3',5,1),
	('CRS030','S001','T006',2,0,64,'CR201','32','1',5,1),
	('CRS031','S002','T008',1,0,57,'CR401','32','3',4,1),
	('CRS032','S006','T003',1,0,42,'CR102','32','3',6,1),
	('CRS033','S003','T011',2,0,58,'CR101','32','5',4,1),
	('CRS034','S002','T015',1,0,58,'CR102','32','5',1,1),
	('CRS035','S002','T003',1,0,68,'CR202','32','5',2,1),
	('CRS036','S009','T002',2,0,34,'CR201','32','5',5,1),
	('CRS037','S007','T015',2,0,44,'CR402','32','4',5,1),
	('CRS038','S005','T008',1,0,67,'CR303','32','2',4,1),
	('CRS039','S010','T004',2,0,67,'CR303','32','1',1,1),
	('CRS040','S004','T008',1,0,32,'CR401','32','5',5,1),
	('CRS041','S002','T013',2,0,62,'CR102','32','4',4,1),
	('CRS042','S002','T015',1,0,75,'CR401','32','1',6,1),
	('CRS043','S004','T002',2,0,67,'CR302','32','2',5,1),
	('CRS044','S010','T008',2,0,32,'CR301','32','1',5,1),
	('CRS045','S009','T001',2,0,78,'CR202','32','3',3,1),
	('CRS046','S003','T002',2,0,44,'CR401','32','2',1,1),
	('CRS047','S003','T009',1,0,67,'CR101','32','3',2,1),
	('CRS048','S008','T011',1,0,41,'CR202','32','3',5,1),
	('CRS049','S002','T014',1,0,59,'CR301','32','3',3,1),
	('CRS050','S003','T008',2,0,31,'CR302','32','3',6,1),
	('CRS051','S003','T005',2,0,43,'CR401','32','4',1,1),
	('CRS052','S005','T010',2,0,42,'CR302','32','4',4,1),
	('CRS053','S005','T012',1,0,77,'CR201','32','2',2,1),
	('CRS054','S009','T007',2,0,39,'CR401','32','4',4,1),
	('CRS055','S008','T002',1,0,51,'CR301','32','1',5,1),
	('CRS056','S004','T010',2,0,48,'CR102','32','1',3,1),
	('CRS057','S005','T005',1,0,70,'CR202','32','5',6,1),
	('CRS058','S009','T001',2,0,69,'CR102','32','5',6,1),
	('CRS059','S001','T010',1,0,55,'CR402','32','2',3,1),
	('CRS060','S007','T011',2,0,48,'CR103','32','2',5,1),
	('CRS061','S006','T011',2,0,44,'CR101','32','3',4,1),
	('CRS062','S001','T006',2,0,51,'CR401','32','5',4,1),
	('CRS063','S001','T015',2,0,60,'CR302','32','1',5,1),
	('CRS064','S004','T012',2,0,53,'CR401','32','3',3,1),
	('CRS065','S003','T015',2,0,44,'CR201','32','3',5,1),
	('CRS066','S006','T013',2,0,76,'CR102','32','1',5,1),
	('CRS067','S006','T004',1,0,57,'CR101','32','3',1,1),
	('CRS068','S007','T008',2,0,73,'CR301','32','4',2,1),
	('CRS069','S007','T012',2,0,46,'CR101','32','1',6,1),
	('CRS070','S005','T002',1,0,52,'CR101','32','3',5,1),
	('CRS071','S007','T014',2,0,49,'CR401','32','1',2,1),
	('CRS072','S003','T003',1,0,66,'CR302','32','2',2,1),
	('CRS073','S003','T013',2,0,50,'CR101','32','3',2,1),
	('CRS074','S009','T001',2,0,76,'CR102','32','5',5,1),
	('CRS075','S009','T008',2,0,31,'CR301','32','2',3,1),
	('CRS076','S005','T004',2,0,52,'CR402','32','4',3,1),
	('CRS077','S008','T010',2,0,59,'CR401','32','5',6,1),
	('CRS078','S004','T014',1,0,44,'CR301','32','2',5,1),
	('CRS079','S010','T015',2,0,47,'CR303','32','5',2,1),
	('CRS080','S009','T002',2,0,50,'CR102','32','3',2,1),
	('CRS081','S009','T003',1,0,57,'CR102','32','5',3,1),
	('CRS082','S006','T005',2,0,37,'CR402','32','2',4,1),
	('CRS083','S003','T014',2,0,77,'CR102','32','2',2,1),
	('CRS084','S008','T010',1,0,41,'CR401','32','1',5,1),
	('CRS085','S005','T009',1,0,47,'CR402','32','2',5,1),
	('CRS086','S008','T007',1,0,45,'CR402','32','3',5,1),
	('CRS087','S010','T015',2,0,54,'CR303','32','5',3,1),
	('CRS088','S006','T003',1,0,62,'CR302','32','5',1,1),
	('CRS089','S007','T008',2,0,61,'CR201','32','1',2,1),
	('CRS090','S003','T003',1,0,78,'CR201','32','2',5,1),
	('CRS091','S003','T009',1,0,79,'CR201','32','1',5,1),
	('CRS092','S004','T010',1,0,48,'CR103','32','3',5,1),
	('CRS093','S001','T004',2,0,65,'CR402','32','1',4,1),
	('CRS094','S010','T011',2,0,71,'CR103','32','4',3,1),
	('CRS095','S003','T014',2,0,36,'CR201','32','2',6,1),
	('CRS096','S002','T003',1,0,65,'CR401','32','3',2,1),
	('CRS097','S001','T005',1,0,47,'CR302','32','4',6,1),
	('CRS098','S009','T003',1,0,37,'CR301','32','1',4,1),
	('CRS099','S007','T014',2,0,73,'CR401','32','5',2,1),
	('CRS100','S004','T015',2,0,37,'CR402','32','5',5,1),
	('CRS901','S001','T001',1,0,60,'CR101','64','1',1,1),
	('CRS902','S002','T002',1,0,60,'CR102','48','2',3,1),
	('CRS903','S003','T003',1,0,60,'CR103','48','3',5,1),
	('CRS904','S001','T004',1,1,60,'CR201','64','1',2,1),
	('CRS905','S002','T005',1,0,60,'CR202','48','2',4,1),
	('CRS906','S003','T006',1,0,60,'CR301','48','3',6,1);

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
	('S2021001','CRS020','2024-12-27 10:53:35'),
	('S2021002','CRS008','2024-12-27 11:19:00'),
	('S2021002','CRS020','2024-12-27 11:14:37'),
	('S2021002','CRS904','2024-12-27 11:18:58');

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
	(1,'system','select','2024-12-27 10:53:31','course','CRS030','select operation on course'),
	(2,'system','select','2024-12-27 10:53:31','course','CRS030','select operation on course'),
	(3,'system','select','2024-12-27 10:53:32','student-courses','S2021001','select operation on student-courses'),
	(4,'system','select','2024-12-27 10:53:33','available-courses',NULL,'select operation on available-courses'),
	(5,'system','create','2024-12-27 10:53:35','select-course',NULL,'create operation on select-course'),
	(6,'system','select','2024-12-27 10:53:35','available-courses',NULL,'select operation on available-courses'),
	(7,'system','select','2024-12-27 10:53:36','student-courses','S2021001','select operation on student-courses'),
	(8,'system','select','2024-12-27 10:53:36','course','CRS020','select operation on course'),
	(9,'system','select','2024-12-27 10:53:36','course','CRS020','select operation on course'),
	(10,'system','select','2024-12-27 10:56:18','course','CRS020','select operation on course'),
	(11,'system','select','2024-12-27 10:56:18','course','CRS020','select operation on course'),
	(12,'system','select','2024-12-27 10:56:19','available-courses',NULL,'select operation on available-courses'),
	(13,'system','select','2024-12-27 10:56:19','student-courses','S2021001','select operation on student-courses'),
	(14,'system','select','2024-12-27 10:56:20','course','CRS020','select operation on course'),
	(15,'system','select','2024-12-27 10:56:20','course','CRS020','select operation on course'),
	(16,'system','select','2024-12-27 10:56:32','course','CRS020','select operation on course'),
	(17,'system','select','2024-12-27 10:56:32','course','CRS020','select operation on course'),
	(18,'system','select','2024-12-27 10:56:39','course','CRS020','select operation on course'),
	(19,'system','select','2024-12-27 10:56:39','course','CRS020','select operation on course'),
	(20,'system','select','2024-12-27 10:56:40','student-courses','S2021001','select operation on student-courses'),
	(21,'system','create','2024-12-27 10:56:52','login',NULL,'create operation on login'),
	(22,'system','select','2024-12-27 10:56:53','available-courses',NULL,'select operation on available-courses'),
	(23,'system','select','2024-12-27 10:56:54','student-courses','S2021001','select operation on student-courses'),
	(24,'system','select','2024-12-27 10:56:55','course','CRS020','select operation on course'),
	(25,'system','select','2024-12-27 10:56:55','course','CRS020','select operation on course'),
	(26,'system','select','2024-12-27 11:01:13','course','CRS020','select operation on course'),
	(27,'system','select','2024-12-27 11:01:13','course','CRS020','select operation on course'),
	(28,'system','select','2024-12-27 11:01:14','course','CRS020','select operation on course'),
	(29,'system','select','2024-12-27 11:01:14','course','CRS020','select operation on course'),
	(30,'system','select','2024-12-27 11:01:36','course','CRS020','select operation on course'),
	(31,'system','select','2024-12-27 11:01:36','course','CRS020','select operation on course'),
	(32,'system','select','2024-12-27 11:01:37','available-courses',NULL,'select operation on available-courses'),
	(33,'system','select','2024-12-27 11:01:37','available-courses',NULL,'select operation on available-courses'),
	(34,'system','select','2024-12-27 11:01:38','student-courses','S2021001','select operation on student-courses'),
	(35,'system','select','2024-12-27 11:01:39','course','CRS020','select operation on course'),
	(36,'system','select','2024-12-27 11:01:39','course','CRS020','select operation on course'),
	(37,'system','select','2024-12-27 11:01:40','course','CRS020','select operation on course'),
	(38,'system','select','2024-12-27 11:01:40','course','CRS020','select operation on course'),
	(39,'system','select','2024-12-27 11:02:19','available-courses',NULL,'select operation on available-courses'),
	(40,'system','select','2024-12-27 11:02:20','student-courses','S2021001','select operation on student-courses'),
	(41,'system','select','2024-12-27 11:02:37','student-courses','S2021001','select operation on student-courses'),
	(42,'system','select','2024-12-27 11:02:39','available-courses',NULL,'select operation on available-courses'),
	(43,'system','select','2024-12-27 11:02:40','student-courses','S2021001','select operation on student-courses'),
	(44,'system','select','2024-12-27 11:03:33','student-courses','S2021001','select operation on student-courses'),
	(45,'system','select','2024-12-27 11:03:33','course','CRS020','select operation on course'),
	(46,'system','select','2024-12-27 11:03:33','course','CRS020','select operation on course'),
	(47,'system','select','2024-12-27 11:03:35','available-courses',NULL,'select operation on available-courses'),
	(48,'system','select','2024-12-27 11:03:39','student-courses','S2021001','select operation on student-courses'),
	(49,'system','select','2024-12-27 11:03:39','course','CRS020','select operation on course'),
	(50,'system','select','2024-12-27 11:03:39','course','CRS020','select operation on course'),
	(51,'system','select','2024-12-27 11:04:56','course','CRS020','select operation on course'),
	(52,'system','select','2024-12-27 11:04:56','course','CRS020','select operation on course'),
	(53,'system','select','2024-12-27 11:05:20','course','CRS020','select operation on course'),
	(54,'system','select','2024-12-27 11:05:20','course','CRS020','select operation on course'),
	(55,'system','select','2024-12-27 11:05:32','course','CRS020','select operation on course'),
	(56,'system','select','2024-12-27 11:05:32','course','CRS020','select operation on course'),
	(57,'system','select','2024-12-27 11:05:38','course','CRS020','select operation on course'),
	(58,'system','select','2024-12-27 11:05:38','course','CRS020','select operation on course'),
	(59,'system','create','2024-12-27 11:05:53','login',NULL,'create operation on login'),
	(60,'system','select','2024-12-27 11:05:54','teacher-students','T001','select operation on teacher-students'),
	(61,'system','select','2024-12-27 11:05:55','teacher-courses','T001','select operation on teacher-courses'),
	(62,'system','select','2024-12-27 11:05:56','course','CRS045','select operation on course'),
	(63,'system','select','2024-12-27 11:05:56','course','CRS045','select operation on course'),
	(64,'system','select','2024-12-27 11:05:59','course','CRS045','select operation on course'),
	(65,'system','select','2024-12-27 11:05:59','course','CRS045','select operation on course'),
	(66,'system','select','2024-12-27 11:05:59','course','CRS020','select operation on course'),
	(67,'system','select','2024-12-27 11:05:59','course','CRS020','select operation on course'),
	(68,'system','select','2024-12-27 11:05:59','teacher-courses','T001','select operation on teacher-courses'),
	(69,'system','select','2024-12-27 11:06:01','course','CRS901','select operation on course'),
	(70,'system','select','2024-12-27 11:06:01','course','CRS901','select operation on course'),
	(71,'system','select','2024-12-27 11:06:04','teacher-courses','T001','select operation on teacher-courses'),
	(72,'system','select','2024-12-27 11:06:11','available-courses',NULL,'select operation on available-courses'),
	(73,'system','select','2024-12-27 11:06:11','student-courses','S2021001','select operation on student-courses'),
	(74,'system','select','2024-12-27 11:06:17','course','CRS020','select operation on course'),
	(75,'system','select','2024-12-27 11:06:17','course','CRS020','select operation on course'),
	(76,'system','select','2024-12-27 11:06:35','course','CRS020','select operation on course'),
	(77,'system','select','2024-12-27 11:06:35','course','CRS020','select operation on course'),
	(78,'system','select','2024-12-27 11:06:54','course','CRS020','select operation on course'),
	(79,'system','select','2024-12-27 11:06:54','course','CRS020','select operation on course'),
	(80,'system','select','2024-12-27 11:08:19','student-courses','S2021001','select operation on student-courses'),
	(81,'system','select','2024-12-27 11:08:20','course','CRS020','select operation on course'),
	(82,'system','select','2024-12-27 11:08:20','course','CRS020','select operation on course'),
	(83,'system','select','2024-12-27 11:08:31','teacher-courses','T001','select operation on teacher-courses'),
	(84,'system','select','2024-12-27 11:09:04','course','CRS020','select operation on course'),
	(85,'system','select','2024-12-27 11:09:04','course','CRS020','select operation on course'),
	(86,'system','select','2024-12-27 11:09:30','course','CRS020','select operation on course'),
	(87,'system','select','2024-12-27 11:09:30','course','CRS020','select operation on course'),
	(88,'system','select','2024-12-27 11:09:48','course','CRS020','select operation on course'),
	(89,'system','select','2024-12-27 11:09:48','course','CRS020','select operation on course'),
	(90,'system','select','2024-12-27 11:11:17','course','CRS020','select operation on course'),
	(91,'system','select','2024-12-27 11:11:17','course','CRS020','select operation on course'),
	(92,'system','select','2024-12-27 11:11:17','course','CRS020','select operation on course'),
	(93,'system','select','2024-12-27 11:11:17','course','CRS020','select operation on course'),
	(94,'system','select','2024-12-27 11:12:02','course','CRS020','select operation on course'),
	(95,'system','select','2024-12-27 11:12:02','course','CRS020','select operation on course'),
	(96,'system','select','2024-12-27 11:12:04','student-courses','S2021001','select operation on student-courses'),
	(97,'system','select','2024-12-27 11:12:05','course','CRS020','select operation on course'),
	(98,'system','select','2024-12-27 11:12:05','course','CRS020','select operation on course'),
	(99,'system','select','2024-12-27 11:12:57','teacher-students','T001','select operation on teacher-students'),
	(100,'system','select','2024-12-27 11:12:59','teacher-courses','T001','select operation on teacher-courses'),
	(101,'system','select','2024-12-27 11:13:00','course','CRS058','select operation on course'),
	(102,'system','select','2024-12-27 11:13:00','course','CRS058','select operation on course'),
	(103,'system','select','2024-12-27 11:13:04','teacher-students','T001','select operation on teacher-students'),
	(104,'system','select','2024-12-27 11:13:06','teacher-courses','T001','select operation on teacher-courses'),
	(105,'system','select','2024-12-27 11:13:09','course','CRS020','select operation on course'),
	(106,'system','select','2024-12-27 11:13:09','course','CRS020','select operation on course'),
	(107,'system','select','2024-12-27 11:13:21','teacher-courses','T001','select operation on teacher-courses'),
	(108,'system','select','2024-12-27 11:13:22','course','CRS020','select operation on course'),
	(109,'system','select','2024-12-27 11:13:22','course','CRS020','select operation on course'),
	(110,'system','select','2024-12-27 11:13:27','course','CRS020','select operation on course'),
	(111,'system','select','2024-12-27 11:13:27','course','CRS020','select operation on course'),
	(112,'system','select','2024-12-27 11:14:15','teacher-courses','T001','select operation on teacher-courses'),
	(113,'system','select','2024-12-27 11:14:24','course','CRS020','select operation on course'),
	(114,'system','select','2024-12-27 11:14:24','course','CRS020','select operation on course'),
	(115,'system','create','2024-12-27 11:14:33','login',NULL,'create operation on login'),
	(116,'system','select','2024-12-27 11:14:34','available-courses',NULL,'select operation on available-courses'),
	(117,'system','create','2024-12-27 11:14:37','select-course',NULL,'create operation on select-course'),
	(118,'system','select','2024-12-27 11:14:37','available-courses',NULL,'select operation on available-courses'),
	(119,'system','select','2024-12-27 11:14:39','student-courses','S2021002','select operation on student-courses'),
	(120,'system','select','2024-12-27 11:14:39','course','CRS020','select operation on course'),
	(121,'system','select','2024-12-27 11:14:39','course','CRS020','select operation on course'),
	(122,'system','select','2024-12-27 11:14:54','available-courses',NULL,'select operation on available-courses'),
	(123,'system','select','2024-12-27 11:17:41','available-courses',NULL,'select operation on available-courses'),
	(124,'system','select','2024-12-27 11:18:55','available-courses',NULL,'select operation on available-courses'),
	(125,'system','create','2024-12-27 11:18:58','select-course',NULL,'create operation on select-course'),
	(126,'system','select','2024-12-27 11:18:58','available-courses',NULL,'select operation on available-courses'),
	(127,'system','create','2024-12-27 11:19:00','select-course',NULL,'create operation on select-course'),
	(128,'system','select','2024-12-27 11:19:00','available-courses',NULL,'select operation on available-courses'),
	(129,'system','select','2024-12-27 11:19:01','student-courses','S2021002','select operation on student-courses'),
	(130,'system','select','2024-12-27 11:19:10','student-courses','S2021002','select operation on student-courses'),
	(131,'system','select','2024-12-27 11:19:24','student-courses','S2021001','select operation on student-courses'),
	(132,'system','select','2024-12-27 11:19:27','course','CRS020','select operation on course'),
	(133,'system','select','2024-12-27 11:19:27','course','CRS020','select operation on course'),
	(134,'system','create','2024-12-27 11:19:37','login',NULL,'create operation on login'),
	(135,'system','select','2024-12-27 11:19:38','teacher-students','T001','select operation on teacher-students'),
	(136,'system','select','2024-12-27 11:19:41','teacher-courses','T001','select operation on teacher-courses'),
	(137,'system','select','2024-12-27 11:19:41','teacher-students','T001','select operation on teacher-students'),
	(138,'system','select','2024-12-27 11:19:42','teacher-courses','T001','select operation on teacher-courses'),
	(139,'system','select','2024-12-27 11:19:44','teacher-students','T001','select operation on teacher-students'),
	(140,'system','select','2024-12-27 11:19:45','departments',NULL,'select operation on departments'),
	(141,'system','select','2024-12-27 11:19:48','teacher-student-courses','T001','select operation on teacher-student-courses'),
	(142,'system','select','2024-12-27 11:19:50','teacher-courses','T001','select operation on teacher-courses'),
	(143,'system','select','2024-12-27 11:19:57','course','CRS020','select operation on course'),
	(144,'system','select','2024-12-27 11:19:57','course','CRS020','select operation on course'),
	(145,'system','select','2024-12-27 11:19:58','course','CRS020','select operation on course'),
	(146,'system','select','2024-12-27 11:19:58','course','CRS020','select operation on course'),
	(147,'system','select','2024-12-27 11:19:59','teacher-courses','T001','select operation on teacher-courses'),
	(148,'system','select','2024-12-27 11:20:00','course','CRS020','select operation on course'),
	(149,'system','select','2024-12-27 11:20:00','course','CRS020','select operation on course'),
	(150,'system','select','2024-12-27 11:20:03','teacher-students','T001','select operation on teacher-students'),
	(151,'system','select','2024-12-27 11:20:04','teacher-courses','T001','select operation on teacher-courses'),
	(152,'system','select','2024-12-27 11:20:06','course-students','CRS020','select operation on course-students'),
	(153,'system','select','2024-12-27 11:20:09','course','CRS020','select operation on course'),
	(154,'system','select','2024-12-27 11:20:09','course','CRS020','select operation on course'),
	(155,'system','create','2024-12-27 11:20:21','task',NULL,'create operation on task'),
	(156,'system','select','2024-12-27 11:20:21','course','CRS020','select operation on course'),
	(157,'system','select','2024-12-27 11:20:26','course','CRS020','select operation on course'),
	(158,'system','select','2024-12-27 11:20:26','course','CRS020','select operation on course'),
	(159,'system','select','2024-12-27 11:20:27','task','1','select operation on task'),
	(160,'system','select','2024-12-27 11:20:27','task','1','select operation on task');

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
	('S2021001','刘洋','123456','男','liuyang@example.com','北京市朝阳区','D001','本科','2021-09-01','M001','C001',1,3.00,0.00),
	('S2021002','王芳','123456','女','wangfang@example.com','上海市黄浦区','D001','本科','2021-09-01','M001','C002',1,10.00,0.00),
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


# 转储表 TaskSubmission
# ------------------------------------------------------------

DROP TABLE IF EXISTS `TaskSubmission`;

CREATE TABLE `TaskSubmission` (
  `submission_id` int NOT NULL AUTO_INCREMENT,
  `task_id` int NOT NULL,
  `student_id` varchar(20) NOT NULL,
  `submission_content` text,
  `attachment_url` varchar(255) DEFAULT NULL,
  `score` int DEFAULT NULL,
  `feedback` text,
  `submitted_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`submission_id`),
  UNIQUE KEY `unique_submission` (`task_id`,`student_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `tasksubmission_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `TeachingTask` (`task_id`) ON DELETE CASCADE,
  CONSTRAINT `tasksubmission_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `Student` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `tasksubmission_chk_1` CHECK (((`score` >= 0) and (`score` <= 100)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `check_submission_time` BEFORE INSERT ON `TaskSubmission` FOR EACH ROW BEGIN
  DECLARE task_status VARCHAR(10);
  DECLARE task_end_time DATETIME;
  
  SELECT status, end_time INTO task_status, task_end_time
  FROM TeachingTask
  WHERE task_id = NEW.task_id;
  
  IF task_status = 'closed' OR CURRENT_TIMESTAMP > task_end_time THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = '作业已截止，不能提交';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


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


# 转储表 TeachingTask
# ------------------------------------------------------------

DROP TABLE IF EXISTS `TeachingTask`;

CREATE TABLE `TeachingTask` (
  `task_id` int NOT NULL AUTO_INCREMENT,
  `course_id` varchar(20) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text,
  `weight` int NOT NULL,
  `attachment_url` varchar(255) DEFAULT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `status` enum('active','closed') DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`task_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `teachingtask_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `Course` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `teachingtask_chk_1` CHECK (((`weight` >= 0) and (`weight` <= 100)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `TeachingTask` WRITE;
/*!40000 ALTER TABLE `TeachingTask` DISABLE KEYS */;

INSERT INTO `TeachingTask` (`task_id`, `course_id`, `title`, `description`, `weight`, `attachment_url`, `start_time`, `end_time`, `status`, `created_at`, `updated_at`)
VALUES
	(1,'CRS020','1','2',10,'','2024-12-26 03:20:14','2024-12-28 03:20:18','active','2024-12-27 11:20:21','2024-12-27 11:20:21');

/*!40000 ALTER TABLE `TeachingTask` ENABLE KEYS */;
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
