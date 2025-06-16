const pool = require('../config/database')

// 字段白名单
const gradeFields = [
  'id',
  'course_id',
  'student_id',
  'score',
  'comment'
]

// 字段过滤函数
function filterFields(data, fields) {
  const result = {}
  for (const key of fields) {
    if (data[key] !== undefined) result[key] = data[key]
  }
  return result
}

// 参数验证函数
const validateGradeData = (data) => {
  const errors = []
  
  if (data.grade === undefined) errors.push('成绩不能为空')
  if (data.grade < 0 || data.grade > 100) errors.push('成绩必须在0-100之间')
  
  return errors
}

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

  // 获取课程的学生成绩列表
  async getCourseGrades(ctx) {
    try {
      const { course_id } = ctx.params
      
      const [rows] = await pool.execute(`
        SELECT 
          s.student_id,
          s.name,
          c.class_name,
          g.grade
        FROM CourseSelection cs
        JOIN Student s ON cs.student_id = s.student_id
        JOIN Class c ON s.class_id = c.class_id
        LEFT JOIN Grades g ON cs.student_id = g.student_id AND cs.course_id = g.course_id
        WHERE cs.course_id = ?
        ORDER BY s.student_id
      `, [course_id])

      ctx.body = {
        success: true,
        data: rows
      }
    } catch (error) {
      console.error('获取课程成绩列表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  // 获取管理员成绩列表
  async getGradesAdmin(ctx) {
    const { 
      page = 1, 
      pageSize = 10,
      course_name,
      student_name,
      student_id,
      min_score,
      max_score
    } = ctx.query
    const offset = (page - 1) * pageSize

    try {
      // 构建基础查询
      let whereConditions = []
      const queryParams = []

      // 添加筛选条件
      if (course_name) {
        whereConditions.push('s.subject_name LIKE ?')
        queryParams.push(`%${course_name}%`)
      }
      if (student_name) {
        whereConditions.push('stu.name LIKE ?')
        queryParams.push(`%${student_name}%`)
      }
      if (student_id) {
        whereConditions.push('g.student_id LIKE ?')
        queryParams.push(`%${student_id}%`)
      }
      if (min_score !== undefined) {
        whereConditions.push('g.grade >= ?')
        queryParams.push(parseFloat(min_score))
      }
      if (max_score !== undefined) {
        whereConditions.push('g.grade <= ?')
        queryParams.push(parseFloat(max_score))
      }

      // 构建 WHERE 子句
      const whereClause = whereConditions.length > 0 
        ? `WHERE ${whereConditions.join(' AND ')}` 
        : ''

      // 获取总数
      const [countResult] = await pool.query(
        `SELECT COUNT(*) as total 
         FROM Grades g
         LEFT JOIN Student stu ON g.student_id = stu.student_id
         LEFT JOIN Course c ON g.course_id = c.course_id
         LEFT JOIN Subject s ON c.subject_id = s.subject_id
         ${whereClause}`,
        queryParams
      )
      const total = countResult[0].total

      // 获取分页数据
      const [rows] = await pool.query(
        `SELECT g.*, 
           stu.name as student_name,
           s.subject_name as course_name,
           s.credits,
           s.class_hours,
           t.name as teacher_name,
           t.title as teacher_title
         FROM Grades g
         LEFT JOIN Student stu ON g.student_id = stu.student_id
         LEFT JOIN Course c ON g.course_id = c.course_id
         LEFT JOIN Subject s ON c.subject_id = s.subject_id
         LEFT JOIN Teacher t ON c.teacher_id = t.teacher_id
         ${whereClause}
         ORDER BY g.student_id DESC, g.course_id DESC
         LIMIT ? OFFSET ?`,
        [...queryParams, parseInt(pageSize), offset]
      )

      ctx.body = {
        success: true,
        data: {
          items: rows,
          total,
          page: parseInt(page),
          pageSize: parseInt(pageSize)
        }
      }
    } catch (error) {
      console.error('获取成绩列表失败:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '获取成绩列表失败'
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
        console.log('@@@@@@@@@@@', selections);
  
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
    },
}

module.exports = gradeController 