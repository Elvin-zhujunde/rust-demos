
DROP DATABASE IF EXISTS TeachingManagementSystem;
-- 1.创建数据库
CREATE DATABASE TeachingManagementSystem;
USE TeachingManagementSystem;

-- 2.1 创建学院表
CREATE TABLE Department (
    department_id VARCHAR(20) PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

-- 2.2 创建专业表
CREATE TABLE Major (
    major_id VARCHAR(20) PRIMARY KEY,
    major_name VARCHAR(100) NOT NULL,
    department_id VARCHAR(20),
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
);

-- 2.3 创建班级表
CREATE TABLE Class (
    class_id VARCHAR(20) PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL,
    major_id VARCHAR(20),
    FOREIGN KEY (major_id) REFERENCES Major(major_id)
);

-- 2.4 创建学生表
CREATE TABLE Student (
    student_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    gender ENUM('男', '女') NOT NULL,
    email VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    department_id VARCHAR(20),
    degree VARCHAR(50) NOT NULL,
    enrollment_date DATE NOT NULL,
    major_id VARCHAR(20),
    class_id VARCHAR(20),
    semester INT NOT NULL,
    total_credits DECIMAL(5,2) DEFAULT 0,
    gpa DECIMAL(4,2) DEFAULT 0,
    FOREIGN KEY (department_id) REFERENCES Department(department_id),
    FOREIGN KEY (major_id) REFERENCES Major(major_id),
    FOREIGN KEY (class_id) REFERENCES Class(class_id)
);

-- 2.5 创建教师表
CREATE TABLE Teacher (
    teacher_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    gender ENUM('男', '女') NOT NULL,
    email VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    department_id VARCHAR(20),
    title VARCHAR(50) NOT NULL,
    entry_date DATE NOT NULL,
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
);

-- 2.6 创建学科表
CREATE TABLE Subject (
    subject_id VARCHAR(20) PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    class_hours INT NOT NULL,
    credits DECIMAL(3,1) NOT NULL
);

-- 2.7 创建课程表
CREATE TABLE Course (
    course_id VARCHAR(20) PRIMARY KEY,
    subject_id VARCHAR(20) NOT NULL,
    teacher_id VARCHAR(20),
    semester INT NOT NULL,
    student_count INT DEFAULT 0,
    max_students INT NOT NULL,
    class_hours ENUM('16', '32', '48', '64') NOT NULL,
    week_day ENUM('1','2','3','4','5','6','7') NOT NULL COMMENT '周几上课',
    start_section INT NOT NULL COMMENT '第几节开始上课',
    section_count INT NOT NULL COMMENT '连续上几节课',
    FOREIGN KEY (subject_id) REFERENCES Subject(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES Teacher(teacher_id),
    CONSTRAINT valid_section CHECK (
        start_section BETWEEN 1 AND 12 AND
        section_count BETWEEN 1 AND 4 AND
        start_section + section_count - 1 <= 
        CASE 
            WHEN start_section <= 4 THEN 4  -- 上午课程
            WHEN start_section <= 8 THEN 8  -- 下午课程
            WHEN start_section <= 12 THEN 12 -- 晚上课程
        END
    )
);

-- 2.8 创建选课表
CREATE TABLE CourseSelection (
    student_id VARCHAR(20),
    course_id VARCHAR(20),
    selection_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);


-- 2.9 创建成绩表
CREATE TABLE Grades (
    student_id VARCHAR(20),
    course_id VARCHAR(20),
    grade DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

-- 2.10 创建操作日志表
CREATE TABLE OperationLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(20) NOT NULL,
    operation_type VARCHAR(10) NOT NULL,
    operation_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    table_name VARCHAR(50) NOT NULL,
    record_id VARCHAR(50),
    description VARCHAR(200)
);

-- 2.11 创建备份学生表
CREATE TABLE BackupStudent LIKE Student;

-- 2.12 创建教学班级-课程关联表
CREATE TABLE CourseClass (
    course_id VARCHAR(20),
    class_id VARCHAR(20),
    PRIMARY KEY (course_id, class_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES Class(class_id) ON DELETE CASCADE
);

-- 添加一些测试数据
INSERT INTO CourseClass (course_id, class_id) VALUES
('CRS001', 'C001'),  -- 高等数学课程分配给计科一班
('CRS001', 'C002'),  -- 高等数学课程也分配给计科二班
('CRS002', 'C001'),  -- 大学英语课程分配给计科一班
('CRS003', 'C003');  -- 数据结构课程分配给软件一班

-- 3.1 创建选课插入触发器（更新学生总学分）
DELIMITER $$

CREATE TRIGGER trg_CourseSelection_insert
AFTER INSERT ON CourseSelection
FOR EACH ROW
BEGIN
    DECLARE course_credits DECIMAL(3,1);
    SELECT credits INTO course_credits 
    FROM Subject 
    WHERE subject_id = (SELECT subject_id FROM Course WHERE course_id = NEW.course_id);
    UPDATE Student 
    SET total_credits = total_credits + course_credits 
    WHERE student_id = NEW.student_id;
END$$

DELIMITER ;

-- 3.2 选课删除触发器（更新学生总学分）
DELIMITER $$

CREATE TRIGGER trg_CourseSelection_delete
AFTER DELETE ON CourseSelection
FOR EACH ROW
BEGIN
    DECLARE course_credits DECIMAL(3,1);
    SELECT credits INTO course_credits 
    FROM Subject 
    WHERE subject_id = (SELECT subject_id FROM Course WHERE course_id = OLD.course_id);
    UPDATE Student 
    SET total_credits = total_credits - course_credits 
    WHERE student_id = OLD.student_id;
END$$

DELIMITER ;

-- 3.3 成绩插入触发器（更新学生GPA）
DELIMITER $$

CREATE TRIGGER trg_Grades_insert
AFTER INSERT ON Grades
FOR EACH ROW
BEGIN
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
END$$

DELIMITER ;

-- 3.4 学生删除触发器（备份学生信息）
DELIMITER $$

CREATE TRIGGER trg_Student_delete
BEFORE DELETE ON Student
FOR EACH ROW
BEGIN
    INSERT INTO BackupStudent SELECT * FROM Student WHERE student_id = OLD.student_id;
END$$

DELIMITER ;

-- 3.5 授课更新触发器（记录教师变更）
DELIMITER $$

CREATE TRIGGER trg_Course_teacher_update
AFTER UPDATE ON Course
FOR EACH ROW
BEGIN
    IF NEW.teacher_id <> OLD.teacher_id THEN
        INSERT INTO OperationLog(user_id, operation_type, table_name, record_id, description)
        VALUES('system', 'update', 'Course', NEW.course_id, CONCAT('教师从 ', OLD.teacher_id, ' 更改为 ', NEW.teacher_id));
    END IF;
END$$

DELIMITER ;

-- 4. 创建存储过程
-- 4.1 查询某课程平均分
DELIMITER $$

CREATE PROCEDURE sp_get_course_average(IN input_course_name VARCHAR(100))
BEGIN
    DECLARE course_id_var VARCHAR(20);
    SELECT course_id INTO course_id_var 
    FROM Course 
    WHERE subject_id IN (SELECT subject_id FROM Subject WHERE subject_name = input_course_name);
    SELECT AVG(grade) AS average_grade 
    FROM Grades 
    WHERE course_id = course_id_var;
END$$

DELIMITER ;

-- 4.2 查询某学生的平均学分绩点（GPA）
DELIMITER $$

CREATE PROCEDURE sp_get_student_gpa(IN input_student_id VARCHAR(20))
BEGIN
    SELECT SUM(G.grade * S.credits) / SUM(S.credits) AS GPA
    FROM Grades G
    JOIN Course C ON G.course_id = C.course_id
    JOIN Subject S ON C.subject_id = S.subject_id
    WHERE G.student_id = input_student_id;
END$$

DELIMITER ;

-- 5. 创建视图
-- 5.1 课程信息与授课教师视图
CREATE VIEW vw_Course_Teacher AS
SELECT 
    C.course_id,
    S.subject_name,
    C.semester,
    C.class_hours,
    C.student_count,
    C.max_students,
    T.teacher_id,
    T.name AS teacher_name,
    T.title,
    T.department_id
FROM Course C
JOIN Subject S ON C.subject_id = S.subject_id
JOIN Teacher T ON C.teacher_id = T.teacher_id;

-- 5.2 学生成绩-课程信息-授课教师视图
CREATE VIEW vw_Student_Grades_Course_Teacher AS
SELECT
    G.student_id,
    Stu.name AS student_name,
    G.course_id,
    S.subject_name,
    G.grade,
    T.teacher_id,
    T.name AS teacher_name
FROM Grades G
JOIN Student Stu ON G.student_id = Stu.student_id
JOIN Course C ON G.course_id = C.course_id
JOIN Subject S ON C.subject_id = S.subject_id
JOIN Teacher T ON C.teacher_id = T.teacher_id;

-- 5.3 学生选课方案-各门科目视图
CREATE VIEW vw_Student_CourseSelection AS
SELECT
    CS.student_id,
    Stu.name AS student_name,
    CS.course_id,
    S.subject_name,
    S.credits,
    C.semester
FROM CourseSelection CS
JOIN Student Stu ON CS.student_id = Stu.student_id
JOIN Course C ON CS.course_id = C.course_id
JOIN Subject S ON C.subject_id = S.subject_id;

-- 6. 设置用户权限（安全性与完整性要求）
-- 6.1 创建用户
DROP USER IF EXISTS 'student_user'@'localhost';
DROP USER IF EXISTS 'teacher_user'@'localhost';
DROP USER IF EXISTS 'admin_user'@'localhost';
-- 学生用户
CREATE USER 'student_user'@'localhost' IDENTIFIED BY '123456';

-- 教师用户
CREATE USER 'teacher_user'@'localhost' IDENTIFIED BY '123456';

-- 管理员用户
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY '123456';

--6.2 分配权限
-- 分配学生用户权限
GRANT SELECT ON TeachingManagementSystem.Student TO 'student_user'@'localhost';
GRANT SELECT ON TeachingManagementSystem.Course TO 'student_user'@'localhost';
GRANT SELECT, INSERT, DELETE ON TeachingManagementSystem.CourseSelection TO 'student_user'@'localhost';
GRANT SELECT ON TeachingManagementSystem.Subject TO 'student_user'@'localhost';
GRANT EXECUTE ON PROCEDURE TeachingManagementSystem.sp_get_student_gpa TO 'student_user'@'localhost';
GRANT SELECT ON TeachingManagementSystem.vw_Student_CourseSelection TO 'student_user'@'localhost';

-- 分配教师用户权限
GRANT SELECT, INSERT, UPDATE, DELETE ON TeachingManagementSystem.Student TO 'teacher_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON TeachingManagementSystem.Course TO 'teacher_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON TeachingManagementSystem.Grades TO 'teacher_user'@'localhost';
GRANT EXECUTE ON PROCEDURE TeachingManagementSystem.sp_get_course_average TO 'teacher_user'@'localhost';
GRANT SELECT ON TeachingManagementSystem.vw_Student_Grades_Course_Teacher TO 'teacher_user'@'localhost';

-- 分配管理员用户权限
GRANT ALL PRIVILEGES ON TeachingManagementSystem.* TO 'admin_user'@'localhost';

-- 7 插入数据
-- 学院表
INSERT INTO Department (department_id, department_name) VALUES
('D001', '计算机学院'),
('D002', '电子信息学院'),
('D003', '经济管理学院');

-- 专业表
INSERT INTO Major (major_id, major_name, department_id) VALUES
('M001', '计算机科学与技术', 'D001'),
('M002', '软件工程', 'D001'),
('M003', '电子信息工程', 'D002'),
('M004', '国际经济与贸易', 'D003');

-- 班级表
INSERT INTO Class (class_id, class_name, major_id) VALUES
('C001', '计科一班', 'M001'),
('C002', '计科二班', 'M001'),
('C003', '软件一班', 'M002'),
('C004', '电信一班', 'M003'),
('C005', '国贸一班', 'M004');

-- 学科表
INSERT INTO Subject (subject_id, subject_name, class_hours, credits) VALUES
('S001', '高等数学', 64, 4.0),
('S002', '大学英语', 48, 3.0),
('S003', '数据结构', 48, 3.0),
('S004', '电路分析', 48, 3.0),
('S005', '国际贸易', 48, 3.0);

-- 教师表
INSERT INTO Teacher (teacher_id, name, password, gender, email, address, department_id, title, entry_date) VALUES
('T001', '张伟', '123456', '男', 'zhangwei@example.com', '北京市海淀区', 'D001', '教授', '2010-09-01'),
('T002', '李娜', '123456', '女', 'lina@example.com', '上海市浦东新区', 'D001', '副教授', '2012-08-15'),
('T003', '王强', '123456', '男', 'wangqiang@example.com', '深圳市南山区', 'D002', '讲师', '2015-07-01'),
('T004', '赵敏', '123456', '女', 'zhaomin@example.com', '广州市天河区', 'D003', '教授', '2008-03-10');

-- 学生表
INSERT INTO Student (student_id, name, password, gender, email, address, department_id, degree, enrollment_date, major_id, class_id, semester) VALUES
('S2021001', '刘洋', '123456', '男', 'liuyang@example.com', '北京市朝阳区', 'D001', '本科', '2021-09-01', 'M001', 'C001', 1),
('S2021002', '王芳', '123456', '女', 'wangfang@example.com', '上海市黄浦区', 'D001', '本科', '2021-09-01', 'M001', 'C002', 1),
('S2021003', '陈杰', '123456', '男', 'chenjie@example.com', '广州市越秀区', 'D001', '本科', '2021-09-01', 'M002', 'C003', 1),
('S2021004', '赵丽', '123456', '女', 'zhaoli@example.com', '深圳市罗湖区', 'D002', '本科', '2021-09-01', 'M003', 'C004', 1),
('S2021005', '孙浩', '123456', '男', 'sunhao@example.com', '杭州市西湖区', 'D003', '本科', '2021-09-01', 'M004', 'C005', 1);

-- 课程表
INSERT INTO Course (
    course_id, 
    subject_id, 
    teacher_id, 
    semester, 
    student_count, 
    max_students, 
    class_hours,
    week_day,
    start_section,
    section_count
) VALUES
-- 周一上午1-2节连上的32学时课程
('Crs001', 'S001', 'T001', 1, 0, 100, '32', '1', 1, 2),
-- 周三下午5-8节连上的64学时课程
('Crs002', 'S002', 'T002', 1, 0, 100, '64', '3', 5, 4),
-- 周五晚上9-10节连上的32学时课程
('Crs003', 'S003', 'T001', 2, 0, 60, '32', '5', 9, 2);

-- 选课表
INSERT INTO CourseSelection (student_id, course_id, selection_date) VALUES
('S2021001', 'Crs001', '2021-09-10'),
('S2021001', 'Crs002', '2021-09-11'),
('S2021002', 'Crs001', '2021-09-10'),
('S2021002', 'Crs003', '2021-09-12'),
('S2021003', 'Crs002', '2021-09-10'),
('S2021003', 'Crs003', '2021-09-12'),
('S2021004', 'Crs004', '2021-09-13'),
('S2021005', 'Crs005', '2021-09-14');

-- 成绩表
INSERT INTO Grades (student_id, course_id, grade) VALUES
('S2021001', 'Crs001', 85.5),
('S2021001', 'Crs002', 90.0),
('S2021002', 'Crs001', 78.0),
('S2021002', 'Crs003', 88.0),
('S2021003', 'Crs002', 92.0),
('S2021003', 'Crs003', 80.0),
('S2021004', 'Crs004', 75.0),
('S2021005', 'Crs005', 83.0);

-- 7.1 更新课程的学生人数
UPDATE Course C
SET student_count = (
    SELECT COUNT(*)
    FROM CourseSelection CS
    WHERE CS.course_id = C.course_id
);

-- 7.2 检查学生的总学分和GPA
SELECT student_id, name, total_credits, gpa FROM Student;

-- 插入更多教师数据
INSERT INTO Teacher (teacher_id, name, password, gender, email, address, department_id, title, entry_date) VALUES
-- 计算机学院教师
('T001', '张伟', '123456', '男', 'zhangwei@example.com', '北京市海淀区', 'D001', '教授', '2010-09-01'),
('T002', '李娜', '123456', '女', 'lina@example.com', '北京市朝阳区', 'D001', '副教授', '2012-08-15'),
('T003', '王强', '123456', '男', 'wangqiang@example.com', '北京市西城区', 'D001', '讲师', '2015-07-01'),
('T004', '赵敏', '123456', '女', 'zhaomin@example.com', '北京市东城区', 'D001', '助教', '2018-03-10'),
('T005', '刘洋', '123456', '男', 'liuyang@example.com', '北京市海淀区', 'D001', '教授', '2009-09-01'),

-- 电子信息学院教师
('T006', '陈明', '123456', '男', 'chenming@example.com', '上海市浦东新区', 'D002', '教授', '2008-09-01'),
('T007', '周红', '123456', '女', 'zhouhong@example.com', '上海市黄浦区', 'D002', '副教授', '2011-08-15'),
('T008', '吴强', '123456', '男', 'wuqiang@example.com', '上海市徐汇区', 'D002', '讲师', '2014-07-01'),
('T009', '郑丽', '123456', '女', 'zhengli@example.com', '上海市长宁区', 'D002', '助教', '2017-03-10'),
('T010', '孙华', '123456', '男', 'sunhua@example.com', '上海市静安区', 'D002', '教授', '2007-09-01'),

-- 经济管理学院教师
('T011', '杨波', '123456', '男', 'yangbo@example.com', '广州市天河区', 'D003', '教授', '2006-09-01'),
('T012', '林芳', '123456', '女', 'linfang@example.com', '广州市越秀区', 'D003', '副教授', '2010-08-15'),
('T013', '黄强', '123456', '男', 'huangqiang@example.com', '广州市海珠区', 'D003', '讲师', '2013-07-01'),
('T014', '马丽', '123456', '女', 'mali@example.com', '广州市荔湾区', 'D003', '助教', '2016-03-10'),
('T015', '朱华', '123456', '男', 'zhuhua@example.com', '广州市白云区', 'D003', '教授', '2005-09-01');

-- 生成课程数据的函数
DELIMITER $$

CREATE PROCEDURE GenerateCourseData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_course_id VARCHAR(20);
    DECLARE v_subject_id VARCHAR(20);
    DECLARE v_teacher_id VARCHAR(20);
    DECLARE v_class_hours ENUM('16', '32', '48', '64');
    DECLARE v_week_day ENUM('1','2','3','4','5','6','7');
    DECLARE v_start_section INT;
    DECLARE v_section_count INT;
    DECLARE v_semester INT;
    
    -- 清空现有课程数据
    DELETE FROM Grades;
    DELETE FROM CourseSelection;
    DELETE FROM Course;
    
    WHILE i <= 100 DO
        -- 生成课程ID
        SET v_course_id = CONCAT('CRS', LPAD(i, 3, '0'));
        
        -- 随机选择学科ID (假设有20个学科)
        SET v_subject_id = CONCAT('S', LPAD(FLOOR(RAND() * 20) + 1, 3, '0'));
        
        -- 随机选择教师ID (15个教师)
        SET v_teacher_id = CONCAT('T', LPAD(FLOOR(RAND() * 15) + 1, 3, '0'));
        
        -- 随机选择课时
        SET v_class_hours = ELT(FLOOR(RAND() * 4) + 1, '16', '32', '48', '64');
        
        -- 随机选择学期 (1-2)
        SET v_semester = FLOOR(RAND() * 2) + 1;
        
        -- 为每个教师安排不冲突的时间
        -- 1. 先查询该教师在本学期已有的课程时间
        -- 2. 找到一个不冲突的时间段
        CALL FindNonConflictingTime(v_teacher_id, v_semester, @week_day, @start_section, @section_count);
        
        -- 插入课程数据
        INSERT INTO Course (
            course_id, 
            subject_id,
            teacher_id,
            semester,
            student_count,
            max_students,
            class_hours,
            week_day,
            start_section,
            section_count
        ) VALUES (
            v_course_id,
            v_subject_id,
            v_teacher_id,
            v_semester,
            0,
            FLOOR(RAND() * 50) + 30, -- 30-80的随机容量
            v_class_hours,
            @week_day,
            @start_section,
            @section_count
        );
        
        SET i = i + 1;
    END WHILE;
END$$

-- 查找不冲突时间的函数
CREATE PROCEDURE FindNonConflictingTime(
    IN p_teacher_id VARCHAR(20),
    IN p_semester INT,
    OUT p_week_day ENUM('1','2','3','4','5','6','7'),
    OUT p_start_section INT,
    OUT p_section_count INT
)
BEGIN
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE found BOOLEAN DEFAULT FALSE;
    DECLARE try_count INT DEFAULT 0;
    
    WHILE NOT found AND try_count < 100 DO
        -- 随机生成时间
        SET p_week_day = CAST(FLOOR(RAND() * 5) + 1 AS CHAR); -- 周一到周五
        
        -- 根据时间段随机生成起始节次和持续节数
        IF RAND() < 0.4 THEN
            -- 上午课程 (1-4节)
            SET p_start_section = FLOOR(RAND() * 3) + 1;
            SET p_section_count = FLOOR(RAND() * (5 - p_start_section)) + 1;
        ELSEIF RAND() < 0.7 THEN
            -- 下午课程 (5-8节)
            SET p_start_section = FLOOR(RAND() * 3) + 5;
            SET p_section_count = FLOOR(RAND() * (9 - p_start_section)) + 1;
        ELSE
            -- 晚上课程 (9-12节)
            SET p_start_section = FLOOR(RAND() * 3) + 9;
            SET p_section_count = FLOOR(RAND() * (13 - p_start_section)) + 1;
        END IF;
        
        -- 检查是否与现有课程冲突
        IF NOT EXISTS (
            SELECT 1 FROM Course 
            WHERE teacher_id = p_teacher_id 
            AND semester = p_semester
            AND week_day = p_week_day
            AND (
                (start_section <= p_start_section AND start_section + section_count > p_start_section)
                OR (start_section < p_start_section + p_section_count AND start_section + section_count >= p_start_section + p_section_count)
                OR (start_section >= p_start_section AND start_section + section_count <= p_start_section + p_section_count)
            )
        ) THEN
            SET found = TRUE;
        END IF;
        
        SET try_count = try_count + 1;
    END WHILE;
    
    -- 如果没找到合适时间，使用默认值
    IF NOT found THEN
        SET p_week_day = '1';
        SET p_start_section = 1;
        SET p_section_count = 2;
    END IF;
END$$

DELIMITER ;

-- 调用存储过程生成数据
CALL GenerateCourseData();

-- 清理存储过程
DROP PROCEDURE IF EXISTS GenerateCourseData;
DROP PROCEDURE IF EXISTS FindNonConflictingTime;

