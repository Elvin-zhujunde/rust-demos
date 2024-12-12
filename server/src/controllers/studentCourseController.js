const pool = require('../config/database')

const studentCourseController = {
  // 获取学生的课程列表
  async getStudentCourses(ctx) {
    try {
      const { student_id } = ctx.params

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
          c.week_day,
          c.start_section,
          c.section_count,
          CASE c.week_day
            WHEN '1' THEN '周一'
            WHEN '2' THEN '周二'
            WHEN '3' THEN '周三'
            WHEN '4' THEN '周四'
            WHEN '5' THEN '周五'
            WHEN '6' THEN '周六'
            WHEN '7' THEN '周日'
          END as week_day_text,
          CONCAT('第', c.start_section, '-', c.start_section + c.section_count - 1, '节') as section_text,
          cs.selection_date,
          g.grade
        FROM CourseSelection cs
        JOIN Course c ON cs.course_id = c.course_id
        JOIN Subject s ON c.subject_id = s.subject_id
        JOIN Teacher t ON c.teacher_id = t.teacher_id
        LEFT JOIN Grades g ON cs.student_id = g.student_id AND cs.course_id = g.course_id
        WHERE cs.student_id = ?
        ORDER BY c.week_day, c.start_section
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

  // 添加选课方法
  async enrollCourse(ctx) {
    try {
      const { student_id, course_id } = ctx.request.body

      // 检查是否已经选过这门课
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

      // 检查课程是否存在且未满
      const [courses] = await pool.execute(`
        SELECT student_count, max_students 
        FROM Course 
        WHERE course_id = ?
      `, [course_id])

      if (courses.length === 0) {
        ctx.status = 404
        ctx.body = {
          success: false,
          message: '课程不存在'
        }
        return
      }

      const course = courses[0]
      if (course.student_count >= course.max_students) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '课程已满'
        }
        return
      }

      // 添加选课记录
      await pool.execute(
        'INSERT INTO CourseSelection (student_id, course_id) VALUES (?, ?)',
        [student_id, course_id]
      )

      // 更新课程人数
      await pool.execute(
        'UPDATE Course SET student_count = student_count + 1 WHERE course_id = ?',
        [course_id]
      )

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
  }
}

module.exports = studentCourseController 