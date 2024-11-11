const pool = require('../config/database')

const courseController = {
  // 获取课程列表
  async getCourses(ctx) {
    try {
      const page = parseInt(ctx.query.page) || 1
      const pageSize = parseInt(ctx.query.pageSize) || 10
      const teacher_id = ctx.query.teacher_id
      const offset = (page - 1) * pageSize

      // 打印参数用于调试
      console.log('Query params:', { page, pageSize, offset, teacher_id })

      let sql = `
        SELECT 
          c.*,
          s.subject_name,
          t.name as teacher_name,
          s.credits,
          s.class_hours
        FROM Course c
        LEFT JOIN Subject s ON c.subject_id = s.subject_id
        LEFT JOIN Teacher t ON c.teacher_id = t.teacher_id
      `
      let countSql = `SELECT COUNT(*) as total FROM Course c`
      let params = []
      let countParams = []

      if (teacher_id) {
        sql += ` WHERE c.teacher_id = ?`
        countSql += ` WHERE c.teacher_id = ?`
        params.push(teacher_id)
        countParams.push(teacher_id)
      }

      // 添加排序和分页
      sql += ` ORDER BY c.course_id`
      sql += ` LIMIT ${pageSize} OFFSET ${offset}`

      // 打印SQL语句用于调试
      console.log('SQL:', sql)
      console.log('Params:', params)

      const [rows] = await pool.execute(sql, params)
      const [countResult] = await pool.execute(countSql, countParams)

      ctx.body = {
        success: true,
        data: {
          total: countResult[0].total,
          list: rows,
          page,
          pageSize
        }
      }
    } catch (error) {
      console.error('获取课程列表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 创建课程
  async createCourse(ctx) {
    try {
      const { 
        course_id,
        subject_id,
        teacher_id,
        semester,
        max_students
      } = ctx.request.body

      if (!course_id || !subject_id || !teacher_id || !semester || !max_students) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '所有字段都必须填写'
        }
        return
      }

      await pool.execute(`
        INSERT INTO Course (
          course_id,
          subject_id,
          teacher_id,
          semester,
          student_count,
          max_students,
          class_hours
        ) VALUES (?, ?, ?, ?, 0, ?, (
          SELECT class_hours 
          FROM Subject 
          WHERE subject_id = ?
        ))
      `, [course_id, subject_id, teacher_id, semester, max_students, subject_id])

      ctx.body = {
        success: true,
        message: '创建成功'
      }
    } catch (error) {
      console.error('创建课程错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 更新课程
  async updateCourse(ctx) {
    try {
      const { id } = ctx.params
      const { 
        subject_id,
        teacher_id,
        semester,
        max_students
      } = ctx.request.body

      if (!subject_id || !teacher_id || !semester || !max_students) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '所有字段都必须填写'
        }
        return
      }

      await pool.execute(`
        UPDATE Course 
        SET subject_id = ?,
            teacher_id = ?,
            semester = ?,
            max_students = ?,
            class_hours = (
              SELECT class_hours 
              FROM Subject 
              WHERE subject_id = ?
            )
        WHERE course_id = ?
      `, [subject_id, teacher_id, semester, max_students, subject_id, id])

      ctx.body = {
        success: true,
        message: '更新成功'
      }
    } catch (error) {
      console.error('更新课程错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 删除课程
  async deleteCourse(ctx) {
    try {
      const { id } = ctx.params

      // 首先删除相关的选课记录
      await pool.execute(`
        DELETE FROM CourseSelection 
        WHERE course_id = ?
      `, [id])

      // 删除成绩记录
      await pool.execute(`
        DELETE FROM Grades
        WHERE course_id = ?
      `, [id])

      // 删除课程记录
      await pool.execute(`
        DELETE FROM Course 
        WHERE course_id = ?
      `, [id])

      ctx.body = {
        success: true,
        message: '删除成功'
      }
    } catch (error) {
      console.error('删除课程错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取课程统计信息
  async getCourseStatistics(ctx) {
    try {
      const { course_id } = ctx.params

      // 获取基本统计信息
      const [stats] = await pool.execute(`
        SELECT 
          COUNT(DISTINCT cs.student_id) as total_students,
          AVG(g.grade) as average_score,
          COUNT(CASE WHEN g.grade >= 60 THEN 1 END) * 100.0 / COUNT(*) as pass_rate
        FROM CourseSelection cs
        LEFT JOIN Grades g ON cs.student_id = g.student_id AND cs.course_id = g.course_id
        WHERE cs.course_id = ?
      `, [course_id])

      // 获取成绩分布
      const [distribution] = await pool.execute(`
        SELECT 
          CASE 
            WHEN grade >= 90 THEN '90-100'
            WHEN grade >= 80 THEN '80-89'
            WHEN grade >= 70 THEN '70-79'
            WHEN grade >= 60 THEN '60-69'
            ELSE '0-59'
          END as range,
          COUNT(*) as count
        FROM Grades
        WHERE course_id = ?
        GROUP BY 
          CASE 
            WHEN grade >= 90 THEN '90-100'
            WHEN grade >= 80 THEN '80-89'
            WHEN grade >= 70 THEN '70-79'
            WHEN grade >= 60 THEN '60-69'
            ELSE '0-59'
          END
        ORDER BY range DESC
      `, [course_id])

      ctx.body = {
        success: true,
        data: {
          ...stats[0],
          score_distribution: distribution
        }
      }
    } catch (error) {
      console.error('获取课程统计信息错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  }
}

module.exports = courseController 