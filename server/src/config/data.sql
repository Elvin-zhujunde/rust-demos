-- 创建聊天消息表
CREATE TABLE IF NOT EXISTS ChatMessage (
  message_id INT PRIMARY KEY AUTO_INCREMENT,
  course_id VARCHAR(20) NOT NULL,
  sender_id VARCHAR(20) NOT NULL,
  sender_type ENUM('student', 'teacher') NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE
);

-- 添加测试数据
INSERT INTO ChatMessage (course_id, sender_id, sender_type, content) VALUES
('CS101', 'T001', 'teacher', '欢迎大家来到CS101课程！'),
('CS101', 'S001', 'student', '谢谢老师！'),
('CS102', 'T002', 'teacher', '有关下周作业的问题可以在这里讨论。'),
('CS102', 'S002', 'student', '老师，我想请教一个问题...'); 


