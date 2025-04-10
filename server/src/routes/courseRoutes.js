const Router = require('koa-router')
const courseController = require('../controllers/courseController')

const router = new Router()

router.get('/courses', courseController.getCourses)
router.post('/courses', courseController.createCourse)
router.put('/courses/:id', courseController.updateCourse)
router.delete('/courses/:id', courseController.deleteCourse)
router.post('/:id/end', courseController.endCourse)
router.get('/:id', courseController.getCourseDetail)

module.exports = router 