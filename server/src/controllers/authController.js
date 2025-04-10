const pool = require('../config/database')

const authController = {
  async login(ctx) {
    try {
      const { code, name, password, role } = ctx.request.body
      console.log({ code, name, password, role });

      // 管理员登录判断
      if (code === 'root' && password === '123456') {
        ctx.body = {
          success: true,
          role: 'admin',
          roleCode: 1,
          message: '管理员登录成功'
        }
        return
      }

      // 根据角色选择查询的表
      const tableName = role === 'teacher' ? 'Teacher' : 'Student'
      const idField = role === 'teacher' ? 'teacher_id' : 'student_id'

      // 查询用户
      const [users] = await pool.execute(`
        SELECT * FROM ${tableName} 
        WHERE ${idField} = ? AND password = ? AND name = ?
      `, [code, password, name])

      if (users.length === 0) {
        ctx.status = 401
        ctx.body = {
          success: false,
          message: '用户名或密码错误'
        }
        return
      }

      const user = users[0]
      const roleCode = role === 'teacher' ? 2 : 3

      ctx.body = {
        success: true,
        role,
        roleCode,
        userId: user[idField],
        name: user.name,
        message: '登录成功'
      }
    } catch (error) {
      console.error('登录错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  },

  async register(ctx) {
    try {
      const { role, ...data } = ctx.request.body

      // 根据角色选择不同的验证和插入逻辑
      if (role === 'student') {
        // 验证学生必填字段
        const requiredFields = ['student_id', 'name', 'password', 'gender', 'email', 'department_id', 'major_id', 'class_id']
        for (const field of requiredFields) {
          if (!data[field]) {
            ctx.status = 400
            ctx.body = {
              success: false,
              message: `${field} 是必填项`
            }
            return
          }
        }

        // 检查学号是否已存在
        const [existingStudent] = await pool.execute(
          'SELECT student_id FROM Student WHERE student_id = ?',
          [data.student_id]
        )

        if (existingStudent.length > 0) {
          ctx.status = 400
          ctx.body = {
            success: false,
            message: '学号已存在'
          }
          return
        }

        // 插入学生记录
        await pool.execute(`
          INSERT INTO Student (
            student_id,
            name,
            password,
            gender,
            email,
            address,
            department_id,
            major_id,
            class_id,
            degree,
            enrollment_date,
            semester
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, '本科', NOW(), 1)
        `, [
          data.student_id,
          data.name,
          data.password,
          data.gender,
          data.email,
          data.address || '',
          data.department_id,
          data.major_id,
          data.class_id
        ])

      } else if (role === 'teacher') {
        // 验证教师必填字段
        const requiredFields = ['teacher_id', 'name', 'password', 'gender', 'email', 'department_id', 'title']
        for (const field of requiredFields) {
          if (!data[field]) {
            ctx.status = 400
            ctx.body = {
              success: false,
              message: `${field} 是必填项`
            }
            return
          }
        }

        // 检查教师编号是否已存在
        const [existingTeacher] = await pool.execute(
          'SELECT teacher_id FROM Teacher WHERE teacher_id = ?',
          [data.teacher_id]
        )

        if (existingTeacher.length > 0) {
          ctx.status = 400
          ctx.body = {
            success: false,
            message: '教师编号已存在'
          }
          return
        }

        // 插入教师记录
        await pool.execute(`
          INSERT INTO Teacher (
            teacher_id,
            name,
            password,
            gender,
            email,
            address,
            department_id,
            title,
            entry_date
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())
        `, [
          data.teacher_id,
          data.name,
          data.password,
          data.gender,
          data.email,
          data.address || '',
          data.department_id,
          data.title
        ])
      }

      ctx.body = {
        success: true,
        message: '注册成功'
      }
    } catch (error) {
      console.error('注册错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: error.sqlMessage || '服务器错误'
      }
    }
  }
}

module.exports = authController