const pool = require('../config/database')

const studentController = {
  // 获取学生列表
  async getStudents(ctx) {
    try {
      const page = parseInt(ctx.query.page) || 1
      const pageSize = parseInt(ctx.query.pageSize) || 10
      const keyword = ctx.query.keyword || ''
      const offset = (page - 1) * pageSize

      // 打印参数用于调试
      console.log('Query params:', { page, pageSize, offset, keyword })

      let sql = `
        SELECT s.*, d.department_name, m.major_name, c.class_name
        FROM Student s
        LEFT JOIN Department d ON s.department_id = d.department_id
        LEFT JOIN Major m ON s.major_id = m.major_id
        LEFT JOIN Class c ON s.class_id = c.class_id
      `
      let countSql = `SELECT COUNT(*) as total FROM Student s`
      let params = []
      let countParams = []

      // 如果有关键字搜索
      if (keyword) {
        sql += ` WHERE s.name LIKE CONCAT('%', ?, '%') OR s.student_id LIKE CONCAT('%', ?, '%')`
        countSql += ` WHERE s.name LIKE CONCAT('%', ?, '%') OR s.student_id LIKE CONCAT('%', ?, '%')`
        params.push(keyword, keyword)
        countParams.push(keyword, keyword)
      }

      // 添加排序和分页
      sql += ` ORDER BY s.student_id`
      sql += ` LIMIT ${pageSize} OFFSET ${offset}`

      // 打印SQL语句用于调试
      console.log('SQL:', sql)
      console.log('Params:', params)

      // 执行查询
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
      console.error('获取学生列表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取学生详情
  async getStudentById(ctx) {
    try {
      const { id } = ctx.params

      // 获取学生基本信息
      const [students] = await pool.execute(`
        SELECT s.*, d.department_name, m.major_name, c.class_name
        FROM Student s
        LEFT JOIN Department d ON s.department_id = d.department_id
        LEFT JOIN Major m ON s.major_id = m.major_id
        LEFT JOIN Class c ON s.class_id = c.class_id
        WHERE s.student_id = ?
      `, [id])

      if (students.length === 0) {
        ctx.status = 404
        ctx.body = {
          success: false,
          message: '学生不存在'
        }
        return
      }

      // 获取学生的课程信息
      const [courses] = await pool.execute(`
        SELECT 
          c.course_id,
          s.subject_name,
          s.credits,
          g.grade
        FROM CourseSelection cs
        LEFT JOIN Course c ON cs.course_id = c.course_id
        LEFT JOIN Subject s ON c.subject_id = s.subject_id
        LEFT JOIN Grades g ON cs.student_id = g.student_id AND cs.course_id = g.course_id
        WHERE cs.student_id = ?
      `, [id])

      ctx.body = {
        success: true,
        data: {
          ...students[0],
          courses
        }
      }
    } catch (error) {
      console.error('获取学生详情错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 更新学生信息
  async updateStudent(ctx) {
    try {
      const { id } = ctx.params
      const { 
        name, 
        gender,
        email,
        address,
        department_id,
        major_id,
        class_id 
      } = ctx.request.body

      await pool.execute(`
        UPDATE Student 
        SET name = ?, 
            gender = ?,
            email = ?,
            address = ?,
            department_id = ?,
            major_id = ?,
            class_id = ?
        WHERE student_id = ?
      `, [name, gender, email, address, department_id, major_id, class_id, id])

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

  // 删除学生
  async deleteStudent(ctx) {
    try {
      const { id } = ctx.params

      // 首先删除相关的选课记录
      await pool.execute(`
        DELETE FROM CourseSelection 
        WHERE student_id = ?
      `, [id])

      // 删除成绩记录
      await pool.execute(`
        DELETE FROM Grades
        WHERE student_id = ?
      `, [id])

      // 删除学生记录
      await pool.execute(`
        DELETE FROM Student 
        WHERE student_id = ?
      `, [id])

      ctx.body = {
        success: true,
        message: '删除成功'
      }
    } catch (error) {
      console.error('删除学生错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  }
}

module.exports = studentController 