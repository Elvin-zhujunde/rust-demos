const Router = require('koa-router')
const authController = require('../controllers/authController')
const studentController = require('../controllers/studentController')
const courseController = require('../controllers/courseController')
const studentCourseController = require('../controllers/studentCourseController')
const departmentController = require('../controllers/departmentController')

const router = new Router()

// 认证相关路由
router.post('/login', authController.login)
router.post('/register', authController.register)

// 学生相关路由
router.get('/student', studentController.getStudents)
router.get('/student/:id', studentController.getStudentById)
router.put('/student/:id', studentController.updateStudent)
router.delete('/student/:id', studentController.deleteStudent)

// 课程相关路由
router.get('/course', courseController.getCourses)
router.post('/course', courseController.createCourse)
router.put('/course/:id', courseController.updateCourse)
router.delete('/course/:id', courseController.deleteCourse)

// 选课相关路由
router.get('/course-selection/:student_id', studentCourseController.getStudentCourses)
router.post('/course-selection', studentCourseController.enrollCourse)
router.delete('/course-selection', studentCourseController.dropCourse)

// 院系相关路由
router.get('/department', departmentController.getDepartments)
router.get('/department/:id', departmentController.getDepartmentById)

module.exports = router 