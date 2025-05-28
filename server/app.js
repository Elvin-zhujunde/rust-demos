const Koa = require('koa')
const { koaBody } = require('koa-body')
const cors = require('koa-cors')
const serve = require('koa-static')
const path = require('path')
const fs = require('fs')
const http = require('http')
const initWebSocket = require('./src/websocket')
require('dotenv').config()

const app = new Koa()

// 创建HTTP服务器
const server = http.createServer(app.callback())

// 初始化WebSocket服务
const io = initWebSocket(server)

// 数据库连接
require('./src/config/database')

// 确保上传目录存在
const publicDir = path.join(__dirname, 'public')
const uploadDir = path.join(publicDir, 'uploads')

console.log('Public目录:', publicDir)
console.log('上传目录:', uploadDir)

if (!fs.existsSync(publicDir)) {
  fs.mkdirSync(publicDir, { recursive: true })
}
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true })
}

// CORS配置
app.use(cors({
  origin: '*',
  credentials: true,
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization', 'Accept', 'X-Student-Id'],
  exposeHeaders: ['WWW-Authenticate', 'Server-Authorization'],
  maxAge: 5
}))

// 配置静态文件服务
app.use(serve(publicDir))

// 配置请求体解析，支持文件上传
app.use(koaBody({
  multipart: true,
  formidable: {
    uploadDir: uploadDir,
    keepExtensions: true,
    maxFileSize: 10 * 1024 * 1024, // 10MB
    onFileBegin: (name, file) => {
      const ext = path.extname(file.originalFilename || '')
      file.newFilename = `${Date.now()}-${Math.round(Math.random() * 1E9)}${ext}`
      file.filepath = path.join(uploadDir, file.newFilename)
    }
  }
}))

// 错误处理中间件
app.use(async (ctx, next) => {
  try {
    ctx.set('Cache-Control', 'no-store')// 禁止缓存
    await next()
  } catch (err) {
    console.error('请求处理错误:', err)
    ctx.status = err.status || 500
    ctx.body = {
      success: false,
      message: err.message || '服务器内部错误'
    }
  }
})

// 路由配置
const router = require('./src/routes')
app.use(router.routes())
app.use(router.allowedMethods())

const PORT = process.env.PORT || 8088

// 使用HTTP服务器启动应用
server.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`)
  console.log(`WebSocket server is running`)
  console.log(`Static files served from ${publicDir}`)
  console.log(`File uploads stored in ${uploadDir}`)
}) 