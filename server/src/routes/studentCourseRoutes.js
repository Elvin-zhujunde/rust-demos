const Router = require('koa-router')
const studentCourseController = require('../controllers/studentCourseController')

const router = new Router()

router.get('/student-courses/:student_id', studentCourseController.getStudentCourses)
router.post('/student-courses', studentCourseController.enrollCourse)
router.put('/student-courses/score', studentCourseController.updateScore)
router.delete('/student-courses', studentCourseController.dropCourse)
router.post('/course-evaluation', studentCourseController.evaluateCourse)

module.exports = router 