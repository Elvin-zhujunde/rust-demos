const pool = require('../config/database')

const departmentController = {
  // 获取所有院系
  async getDepartments(ctx) {
    try {
      const [rows] = await pool.execute(`
        SELECT 
          d.department_id,
          d.department_name,
          COUNT(DISTINCT t.teacher_id) as teacher_count,
          COUNT(DISTINCT s.student_id) as student_count
        FROM Department d
        LEFT JOIN Teacher t ON d.department_id = t.department_id
        LEFT JOIN Student s ON d.department_id = s.department_id
        GROUP BY d.department_id, d.department_name
        ORDER BY d.department_id
      `)

      ctx.body = {
        success: true,
        data: rows
      }
    } catch (error) {
      console.error('获取院系列表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取院系详情（包括专业列表）
  async getDepartmentById(ctx) {
    try {
      const { id } = ctx.params

      // 获取院系基本信息
      const [departments] = await pool.execute(`
        SELECT * FROM Department WHERE department_id = ?
      `, [id])

      if (departments.length === 0) {
        ctx.status = 404
        ctx.body = {
          success: false,
          message: '院系不存在'
        }
        return
      }

      // 获取该院系的专业列表
      const [majors] = await pool.execute(`
        SELECT 
          m.*,
          COUNT(DISTINCT s.student_id) as student_count
        FROM Major m
        LEFT JOIN Student s ON m.major_id = s.major_id
        WHERE m.department_id = ?
        GROUP BY m.major_id
      `, [id])

      ctx.body = {
        success: true,
        data: {
          ...departments[0],
          majors
        }
      }
    } catch (error) {
      console.error('获取院系详情错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  }
}

module.exports = departmentController 