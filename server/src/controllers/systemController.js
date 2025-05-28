const pool = require('../config/database')

// 用户管理相关接口
const getUsers = async (ctx) => {
  try {
    const { page = 1, pageSize = 10 } = ctx.query
    const offset = (page - 1) * pageSize

    // 获取用户总数
    const [countResult] = await pool.execute(
      'SELECT COUNT(*) as total FROM User'
    )
    const total = countResult[0].total

    // 获取用户列表
    const [users] = await pool.execute(
      `SELECT id, username, name, email, role, status, created_at, updated_at 
       FROM User 
       ORDER BY created_at DESC 
       LIMIT ? OFFSET ?`,
      [parseInt(pageSize), offset]
    )

    ctx.body = {
      success: true,
      data: {
        items: users,
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

const createUser = async (ctx) => {
  try {
    const { username, name, email, role, password } = ctx.request.body

    // 检查用户名是否已存在
    const [existingUsers] = await pool.execute(
      'SELECT id FROM User WHERE username = ?',
      [username]
    )

    if (existingUsers.length > 0) {
      ctx.status = 400
      ctx.body = {
        success: false,
        message: '用户名已存在'
      }
      return
    }

    // 创建新用户
    const [result] = await pool.execute(
      `INSERT INTO User (username, name, email, role, password, status) 
       VALUES (?, ?, ?, ?, ?, 'active')`,
      [username, name, email, role, password]
    )

    ctx.body = {
      success: true,
      message: '创建用户成功',
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

const updateUser = async (ctx) => {
  try {
    const { id } = ctx.params
    const { name, email, role } = ctx.request.body

    await pool.execute(
      `UPDATE User 
       SET name = ?, email = ?, role = ?, updated_at = CURRENT_TIMESTAMP 
       WHERE id = ?`,
      [name, email, role, id]
    )

    ctx.body = {
      success: true,
      message: '更新用户成功'
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

const deleteUser = async (ctx) => {
  try {
    const { id } = ctx.params

    await pool.execute(
      'DELETE FROM User WHERE id = ?',
      [id]
    )

    ctx.body = {
      success: true,
      message: '删除用户成功'
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

const updateUserStatus = async (ctx) => {
  try {
    const { id } = ctx.params
    const { status } = ctx.request.body

    await pool.execute(
      `UPDATE User 
       SET status = ?, updated_at = CURRENT_TIMESTAMP 
       WHERE id = ?`,
      [status, id]
    )

    ctx.body = {
      success: true,
      message: '更新用户状态成功'
    }
  } catch (error) {
    console.error('更新用户状态失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '更新用户状态失败'
    }
  }
}

// 角色管理相关接口
const getRoles = async (ctx) => {
  try {
    const { page = 1, pageSize = 10 } = ctx.query
    const offset = (page - 1) * pageSize

    // 获取角色总数
    const [countResult] = await pool.execute(
      'SELECT COUNT(*) as total FROM Role'
    )
    const total = countResult[0].total

    // 获取角色列表
    const [roles] = await pool.execute(
      `SELECT id, name, code, description, created_at, updated_at 
       FROM Role 
       ORDER BY created_at DESC 
       LIMIT ? OFFSET ?`,
      [parseInt(pageSize), offset]
    )

    ctx.body = {
      success: true,
      data: {
        items: roles,
        total,
        page: parseInt(page),
        pageSize: parseInt(pageSize)
      }
    }
  } catch (error) {
    console.error('获取角色列表失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '获取角色列表失败'
    }
  }
}

const createRole = async (ctx) => {
  try {
    const { name, code, description } = ctx.request.body

    // 检查角色编码是否已存在
    const [existingRoles] = await pool.execute(
      'SELECT id FROM Role WHERE code = ?',
      [code]
    )

    if (existingRoles.length > 0) {
      ctx.status = 400
      ctx.body = {
        success: false,
        message: '角色编码已存在'
      }
      return
    }

    // 创建新角色
    const [result] = await pool.execute(
      `INSERT INTO Role (name, code, description) 
       VALUES (?, ?, ?)`,
      [name, code, description]
    )

    ctx.body = {
      success: true,
      message: '创建角色成功',
      data: {
        id: result.insertId
      }
    }
  } catch (error) {
    console.error('创建角色失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '创建角色失败'
    }
  }
}

const updateRole = async (ctx) => {
  try {
    const { id } = ctx.params
    const { name, code, description } = ctx.request.body

    await pool.execute(
      `UPDATE Role 
       SET name = ?, code = ?, description = ?, updated_at = CURRENT_TIMESTAMP 
       WHERE id = ?`,
      [name, code, description, id]
    )

    ctx.body = {
      success: true,
      message: '更新角色成功'
    }
  } catch (error) {
    console.error('更新角色失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '更新角色失败'
    }
  }
}

const deleteRole = async (ctx) => {
  try {
    const { id } = ctx.params

    await pool.execute(
      'DELETE FROM Role WHERE id = ?',
      [id]
    )

    ctx.body = {
      success: true,
      message: '删除角色成功'
    }
  } catch (error) {
    console.error('删除角色失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '删除角色失败'
    }
  }
}

const getRolePermissions = async (ctx) => {
  try {
    const { id } = ctx.params

    // 获取角色权限
    const [permissions] = await pool.execute(
      `SELECT p.id, p.name, p.code, p.type, p.parent_id 
       FROM Permission p 
       INNER JOIN RolePermission rp ON p.id = rp.permission_id 
       WHERE rp.role_id = ?`,
      [id]
    )

    ctx.body = {
      success: true,
      data: {
        permissions: permissions.map(p => p.id)
      }
    }
  } catch (error) {
    console.error('获取角色权限失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '获取角色权限失败'
    }
  }
}

const updateRolePermissions = async (ctx) => {
  try {
    const { id } = ctx.params
    const { permissions } = ctx.request.body

    // 开启事务
    const connection = await pool.getConnection()
    await connection.beginTransaction()

    try {
      // 删除原有权限
      await connection.execute(
        'DELETE FROM RolePermission WHERE role_id = ?',
        [id]
      )

      // 添加新权限
      if (permissions && permissions.length > 0) {
        const values = permissions.map(permissionId => [id, permissionId])
        await connection.query(
          'INSERT INTO RolePermission (role_id, permission_id) VALUES ?',
          [values]
        )
      }

      await connection.commit()
      ctx.body = {
        success: true,
        message: '更新角色权限成功'
      }
    } catch (error) {
      await connection.rollback()
      throw error
    } finally {
      connection.release()
    }
  } catch (error) {
    console.error('更新角色权限失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '更新角色权限失败'
    }
  }
}

// 权限管理相关接口
const getPermissions = async (ctx) => {
  try {
    const { page = 1, pageSize = 10 } = ctx.query
    const offset = (page - 1) * pageSize

    // 获取权限总数
    const [countResult] = await pool.execute(
      'SELECT COUNT(*) as total FROM Permission'
    )
    const total = countResult[0].total

    // 获取权限列表
    const [permissions] = await pool.execute(
      `SELECT p.*, parent.name as parent_name 
       FROM Permission p 
       LEFT JOIN Permission parent ON p.parent_id = parent.id 
       ORDER BY p.created_at DESC 
       LIMIT ? OFFSET ?`,
      [parseInt(pageSize), offset]
    )

    ctx.body = {
      success: true,
      data: {
        items: permissions,
        total,
        page: parseInt(page),
        pageSize: parseInt(pageSize)
      }
    }
  } catch (error) {
    console.error('获取权限列表失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '获取权限列表失败'
    }
  }
}

const createPermission = async (ctx) => {
  try {
    const { name, code, type, parentId, description } = ctx.request.body

    // 检查权限编码是否已存在
    const [existingPermissions] = await pool.execute(
      'SELECT id FROM Permission WHERE code = ?',
      [code]
    )

    if (existingPermissions.length > 0) {
      ctx.status = 400
      ctx.body = {
        success: false,
        message: '权限编码已存在'
      }
      return
    }

    // 创建新权限
    const [result] = await pool.execute(
      `INSERT INTO Permission (name, code, type, parent_id, description) 
       VALUES (?, ?, ?, ?, ?)`,
      [name, code, type, parentId, description]
    )

    ctx.body = {
      success: true,
      message: '创建权限成功',
      data: {
        id: result.insertId
      }
    }
  } catch (error) {
    console.error('创建权限失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '创建权限失败'
    }
  }
}

const updatePermission = async (ctx) => {
  try {
    const { id } = ctx.params
    const { name, code, type, parentId, description } = ctx.request.body

    await pool.execute(
      `UPDATE Permission 
       SET name = ?, code = ?, type = ?, parent_id = ?, description = ?, 
           updated_at = CURRENT_TIMESTAMP 
       WHERE id = ?`,
      [name, code, type, parentId, description, id]
    )

    ctx.body = {
      success: true,
      message: '更新权限成功'
    }
  } catch (error) {
    console.error('更新权限失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '更新权限失败'
    }
  }
}

const deletePermission = async (ctx) => {
  try {
    const { id } = ctx.params

    // 检查是否有子权限
    const [childPermissions] = await pool.execute(
      'SELECT id FROM Permission WHERE parent_id = ?',
      [id]
    )

    if (childPermissions.length > 0) {
      ctx.status = 400
      ctx.body = {
        success: false,
        message: '该权限下存在子权限，无法删除'
      }
      return
    }

    // 删除权限
    await pool.execute(
      'DELETE FROM Permission WHERE id = ?',
      [id]
    )

    ctx.body = {
      success: true,
      message: '删除权限成功'
    }
  } catch (error) {
    console.error('删除权限失败:', error)
    ctx.status = 500
    ctx.body = {
      success: false,
      message: '删除权限失败'
    }
  }
}

module.exports = {
  // 用户管理
  getUsers,
  createUser,
  updateUser,
  deleteUser,
  updateUserStatus,

  // 角色管理
  getRoles,
  createRole,
  updateRole,
  deleteRole,
  getRolePermissions,
  updateRolePermissions,

  // 权限管理
  getPermissions,
  createPermission,
  updatePermission,
  deletePermission
} 