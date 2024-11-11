const pool = require('../config/database')

const adminController = {
  // 获取系统统计数据
  async getStatistics(ctx) {
    try {
      // 获取学生总数
      const [studentCount] = await pool.execute(
        'SELECT COUNT(*) as count FROM Student'
      )

      // 获取教师总数
      const [teacherCount] = await pool.execute(
        'SELECT COUNT(*) as count FROM Teacher'
      )

      // 获取课程总数
      const [courseCount] = await pool.execute(
        'SELECT COUNT(*) as count FROM Course'
      )

      ctx.body = {
        success: true,
        data: {
          studentCount: studentCount[0].count,
          teacherCount: teacherCount[0].count,
          courseCount: courseCount[0].count
        }
      }
    } catch (error) {
      console.error('获取统计数据错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  }
}

module.exports = adminController 