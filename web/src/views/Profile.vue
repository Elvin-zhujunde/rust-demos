<template>
  <div class="profile-container">
    <a-card :bordered="false">
      <template #title>
        <h2>个人信息</h2>
      </template>

      <a-descriptions :column="2" :loading="loading">
        <!-- 教师信息 -->
        <template v-if="userRole === 'teacher'">
          <a-descriptions-item label="教师编号">
            {{ teacherInfo.teacher_id }}
          </a-descriptions-item>
          <a-descriptions-item label="姓名">
            {{ teacherInfo.name }}
          </a-descriptions-item>
          <a-descriptions-item label="性别">
            {{ teacherInfo.gender }}
          </a-descriptions-item>
          <a-descriptions-item label="职称">
            {{ teacherInfo.title }}
          </a-descriptions-item>
          <a-descriptions-item label="所属院系">
            {{ teacherInfo.department_name }}
          </a-descriptions-item>
          <a-descriptions-item label="入职日期">
            {{ formatDate(teacherInfo.entry_date) }}
          </a-descriptions-item>
          <a-descriptions-item label="邮箱">
            {{ teacherInfo.email }}
          </a-descriptions-item>
          <a-descriptions-item label="地址">
            {{ teacherInfo.address }}
          </a-descriptions-item>
          <a-descriptions-item label="授课数量">
            {{ teacherInfo.course_count }} 门
          </a-descriptions-item>
          <a-descriptions-item label="学生数量">
            {{ teacherInfo.student_count }} 人
          </a-descriptions-item>
        </template>

        <!-- 学生信息 -->
        <template v-else>
          <a-descriptions-item label="学号">
            {{ studentInfo.student_id }}
          </a-descriptions-item>
          <a-descriptions-item label="姓名">
            {{ studentInfo.name }}
          </a-descriptions-item>
          <a-descriptions-item label="性别">
            {{ studentInfo.gender }}
          </a-descriptions-item>
          <a-descriptions-item label="所属院系">
            {{ studentInfo.department_name }}
          </a-descriptions-item>
          <a-descriptions-item label="专业">
            {{ studentInfo.major_name }}
          </a-descriptions-item>
          <a-descriptions-item label="班级">
            {{ studentInfo.class_name }}
          </a-descriptions-item>
          <a-descriptions-item label="入学日期">
            {{ formatDate(studentInfo.enrollment_date) }}
          </a-descriptions-item>
          <a-descriptions-item label="学期">
            第 {{ studentInfo.semester }} 学期
          </a-descriptions-item>
          <a-descriptions-item label="总学分">
            {{ studentInfo.total_credits }}
          </a-descriptions-item>
          <a-descriptions-item label="GPA">
            {{ studentInfo.gpa }}
          </a-descriptions-item>
          <a-descriptions-item label="邮箱">
            {{ studentInfo.email }}
          </a-descriptions-item>
          <a-descriptions-item label="地址">
            {{ studentInfo.address }}
          </a-descriptions-item>
        </template>
      </a-descriptions>

      <!-- 如果是学生，显示课程信息 -->
      <template v-if="userRole === 'student' && studentInfo.courses?.length">
        <a-divider />
        <h3>选课记录</h3>
        <a-table
          :columns="courseColumns"
          :data-source="studentInfo.courses"
          :pagination="false"
          size="small"
        />
      </template>
    </a-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import axios from 'axios'

const userRole = ref(localStorage.getItem('role'))
const teacherInfo = ref({})
const studentInfo = ref({})
const loading = ref(false)

// 课程表格列定义
const courseColumns = [
  {
    title: '课程名称',
    dataIndex: 'subject_name',
    key: 'subject_name'
  },
  {
    title: '学分',
    dataIndex: 'credits',
    key: 'credits'
  },
  {
    title: '成绩',
    dataIndex: 'grade',
    key: 'grade'
  }
]

// 格式化日期
const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('zh-CN')
}

// 获取教师信息
const fetchTeacherInfo = async () => {
  loading.value = true
  try {
    const teacherId = localStorage.getItem('userId')
    const response = await axios.get(`/teacher/${teacherId}`)
    if (response.data.success) {
      teacherInfo.value = response.data.data
    }
  } catch (error) {
    console.error('获取教师信息失败:', error)
    message.error('获取个人信息失败')
  } finally {
    loading.value = false
  }
}

// 获取学生信息
const fetchStudentInfo = async () => {
  loading.value = true
  try {
    const studentId = localStorage.getItem('userId')
    const response = await axios.get(`/student/${studentId}`)
    if (response.data.success) {
      studentInfo.value = response.data.data
    }
  } catch (error) {
    console.error('获取学生信息失败:', error)
    message.error('获取个人信息失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  if (userRole.value === 'teacher') {
    fetchTeacherInfo()
  } else {
    fetchStudentInfo()
  }
})
</script>

<style scoped>
.profile-container {
  padding: 24px;
  background: #f0f2f5;
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}

:deep(.ant-descriptions-item-label) {
  font-weight: bold;
  width: 100px;
}

h3 {
  margin: 16px 0;
  font-weight: 500;
}
</style> 