const pool = require('../config/database')

const studentCourseController = {
  // 获取学生的课程列表
  async getStudentCourses(ctx) {
    try {
      const { student_id } = ctx.params

      const [rows] = await pool.execute(`
        SELECT 
          c.id as course_id,
          c.name as course_name,
          t.name as teacher_name,
          c.credit,
          sc.score
        FROM student_courses sc
        LEFT JOIN courses c ON sc.course_id = c.id
        LEFT JOIN teachers t ON c.teacher_id = t.id
        WHERE sc.student_id = ? AND sc.deleted_at IS NULL
      `, [student_id])

      ctx.body = {
        success: true,
        data: rows
      }
    } catch (error) {
      console.error('获取学生课程错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 选课
  async enrollCourse(ctx) {
    try {
      const { student_id, course_id } = ctx.request.body

      // 检查是否已经选过这门课
      const [existing] = await pool.execute(`
        SELECT id FROM student_courses 
        WHERE student_id = ? AND course_id = ? AND deleted_at IS NULL
      `, [student_id, course_id])

      if (existing.length > 0) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '已经选过这门课程'
        }
        return
      }

      await pool.execute(`
        INSERT INTO student_courses (student_id, course_id, created_at, updated_at)
        VALUES (?, ?, NOW(), NOW())
      `, [student_id, course_id])

      ctx.body = {
        success: true,
        message: '选课成功'
      }
    } catch (error) {
      console.error('选课错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 更新成绩
  async updateScore(ctx) {
    try {
      const { student_id, course_id, score } = ctx.request.body

      if (score < 0 || score > 100) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '成绩必须在0-100之间'
        }
        return
      }

      await pool.execute(`
        UPDATE student_courses 
        SET score = ?, updated_at = NOW()
        WHERE student_id = ? AND course_id = ? AND deleted_at IS NULL
      `, [score, student_id, course_id])

      ctx.body = {
        success: true,
        message: '成绩更新成功'
      }
    } catch (error) {
      console.error('更新成绩错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 退课
  async dropCourse(ctx) {
    try {
      const { student_id, course_id } = ctx.request.body

      await pool.execute(`
        UPDATE student_courses 
        SET deleted_at = NOW()
        WHERE student_id = ? AND course_id = ?
      `, [student_id, course_id])

      ctx.body = {
        success: true,
        message: '退课成功'
      }
    } catch (error) {
      console.error('退课错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  }
}

module.exports = studentCourseController 