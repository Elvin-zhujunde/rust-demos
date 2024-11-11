const Koa = require('koa')
const bodyParser = require('koa-bodyparser')
const cors = require('koa-cors')
require('dotenv').config()

const app = new Koa()

// 数据库连接
require('./src/config/database')

// CORS配置 - 允许所有来源访问
app.use(cors({
  origin: '*',
  credentials: true,
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization', 'Accept'],
  exposeHeaders: ['WWW-Authenticate', 'Server-Authorization'],
  maxAge: 5
}))

// body解析中间件
app.use(bodyParser())

// 路由配置
const router = require('./src/routes')
app.use(router.routes())
app.use(router.allowedMethods())

// 错误处理
app.on('error', (err, ctx) => {
  console.error('server error', err)
})

const PORT = process.env.PORT || 8088

app.listen(PORT, () => {
  console.log(`http://localhost:${PORT}`)
}) 