const Router = require('koa-router')
const authController = require('../controllers/authController')

const router = new Router()

// 登录路由
router.post('/login', authController.login)
// 注册路由
router.post('/register', authController.register)

module.exports = router