const Router = require('koa-router')
const pool = require('../config/database')
const authController = require('../controllers/authController')
const studentController = require('../controllers/studentController')
const teacherController = require('../controllers/teacherController')
const studentCourseController = require('../controllers/studentCourseController')
const courseController = require('../controllers/courseController')
const gradeController = require('../controllers/gradeController')
const logController = require('../controllers/logController')
const adminController = require('../controllers/adminController')

// 操作日志记录函数
const logOperation = async (ctx, next) => {
  try {
    await next()
    // 只记录成功的操作
    if (ctx.body?.success) {
      const method = ctx.method
      let operationType = 'select'
      
      // 根据HTTP方法判断操作类型
      switch (method) {
        case 'POST':
          operationType = 'create'
          break
        case 'PUT':
          operationType = 'update'
          break
        case 'DELETE':
          operationType = 'delete'
          break
      }

      // 从URL中获取操作的表名
      const pathParts = ctx.path.split('/')
      const tableName = pathParts[1] // 例如 /student/123 中的 student

      // 记录操作日志
      await pool.execute(`
        INSERT INTO OperationLog (
          user_id,
          operation_type,
          table_name,
          record_id,
          description
        ) VALUES (?, ?, ?, ?, ?)
      `, [
        'system', // 可以从ctx中获取用户ID
        operationType,
        tableName,
        pathParts[2] || null, // URL中的ID部分
        `${operationType} operation on ${tableName}`
      ])
    }
  } catch (error) {
    console.error('Log operation error:', error)
    // 继续抛出错误，不影响主流程
    throw error
  }
}

const router = new Router()

// 在所有路由之前使用日志记录中间件
router.use(logOperation)

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

// 学生信息管理相关路由
router.put('/student/:student_id', teacherController.updateStudentInfo)
router.get('/departments', teacherController.getDepartments)
router.get('/majors', teacherController.getMajors)
router.get('/classes', teacherController.getClasses)

// 日志相关路由
router.get('/logs', logController.getLogs)

// 管理员相关路由
router.get('/admin/statistics', adminController.getStatistics)

module.exports = router 