import { createRouter, createWebHistory } from 'vue-router'
import BasicLayout from '../layouts/BasicLayout.vue'
import Home from '../views/Home.vue'
import Login from '../views/login/index.vue'
import AdminLayout from '../views/admin/AdminLayout.vue'
import AdminHome from '../views/admin/Home.vue'
import AdminUsers from '../views/admin/Users.vue'
import AdminCourses from '../views/admin/Courses.vue'
import AdminClassrooms from '../views/admin/Classrooms.vue'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/login/index.vue')
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('../views/register/index.vue')
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
        path: 'ai-assistant',
        name: 'AIAssistant',
        component: () => import('../views/student/AIAssistant.vue'),
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
        path: 'grade-management/:course_id',
        name: 'GradeManagement',
        component: () => import('../views/teacher/GradeManagement.vue'),
        meta: { requiresAuth: true, role: 'teacher', hideInMenu: true }
      },
      {
        path: 'student-management',
        name: 'StudentManagement',
        component: () => import('../views/teacher/StudentManagement.vue'),
        meta: { requiresAuth: true, role: 'teacher' }
      },
      // 公共路由
      {
        path: 'course/:id',
        name: 'CourseDetail',
        component: () => import('../views/Course/CourseDetail.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('../views/Profile.vue'),
        meta: { requiresAuth: true }
      }
    ]
  },
  {
    path: '/admin',
    component: AdminLayout,
    children: [
      {
        path: 'home',
        name: 'AdminHome',
        component: AdminHome,
        meta: { requiresAuth: true, role: 'admin' }
      },
      {
        path: 'logs',
        name: 'AdminLogs',
        component: () => import('../views/admin/Logs.vue'),
        meta: { requiresAuth: true, requiresAdmin: true }
      },
      {
        path: 'users',
        name: 'AdminUsers',
        component: AdminUsers,
        meta: { requiresAuth: true, requiresAdmin: true }
      },
      {
        path: 'courses',
        name: 'AdminCourses',
        component: AdminCourses,
        meta: { requiresAuth: true, requiresAdmin: true }
      },
      {
        path: 'classrooms',
        name: 'AdminClassrooms',
        component: AdminClassrooms,
        meta: { requiresAuth: true, role: 'admin' },
      },
      {
        path: 'grades',
        name: 'AdminGrades',
        component: () => import('../views/admin/Grades.vue'),
        meta: { requiresAuth: true, requiresAdmin: true }
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


