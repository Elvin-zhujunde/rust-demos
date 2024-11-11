const pool = require('../config/database')

const courseController = {
  // 获取可选课程列表
  async getAvailableCourses(ctx) {
    try {
      const { student_id } = ctx.query
      
      const [rows] = await pool.execute(`
        SELECT 
          c.course_id,
          s.subject_name,
          s.class_hours,
          s.credits,
          t.name as teacher_name,
          t.title as teacher_title,
          c.student_count,
          c.max_students,
          CASE 
            WHEN cs.student_id IS NOT NULL THEN true 
            ELSE false 
          END as is_selected
        FROM Course c
        JOIN Subject s ON c.subject_id = s.subject_id
        JOIN Teacher t ON c.teacher_id = t.teacher_id
        LEFT JOIN CourseSelection cs ON c.course_id = cs.course_id AND cs.student_id = ?
        WHERE c.student_count < c.max_students
        ORDER BY c.course_id
      `, [student_id])

      ctx.body = {
        success: true,
        data: rows
      }
    } catch (error) {
      console.error('获取可选课程列表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 选课
  async selectCourse(ctx) {
    try {
      const { student_id, course_id } = ctx.request.body

      // 检查是否已选
      const [existing] = await pool.execute(
        'SELECT * FROM CourseSelection WHERE student_id = ? AND course_id = ?',
        [student_id, course_id]
      )

      if (existing.length > 0) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '已经选过这门课程'
        }
        return
      }

      // 检查课程容量
      const [course] = await pool.execute(
        'SELECT student_count, max_students FROM Course WHERE course_id = ?',
        [course_id]
      )

      if (course[0].student_count >= course[0].max_students) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '课程已满'
        }
        return
      }

      // 开始选课事务
      const connection = await pool.getConnection()
      await connection.beginTransaction()

      try {
        // 添加选课记录
        await connection.execute(
          'INSERT INTO CourseSelection (student_id, course_id) VALUES (?, ?)',
          [student_id, course_id]
        )

        // 更新课程人数
        await connection.execute(
          'UPDATE Course SET student_count = student_count + 1 WHERE course_id = ?',
          [course_id]
        )

        await connection.commit()

        ctx.body = {
          success: true,
          message: '选课成功'
        }
      } catch (err) {
        await connection.rollback()
        throw err
      } finally {
        connection.release()
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

  // 退课
  async dropCourse(ctx) {
    try {
      const { student_id, course_id } = ctx.request.body

      // 开始退课事务
      const connection = await pool.getConnection()
      await connection.beginTransaction()

      try {
        // 删除选课记录
        await connection.execute(
          'DELETE FROM CourseSelection WHERE student_id = ? AND course_id = ?',
          [student_id, course_id]
        )

        // 更新课程人数
        await connection.execute(
          'UPDATE Course SET student_count = student_count - 1 WHERE course_id = ?',
          [course_id]
        )

        await connection.commit()

        ctx.body = {
          success: true,
          message: '退课成功'
        }
      } catch (err) {
        await connection.rollback()
        throw err
      } finally {
        connection.release()
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

module.exports = courseController 