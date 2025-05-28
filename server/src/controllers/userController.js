const pool = require('../config/database')

// 字段白名单
const studentFields = [
  'student_id', 'name', 'password', 'gender', 'email', 'address',
  'department_id', 'degree', 'enrollment_date', 'major_id', 'class_id',
  'semester', 'total_credits', 'gpa'
]
const teacherFields = [
  'teacher_id', 'name', 'password', 'gender', 'email', 'address',
  'department_id', 'title', 'entry_date'
]
function filterFields(data, fields) {
  const result = {}
  for (const key of fields) {
    if (data[key] !== undefined) result[key] = data[key]
  }
  return result
}

function formatDateField(obj, field) {
  if (obj[field]) {
    // 如果是字符串且包含T，说明是ISO格式，需截断
    if (typeof obj[field] === 'string' && obj[field].includes('T')) {
      obj[field] = obj[field].slice(0, 10)
    }
    // 如果是 Date 对象
    if (obj[field] instanceof Date) {
      obj[field] = obj[field].toISOString().slice(0, 10)
    }
  }
}

// 参数验证函数
const validateUserData = (data, role) => {
  const errors = []
  
  if (!data.name) errors.push('姓名不能为空')
  if (!['男', '女'].includes(data.gender)) errors.push('性别只能是男或女')
  if (!data.email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(data.email)) errors.push('邮箱格式不正确')
  if (!data.address) errors.push('地址不能为空')
  if (!data.department_id) errors.push('院系不能为空')
  
  if (role === 'student') {
    if (!data.student_id) errors.push('学号不能为空')
    if (!data.enrollment_date) errors.push('入学日期不能为空')
    if (!data.degree) errors.push('学位不能为空')
    if (!data.semester || data.semester < 1 || data.semester > 8) errors.push('学期必须在1-8之间')
  } else {
    if (!data.teacher_id) errors.push('工号不能为空')
    if (!data.title) errors.push('职称不能为空')
    if (!data.entry_date) errors.push('入职日期不能为空')
  }
  
  return errors
}

// 获取用户列表
exports.getUsers = async (ctx) => {
  const { role, page = 1, pageSize = 10 } = ctx.query
  const offset = (page - 1) * pageSize

  try {
    let table = role === 'student' ? 'Student' : 'Teacher'
    let idField = role === 'student' ? 'student_id' : 'teacher_id'
    let joinFields = role === 'student' 
      ? 'LEFT JOIN Department d ON s.department_id = d.department_id LEFT JOIN Major m ON s.major_id = m.major_id LEFT JOIN Class c ON s.class_id = c.class_id'
      : 'LEFT JOIN Department d ON t.department_id = d.department_id'
    let selectFields = role === 'student'
      ? 's.*, d.department_name as department_name, m.major_name as major_name, c.class_name as class_name'
      : 't.*, d.department_name as department_name'
    let alias = role === 'student' ? 's' : 't'

    // 获取总数
    const [countResult] = await pool.query(`SELECT COUNT(*) as total FROM ${table}`)
    const total = countResult[0].total

    // 获取分页数据
    const [rows] = await pool.query(
      `SELECT ${selectFields} FROM ${table} ${alias} ${joinFields} LIMIT ? OFFSET ?`,
      [parseInt(pageSize), offset]
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
    console.error('获取用户列表失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '获取用户列表失败'
    }
  }
}

// 创建用户
exports.createUser = async (ctx) => {
  const { role, ...userData } = ctx.request.body
  
  // 参数验证
  const errors = validateUserData(userData, role)
  if (errors.length > 0) {
    ctx.status = 400
    ctx.body = {
      success: false,
      message: errors.join(', ')
    }
    return
  }

  const table = role === 'student' ? 'Student' : 'Teacher'
  const idField = role === 'student' ? 'student_id' : 'teacher_id'
  const fields = role === 'student' ? studentFields : teacherFields
  const filteredData = filterFields(userData, fields)

  // 日期字段兜底格式化
  if (role === 'student') {
    formatDateField(filteredData, 'enrollment_date')
  }
  if (role === 'teacher') {
    formatDateField(filteredData, 'entry_date')
  }

  try {
    // 检查ID是否已存在
    const [existing] = await pool.query(
      `SELECT ${idField} FROM ${table} WHERE ${idField} = ?`,
      [filteredData[idField]]
    )

    if (existing.length > 0) {
      ctx.status = 400
      ctx.body = {
        success: false,
        message: `${role === 'student' ? '学号' : '工号'}已存在`
      }
      return
    }

    // 插入数据
    const [result] = await pool.query(
      `INSERT INTO ${table} SET ?`,
      [filteredData]
    )

    ctx.status = 201
    ctx.body = {
      success: true,
      message: '创建成功',
      data: {
        id: result.insertId
      }
    }
  } catch (error) {
    console.error('创建用户失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '创建用户失败'
    }
  }
}

// 更新用户
exports.updateUser = async (ctx) => {
  const { id } = ctx.params
  const { role, ...userData } = ctx.request.body
  
  // 参数验证
  const errors = validateUserData(userData, role)
  if (errors.length > 0) {
    ctx.status = 400
    ctx.body = {
      success: false,
      message: errors.join(', ')
    }
    return
  }

  const table = role === 'student' ? 'Student' : 'Teacher'
  const idField = role === 'student' ? 'student_id' : 'teacher_id'
  const fields = role === 'student' ? studentFields : teacherFields
  const filteredData = filterFields(userData, fields)

  // 日期字段兜底格式化
  if (role === 'student') {
    formatDateField(filteredData, 'enrollment_date')
  }
  if (role === 'teacher') {
    formatDateField(filteredData, 'entry_date')
  }

  try {
    // 检查用户是否存在
    const [existing] = await pool.query(
      `SELECT ${idField} FROM ${table} WHERE ${idField} = ?`,
      [id]
    )

    if (existing.length === 0) {
      ctx.status = 404
      ctx.body = {
        success: false,
        message: '用户不存在'
      }
      return
    }

    // 更新数据
    await pool.query(
      `UPDATE ${table} SET ? WHERE ${idField} = ?`,
      [filteredData, id]
    )

    ctx.body = {
      success: true,
      message: '更新成功'
    }
  } catch (error) {
    console.error('更新用户失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '更新用户失败'
    }
  }
}

// 删除用户
exports.deleteUser = async (ctx) => {
  const { id } = ctx.params
  const { role } = ctx.query
  const table = role === 'student' ? 'Student' : 'Teacher'
  const idField = role === 'student' ? 'student_id' : 'teacher_id'

  try {
    // 检查用户是否存在
    const [existing] = await pool.query(
      `SELECT ${idField} FROM ${table} WHERE ${idField} = ?`,
      [id]
    )

    if (existing.length === 0) {
      ctx.status = 404
      ctx.body = {
        success: false,
        message: '用户不存在'
      }
      return
    }

    // 删除用户
    await pool.query(
      `DELETE FROM ${table} WHERE ${idField} = ?`,
      [id]
    )

    ctx.body = {
      success: true,
      message: '删除成功'
    }
  } catch (error) {
    console.error('删除用户失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '删除用户失败'
    }
  }
} 