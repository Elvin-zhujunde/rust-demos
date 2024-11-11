const pool = require('../config/database')

const authController = {
  async login(ctx) {
    try {
      const { username, password, role } = ctx.request.body

      // 管理员登录判断
      if (username === 'root' && password === '123456') {
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
        WHERE ${idField} = ? AND password = ?
      `, [username, password])

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
      const { 
        username, // 学号/教师编号
        password,
        role,
        name,
        gender,
        email,
        address,
        department_id
      } = ctx.request.body

      // 验证必填字段
      if (!username || !password || !name || !gender || !email) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '请填写所有必填字段'
        }
        return
      }

      // 根据角色选择表
      const tableName = role === 'teacher' ? 'Teacher' : 'Student'
      const idField = role === 'teacher' ? 'teacher_id' : 'student_id'

      // 检查用户是否已存在
      const [existingUsers] = await pool.execute(`
        SELECT ${idField} FROM ${tableName} 
        WHERE ${idField} = ?
      `, [username])

      if (existingUsers.length > 0) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: role === 'teacher' ? '教师编号已存在' : '学号已存在'
        }
        return
      }

      // 检查department_id是否存在
      const [departments] = await pool.execute(
        'SELECT department_id FROM Department WHERE department_id = ?',
        [department_id]
      )

      if (departments.length === 0) {
        ctx.status = 400
        ctx.body = {
          success: false,
          message: '所选院系不存在'
        }
        return
      }

      // 创建新用户
      if (role === 'teacher') {
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
          ) VALUES (?, ?, ?, ?, ?, ?, ?, '讲师', NOW())
        `, [username, name, password, gender, email, address || '', department_id])
      } else {
        await pool.execute(`
          INSERT INTO Student (
            student_id,
            name,
            password,
            gender,
            email,
            address,
            department_id,
            degree,
            enrollment_date,
            semester
          ) VALUES (?, ?, ?, ?, ?, ?, ?, '本科', NOW(), 1)
        `, [username, name, password, gender, email, address || '', department_id])
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