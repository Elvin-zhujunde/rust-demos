const pool = require('../config/database')

const gradeController = {
  // 获取教师所有课程的成绩列表
  async getTeacherGrades(ctx) {
    try {
      const { teacher_id } = ctx.params

      const [rows] = await pool.execute(`
        SELECT 
          c.course_id,
          s.subject_name,
          stu.student_id,
          stu.name as student_name,
          cl.class_name,
          g.grade
        FROM Course c
        JOIN Subject s ON c.subject_id = s.subject_id
        JOIN CourseSelection cs ON c.course_id = cs.course_id
        JOIN Student stu ON cs.student_id = stu.student_id
        LEFT JOIN Class cl ON stu.class_id = cl.class_id
        LEFT JOIN Grades g ON cs.student_id = g.student_id AND cs.course_id = g.course_id
        WHERE c.teacher_id = ?
        ORDER BY c.course_id, stu.student_id
      `, [teacher_id])

      ctx.body = {
        success: true,
        data: rows
      }
    } catch (error) {
      console.error('获取成绩列表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 更新学生成绩
  async updateGrade(ctx) {
    try {
      const { student_id, course_id, grade } = ctx.request.body

      // 验证成绩范围
      if (grade < 0 || grade > 100) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '成绩必须在0-100之间'
        }
        return
      }

      // 检查是否存在选课记录
      const [selections] = await pool.execute(
        'SELECT * FROM CourseSelection WHERE student_id = ? AND course_id = ?',
        [student_id, course_id]
      )

      if (selections.length === 0) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '未找到选课记录'
        }
        return
      }

      // 检查成绩是否已存在
      const [existing] = await pool.execute(
        'SELECT * FROM Grades WHERE student_id = ? AND course_id = ?',
        [student_id, course_id]
      )

      if (existing.length > 0) {
        // 更新成绩
        await pool.execute(
          'UPDATE Grades SET grade = ? WHERE student_id = ? AND course_id = ?',
          [grade, student_id, course_id]
        )
      } else {
        // 插入新成绩
        await pool.execute(
          'INSERT INTO Grades (student_id, course_id, grade) VALUES (?, ?, ?)',
          [student_id, course_id, grade]
        )
      }

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
  }
}

module.exports = gradeController 