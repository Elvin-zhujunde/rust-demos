const pool = require('../config/database')

const teacherController = {
  // 获取教师个人信息
  async getTeacherInfo(ctx) {
    try {
      const { teacher_id } = ctx.params

      const [rows] = await pool.execute(`
        SELECT 
          t.teacher_id,
          t.name,
          t.gender,
          t.email,
          t.address,
          t.title,
          t.entry_date,
          d.department_name,
          (
            SELECT COUNT(DISTINCT c.course_id)
            FROM Course c
            WHERE c.teacher_id = t.teacher_id
          ) as course_count,
          (
            SELECT COUNT(DISTINCT cs.student_id)
            FROM Course c
            JOIN CourseSelection cs ON c.course_id = cs.course_id
            WHERE c.teacher_id = t.teacher_id
          ) as student_count
        FROM Teacher t
        LEFT JOIN Department d ON t.department_id = d.department_id
        WHERE t.teacher_id = ?
      `, [teacher_id])

      if (rows.length === 0) {
        ctx.status = 404
        ctx.body = {
          success: false,
          message: '教师不存在'
        }
        return
      }

      ctx.body = {
        success: true,
        data: rows[0]
      }
    } catch (error) {
      console.error('获取教师信息错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取教师的授课列表
  async getTeacherCourses(ctx) {
    try {
      const { teacher_id } = ctx.params
      const { keyword } = ctx.query

      let sql = `
        SELECT 
          c.course_id,
          s.subject_id,
          s.subject_name,
          s.class_hours,
          s.credits,
          c.semester,
          c.student_count,
          c.max_students,
          c.week_day,
          c.start_section,
          c.section_count,
          CONCAT(cr.building, ' ', cr.room_number) as classroom_name,
          CASE c.week_day
            WHEN '1' THEN '周一'
            WHEN '2' THEN '周二'
            WHEN '3' THEN '周三'
            WHEN '4' THEN '周四'
            WHEN '5' THEN '周五'
            WHEN '6' THEN '周六'
            WHEN '7' THEN '周日'
          END as week_day_text,
          CONCAT('第', c.start_section, '-', c.start_section + c.section_count - 1, '节') as section_text
        FROM Course c
        JOIN Subject s ON c.subject_id = s.subject_id
        LEFT JOIN Classroom cr ON c.classroom_id = cr.classroom_id
        WHERE c.teacher_id = ?
      `
      
      const params = [teacher_id]

      if (keyword) {
        sql += ` AND s.subject_name LIKE ?`
        params.push(`%${keyword}%`)
      }

      sql += ` ORDER BY c.semester DESC, c.course_id`

      const [rows] = await pool.execute(sql, params)

      ctx.body = {
        success: true,
        data: rows
      }
    } catch (error) {
      console.error('获取教师课程列表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取课程的学生列表
  async getCourseStudents(ctx) {
    try {
      const { course_id } = ctx.params
      
      const [rows] = await pool.execute(`
        SELECT 
          s.student_id,
          s.name,
          s.gender,
          d.department_name,
          m.major_name,
          c.class_name,
          cs.selection_date
        FROM CourseSelection cs
        JOIN Student s ON cs.student_id = s.student_id
        JOIN Department d ON s.department_id = d.department_id
        JOIN Major m ON s.major_id = m.major_id
        JOIN Class c ON s.class_id = c.class_id
        WHERE cs.course_id = ?
        ORDER BY s.student_id
      `, [course_id])

      ctx.body = {
        success: true,
        data: rows
      }
    } catch (error) {
      console.error('获取课程学生名单错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取教师所教课程的所有学生
  async getTeacherStudents(ctx) {
    try {
      const { teacher_id } = ctx.params

      const [rows] = await pool.execute(`
        SELECT DISTINCT
          s.student_id,
          s.name,
          s.gender,
          s.email,
          d.department_name,
          m.major_name,
          c.class_name,
          s.enrollment_date,
          s.semester,
          s.total_credits,
          s.gpa,
          (
            SELECT COUNT(*)
            FROM CourseSelection cs
            JOIN Course co ON cs.course_id = co.course_id
            WHERE cs.student_id = s.student_id
            AND co.teacher_id = ?
          ) as course_count
        FROM Student s
        JOIN CourseSelection cs ON s.student_id = cs.student_id
        JOIN Course co ON cs.course_id = co.course_id
        LEFT JOIN Department d ON s.department_id = d.department_id
        LEFT JOIN Major m ON s.major_id = m.major_id
        LEFT JOIN Class c ON s.class_id = c.class_id
        WHERE co.teacher_id = ?
        ORDER BY s.student_id
      `, [teacher_id, teacher_id])

      ctx.body = {
        success: true,
        data: rows
      }
    } catch (error) {
      console.error('获取学生列表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取学生选课详情
  async getStudentCourseDetails(ctx) {
    try {
      const { teacher_id, student_id } = ctx.params

      const [rows] = await pool.execute(`
        SELECT 
          c.course_id,
          s.subject_name,
          s.credits,
          cs.selection_date,
          g.grade
        FROM CourseSelection cs
        JOIN Course c ON cs.course_id = c.course_id
        JOIN Subject s ON c.subject_id = s.subject_id
        LEFT JOIN Grades g ON cs.student_id = g.student_id AND cs.course_id = g.course_id
        WHERE cs.student_id = ? AND c.teacher_id = ?
        ORDER BY cs.selection_date DESC
      `, [student_id, teacher_id])

      ctx.body = {
        success: true,
        data: rows
      }
    } catch (error) {
      console.error('获取学生选课详情错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 修改学生信息
  async updateStudentInfo(ctx) {
    try {
      const { student_id } = ctx.params
      const { 
        name,
        gender,
        department_id,
        major_id,
        class_id
      } = ctx.request.body

      // 验证学生是否存在
      const [students] = await pool.execute(
        'SELECT * FROM Student WHERE student_id = ?',
        [student_id]
      )

      if (students.length === 0) {
        ctx.status = 404
        ctx.body = {
          success: false,
          message: '学生不存在'
        }
        return
      }

      // 更新学生信息
      await pool.execute(`
        UPDATE Student 
        SET name = ?,
            gender = ?,
            department_id = ?,
            major_id = ?,
            class_id = ?
        WHERE student_id = ?
      `, [name, gender, department_id, major_id, class_id, student_id])

      ctx.body = {
        success: true,
        message: '更新成功'
      }
    } catch (error) {
      console.error('更新学生信息错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取所有院系
  async getDepartments(ctx) {
    try {
      const [rows] = await pool.execute('SELECT department_id, department_name FROM Department')
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

  // 获取专业列表
  async getMajors(ctx) {
    try {
      const [rows] = await pool.query('SELECT * FROM Major')
      ctx.body = {
        success: true,
        data: rows
      }
    } catch (error) {
      console.error('获取专业列表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '获取专业列表失败'
      }
    }
  },

  // 获取班级列表
  async getClasses(ctx) {
    try {
      const [rows] = await pool.query('SELECT * FROM Class')
      ctx.body = {
        success: true,
        data: rows
      }
    } catch (error) {
      console.error('获取班级列表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '获取班级列表失败'
      }
    }
  },

  // 获取所有教师（下拉用）
  async getAllTeachers(ctx) {
    try {
      const [rows] = await pool.query('SELECT teacher_id, name FROM Teacher ORDER BY name')
      ctx.body = { success: true, data: rows }
    } catch (e) {
      ctx.status = 500
      ctx.body = { success: false, message: '获取教师列表失败' }
    }
  }
}

module.exports = teacherController 