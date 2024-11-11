const Router = require('koa-router')
const authController = require('../controllers/authController')
const studentController = require('../controllers/studentController')
const teacherController = require('../controllers/teacherController')
const studentCourseController = require('../controllers/studentCourseController')
const courseController = require('../controllers/courseController')
const gradeController = require('../controllers/gradeController')

const router = new Router()

// 认证相关路由
router.post('/login', authController.login)
router.post('/register', authController.register)

// 教师信息接口
router.get('/teacher/:teacher_id', teacherController.getTeacherInfo)
router.get('/teacher-courses/:teacher_id', teacherController.getTeacherCourses)
router.get('/course-students/:course_id', teacherController.getCourseStudents)

// 学生信息接口
router.get('/student/:id', studentController.getStudentById)

// 学生课程相关接口
router.get('/student-courses/:student_id', studentCourseController.getStudentCourses)
// 这里出错了，因为没有定义 post 方法
router.post('/course-selection', studentCourseController.enrollCourse)  // 这个方法还未定义

// 选课相关路由
router.get('/available-courses', courseController.getAvailableCourses)
router.post('/select-course', courseController.selectCourse)
router.post('/drop-course', courseController.dropCourse)

// 成绩管理相关路由
router.get('/teacher-grades/:teacher_id', gradeController.getTeacherGrades)
router.post('/update-grade', gradeController.updateGrade)

// 教师的学生管理相关路由
router.get('/teacher-students/:teacher_id', teacherController.getTeacherStudents)
router.get('/teacher-student-courses/:teacher_id/:student_id', teacherController.getStudentCourseDetails)

module.exports = router 