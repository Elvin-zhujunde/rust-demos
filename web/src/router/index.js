import { createRouter, createWebHistory } from 'vue-router'
import BasicLayout from '../layouts/BasicLayout.vue'
import Home from '../views/Home.vue'
import Login from '../views/login/index.vue'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/',
    component: BasicLayout,
    redirect: '/home',
    children: [
      {
        path: 'home',
        name: 'Home',
        component: Home,
        meta: { requiresAuth: true }
      },
      // 学生路由
      {
        path: 'course-selection',
        name: 'CourseSelection',
        component: () => import('../views/student/CourseSelection.vue'),
        meta: { requiresAuth: true, role: 'student' }
      },
      {
        path: 'my-courses',
        name: 'MyCourses',
        component: () => import('../views/student/MyCourses.vue'),
        meta: { requiresAuth: true, role: 'student' }
      },
      {
        path: 'grades',
        name: 'Grades',
        component: () => import('../views/student/Grades.vue'),
        meta: { requiresAuth: true, role: 'student' }
      },
      // 教师路由
      {
        path: 'teaching-courses',
        name: 'TeachingCourses',
        component: () => import('../views/teacher/TeachingCourses.vue'),
        meta: { requiresAuth: true, role: 'teacher' }
      },
      {
        path: 'grade-management',
        name: 'GradeManagement',
        component: () => import('../views/teacher/GradeManagement.vue'),
        meta: { requiresAuth: true, role: 'teacher' }
      },
      {
        path: 'student-management',
        name: 'StudentManagement',
        component: () => import('../views/teacher/StudentManagement.vue'),
        meta: { requiresAuth: true, role: 'teacher' }
      },
      // 公共路由
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('../views/Profile.vue'),
        meta: { requiresAuth: true }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const role = localStorage.getItem('role')
  const isLoggedIn = !!role

  if (to.meta.requiresAuth && !isLoggedIn) {
    next('/login')
    return
  }

  if (to.meta.role && to.meta.role !== role) {
    next('/home')
    return
  }

  if (to.path === '/login' && isLoggedIn) {
    next('/home')
    return
  }

  next()
})

export default router 