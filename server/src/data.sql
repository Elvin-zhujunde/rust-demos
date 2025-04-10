-- 创建聊天消息表
CREATE TABLE ChatMessage (
    message_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    course_id VARCHAR(20) NOT NULL,
    sender_id VARCHAR(20) NOT NULL,
    sender_type ENUM('student', 'teacher') NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE,
    INDEX idx_course_time (course_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建聊天室在线用户表
CREATE TABLE ChatOnlineUser (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    course_id VARCHAR(20) NOT NULL,
    user_id VARCHAR(20) NOT NULL,
    user_type ENUM('student', 'teacher') NOT NULL,
    last_active DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_course (course_id, user_id, user_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
