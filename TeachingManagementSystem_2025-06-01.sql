# ************************************************************
# Sequel Ace SQL dump
# 版本号： 20077
#
# https://sequel-ace.com/
# https://github.com/Sequel-Ace/Sequel-Ace
#
# 主机: 127.0.0.1 (MySQL 8.4.3)
# 数据库: TeachingManagementSystem
# 生成时间: 2025-06-01 03:36:12 +0000
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
  CONSTRAINT `courseevaluation_ibfk_3` FOREIGN KEY (`teacher_id`) REFERENCES `Teacher` (`teacher_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



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


DELIMITER ;;
/*!50003 SET SESSION SQL_MODE="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION" */;;
/*!50003 CREATE */ /*!50017 DEFINER=`root`@`localhost` */ /*!50003 TRIGGER `trg_Student_delete` BEFORE DELETE ON `Student` FOR EACH ROW BEGIN
    INSERT INTO BackupStudent SELECT * FROM Student WHERE student_id = OLD.student_id;
END */;;
DELIMITER ;
/*!50003 SET SESSION SQL_MODE=@OLD_SQL_MODE */;


# 转储表 StudentAIChatHistory
# ------------------------------------------------------------

DROP TABLE IF EXISTS `StudentAIChatHistory`;

CREATE TABLE `StudentAIChatHistory` (
  `chat_id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(20) NOT NULL,
  `message_type` enum('user','assistant') NOT NULL COMMENT '消息类型：用户或AI助手',
  `content` text NOT NULL COMMENT '聊天内容',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`chat_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `studentaichathistory_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `Student` (`student_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



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
