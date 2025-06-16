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
const teachingTaskController = require('../controllers/teachingTaskController')
const aiController = require('../controllers/aiController')
const systemController = require('../controllers/systemController')
const userController = require('../controllers/userController')
const classroomController = require("../controllers/classroomController")

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
router.post('/course-selection', studentCourseController.enrollCourse)
router.post('/course-evaluation', studentCourseController.evaluateCourse)
router.get('/recommended-courses/:student_id', studentCourseController.getRecommendedCourses)

// 选课相关路由
router.get('/available-courses', courseController.getAvailableCourses)
router.post('/select-course', courseController.selectCourse)
router.post('/drop-course', courseController.dropCourse)
router.post('/course/:id/end', courseController.endCourse)
router.get('/course/:id/comments', courseController.getCourseComments)

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

// 教师课表相关路由
router.get('/teacher-schedule/:teacher_id', courseController.getTeacherSchedule)

// 学生课表相关路由
router.get('/student-schedule/:student_id', courseController.getStudentSchedule)

// 课程相关路由
router.get('/course/:course_id', courseController.getCourseDetail)

// 成绩相关路由
router.get('/course-grades/:course_id', gradeController.getCourseGrades)

// 班级课程相关路由
router.get('/class-courses/:student_id', courseController.getClassRequiredCourses)
router.post('/apply-class-courses', courseController.applyClassCourses)

// 教学任务相关路由
router.get('/course/:course_id/tasks', teachingTaskController.getTasksByCourse)
router.get('/task/:task_id', teachingTaskController.getTaskDetail)
router.post('/task', teachingTaskController.createTask)
router.put('/task/:task_id', teachingTaskController.updateTask)
router.delete('/task/:task_id', teachingTaskController.deleteTask)

// 文件上传路由
router.post('/upload/task-file', teachingTaskController.uploadTaskFile)

// 作业提交相关路由
router.get('/task/:task_id/submissions', teachingTaskController.getTaskSubmissions)
router.get('/task/:task_id/my-submission', teachingTaskController.getMySubmission)
router.post('/task-submission', teachingTaskController.submitAssignment)
router.put('/task-submission/:submission_id', teachingTaskController.gradeSubmission)

// AI 助手相关路由
router.get('/ai/chat-history/:student_id', aiController.getChatHistory)
router.post('/ai/send-message', aiController.sendMessage)

// 用户管理路由
router.get('/users', userController.getUsers)
router.post('/users', userController.createUser)
router.put('/users/:id', userController.updateUser)
router.delete('/users/:id', userController.deleteUser)

// 管理员课程管理
router.get('/admin/courses', courseController.adminListCourses)
router.post('/admin/courses', courseController.adminCreateCourse)
router.put('/admin/courses/:course_id', courseController.adminUpdateCourse)
router.delete('/admin/courses/:course_id', courseController.adminDeleteCourse)

// 教师、课程、教室下拉接口
router.get('/teachers', teacherController.getAllTeachers)
router.get('/subjects', courseController.getAllSubjects)
router.get('/classrooms', courseController.getAllClassrooms)

// 教室管理路由
router.get('/classroomss', classroomController.getClassrooms)
router.post('/classrooms', classroomController.createClassroom)
router.put('/classrooms/:classroom_id', classroomController.updateClassroom)
router.delete('/classrooms/:classroom_id', classroomController.deleteClassroom)

// 成绩管理路由
router.get('/grades/admin', gradeController.getGradesAdmin)

// 测试静态文件访问
router.get('/test-static', async (ctx) => {
  const fs = require('fs');
  const path = require('path');
  const publicDir = path.join(__dirname, '../../public');
  const uploadDir = path.join(publicDir, 'uploads');

  // 列出所有上传的文件
  const files = fs.readdirSync(uploadDir);

  ctx.body = {
    success: true,
    data: {
      publicDir,
      uploadDir,
      files: files.map(file => ({
        name: file,
        path: `/uploads/${file}`,
        fullPath: path.join(uploadDir, file),
        exists: fs.existsSync(path.join(uploadDir, file))
      }))
    }
  };
});

module.exports = router 