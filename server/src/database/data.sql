-- 1. 删除已有数据库和用户
DROP DATABASE IF EXISTS TeachingManagementSystem;
DROP USER IF EXISTS 'student_user'@'localhost';
DROP USER IF EXISTS 'teacher_user'@'localhost';
DROP USER IF EXISTS 'admin_user'@'localhost';

-- 创建并使用数据库
CREATE DATABASE TeachingManagementSystem;
USE TeachingManagementSystem;

-- 2. 创建基础表
-- 2.1 院系表
CREATE TABLE Department (
    department_id VARCHAR(20) PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

-- 2.2 专业表
CREATE TABLE Major (
    major_id VARCHAR(20) PRIMARY KEY,
    major_name VARCHAR(100) NOT NULL,
    department_id VARCHAR(20),
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
);

-- 2.3 班级表
CREATE TABLE Class (
    class_id VARCHAR(20) PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL,
    major_id VARCHAR(20),
    FOREIGN KEY (major_id) REFERENCES Major(major_id)
);

-- 2.4 学科表
CREATE TABLE Subject (
    subject_id VARCHAR(20) PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    class_hours INT NOT NULL,
    credits DECIMAL(3,1) NOT NULL
);

-- 2.5 教师表
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

-- 2.6 学生表
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

-- 2.7 课程表
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

-- 2.8 选课表
CREATE TABLE CourseSelection (
    student_id VARCHAR(20),
    course_id VARCHAR(20),
    selection_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

-- 2.9 成绩表
CREATE TABLE Grades (
    student_id VARCHAR(20),
    course_id VARCHAR(20),
    grade DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

-- 2.10 操作日志表
CREATE TABLE OperationLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(20) NOT NULL,
    operation_type VARCHAR(10) NOT NULL,
    operation_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    table_name VARCHAR(50) NOT NULL,
    record_id VARCHAR(50),
    description VARCHAR(200)
);

-- 2.11 备份学生表
CREATE TABLE BackupStudent LIKE Student;
-- 2.12 创建教学班级-课程关联表
CREATE TABLE CourseClass (
    course_id VARCHAR(20),
    class_id VARCHAR(20),
    PRIMARY KEY (course_id, class_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES Class(class_id) ON DELETE CASCADE
);


-- 3. 创建触发器和存储过程
DELIMITER $$

-- 3.1 选课插入触发器（更新学生总学分）
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

-- 3.2 选课删除触发器（更新学生总学分）
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

-- 3.3 成绩插入触发器（更新学生GPA）
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

-- 3.4 学生删除触发器（备份学生信息）
CREATE TRIGGER trg_Student_delete
BEFORE DELETE ON Student
FOR EACH ROW
BEGIN
    INSERT INTO BackupStudent SELECT * FROM Student WHERE student_id = OLD.student_id;
END$$

-- 3.5 课程学生人数更新触发器
CREATE TRIGGER trg_CourseSelection_count_insert
AFTER INSERT ON CourseSelection
FOR EACH ROW
BEGIN
    UPDATE Course 
    SET student_count = student_count + 1
    WHERE course_id = NEW.course_id;
END$$

CREATE TRIGGER trg_CourseSelection_count_delete
AFTER DELETE ON CourseSelection
FOR EACH ROW
BEGIN
    UPDATE Course 
    SET student_count = student_count - 1
    WHERE course_id = OLD.course_id;
END$$

DELIMITER ;



-- 4. 插入基础数据
-- 4.1 院系数据


INSERT INTO Department (department_id, department_name) VALUES
('D001', '计算机学院'),
('D002', '电子信息学院'),
('D003', '经济管理学院');

-- 4.2 专业数据
INSERT INTO Major (major_id, major_name, department_id) VALUES
('M001', '计算机科学与技术', 'D001'),
('M002', '软件工程', 'D001'),
('M003', '电子信息工程', 'D002'),
('M004', '国际经济与贸易', 'D003');

-- 4.3 班级数据
INSERT INTO Class (class_id, class_name, major_id) VALUES
('C001', '计科2101班', 'M001'),
('C002', '计科2102班', 'M001'),
('C003', '软工2101班', 'M002'),
('C004', '电信2101班', 'M003'),
('C005', '国贸2101班', 'M004');

-- 4.4 学科数据
INSERT INTO Subject (subject_id, subject_name, class_hours, credits) VALUES
('S001', '高等数学', 64, 4.0),
('S002', '大学英语', 48, 3.0),
('S003', '数据结构', 48, 3.0),
('S004', '电路分析', 48, 3.0),
('S005', '国际贸易', 48, 3.0),
('S006', '程序设计基础', 64, 4.0),
('S007', '离散数学', 48, 3.0),
('S008', '计算机组成原理', 64, 4.0),
('S009', '操作系统', 48, 3.0),
('S010', '计算机网络', 48, 3.0);

-- 4.5 教师数据
INSERT INTO Teacher (teacher_id, name, password, gender, email, address, department_id, title, entry_date) VALUES
-- 计算机学院教师
('T001', '张伟', '123456', '男', 'zhangwei@example.com', '北京市海淀区', 'D001', '教授', '2010-09-01'),
('T002', '李娜', '123456', '女', 'lina@example.com', '北京市朝阳区', 'D001', '副教授', '2012-08-15'),
('T003', '王强', '123456', '男', 'wangqiang@example.com', '北京市西城区', 'D001', '讲师', '2015-07-01'),
('T004', '赵敏', '123456', '女', 'zhaomin@example.com', '北京市东城区', 'D001', '助教', '2018-03-10'),
('T005', '刘洋', '123456', '男', 'liuyang@example.com', '北京市海淀区', 'D001', '教授', '2009-09-01'),

-- 电子信息学院教师
('T006', '陈明', '123456', '男', 'chenming@example.com', '上海市浦东新区', 'D002', '教授', '2008-09-01'),
('T007', '周红', '123456', '女', 'zhouhong@example.com', '上海市黄浦��', 'D002', '副教授', '2011-08-15'),
('T008', '吴强', '123456', '男', 'wuqiang@example.com', '上海市徐汇区', 'D002', '讲师', '2014-07-01'),
('T009', '郑丽', '123456', '女', 'zhengli@example.com', '上海市长宁区', 'D002', '助教', '2017-03-10'),
('T010', '孙华', '123456', '男', 'sunhua@example.com', '上海市静安区', 'D002', '教授', '2007-09-01'),

-- 经济管理学院教师
('T011', '杨波', '123456', '男', 'yangbo@example.com', '广州市天河区', 'D003', '教授', '2006-09-01'),
('T012', '林芳', '123456', '女', 'linfang@example.com', '广州市越秀区', 'D003', '副教授', '2010-08-15'),
('T013', '黄强', '123456', '男', 'huangqiang@example.com', '广州市海珠区', 'D003', '讲师', '2013-07-01'),
('T014', '马丽', '123456', '女', 'mali@example.com', '广州市荔湾区', 'D003', '助教', '2016-03-10'),
('T015', '朱华', '123456', '男', 'zhuhua@example.com', '广州市白云区', 'D003', '教授', '2005-09-01');

-- 学生表
INSERT INTO Student (student_id, name, password, gender, email, address, department_id, degree, enrollment_date, major_id, class_id, semester) VALUES
('S2021001', '刘洋', '123456', '男', 'liuyang@example.com', '北京市朝阳区', 'D001', '本科', '2021-09-01', 'M001', 'C001', 1),
('S2021002', '王芳', '123456', '女', 'wangfang@example.com', '上海市黄浦区', 'D001', '本科', '2021-09-01', 'M001', 'C002', 1),
('S2021003', '陈杰', '123456', '男', 'chenjie@example.com', '广州市越秀区', 'D001', '本科', '2021-09-01', 'M002', 'C003', 1),
('S2021004', '赵丽', '123456', '女', 'zhaoli@example.com', '深圳市罗湖区', 'D002', '本科', '2021-09-01', 'M003', 'C004', 1),
('S2021005', '孙浩', '123456', '男', 'sunhao@example.com', '杭州市西湖区', 'D003', '本科', '2021-09-01', 'M004', 'C005', 1);

-- 5. 生成课程数据
DELIMITER $$

CREATE PROCEDURE GenerateCourseData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_course_id VARCHAR(20);
    DECLARE v_subject_id VARCHAR(20);
    DECLARE v_teacher_id VARCHAR(20);
    DECLARE v_class_hours ENUM('16', '32', '48', '64');
    DECLARE v_semester INT;
    DECLARE v_week_day ENUM('1','2','3','4','5','6','7');
    DECLARE v_start_section INT;
    DECLARE v_section_count INT;
    DECLARE max_attempts INT DEFAULT 50;
    DECLARE attempt_count INT;
    DECLARE success BOOLEAN;
    
    -- 清空现有课程数据
    DELETE FROM Grades;
    DELETE FROM CourseSelection;
    DELETE FROM Course;
    
    outer_loop: WHILE i <= 100 DO
        SET success = FALSE;
        SET attempt_count = 0;
        SET v_course_id = CONCAT('CRS', LPAD(i, 3, '0'));
        
        -- 随机选择学科
        SET v_subject_id = CONCAT('S', LPAD(FLOOR(RAND() * 10) + 1, 3, '0'));
        
        -- 随机选择教师
        SET v_teacher_id = CONCAT('T', LPAD(FLOOR(RAND() * 15) + 1, 3, '0'));
        
        -- 根据课时设置每周课时数
        SET v_class_hours = ELT(FLOOR(RAND() * 4) + 1, '16', '32', '48', '64');
        SET v_section_count = CAST(v_class_hours AS SIGNED) DIV 16; -- 16课时对应1节/周
        
        -- 随机选择学期
        SET v_semester = FLOOR(RAND() * 2) + 1;
        
        -- 尝试找到不冲突的时间段
        WHILE attempt_count < max_attempts AND NOT success DO
            -- 随机选择周几 (1-5)
            SET v_week_day = CAST(FLOOR(RAND() * 5) + 1 AS CHAR);
            
            -- 随机选择时间段
            CASE FLOOR(RAND() * 3)
                WHEN 0 THEN -- 上午 1-4
                    SET v_start_section = FLOOR(RAND() * (5 - v_section_count)) + 1;
                WHEN 1 THEN -- 下午 5-8
                    SET v_start_section = FLOOR(RAND() * (9 - v_section_count - 4)) + 5;
                ELSE -- 晚上 9-12
                    SET v_start_section = FLOOR(RAND() * (13 - v_section_count - 8)) + 9;
            END CASE;
            
            -- 检查该教师在这个时间段是否有课
            IF NOT EXISTS (
                SELECT 1 
                FROM Course 
                WHERE teacher_id = v_teacher_id 
                AND semester = v_semester
                AND week_day = v_week_day
                AND (
                    -- 检查是否有时间重叠
                    (start_section <= v_start_section AND start_section + section_count > v_start_section)
                    OR (start_section < v_start_section + v_section_count AND start_section + section_count >= v_start_section + v_section_count)
                    OR (start_section >= v_start_section AND start_section < v_start_section + v_section_count)
                )
            ) THEN
                -- 找到合适的时间段，插入课程
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
                    FLOOR(RAND() * 50) + 30,
                    v_class_hours,
                    v_week_day,
                    v_start_section,
                    v_section_count
                );
                
                SET success = TRUE;
            END IF;
            
            SET attempt_count = attempt_count + 1;
        END WHILE;
        
        -- 如果尝试次数用完还没找到合适时间，跳过这门课
        IF NOT success THEN
            SET i = i + 1;
            ITERATE outer_loop;
        END IF;
        
        SET i = i + 1;
    END WHILE outer_loop;
END$$

DELIMITER ;

-- 调用存储过程生成课程数据
CALL GenerateCourseData();

-- 清理存储过程
DROP PROCEDURE IF EXISTS GenerateCourseData;

-- 添加一些测试数据
INSERT INTO CourseClass (course_id, class_id) VALUES
('CRS001', 'C001'),  -- 高等数学课程分配给计科一班
('CRS001', 'C002'),  -- 高等数学课程也分配给计科二班
('CRS002', 'C001'),  -- 大学英语课程分配给计科一班
('CRS003', 'C003');  -- 数据结构课程分配给软件一班

-- 6. 创建视图
-- 6.1 课程信息与授课教师视图
CREATE VIEW vw_Course_Teacher AS
SELECT 
    C.course_id,
    S.subject_name,
    C.semester,
    C.class_hours,
    C.student_count,
    C.max_students,
    C.week_day,
    C.start_section,
    C.section_count,
    T.teacher_id,
    T.name AS teacher_name,
    T.title,
    T.department_id
FROM Course C
JOIN Subject S ON C.subject_id = S.subject_id
JOIN Teacher T ON C.teacher_id = T.teacher_id;

-- 6.2 学生成绩-课程信息-授课教师视图
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

-- 6.3 学生选课方案视图
CREATE VIEW vw_Student_CourseSelection AS
SELECT
    CS.student_id,
    Stu.name AS student_name,
    CS.course_id,
    S.subject_name,
    S.credits,
    C.semester,
    C.week_day,
    C.start_section,
    C.section_count
FROM CourseSelection CS
JOIN Student Stu ON CS.student_id = Stu.student_id
JOIN Course C ON CS.course_id = C.course_id
JOIN Subject S ON C.subject_id = S.subject_id;


-- 7. 设置用户权限
-- 7.1 创建用户
CREATE USER 'student_user'@'localhost' IDENTIFIED BY '123456';
CREATE USER 'teacher_user'@'localhost' IDENTIFIED BY '123456';
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY '123456';

-- 7.2 分配权限
-- 学生用户权限
GRANT SELECT ON TeachingManagementSystem.Student TO 'student_user'@'localhost';
GRANT SELECT ON TeachingManagementSystem.Course TO 'student_user'@'localhost';
GRANT SELECT, INSERT, DELETE ON TeachingManagementSystem.CourseSelection TO 'student_user'@'localhost';
GRANT SELECT ON TeachingManagementSystem.Subject TO 'student_user'@'localhost';
GRANT SELECT ON TeachingManagementSystem.vw_Student_CourseSelection TO 'student_user'@'localhost';

-- 教师用户权限
GRANT SELECT ON TeachingManagementSystem.* TO 'teacher_user'@'localhost';
GRANT INSERT, UPDATE ON TeachingManagementSystem.Grades TO 'teacher_user'@'localhost';
GRANT SELECT ON TeachingManagementSystem.vw_Course_Teacher TO 'teacher_user'@'localhost';
GRANT SELECT ON TeachingManagementSystem.vw_Student_Grades_Course_Teacher TO 'teacher_user'@'localhost';

-- 管理员用户权限
GRANT ALL PRIVILEGES ON TeachingManagementSystem.* TO 'admin_user'@'localhost';

FLUSH PRIVILEGES;