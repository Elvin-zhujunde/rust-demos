const pool = require('../config/database');
const axios = require('axios');

const DEEPSEEK_API_URL = 'https://api.deepseek.com/v1/chat/completions';
const DEEPSEEK_API_KEY = 'sk-9b2ef561e0454b15aa8cf8fe208cc1da';

const aiController = {
  // 获取学生的聊天历史
  async getChatHistory(ctx) {
    try {
      const { student_id } = ctx.params;
      const [rows] = await pool.execute(
        'SELECT * FROM StudentAIChatHistory WHERE student_id = ? ORDER BY created_at ASC',
        [student_id]
      );
      ctx.body = {
        success: true,
        data: rows
      };
    } catch (error) {
      console.error('获取聊天历史错误:', error);
      ctx.status = 500;
      ctx.body = {
        success: false,
        message: '获取聊天历史失败'
      };
    }
  },

  // 发送消息给 AI 并保存对话
  async sendMessage(ctx) {
    try {
      const { student_id, creater, content } = ctx.request.body;

      if (creater === 'user') {
        // 保存用户消息
        await pool.execute(
          'INSERT INTO StudentAIChatHistory (student_id, message_type, content) VALUES (?, ?, ?)',
          [student_id, 'user', content]
        );
      } else if (creater === 'assistant') {
        // 保存 AI 回复
        await pool.execute(
          'INSERT INTO StudentAIChatHistory (student_id, message_type, content) VALUES (?, ?, ?)',
          [student_id, 'assistant', content]
        );
      }

      ctx.body = {
        success: true,
      };
    } catch (error) {
      console.error('发送消息错误:', error);
      ctx.status = 500;
      ctx.body = {
        success: false,
        message: '保存消息失败'
      };
    }
  }
};

module.exports = aiController; 