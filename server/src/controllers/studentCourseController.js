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
          s.credits,
          s.class_hours,
          t.name as teacher_name,
          t.title as teacher_title,
          c.student_count,
          c.max_students,
          c.week_day,
          c.start_section,
          c.section_count,
          c.classroom_id,
          CONCAT(cl.building, cl.room_number) as classroom_name,
          CASE c.week_day
            WHEN '1' THEN '周一'
            WHEN '2' THEN '周二'
            WHEN '3' THEN '周三'
            WHEN '4' THEN '周四'
            WHEN '5' THEN '周五'
            WHEN '6' THEN '周六'
            WHEN '7' THEN '周日'
          END as week_day_text,
          CASE c.start_section
            WHEN 1 THEN '08:00-09:30'
            WHEN 2 THEN '09:40-11:10'
            WHEN 3 THEN '14:00-15:30'
            WHEN 4 THEN '15:40-17:10'
            WHEN 5 THEN '18:00-19:30'
            WHEN 6 THEN '19:40-21:10'
          END as time_text
        FROM CourseSelection cs
        JOIN Course c ON cs.course_id = c.course_id
        JOIN Subject s ON c.subject_id = s.subject_id
        JOIN Teacher t ON c.teacher_id = t.teacher_id
        LEFT JOIN Classroom cl ON c.classroom_id = cl.classroom_id
        WHERE cs.student_id = ?
        ORDER BY c.week_day, c.start_section
      `, [student_id])

      // 处理教室显示格式
      const formattedRows = rows.map(row => ({
        ...row,
        classroom_display: row.classroom_id ? 
          `${row.classroom_id.match(/^CR(\d)(\d{2})$/)[1]}教-${row.classroom_id.match(/^CR(\d)(\d{2})$/)[2]}` : 
          '待定',
        course_time: `${row.week_day_text} ${row.time_text}`
      }))

      ctx.body = {
        success: true,
        data: formattedRows
      }
    } catch (error) {
      console.error('获取学生课程列表错误:', error)
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