const pool = require('../config/database')

const logController = {
  // 获取操作日志列表
  async getLogs(ctx) {
    try {
      const page = parseInt(ctx.query.page) || 1
      const pageSize = parseInt(ctx.query.pageSize) || 10
      const offset = (page - 1) * pageSize

      // 获取总数
      const [countResult] = await pool.execute(
        'SELECT COUNT(*) as total FROM OperationLog'
      )

      // 获取日志列表，使用数字类型的参数
      const [logs] = await pool.execute(`
        SELECT 
          log_id,
          user_id,
          operation_type,
          operation_time,
          table_name,
          record_id,
          description
        FROM OperationLog
        ORDER BY operation_time DESC
        LIMIT ${Number(pageSize)} OFFSET ${Number(offset)}
      `)

      ctx.body = {
        success: true,
        data: {
          list: logs,
          total: countResult[0].total,
          page: page,
          pageSize: pageSize
        }
      }
    } catch (error) {
      console.error('获取日志列表错误:', error)
      ctx.status = 500
      ctx.body = {
        success: false,
        message: '服务器错误'
      }
    }
  }
}

module.exports = logController 