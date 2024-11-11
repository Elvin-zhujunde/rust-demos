const Router = require('koa-router')
const studentController = require('../controllers/studentController')

const router = new Router()

router.get('/students', studentController.getStudents)
router.get('/students/:id', studentController.getStudentById)
router.put('/students/:id', studentController.updateStudent)
router.delete('/students/:id', studentController.deleteStudent)

module.exports = router 