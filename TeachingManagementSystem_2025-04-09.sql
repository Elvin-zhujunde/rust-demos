# ************************************************************
# Sequel Ace SQL dump
# 版本号： 20077
#
# https://sequel-ace.com/
# https://github.com/Sequel-Ace/Sequel-Ace
#
# 主机: 127.0.0.1 (MySQL 8.4.3)
# 数据库: TeachingManagementSystem
# 生成时间: 2025-04-09 14:38:29 +0000
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
	(7,'CRS020','S2021001','student','哈哈哈哈','2024-12-27 11:14:59'),
	(8,'CRS904','S2021001','student','1','2025-04-05 14:30:32');

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
	('CRS089','S007','T008',2,1,61,'CR201','32','1',2,1),
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


# 转储表 CourseEvaluation
# ------------------------------------------------------------

DROP TABLE IF EXISTS `CourseEvaluation`;

CREATE TABLE `CourseEvaluation` (
  `evaluation_id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(20) NOT NULL,
  `course_id` varchar(20) NOT NULL,
  `teacher_id` varchar(20) NOT NULL,
  `rating` int NOT NULL COMMENT '评分1-5星',
  `content` text NOT NULL COMMENT '评价内容',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`evaluation_id`),
  UNIQUE KEY `unique_evaluation` (`student_id`,`course_id`) COMMENT '每个学生只能评价同一门课程一次',
  KEY `course_id` (`course_id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `courseevaluation_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `Student` (`student_id`),
  CONSTRAINT `courseevaluation_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `Course` (`course_id`),
  CONSTRAINT `courseevaluation_ibfk_3` FOREIGN KEY (`teacher_id`) REFERENCES `Teacher` (`teacher_id`),
  CONSTRAINT `courseevaluation_chk_1` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `CourseEvaluation` WRITE;
/*!40000 ALTER TABLE `CourseEvaluation` DISABLE KEYS */;

INSERT INTO `CourseEvaluation` (`evaluation_id`, `student_id`, `course_id`, `teacher_id`, `rating`, `content`, `created_at`)
VALUES
	(2,'S2021001','CRS020','T001',5,'非常nice啊','2025-04-06 15:37:39');

/*!40000 ALTER TABLE `CourseEvaluation` ENABLE KEYS */;
UNLOCK TABLES;


# 转储表 CourseSelection
# ------------------------------------------------------------

DROP TABLE IF EXISTS `CourseSelection`;

CREATE TABLE `CourseSelection` (
  `student_id` varchar(20) NOT NULL,
  `course_id` varchar(20) NOT NULL,
  `status` varchar(3) DEFAULT NULL,
  `selection_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`student_id`,`course_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `courseselection_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `Student` (`student_id`),
  CONSTRAINT `courseselection_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `Course` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `CourseSelection` WRITE;
/*!40000 ALTER TABLE `CourseSelection` DISABLE KEYS */;

INSERT INTO `CourseSelection` (`student_id`, `course_id`, `status`, `selection_date`)
VALUES
	('S2021001','CRS020','2','2025-04-06 15:33:11'),
	('S2021001','CRS089','0','2025-04-06 15:47:01'),
	('S2021002','CRS008','0','2024-12-27 11:19:00'),
	('S2021002','CRS020','0','2024-12-27 11:14:37'),
	('S2021002','CRS904','0','2024-12-27 11:18:58');

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
	('S2021001','CRS020',99.00),
	('S2021002','CRS020',99.00);

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
	(160,'system','select','2024-12-27 11:20:27','task','1','select operation on task'),
	(161,'system','select','2024-12-27 14:11:25','available-courses',NULL,'select operation on available-courses'),
	(162,'system','select','2024-12-27 14:11:56','student','S2021001','select operation on student'),
	(163,'system','select','2024-12-27 14:11:59','available-courses',NULL,'select operation on available-courses'),
	(164,'system','select','2024-12-27 14:11:59','student-courses','S2021001','select operation on student-courses'),
	(165,'system','select','2024-12-27 14:12:01','course','CRS020','select operation on course'),
	(166,'system','select','2024-12-27 14:12:01','course','CRS020','select operation on course'),
	(167,'system','select','2024-12-27 14:12:52','available-courses',NULL,'select operation on available-courses'),
	(168,'system','create','2024-12-27 14:13:07','login',NULL,'create operation on login'),
	(169,'system','select','2024-12-27 14:13:08','teacher-courses','T001','select operation on teacher-courses'),
	(170,'system','select','2024-12-27 14:13:22','course','CRS045','select operation on course'),
	(171,'system','select','2024-12-27 14:13:22','course','CRS045','select operation on course'),
	(172,'system','select','2024-12-27 14:13:42','teacher-students','T001','select operation on teacher-students'),
	(173,'system','select','2024-12-27 14:13:57','teacher','T001','select operation on teacher'),
	(174,'system','select','2024-12-27 14:13:59','teacher-courses','T001','select operation on teacher-courses'),
	(175,'system','select','2024-12-27 14:14:00','teacher-schedule','T001','select operation on teacher-schedule'),
	(176,'system','select','2024-12-27 14:16:00','teacher-students','T001','select operation on teacher-students'),
	(177,'system','select','2024-12-27 14:16:02','teacher-student-courses','T001','select operation on teacher-student-courses'),
	(178,'system','select','2024-12-27 14:16:06','teacher-student-courses','T001','select operation on teacher-student-courses'),
	(179,'system','select','2024-12-27 14:16:08','teacher-student-courses','T001','select operation on teacher-student-courses'),
	(180,'system','select','2024-12-27 14:16:25','teacher','T001','select operation on teacher'),
	(181,'system','select','2024-12-27 14:16:39','teacher-courses','T001','select operation on teacher-courses'),
	(182,'system','select','2024-12-27 14:16:39','teacher-students','T001','select operation on teacher-students'),
	(183,'system','select','2024-12-27 14:16:40','teacher','T001','select operation on teacher'),
	(184,'system','select','2024-12-27 15:11:53','departments',NULL,'select operation on departments'),
	(185,'system','select','2024-12-27 15:15:26','departments',NULL,'select operation on departments'),
	(186,'system','select','2024-12-27 15:15:27','departments',NULL,'select operation on departments'),
	(187,'system','select','2024-12-27 15:15:29','departments',NULL,'select operation on departments'),
	(188,'system','create','2024-12-27 15:19:01','login',NULL,'create operation on login'),
	(189,'system','select','2024-12-27 15:19:05','departments',NULL,'select operation on departments'),
	(190,'system','select','2024-12-27 15:19:13','departments',NULL,'select operation on departments'),
	(191,'system','select','2024-12-27 15:19:20','departments',NULL,'select operation on departments'),
	(192,'system','select','2024-12-27 15:22:01','departments',NULL,'select operation on departments'),
	(193,'system','select','2024-12-27 15:22:34','departments',NULL,'select operation on departments'),
	(194,'system','select','2024-12-27 15:22:44','departments',NULL,'select operation on departments'),
	(195,'system','select','2024-12-27 15:22:45','departments',NULL,'select operation on departments'),
	(196,'system','select','2024-12-27 15:22:55','departments',NULL,'select operation on departments'),
	(197,'system','select','2024-12-27 15:22:59','departments',NULL,'select operation on departments'),
	(198,'system','select','2024-12-27 15:23:19','departments',NULL,'select operation on departments'),
	(199,'system','select','2024-12-30 15:20:30','departments',NULL,'select operation on departments'),
	(200,'system','select','2024-12-30 15:20:53','majors',NULL,'select operation on majors'),
	(201,'system','select','2024-12-30 15:20:54','classes',NULL,'select operation on classes'),
	(202,'system','create','2024-12-30 15:20:56','register',NULL,'create operation on register'),
	(203,'system','create','2024-12-30 15:21:03','login',NULL,'create operation on login'),
	(204,'system','select','2024-12-30 15:21:04','available-courses',NULL,'select operation on available-courses'),
	(205,'system','select','2024-12-30 15:21:05','student-courses','S0001','select operation on student-courses'),
	(206,'system','select','2024-12-30 15:21:06','student','S0001','select operation on student'),
	(207,'system','select','2024-12-30 21:26:19','available-courses',NULL,'select operation on available-courses'),
	(208,'system','select','2024-12-30 21:26:19','available-courses',NULL,'select operation on available-courses'),
	(209,'system','select','2024-12-30 21:26:21','student-courses','S0001','select operation on student-courses'),
	(210,'system','select','2024-12-30 21:26:21','available-courses',NULL,'select operation on available-courses'),
	(211,'system','select','2024-12-30 21:28:12','student-courses','S0001','select operation on student-courses'),
	(212,'system','select','2024-12-30 21:28:13','available-courses',NULL,'select operation on available-courses'),
	(213,'system','select','2024-12-30 21:28:29','available-courses',NULL,'select operation on available-courses'),
	(214,'system','select','2024-12-30 21:28:30','available-courses',NULL,'select operation on available-courses'),
	(215,'system','create','2024-12-30 21:30:00','login',NULL,'create operation on login'),
	(216,'system','select','2024-12-30 21:30:02','teacher-courses','T001','select operation on teacher-courses'),
	(217,'system','select','2024-12-30 21:30:03','course','CRS045','select operation on course'),
	(218,'system','select','2024-12-30 21:30:03','course','CRS045','select operation on course'),
	(219,'system','select','2024-12-30 21:30:18','teacher-students','T001','select operation on teacher-students'),
	(220,'system','select','2024-12-30 21:30:21','teacher-courses','T001','select operation on teacher-courses'),
	(221,'system','select','2024-12-30 21:30:22','course','CRS058','select operation on course'),
	(222,'system','select','2024-12-30 21:30:22','course','CRS058','select operation on course'),
	(223,'system','select','2024-12-30 21:30:46','teacher-courses','T001','select operation on teacher-courses'),
	(224,'system','select','2024-12-30 21:30:46','teacher-students','T001','select operation on teacher-students'),
	(225,'system','select','2024-12-30 21:30:47','teacher','T001','select operation on teacher'),
	(226,'system','create','2024-12-30 21:32:20','login',NULL,'create operation on login'),
	(227,'system','create','2024-12-30 21:32:42','login',NULL,'create operation on login'),
	(228,'system','create','2024-12-30 21:33:19','login',NULL,'create operation on login'),
	(229,'system','select','2024-12-30 21:33:20','teacher-students','T001','select operation on teacher-students'),
	(230,'system','select','2024-12-30 21:33:21','teacher-courses','T001','select operation on teacher-courses'),
	(231,'system','select','2024-12-30 21:33:22','course','CRS045','select operation on course'),
	(232,'system','select','2024-12-30 21:33:22','course','CRS045','select operation on course'),
	(233,'system','select','2024-12-30 21:33:30','teacher-students','T001','select operation on teacher-students'),
	(234,'system','select','2024-12-30 21:33:31','teacher-courses','T001','select operation on teacher-courses'),
	(235,'system','select','2024-12-30 21:33:32','course-students','CRS045','select operation on course-students'),
	(236,'system','select','2024-12-30 21:33:35','teacher-students','T001','select operation on teacher-students'),
	(237,'system','select','2024-12-30 21:33:36','teacher-courses','T001','select operation on teacher-courses'),
	(238,'system','select','2024-12-30 21:33:37','course','CRS045','select operation on course'),
	(239,'system','select','2024-12-30 21:33:37','course-grades','CRS045','select operation on course-grades'),
	(240,'system','select','2024-12-30 21:36:27','course','CRS045','select operation on course'),
	(241,'system','select','2024-12-30 21:36:27','course-grades','CRS045','select operation on course-grades'),
	(242,'system','create','2024-12-31 11:25:28','login',NULL,'create operation on login'),
	(243,'system','select','2024-12-31 11:25:30','available-courses',NULL,'select operation on available-courses'),
	(244,'system','select','2024-12-31 11:25:31','student-courses','S2021001','select operation on student-courses'),
	(245,'system','select','2024-12-31 11:25:33','student-courses','S2021001','select operation on student-courses'),
	(246,'system','select','2024-12-31 11:25:34','available-courses',NULL,'select operation on available-courses'),
	(247,'system','select','2024-12-31 11:25:34','student-courses','S2021001','select operation on student-courses'),
	(248,'system','select','2024-12-31 11:25:35','student','S2021001','select operation on student'),
	(249,'system','create','2024-12-31 11:25:48','login',NULL,'create operation on login'),
	(250,'system','select','2024-12-31 11:25:49','student','S2021001','select operation on student'),
	(251,'system','select','2024-12-31 11:25:50','student-courses','S2021001','select operation on student-courses'),
	(252,'system','select','2024-12-31 11:25:50','available-courses',NULL,'select operation on available-courses'),
	(253,'system','select','2024-12-31 11:25:51','student-courses','S2021001','select operation on student-courses'),
	(254,'system','create','2024-12-31 11:26:04','login',NULL,'create operation on login'),
	(255,'system','select','2024-12-31 11:26:05','teacher-courses','T001','select operation on teacher-courses'),
	(256,'system','select','2024-12-31 11:26:05','teacher-students','T001','select operation on teacher-students'),
	(257,'system','select','2024-12-31 11:26:06','teacher','T001','select operation on teacher'),
	(258,'system','select','2024-12-31 11:26:08','teacher-students','T001','select operation on teacher-students'),
	(259,'system','select','2024-12-31 11:26:09','teacher-courses','T001','select operation on teacher-courses'),
	(260,'system','select','2024-12-31 11:27:56','departments',NULL,'select operation on departments'),
	(261,'system','select','2024-12-31 11:28:15','departments',NULL,'select operation on departments'),
	(262,'system','select','2024-12-31 11:28:44','departments',NULL,'select operation on departments'),
	(263,'system','select','2024-12-31 11:28:52','departments',NULL,'select operation on departments'),
	(264,'system','select','2024-12-31 11:30:14','departments',NULL,'select operation on departments'),
	(265,'system','select','2024-12-31 11:30:19','departments',NULL,'select operation on departments'),
	(266,'system','select','2024-12-31 11:30:27','departments',NULL,'select operation on departments'),
	(267,'system','create','2024-12-31 11:30:42','login',NULL,'create operation on login'),
	(268,'system','select','2024-12-31 11:30:43','available-courses',NULL,'select operation on available-courses'),
	(269,'system','select','2024-12-31 11:30:44','student-courses','S2021001','select operation on student-courses'),
	(270,'system','select','2024-12-31 11:30:44','student','S2021001','select operation on student'),
	(271,'system','select','2024-12-31 11:30:44','student-courses','S2021001','select operation on student-courses'),
	(272,'system','select','2024-12-31 11:30:45','course','CRS020','select operation on course'),
	(273,'system','select','2024-12-31 11:30:45','course','CRS020','select operation on course'),
	(274,'system','select','2024-12-31 11:30:47','student-courses','S2021001','select operation on student-courses'),
	(275,'system','select','2024-12-31 11:31:24','available-courses',NULL,'select operation on available-courses'),
	(276,'system','select','2024-12-31 11:31:25','student-courses','S2021001','select operation on student-courses'),
	(277,'system','select','2024-12-31 11:31:34','course','CRS020','select operation on course'),
	(278,'system','select','2024-12-31 11:31:34','course','CRS020','select operation on course'),
	(279,'system','select','2024-12-31 11:31:36','student-courses','S2021001','select operation on student-courses'),
	(280,'system','select','2024-12-31 11:31:52','available-courses',NULL,'select operation on available-courses'),
	(281,'system','create','2024-12-31 11:32:08','login',NULL,'create operation on login'),
	(282,'system','select','2024-12-31 11:32:10','teacher-courses','T001','select operation on teacher-courses'),
	(283,'system','select','2024-12-31 11:32:12','course-students','CRS074','select operation on course-students'),
	(284,'system','select','2024-12-31 11:34:33','teacher-courses','T001','select operation on teacher-courses'),
	(285,'system','select','2024-12-31 11:35:11','teacher-courses','T001','select operation on teacher-courses'),
	(286,'system','select','2024-12-31 11:35:13','course-students','CRS045','select operation on course-students'),
	(287,'system','select','2024-12-31 11:35:16','course','CRS020','select operation on course'),
	(288,'system','select','2024-12-31 11:35:16','course','CRS020','select operation on course'),
	(289,'system','select','2024-12-31 11:35:18','teacher-courses','T001','select operation on teacher-courses'),
	(290,'system','select','2024-12-31 11:35:20','course-students','CRS020','select operation on course-students'),
	(291,'system','select','2024-12-31 11:35:47','course-students','CRS020','select operation on course-students'),
	(292,'system','select','2024-12-31 11:35:56','course','CRS020','select operation on course'),
	(293,'system','select','2024-12-31 11:35:56','course','CRS020','select operation on course'),
	(294,'system','select','2024-12-31 11:35:58','teacher-courses','T001','select operation on teacher-courses'),
	(295,'system','select','2024-12-31 11:35:59','course','CRS020','select operation on course'),
	(296,'system','select','2024-12-31 11:35:59','course','CRS020','select operation on course'),
	(297,'system','select','2024-12-31 11:36:00','teacher-courses','T001','select operation on teacher-courses'),
	(298,'system','select','2024-12-31 11:36:01','course-students','CRS020','select operation on course-students'),
	(299,'system','select','2024-12-31 11:36:21','course-students','CRS020','select operation on course-students'),
	(300,'system','select','2024-12-31 11:36:43','teacher-courses','T001','select operation on teacher-courses'),
	(301,'system','select','2024-12-31 11:36:44','course-students','CRS020','select operation on course-students'),
	(302,'system','select','2024-12-31 11:37:05','teacher-courses','T001','select operation on teacher-courses'),
	(303,'system','select','2024-12-31 11:37:16','course','CRS020','select operation on course'),
	(304,'system','select','2024-12-31 11:37:16','course','CRS020','select operation on course'),
	(305,'system','select','2024-12-31 11:37:27','course','CRS020','select operation on course'),
	(306,'system','select','2024-12-31 11:37:27','course','CRS020','select operation on course'),
	(307,'system','select','2024-12-31 11:38:56','course','CRS020','select operation on course'),
	(308,'system','select','2024-12-31 11:38:56','course','CRS020','select operation on course'),
	(309,'system','select','2024-12-31 11:39:12','teacher-courses','T001','select operation on teacher-courses'),
	(310,'system','select','2024-12-31 11:39:13','course','CRS058','select operation on course'),
	(311,'system','select','2024-12-31 11:39:13','course','CRS058','select operation on course'),
	(312,'system','select','2024-12-31 11:39:15','teacher-courses','T001','select operation on teacher-courses'),
	(313,'system','select','2024-12-31 11:39:16','course-students','CRS020','select operation on course-students'),
	(314,'system','select','2024-12-31 11:39:26','course','CRS045','select operation on course'),
	(315,'system','select','2024-12-31 11:39:26','course','CRS045','select operation on course'),
	(316,'system','select','2024-12-31 11:39:28','teacher-courses','T001','select operation on teacher-courses'),
	(317,'system','select','2024-12-31 11:39:29','course','CRS020','select operation on course'),
	(318,'system','select','2024-12-31 11:39:29','course','CRS020','select operation on course'),
	(319,'system','select','2024-12-31 11:39:54','course','CRS020','select operation on course'),
	(320,'system','select','2024-12-31 11:39:54','course','CRS020','select operation on course'),
	(321,'system','select','2024-12-31 11:39:58','teacher-courses','T001','select operation on teacher-courses'),
	(322,'system','select','2024-12-31 11:40:35','course','CRS045','select operation on course'),
	(323,'system','select','2024-12-31 11:40:35','course','CRS045','select operation on course'),
	(324,'system','select','2024-12-31 11:40:36','teacher-courses','T001','select operation on teacher-courses'),
	(325,'system','select','2024-12-31 11:40:38','course-students','CRS058','select operation on course-students'),
	(326,'system','select','2024-12-31 11:42:36','teacher-courses','T001','select operation on teacher-courses'),
	(327,'system','select','2024-12-31 11:43:02','teacher-courses','T001','select operation on teacher-courses'),
	(328,'system','select','2024-12-31 11:43:04','course-students','CRS020','select operation on course-students'),
	(329,'system','select','2024-12-31 11:43:20','teacher-courses','T001','select operation on teacher-courses'),
	(330,'system','select','2024-12-31 11:43:22','course-students','CRS020','select operation on course-students'),
	(331,'system','select','2024-12-31 11:43:32','course','CRS045','select operation on course'),
	(332,'system','select','2024-12-31 11:43:32','course','CRS045','select operation on course'),
	(333,'system','select','2024-12-31 11:43:58','teacher-courses','T001','select operation on teacher-courses'),
	(334,'system','select','2024-12-31 11:43:59','course-students','CRS020','select operation on course-students'),
	(335,'system','select','2024-12-31 11:45:11','teacher-courses','T001','select operation on teacher-courses'),
	(336,'system','select','2024-12-31 12:51:21','teacher-courses','T001','select operation on teacher-courses'),
	(337,'system','select','2024-12-31 12:53:00','course-students','CRS020','select operation on course-students'),
	(338,'system','select','2024-12-31 12:54:00','teacher-courses','T001','select operation on teacher-courses'),
	(339,'system','select','2024-12-31 12:54:02','course-students','CRS020','select operation on course-students'),
	(340,'system','select','2024-12-31 12:54:08','teacher-courses','T001','select operation on teacher-courses'),
	(341,'system','select','2024-12-31 12:54:09','course-students','CRS020','select operation on course-students'),
	(342,'system','select','2024-12-31 12:56:16','course','CRS045','select operation on course'),
	(343,'system','select','2024-12-31 12:56:16','course','CRS045','select operation on course'),
	(344,'system','select','2024-12-31 12:57:01','teacher-courses','T001','select operation on teacher-courses'),
	(345,'system','select','2024-12-31 12:57:01','teacher-students','T001','select operation on teacher-students'),
	(346,'system','select','2024-12-31 12:57:05','teacher-courses','T001','select operation on teacher-courses'),
	(347,'system','select','2024-12-31 12:57:06','course','CRS045','select operation on course'),
	(348,'system','select','2024-12-31 12:57:06','course-grades','CRS045','select operation on course-grades'),
	(349,'system','select','2024-12-31 12:59:42','course','CRS045','select operation on course'),
	(350,'system','select','2024-12-31 12:59:42','course-grades','CRS045','select operation on course-grades'),
	(351,'system','select','2024-12-31 12:59:58','course','CRS045','select operation on course'),
	(352,'system','select','2024-12-31 12:59:58','course-grades','CRS045','select operation on course-grades'),
	(353,'system','select','2024-12-31 12:59:59','teacher-courses','T001','select operation on teacher-courses'),
	(354,'system','select','2024-12-31 13:00:00','teacher-students','T001','select operation on teacher-students'),
	(355,'system','select','2024-12-31 13:00:01','teacher-courses','T001','select operation on teacher-courses'),
	(356,'system','select','2024-12-31 13:00:03','course','CRS020','select operation on course'),
	(357,'system','select','2024-12-31 13:00:03','course-grades','CRS020','select operation on course-grades'),
	(358,'system','select','2024-12-31 13:00:14','course','CRS020','select operation on course'),
	(359,'system','select','2024-12-31 13:00:14','course-grades','CRS020','select operation on course-grades'),
	(360,'system','create','2024-12-31 13:00:18','update-grade',NULL,'create operation on update-grade'),
	(361,'system','create','2024-12-31 13:00:24','update-grade',NULL,'create operation on update-grade'),
	(362,'system','select','2024-12-31 13:00:33','teacher-courses','T001','select operation on teacher-courses'),
	(363,'system','select','2024-12-31 13:00:35','teacher-courses','T001','select operation on teacher-courses'),
	(364,'system','select','2024-12-31 13:01:50','course','CRS020','select operation on course'),
	(365,'system','select','2024-12-31 13:01:50','course','CRS020','select operation on course'),
	(366,'system','select','2024-12-31 13:01:55','teacher-students','T001','select operation on teacher-students'),
	(367,'system','select','2024-12-31 13:01:57','teacher-courses','T001','select operation on teacher-courses'),
	(368,'system','select','2024-12-31 13:01:58','course','CRS020','select operation on course'),
	(369,'system','select','2024-12-31 13:01:58','course-grades','CRS020','select operation on course-grades'),
	(370,'system','create','2024-12-31 13:02:13','update-grade',NULL,'create operation on update-grade'),
	(371,'system','create','2024-12-31 13:02:18','update-grade',NULL,'create operation on update-grade'),
	(372,'system','select','2024-12-31 13:02:47','course','CRS020','select operation on course'),
	(373,'system','select','2024-12-31 13:02:47','course-grades','CRS020','select operation on course-grades'),
	(374,'system','select','2024-12-31 13:04:56','course','CRS020','select operation on course'),
	(375,'system','select','2024-12-31 13:04:56','course-grades','CRS020','select operation on course-grades'),
	(376,'system','select','2024-12-31 15:26:50','course','CRS020','select operation on course'),
	(377,'system','select','2024-12-31 15:26:50','course-grades','CRS020','select operation on course-grades'),
	(378,'system','select','2024-12-31 15:46:47','course','CRS020','select operation on course'),
	(379,'system','select','2024-12-31 15:46:47','course-grades','CRS020','select operation on course-grades'),
	(380,'system','select','2024-12-31 15:51:21','course','CRS020','select operation on course'),
	(381,'system','select','2024-12-31 15:51:21','course-grades','CRS020','select operation on course-grades'),
	(382,'system','select','2024-12-31 16:10:36','course','CRS020','select operation on course'),
	(383,'system','select','2024-12-31 16:10:36','course-grades','CRS020','select operation on course-grades'),
	(384,'system','select','2024-12-31 16:13:22','course','CRS020','select operation on course'),
	(385,'system','select','2024-12-31 16:13:23','course-grades','CRS020','select operation on course-grades'),
	(386,'system','select','2024-12-31 16:13:51','course','CRS020','select operation on course'),
	(387,'system','select','2024-12-31 16:13:51','course-grades','CRS020','select operation on course-grades'),
	(388,'system','select','2024-12-31 16:39:21','course','CRS020','select operation on course'),
	(389,'system','select','2024-12-31 16:39:21','course-grades','CRS020','select operation on course-grades'),
	(390,'system','select','2025-01-01 00:12:57','course','CRS020','select operation on course'),
	(391,'system','select','2025-01-01 00:12:57','course-grades','CRS020','select operation on course-grades'),
	(392,'system','select','2025-01-01 16:41:19','course','CRS020','select operation on course'),
	(393,'system','select','2025-01-01 16:41:19','course-grades','CRS020','select operation on course-grades'),
	(394,'system','select','2025-01-01 16:44:56','course','CRS020','select operation on course'),
	(395,'system','select','2025-01-01 16:44:56','course-grades','CRS020','select operation on course-grades'),
	(396,'system','select','2025-01-01 16:44:57','course','CRS020','select operation on course'),
	(397,'system','select','2025-01-01 16:44:57','course-grades','CRS020','select operation on course-grades'),
	(398,'system','select','2025-01-01 16:44:57','teacher-courses','T001','select operation on teacher-courses'),
	(399,'system','select','2025-01-01 16:44:58','teacher-students','T001','select operation on teacher-students'),
	(400,'system','select','2025-01-01 16:44:59','teacher-courses','T001','select operation on teacher-courses'),
	(401,'system','select','2025-01-01 16:44:59','course','CRS045','select operation on course'),
	(402,'system','select','2025-01-01 16:44:59','course','CRS045','select operation on course'),
	(403,'system','select','2025-01-01 16:45:01','teacher-courses','T001','select operation on teacher-courses'),
	(404,'system','select','2025-01-01 16:55:42','teacher-courses','T001','select operation on teacher-courses'),
	(405,'system','select','2025-01-01 17:27:10','teacher-courses','T001','select operation on teacher-courses'),
	(406,'system','select','2025-01-01 17:48:27','teacher-students','T001','select operation on teacher-students'),
	(407,'system','select','2025-01-01 17:57:04','teacher-students','T001','select operation on teacher-students'),
	(408,'system','select','2025-01-01 19:52:04','teacher-students','T001','select operation on teacher-students'),
	(409,'system','select','2025-01-02 09:08:54','teacher-students','T001','select operation on teacher-students'),
	(410,'system','select','2025-01-02 09:08:56','teacher-courses','T001','select operation on teacher-courses'),
	(411,'system','select','2025-01-02 09:08:56','teacher-students','T001','select operation on teacher-students'),
	(412,'system','create','2025-01-02 09:09:08','login',NULL,'create operation on login'),
	(413,'system','select','2025-01-02 09:09:09','student-courses','S2021001','select operation on student-courses'),
	(414,'system','select','2025-01-02 09:09:10','available-courses',NULL,'select operation on available-courses'),
	(415,'system','select','2025-01-02 09:17:49','available-courses',NULL,'select operation on available-courses'),
	(416,'system','select','2025-04-04 20:58:49','student','S2021001','select operation on student'),
	(417,'system','select','2025-04-04 20:58:53','student-courses','S2021001','select operation on student-courses'),
	(418,'system','select','2025-04-04 20:58:53','available-courses',NULL,'select operation on available-courses'),
	(419,'system','select','2025-04-04 20:58:54','student-courses','S2021001','select operation on student-courses'),
	(420,'system','select','2025-04-04 20:58:54','student','S2021001','select operation on student'),
	(421,'system','select','2025-04-04 20:59:22','student-courses','S2021001','select operation on student-courses'),
	(422,'system','select','2025-04-04 20:59:23','course','CRS020','select operation on course'),
	(423,'system','select','2025-04-04 20:59:23','course','CRS020','select operation on course'),
	(424,'system','select','2025-04-04 20:59:53','student','S2021001','select operation on student'),
	(425,'system','select','2025-04-04 23:09:09','student','S2021001','select operation on student'),
	(426,'system','select','2025-04-05 12:16:41','student','S2021001','select operation on student'),
	(427,'system','select','2025-04-05 13:07:42','student','S2021001','select operation on student'),
	(428,'system','select','2025-04-05 13:11:36','student','S2021001','select operation on student'),
	(429,'system','select','2025-04-05 13:14:22','available-courses',NULL,'select operation on available-courses'),
	(430,'system','select','2025-04-05 13:15:28','student-courses','S2021001','select operation on student-courses'),
	(431,'system','select','2025-04-05 14:30:19','available-courses',NULL,'select operation on available-courses'),
	(432,'system','create','2025-04-05 14:30:22','select-course',NULL,'create operation on select-course'),
	(433,'system','select','2025-04-05 14:30:22','available-courses',NULL,'select operation on available-courses'),
	(434,'system','select','2025-04-05 14:30:24','student-courses','S2021001','select operation on student-courses'),
	(435,'system','select','2025-04-05 14:30:28','course','CRS904','select operation on course'),
	(436,'system','select','2025-04-05 14:30:28','course','CRS904','select operation on course'),
	(437,'system','select','2025-04-05 14:30:34','student','S2021001','select operation on student'),
	(438,'system','select','2025-04-05 14:32:48','student','S2021001','select operation on student'),
	(439,'system','select','2025-04-05 14:32:48','student-courses','S2021001','select operation on student-courses'),
	(440,'system','select','2025-04-05 14:47:10','student','S2021001','select operation on student'),
	(441,'system','select','2025-04-05 14:47:10','student-courses','S2021001','select operation on student-courses'),
	(442,'system','select','2025-04-05 17:17:45','available-courses',NULL,'select operation on available-courses'),
	(443,'system','select','2025-04-05 17:17:50','student-courses','S2021001','select operation on student-courses'),
	(444,'system','select','2025-04-05 17:20:46','course','CRS020','select operation on course'),
	(445,'system','select','2025-04-05 17:20:46','course','CRS020','select operation on course'),
	(446,'system','select','2025-04-05 17:20:47','student-courses','S2021001','select operation on student-courses'),
	(447,'system','select','2025-04-05 17:22:34','student','S2021001','select operation on student'),
	(448,'system','select','2025-04-05 17:22:36','student-courses','S2021001','select operation on student-courses'),
	(449,'system','select','2025-04-05 17:22:36','student','S2021001','select operation on student'),
	(450,'system','select','2025-04-05 17:22:37','student-courses','S2021001','select operation on student-courses'),
	(451,'system','select','2025-04-05 17:22:37','available-courses',NULL,'select operation on available-courses'),
	(452,'system','select','2025-04-05 17:22:37','student-courses','S2021001','select operation on student-courses'),
	(453,'system','select','2025-04-05 17:22:38','available-courses',NULL,'select operation on available-courses'),
	(454,'system','select','2025-04-05 17:22:40','student-courses','S2021001','select operation on student-courses'),
	(455,'system','select','2025-04-05 17:22:42','available-courses',NULL,'select operation on available-courses'),
	(456,'system','select','2025-04-05 17:26:39','student-courses','S2021001','select operation on student-courses'),
	(457,'system','select','2025-04-05 17:26:39','available-courses',NULL,'select operation on available-courses'),
	(458,'system','select','2025-04-05 17:26:42','student-courses','S2021001','select operation on student-courses'),
	(459,'system','select','2025-04-05 17:26:43','available-courses',NULL,'select operation on available-courses'),
	(460,'system','select','2025-04-05 17:26:47','student-courses','S2021001','select operation on student-courses'),
	(461,'system','select','2025-04-05 17:26:47','available-courses',NULL,'select operation on available-courses'),
	(462,'system','select','2025-04-05 17:26:48','student-courses','S2021001','select operation on student-courses'),
	(463,'system','select','2025-04-05 17:26:49','available-courses',NULL,'select operation on available-courses'),
	(464,'system','select','2025-04-05 17:26:49','student-courses','S2021001','select operation on student-courses'),
	(465,'system','select','2025-04-05 17:26:49','available-courses',NULL,'select operation on available-courses'),
	(466,'system','select','2025-04-05 17:26:50','student-courses','S2021001','select operation on student-courses'),
	(467,'system','select','2025-04-05 17:26:50','available-courses',NULL,'select operation on available-courses'),
	(468,'system','select','2025-04-05 17:26:51','student-courses','S2021001','select operation on student-courses'),
	(469,'system','select','2025-04-05 17:26:51','available-courses',NULL,'select operation on available-courses'),
	(470,'system','select','2025-04-05 17:26:51','student-courses','S2021001','select operation on student-courses'),
	(471,'system','select','2025-04-05 17:27:29','student-schedule','S2021001','select operation on student-schedule'),
	(472,'system','select','2025-04-05 17:31:44','student-courses','S2021001','select operation on student-courses'),
	(473,'system','select','2025-04-05 17:31:44','student-courses','S2021001','select operation on student-courses'),
	(474,'system','select','2025-04-05 17:34:21','student-courses','S2021001','select operation on student-courses'),
	(475,'system','select','2025-04-05 17:34:21','student-courses','S2021001','select operation on student-courses'),
	(476,'system','select','2025-04-05 21:15:43','student-courses','S2021001','select operation on student-courses'),
	(477,'system','select','2025-04-05 21:15:43','student-courses','S2021001','select operation on student-courses'),
	(478,'system','select','2025-04-06 10:02:27','student-courses','S2021001','select operation on student-courses'),
	(479,'system','select','2025-04-06 10:02:27','student-courses','S2021001','select operation on student-courses'),
	(480,'system','select','2025-04-06 10:03:22','student-courses','S2021001','select operation on student-courses'),
	(481,'system','select','2025-04-06 10:03:25','available-courses',NULL,'select operation on available-courses'),
	(482,'system','select','2025-04-06 10:03:28','student-courses','S2021001','select operation on student-courses'),
	(483,'system','select','2025-04-06 10:04:13','student-courses','S2021001','select operation on student-courses'),
	(484,'system','select','2025-04-06 10:04:18','student-courses','S2021001','select operation on student-courses'),
	(485,'system','select','2025-04-06 10:04:23','student-courses','S2021001','select operation on student-courses'),
	(486,'system','select','2025-04-06 10:07:40','student-courses','S2021001','select operation on student-courses'),
	(487,'system','select','2025-04-06 10:11:04','student-courses','S2021001','select operation on student-courses'),
	(488,'system','select','2025-04-06 10:11:10','available-courses',NULL,'select operation on available-courses'),
	(489,'system','select','2025-04-06 10:11:10','student-courses','S2021001','select operation on student-courses'),
	(490,'system','select','2025-04-06 10:11:10','available-courses',NULL,'select operation on available-courses'),
	(491,'system','select','2025-04-06 10:11:11','student-courses','S2021001','select operation on student-courses'),
	(492,'system','select','2025-04-06 10:11:25','course','CRS904','select operation on course'),
	(493,'system','select','2025-04-06 10:11:25','course','CRS904','select operation on course'),
	(494,'system','select','2025-04-06 10:11:25','course','CRS904','select operation on course'),
	(495,'system','select','2025-04-06 10:11:25','course','CRS904','select operation on course'),
	(496,'system','select','2025-04-06 10:11:26','student-courses','S2021001','select operation on student-courses'),
	(497,'system','select','2025-04-06 10:11:40','available-courses',NULL,'select operation on available-courses'),
	(498,'system','select','2025-04-06 10:11:43','student-courses','S2021001','select operation on student-courses'),
	(499,'system','select','2025-04-06 10:11:45','available-courses',NULL,'select operation on available-courses'),
	(500,'system','select','2025-04-06 10:11:47','student-courses','S2021001','select operation on student-courses'),
	(501,'system','create','2025-04-06 10:14:33','course-evaluation',NULL,'create operation on course-evaluation'),
	(502,'system','select','2025-04-06 10:14:33','student-courses','S2021001','select operation on student-courses'),
	(503,'system','select','2025-04-06 10:14:37','course','CRS020','select operation on course'),
	(504,'system','select','2025-04-06 10:14:37','course','CRS020','select operation on course'),
	(505,'system','select','2025-04-06 10:14:40','student-courses','S2021001','select operation on student-courses'),
	(506,'system','select','2025-04-06 10:14:43','course','CRS020','select operation on course'),
	(507,'system','select','2025-04-06 10:14:43','course','CRS020','select operation on course'),
	(508,'system','select','2025-04-06 10:14:46','student-courses','S2021001','select operation on student-courses'),
	(509,'system','select','2025-04-06 10:20:41','available-courses',NULL,'select operation on available-courses'),
	(510,'system','select','2025-04-06 10:20:42','student-courses','S2021001','select operation on student-courses'),
	(511,'system','select','2025-04-06 10:20:44','available-courses',NULL,'select operation on available-courses'),
	(512,'system','select','2025-04-06 10:25:58','available-courses',NULL,'select operation on available-courses'),
	(513,'system','select','2025-04-06 10:26:31','available-courses',NULL,'select operation on available-courses'),
	(514,'system','select','2025-04-06 10:26:35','available-courses',NULL,'select operation on available-courses'),
	(515,'system','create','2025-04-06 10:27:17','select-course',NULL,'create operation on select-course'),
	(516,'system','select','2025-04-06 10:27:17','available-courses',NULL,'select operation on available-courses'),
	(517,'system','create','2025-04-06 10:27:23','select-course',NULL,'create operation on select-course'),
	(518,'system','select','2025-04-06 10:27:23','available-courses',NULL,'select operation on available-courses'),
	(519,'system','create','2025-04-06 10:27:26','select-course',NULL,'create operation on select-course'),
	(520,'system','select','2025-04-06 10:27:26','available-courses',NULL,'select operation on available-courses'),
	(521,'system','select','2025-04-06 10:27:31','student-courses','S2021001','select operation on student-courses'),
	(522,'system','select','2025-04-06 10:27:33','student-schedule','S2021001','select operation on student-schedule'),
	(523,'system','select','2025-04-06 10:27:38','available-courses',NULL,'select operation on available-courses'),
	(524,'system','select','2025-04-06 10:27:57','available-courses',NULL,'select operation on available-courses'),
	(525,'system','select','2025-04-06 10:28:22','available-courses',NULL,'select operation on available-courses'),
	(526,'system','select','2025-04-06 10:28:22','recommended-courses','S2021001','select operation on recommended-courses'),
	(527,'system','select','2025-04-06 10:28:58','available-courses',NULL,'select operation on available-courses'),
	(528,'system','select','2025-04-06 10:28:58','recommended-courses','S2021001','select operation on recommended-courses'),
	(529,'system','select','2025-04-06 10:29:15','student-courses','S2021001','select operation on student-courses'),
	(530,'system','select','2025-04-06 10:29:21','available-courses',NULL,'select operation on available-courses'),
	(531,'system','select','2025-04-06 10:29:21','recommended-courses','S2021001','select operation on recommended-courses'),
	(532,'system','select','2025-04-06 10:29:32','student-courses','S2021001','select operation on student-courses'),
	(533,'system','select','2025-04-06 10:29:33','available-courses',NULL,'select operation on available-courses'),
	(534,'system','select','2025-04-06 10:29:33','recommended-courses','S2021001','select operation on recommended-courses'),
	(535,'system','select','2025-04-06 10:29:35','student-courses','S2021001','select operation on student-courses'),
	(536,'system','select','2025-04-06 10:29:39','course','CRS904','select operation on course'),
	(537,'system','select','2025-04-06 10:29:39','course','CRS904','select operation on course'),
	(538,'system','select','2025-04-06 10:29:40','student-courses','S2021001','select operation on student-courses'),
	(539,'system','select','2025-04-06 10:29:41','available-courses',NULL,'select operation on available-courses'),
	(540,'system','select','2025-04-06 10:29:41','recommended-courses','S2021001','select operation on recommended-courses'),
	(541,'system','create','2025-04-06 10:29:47','select-course',NULL,'create operation on select-course'),
	(542,'system','select','2025-04-06 10:29:47','recommended-courses','S2021001','select operation on recommended-courses'),
	(543,'system','select','2025-04-06 10:29:47','available-courses',NULL,'select operation on available-courses'),
	(544,'system','select','2025-04-06 10:29:57','available-courses',NULL,'select operation on available-courses'),
	(545,'system','select','2025-04-06 10:29:57','recommended-courses','S2021001','select operation on recommended-courses'),
	(546,'system','select','2025-04-06 11:25:39','student-courses','S2021001','select operation on student-courses'),
	(547,'system','select','2025-04-06 11:25:40','available-courses',NULL,'select operation on available-courses'),
	(548,'system','select','2025-04-06 11:25:40','recommended-courses','S2021001','select operation on recommended-courses'),
	(549,'system','select','2025-04-06 11:38:02','available-courses',NULL,'select operation on available-courses'),
	(550,'system','select','2025-04-06 11:38:02','recommended-courses','S2021001','select operation on recommended-courses'),
	(551,'system','create','2025-04-06 11:39:41','login',NULL,'create operation on login'),
	(552,'system','select','2025-04-06 11:39:43','teacher-courses','T001','select operation on teacher-courses'),
	(553,'system','select','2025-04-06 11:39:44','course','CRS058','select operation on course'),
	(554,'system','select','2025-04-06 11:39:44','course','CRS058','select operation on course'),
	(555,'system','select','2025-04-06 11:39:50','teacher-courses','T001','select operation on teacher-courses'),
	(556,'system','select','2025-04-06 11:42:03','teacher-courses','T001','select operation on teacher-courses'),
	(557,'system','select','2025-04-06 11:44:25','teacher-courses','T001','select operation on teacher-courses'),
	(558,'system','select','2025-04-06 12:09:36','teacher-courses','T001','select operation on teacher-courses'),
	(559,'system','select','2025-04-06 12:09:39','course','CRS045','select operation on course'),
	(560,'system','select','2025-04-06 12:09:39','course','CRS045','select operation on course'),
	(561,'system','select','2025-04-06 15:04:36','teacher-courses','T001','select operation on teacher-courses'),
	(562,'system','select','2025-04-06 15:04:37','course','CRS058','select operation on course'),
	(563,'system','select','2025-04-06 15:04:37','course','CRS058','select operation on course'),
	(564,'system','select','2025-04-06 15:04:38','teacher-courses','T001','select operation on teacher-courses'),
	(565,'system','select','2025-04-06 15:04:39','course','CRS045','select operation on course'),
	(566,'system','select','2025-04-06 15:04:39','course','CRS045','select operation on course'),
	(567,'system','select','2025-04-06 15:04:46','teacher-students','T001','select operation on teacher-students'),
	(568,'system','select','2025-04-06 15:04:47','teacher-courses','T001','select operation on teacher-courses'),
	(569,'system','select','2025-04-06 15:07:01','teacher-courses','T001','select operation on teacher-courses'),
	(570,'system','select','2025-04-06 15:09:26','teacher-courses','T001','select operation on teacher-courses'),
	(571,'system','select','2025-04-06 15:10:51','course','CRS045','select operation on course'),
	(572,'system','select','2025-04-06 15:10:51','course','CRS045','select operation on course'),
	(573,'system','select','2025-04-06 15:14:45','course','CRS045','select operation on course'),
	(574,'system','select','2025-04-06 15:14:45','course','CRS045','select operation on course'),
	(575,'system','select','2025-04-06 15:18:37','course','CRS045','select operation on course'),
	(576,'system','select','2025-04-06 15:18:37','course','CRS045','select operation on course'),
	(577,'system','select','2025-04-06 15:20:18','course','CRS045','select operation on course'),
	(578,'system','select','2025-04-06 15:20:18','course','CRS045','select operation on course'),
	(579,'system','select','2025-04-06 15:21:12','course','CRS045','select operation on course'),
	(580,'system','select','2025-04-06 15:21:12','course','CRS045','select operation on course'),
	(581,'system','select','2025-04-06 15:21:17','teacher-courses','T001','select operation on teacher-courses'),
	(582,'system','select','2025-04-06 15:21:21','teacher-students','T001','select operation on teacher-students'),
	(583,'system','create','2025-04-06 15:21:28','login',NULL,'create operation on login'),
	(584,'system','select','2025-04-06 15:21:29','available-courses',NULL,'select operation on available-courses'),
	(585,'system','select','2025-04-06 15:21:29','recommended-courses','S2021001','select operation on recommended-courses'),
	(586,'system','select','2025-04-06 15:21:34','available-courses',NULL,'select operation on available-courses'),
	(587,'system','create','2025-04-06 15:21:35','select-course',NULL,'create operation on select-course'),
	(588,'system','select','2025-04-06 15:21:35','available-courses',NULL,'select operation on available-courses'),
	(589,'system','select','2025-04-06 15:21:35','recommended-courses','S2021001','select operation on recommended-courses'),
	(590,'system','create','2025-04-06 15:21:42','select-course',NULL,'create operation on select-course'),
	(591,'system','select','2025-04-06 15:21:42','available-courses',NULL,'select operation on available-courses'),
	(592,'system','select','2025-04-06 15:21:42','recommended-courses','S2021001','select operation on recommended-courses'),
	(593,'system','create','2025-04-06 15:21:52','login',NULL,'create operation on login'),
	(594,'system','select','2025-04-06 15:21:53','teacher-courses','T001','select operation on teacher-courses'),
	(595,'system','select','2025-04-06 15:21:57','course','CRS045','select operation on course'),
	(596,'system','select','2025-04-06 15:21:57','course','CRS045','select operation on course'),
	(597,'system','create','2025-04-06 15:21:59','course','CRS045','create operation on course'),
	(598,'system','select','2025-04-06 15:21:59','course','CRS045','select operation on course'),
	(599,'system','select','2025-04-06 15:22:01','teacher-courses','T001','select operation on teacher-courses'),
	(600,'system','select','2025-04-06 15:22:06','teacher-courses','T001','select operation on teacher-courses'),
	(601,'system','select','2025-04-06 15:22:06','course','CRS045','select operation on course'),
	(602,'system','select','2025-04-06 15:22:06','course','CRS045','select operation on course'),
	(603,'system','select','2025-04-06 15:22:12','teacher-courses','T001','select operation on teacher-courses'),
	(604,'system','create','2025-04-06 15:22:27','login',NULL,'create operation on login'),
	(605,'system','select','2025-04-06 15:22:28','student-courses','S2021001','select operation on student-courses'),
	(606,'system','select','2025-04-06 15:22:31','student-courses','S2021001','select operation on student-courses'),
	(607,'system','select','2025-04-06 15:22:31','course','CRS098','select operation on course'),
	(608,'system','select','2025-04-06 15:22:31','course','CRS098','select operation on course'),
	(609,'system','select','2025-04-06 15:22:36','available-courses',NULL,'select operation on available-courses'),
	(610,'system','select','2025-04-06 15:22:36','recommended-courses','S2021001','select operation on recommended-courses'),
	(611,'system','select','2025-04-06 15:22:37','student-courses','S2021001','select operation on student-courses'),
	(612,'system','select','2025-04-06 15:23:05','available-courses',NULL,'select operation on available-courses'),
	(613,'system','select','2025-04-06 15:23:05','recommended-courses','S2021001','select operation on recommended-courses'),
	(614,'system','select','2025-04-06 15:23:06','student-courses','S2021001','select operation on student-courses'),
	(615,'system','select','2025-04-06 15:24:02','student-courses','S2021001','select operation on student-courses'),
	(616,'system','select','2025-04-06 15:24:03','student-courses','S2021001','select operation on student-courses'),
	(617,'system','select','2025-04-06 15:24:05','course','CRS020','select operation on course'),
	(618,'system','select','2025-04-06 15:24:05','course','CRS020','select operation on course'),
	(619,'system','select','2025-04-06 15:24:06','available-courses',NULL,'select operation on available-courses'),
	(620,'system','select','2025-04-06 15:24:06','recommended-courses','S2021001','select operation on recommended-courses'),
	(621,'system','select','2025-04-06 15:24:25','student-courses','S2021001','select operation on student-courses'),
	(622,'system','select','2025-04-06 15:24:26','available-courses',NULL,'select operation on available-courses'),
	(623,'system','select','2025-04-06 15:24:26','recommended-courses','S2021001','select operation on recommended-courses'),
	(624,'system','select','2025-04-06 15:24:39','student-courses','S2021001','select operation on student-courses'),
	(625,'system','select','2025-04-06 15:24:39','available-courses',NULL,'select operation on available-courses'),
	(626,'system','select','2025-04-06 15:24:39','recommended-courses','S2021001','select operation on recommended-courses'),
	(627,'system','select','2025-04-06 15:24:43','student-courses','S2021001','select operation on student-courses'),
	(628,'system','select','2025-04-06 15:24:43','course','CRS020','select operation on course'),
	(629,'system','select','2025-04-06 15:24:43','course','CRS020','select operation on course'),
	(630,'system','select','2025-04-06 15:24:46','available-courses',NULL,'select operation on available-courses'),
	(631,'system','select','2025-04-06 15:24:46','recommended-courses','S2021001','select operation on recommended-courses'),
	(632,'system','select','2025-04-06 15:24:47','student-courses','S2021001','select operation on student-courses'),
	(633,'system','select','2025-04-06 15:24:47','available-courses',NULL,'select operation on available-courses'),
	(634,'system','select','2025-04-06 15:24:47','recommended-courses','S2021001','select operation on recommended-courses'),
	(635,'system','select','2025-04-06 15:24:55','student-courses','S2021001','select operation on student-courses'),
	(636,'system','select','2025-04-06 15:24:56','course','CRS020','select operation on course'),
	(637,'system','select','2025-04-06 15:24:56','course','CRS020','select operation on course'),
	(638,'system','select','2025-04-06 15:24:57','student-courses','S2021001','select operation on student-courses'),
	(639,'system','select','2025-04-06 15:24:57','available-courses',NULL,'select operation on available-courses'),
	(640,'system','select','2025-04-06 15:24:57','recommended-courses','S2021001','select operation on recommended-courses'),
	(641,'system','create','2025-04-06 15:25:24','login',NULL,'create operation on login'),
	(642,'system','select','2025-04-06 15:25:27','teacher-courses','T001','select operation on teacher-courses'),
	(643,'system','select','2025-04-06 15:25:28','course','CRS045','select operation on course'),
	(644,'system','select','2025-04-06 15:25:28','course','CRS045','select operation on course'),
	(645,'system','select','2025-04-06 15:25:30','teacher-courses','T001','select operation on teacher-courses'),
	(646,'system','select','2025-04-06 15:25:31','course','CRS045','select operation on course'),
	(647,'system','select','2025-04-06 15:25:31','course','CRS045','select operation on course'),
	(648,'system','select','2025-04-06 15:31:45','course','CRS045','select operation on course'),
	(649,'system','select','2025-04-06 15:31:45','course','CRS045','select operation on course'),
	(650,'system','select','2025-04-06 15:31:49','available-courses',NULL,'select operation on available-courses'),
	(651,'system','select','2025-04-06 15:31:49','recommended-courses','S2021001','select operation on recommended-courses'),
	(652,'system','select','2025-04-06 15:31:54','course','CRS045','select operation on course'),
	(653,'system','select','2025-04-06 15:31:54','course','CRS045','select operation on course'),
	(654,'system','select','2025-04-06 15:31:57','teacher-courses','T001','select operation on teacher-courses'),
	(655,'system','select','2025-04-06 15:31:58','teacher-courses','T001','select operation on teacher-courses'),
	(656,'system','select','2025-04-06 15:32:08','available-courses',NULL,'select operation on available-courses'),
	(657,'system','select','2025-04-06 15:32:10','available-courses',NULL,'select operation on available-courses'),
	(658,'system','select','2025-04-06 15:32:10','recommended-courses','S2021001','select operation on recommended-courses'),
	(659,'system','select','2025-04-06 15:32:27','class-courses','S2021001','select operation on class-courses'),
	(660,'system','select','2025-04-06 15:32:32','student-courses','S2021001','select operation on student-courses'),
	(661,'system','select','2025-04-06 15:32:33','student-schedule','S2021001','select operation on student-schedule'),
	(662,'system','create','2025-04-06 15:32:37','drop-course',NULL,'create operation on drop-course'),
	(663,'system','select','2025-04-06 15:32:37','student-courses','S2021001','select operation on student-courses'),
	(664,'system','create','2025-04-06 15:32:38','drop-course',NULL,'create operation on drop-course'),
	(665,'system','select','2025-04-06 15:32:38','student-courses','S2021001','select operation on student-courses'),
	(666,'system','create','2025-04-06 15:32:38','drop-course',NULL,'create operation on drop-course'),
	(667,'system','select','2025-04-06 15:32:38','student-courses','S2021001','select operation on student-courses'),
	(668,'system','create','2025-04-06 15:32:38','drop-course',NULL,'create operation on drop-course'),
	(669,'system','select','2025-04-06 15:32:38','student-courses','S2021001','select operation on student-courses'),
	(670,'system','create','2025-04-06 15:32:38','drop-course',NULL,'create operation on drop-course'),
	(671,'system','select','2025-04-06 15:32:38','student-courses','S2021001','select operation on student-courses'),
	(672,'system','create','2025-04-06 15:32:38','drop-course',NULL,'create operation on drop-course'),
	(673,'system','select','2025-04-06 15:32:38','student-courses','S2021001','select operation on student-courses'),
	(674,'system','create','2025-04-06 15:32:39','drop-course',NULL,'create operation on drop-course'),
	(675,'system','select','2025-04-06 15:32:39','student-courses','S2021001','select operation on student-courses'),
	(676,'system','create','2025-04-06 15:32:39','drop-course',NULL,'create operation on drop-course'),
	(677,'system','select','2025-04-06 15:32:39','student-courses','S2021001','select operation on student-courses'),
	(678,'system','select','2025-04-06 15:32:40','available-courses',NULL,'select operation on available-courses'),
	(679,'system','select','2025-04-06 15:32:40','recommended-courses','S2021001','select operation on recommended-courses'),
	(680,'system','select','2025-04-06 15:32:48','available-courses',NULL,'select operation on available-courses'),
	(681,'system','select','2025-04-06 15:32:53','available-courses',NULL,'select operation on available-courses'),
	(682,'system','create','2025-04-06 15:33:11','select-course',NULL,'create operation on select-course'),
	(683,'system','select','2025-04-06 15:33:11','available-courses',NULL,'select operation on available-courses'),
	(684,'system','select','2025-04-06 15:33:11','recommended-courses','S2021001','select operation on recommended-courses'),
	(685,'system','select','2025-04-06 15:35:16','teacher-students','T001','select operation on teacher-students'),
	(686,'system','select','2025-04-06 15:35:18','teacher-courses','T001','select operation on teacher-courses'),
	(687,'system','select','2025-04-06 15:35:20','course','CRS045','select operation on course'),
	(688,'system','select','2025-04-06 15:35:20','course','CRS045','select operation on course'),
	(689,'system','select','2025-04-06 15:35:58','teacher-students','T001','select operation on teacher-students'),
	(690,'system','select','2025-04-06 15:35:58','teacher-courses','T001','select operation on teacher-courses'),
	(691,'system','select','2025-04-06 15:36:01','teacher-students','T001','select operation on teacher-students'),
	(692,'system','select','2025-04-06 15:36:09','student-courses','S2021001','select operation on student-courses'),
	(693,'system','select','2025-04-06 15:36:30','student-courses','S2021001','select operation on student-courses'),
	(694,'system','select','2025-04-06 15:37:23','course','CRS020','select operation on course'),
	(695,'system','select','2025-04-06 15:37:23','course','CRS020','select operation on course'),
	(696,'system','select','2025-04-06 15:37:26','student','S2021001','select operation on student'),
	(697,'system','select','2025-04-06 15:37:26','student-courses','S2021001','select operation on student-courses'),
	(698,'system','create','2025-04-06 15:37:39','course-evaluation',NULL,'create operation on course-evaluation'),
	(699,'system','select','2025-04-06 15:37:39','student-courses','S2021001','select operation on student-courses'),
	(700,'system','select','2025-04-06 15:39:29','teacher-courses','T001','select operation on teacher-courses'),
	(701,'system','select','2025-04-06 15:39:30','course','CRS045','select operation on course'),
	(702,'system','select','2025-04-06 15:39:30','course','CRS045','select operation on course'),
	(703,'system','select','2025-04-06 15:39:33','teacher-courses','T001','select operation on teacher-courses'),
	(704,'system','select','2025-04-06 15:39:35','course','CRS074','select operation on course'),
	(705,'system','select','2025-04-06 15:39:35','course','CRS074','select operation on course'),
	(706,'system','select','2025-04-06 15:39:39','teacher-courses','T001','select operation on teacher-courses'),
	(707,'system','select','2025-04-06 15:39:40','course','CRS020','select operation on course'),
	(708,'system','select','2025-04-06 15:39:40','course','CRS020','select operation on course'),
	(709,'system','select','2025-04-06 15:39:42','teacher-courses','T001','select operation on teacher-courses'),
	(710,'system','select','2025-04-06 15:39:43','course','CRS901','select operation on course'),
	(711,'system','select','2025-04-06 15:39:43','course','CRS901','select operation on course'),
	(712,'system','select','2025-04-06 15:39:46','teacher-courses','T001','select operation on teacher-courses'),
	(713,'system','select','2025-04-06 15:39:51','course','CRS020','select operation on course'),
	(714,'system','select','2025-04-06 15:39:51','course','CRS020','select operation on course'),
	(715,'system','select','2025-04-06 15:39:54','course','CRS020','select operation on course'),
	(716,'system','select','2025-04-06 15:39:54','course','CRS020','select operation on course'),
	(717,'system','select','2025-04-06 15:41:38','course','CRS020','select operation on course'),
	(718,'system','select','2025-04-06 15:41:38','course','CRS020','select operation on course'),
	(719,'system','select','2025-04-06 15:42:24','course','CRS020','select operation on course'),
	(720,'system','select','2025-04-06 15:42:24','course','CRS020','select operation on course'),
	(721,'system','select','2025-04-06 15:42:30','course','CRS020','select operation on course'),
	(722,'system','select','2025-04-06 15:42:30','course','CRS020','select operation on course'),
	(723,'system','select','2025-04-06 15:43:20','course','CRS020','select operation on course'),
	(724,'system','select','2025-04-06 15:43:20','course','CRS020','select operation on course'),
	(725,'system','select','2025-04-06 15:43:33','course','CRS020','select operation on course'),
	(726,'system','select','2025-04-06 15:43:33','course','CRS020','select operation on course'),
	(727,'system','select','2025-04-06 15:44:22','course','CRS020','select operation on course'),
	(728,'system','select','2025-04-06 15:44:22','course','CRS020','select operation on course'),
	(729,'system','select','2025-04-06 15:44:23','course','CRS020','select operation on course'),
	(730,'system','select','2025-04-06 15:44:33','teacher-courses','T001','select operation on teacher-courses'),
	(731,'system','select','2025-04-06 15:44:35','teacher-students','T001','select operation on teacher-students'),
	(732,'system','select','2025-04-06 15:44:37','available-courses',NULL,'select operation on available-courses'),
	(733,'system','select','2025-04-06 15:44:37','recommended-courses','S2021001','select operation on recommended-courses'),
	(734,'system','select','2025-04-06 15:45:34','available-courses',NULL,'select operation on available-courses'),
	(735,'system','select','2025-04-06 15:45:34','recommended-courses','S2021001','select operation on recommended-courses'),
	(736,'system','select','2025-04-06 15:46:06','teacher-students','T001','select operation on teacher-students'),
	(737,'system','select','2025-04-06 15:46:10','course','CRS904','select operation on course'),
	(738,'system','select','2025-04-06 15:46:18','course','CRS020','select operation on course'),
	(739,'system','select','2025-04-06 15:46:52','student-courses','S2021001','select operation on student-courses'),
	(740,'system','select','2025-04-06 15:46:53','student','S2021001','select operation on student'),
	(741,'system','select','2025-04-06 15:46:53','student-courses','S2021001','select operation on student-courses'),
	(742,'system','select','2025-04-06 15:46:54','available-courses',NULL,'select operation on available-courses'),
	(743,'system','select','2025-04-06 15:46:54','recommended-courses','S2021001','select operation on recommended-courses'),
	(744,'system','create','2025-04-06 15:47:01','select-course',NULL,'create operation on select-course'),
	(745,'system','select','2025-04-06 15:47:01','available-courses',NULL,'select operation on available-courses'),
	(746,'system','select','2025-04-06 15:47:01','recommended-courses','S2021001','select operation on recommended-courses'),
	(747,'system','select','2025-04-06 15:47:02','student-courses','S2021001','select operation on student-courses'),
	(748,'system','select','2025-04-06 15:47:03','course','CRS089','select operation on course'),
	(749,'system','select','2025-04-06 15:47:03','course','CRS089','select operation on course'),
	(750,'system','select','2025-04-06 15:47:06','course','CRS089','select operation on course'),
	(751,'system','select','2025-04-06 15:49:23','teacher-students','T001','select operation on teacher-students'),
	(752,'system','select','2025-04-06 15:49:23','course','CRS089','select operation on course'),
	(753,'system','select','2025-04-06 15:49:23','course','CRS089','select operation on course'),
	(754,'system','select','2025-04-06 16:15:21','teacher-students','T001','select operation on teacher-students'),
	(755,'system','select','2025-04-06 16:15:21','course','CRS089','select operation on course'),
	(756,'system','select','2025-04-06 16:15:21','course','CRS089','select operation on course'),
	(757,'system','select','2025-04-06 20:34:09','teacher-students','T001','select operation on teacher-students'),
	(758,'system','select','2025-04-06 20:34:09','course','CRS089','select operation on course'),
	(759,'system','select','2025-04-06 20:34:09','course','CRS089','select operation on course'),
	(760,'system','select','2025-04-08 21:25:35','course','CRS089','select operation on course'),
	(761,'system','select','2025-04-08 21:28:38','teacher-students','T001','select operation on teacher-students'),
	(762,'system','select','2025-04-08 21:28:38','course','CRS089','select operation on course'),
	(763,'system','select','2025-04-08 21:28:38','course','CRS089','select operation on course'),
	(764,'system','select','2025-04-08 21:42:20','teacher-students','T001','select operation on teacher-students'),
	(765,'system','select','2025-04-09 21:59:44','teacher-courses','T001','select operation on teacher-courses'),
	(766,'system','select','2025-04-09 21:59:44','teacher-students','T001','select operation on teacher-students');

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
	('S0001','1','123456','男','1123123@q.com','地址','D001','本科','2024-12-30','M001','C002',1,0.00,0.00),
	('S2021001','刘洋','123456','男','liuyang@example.com','北京市朝阳区','D001','本科','2021-09-01','M001','C001',1,6.00,99.00),
	('S2021002','王芳','123456','女','wangfang@example.com','上海市黄浦区','D001','本科','2021-09-01','M001','C002',1,10.00,99.00),
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
