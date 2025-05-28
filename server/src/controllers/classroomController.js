const pool = require('../config/database')

// 字段白名单
const classroomFields = [
  'classroom_id',
  'building',
  'room_number',
  'capacity'
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
const validateClassroomData = (data) => {
  const errors = []
  
  if (!data.building) errors.push('教学楼不能为空')
  if (!data.room_number) errors.push('房间号不能为空')
  if (!data.capacity || data.capacity < 1) errors.push('容纳人数必须大于0')
  
  return errors
}

// 获取教室列表
exports.getClassrooms = async (ctx) => {
  const { page = 1, pageSize = 10 } = ctx.query
  const offset = (page - 1) * pageSize

  try {
    // 获取总数
    const [countResult] = await pool.query('SELECT COUNT(*) as total FROM Classroom')
    const total = countResult[0].total

    // 获取分页数据
    const [rows] = await pool.query(
      'SELECT * FROM Classroom LIMIT ? OFFSET ?',
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
    console.error('获取教室列表失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '获取教室列表失败'
    }
  }
}

// 创建教室
exports.createClassroom = async (ctx) => {
  const classroomData = ctx.request.body
  
  // 参数验证
  const errors = validateClassroomData(classroomData)
  if (errors.length > 0) {
    ctx.status = 400
    ctx.body = {
      success: false,
      message: errors.join(', ')
    }
    return
  }

  const filteredData = filterFields(classroomData, classroomFields)

  try {
    // 检查是否已存在相同的教学楼和房间号
    const [existing] = await pool.query(
      'SELECT classroom_id FROM Classroom WHERE building = ? AND room_number = ?',
      [filteredData.building, filteredData.room_number]
    )

    if (existing.length > 0) {
      ctx.status = 400
      ctx.body = {
        success: false,
        message: '该教室已存在'
      }
      return
    }

    // 生成唯一ID
    filteredData.classroom_id = `CR${Date.now()}${Math.floor(Math.random() * 1000)}`

    // 插入数据
    const [result] = await pool.query(
      'INSERT INTO Classroom SET ?',
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
    console.error('创建教室失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '创建教室失败'
    }
  }
}

// 更新教室
exports.updateClassroom = async (ctx) => {
  const { classroom_id } = ctx.params
  const classroomData = ctx.request.body
  
  // 参数验证
  const errors = validateClassroomData(classroomData)
  if (errors.length > 0) {
    ctx.status = 400
    ctx.body = {
      success: false,
      message: errors.join(', ')
    }
    return
  }

  const filteredData = filterFields(classroomData, classroomFields)

  try {
    // 检查教室是否存在
    const [existing] = await pool.query(
      'SELECT classroom_id FROM Classroom WHERE classroom_id = ?',
      [classroom_id]
    )

    if (existing.length === 0) {
      ctx.status = 404
      ctx.body = {
        success: false,
        message: '教室不存在'
      }
      return
    }

    // 检查是否与其他教室冲突
    const [conflict] = await pool.query(
      'SELECT classroom_id FROM Classroom WHERE building = ? AND room_number = ? AND classroom_id != ?',
      [filteredData.building, filteredData.room_number, classroom_id]
    )

    if (conflict.length > 0) {
      ctx.status = 400
      ctx.body = {
        success: false,
        message: '该教室已存在'
      }
      return
    }

    // 更新数据
    await pool.query(
      'UPDATE Classroom SET ? WHERE classroom_id = ?',
      [filteredData, classroom_id]
    )

    ctx.body = {
      success: true,
      message: '更新成功'
    }
  } catch (error) {
    console.error('更新教室失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '更新教室失败'
    }
  }
}

// 删除教室
exports.deleteClassroom = async (ctx) => {
  const { classroom_id } = ctx.params

  try {
    // 检查教室是否存在
    const [existing] = await pool.query(
      'SELECT classroom_id FROM Classroom WHERE classroom_id = ?',
      [classroom_id]
    )

    if (existing.length === 0) {
      ctx.status = 404
      ctx.body = {
        success: false,
        message: '教室不存在'
      }
      return
    }

    // 检查教室是否被使用
    const [used] = await pool.query(
      'SELECT COUNT(*) as count FROM Course WHERE classroom_id = ?',
      [classroom_id]
    )

    if (used[0].count > 0) {
      ctx.status = 400
      ctx.body = {
        success: false,
        message: '该教室已被课程使用，无法删除'
      }
      return
    }

    // 删除教室
    await pool.query(
      'DELETE FROM Classroom WHERE classroom_id = ?',
      [classroom_id]
    )

    ctx.body = {
      success: true,
      message: '删除成功'
    }
  } catch (error) {
    console.error('删除教室失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '删除教室失败'
    }
  }
} 