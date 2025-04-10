const db = require('../config/database')

const chatController = {
  // 保存新消息
  async saveMessage({ courseId, senderId, senderType, content }) {
    try {
      const [result] = await db.execute(
        'INSERT INTO ChatMessage (course_id, sender_id, sender_type, content) VALUES (?, ?, ?, ?)',
        [courseId, senderId, senderType, content]
      )

      const [message] = await db.execute(
        `SELECT cm.*, 
          CASE 
            WHEN cm.sender_type = 'student' THEN s.name 
            WHEN cm.sender_type = 'teacher' THEN t.name 
          END as sender_name
        FROM ChatMessage cm
        LEFT JOIN Student s ON cm.sender_type = 'student' AND cm.sender_id = s.student_id
        LEFT JOIN Teacher t ON cm.sender_type = 'teacher' AND cm.sender_id = t.teacher_id
        WHERE cm.message_id = ?`,
        [result.insertId]
      )

      return message[0]
    } catch (error) {
      console.error('保存消息失败:', error)
      throw error
    }
  },

  // 获取课程的历史消息
  async getMessages(courseId) {
    try {
      const [messages] = await db.execute(
        `SELECT cm.*, 
          CASE 
            WHEN cm.sender_type = 'student' THEN s.name 
            WHEN cm.sender_type = 'teacher' THEN t.name 
          END as sender_name
        FROM ChatMessage cm
        LEFT JOIN Student s ON cm.sender_type = 'student' AND cm.sender_id = s.student_id
        LEFT JOIN Teacher t ON cm.sender_type = 'teacher' AND cm.sender_id = t.teacher_id
        WHERE cm.course_id = ?
        ORDER BY cm.created_at ASC`,
        [courseId]
      )
      return messages
    } catch (error) {
      console.error('获取历史消息失败:', error)
      throw error
    }
  }
}

module.exports = chatController 