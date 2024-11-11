<template>
  <div class="my-courses">
    <a-card :bordered="false">
      <template #title>
        <h2>我的课程</h2>
      </template>

      <a-table
        :columns="columns"
        :data-source="courseList"
        :loading="loading"
        :pagination="false"
        row-key="course_id"
      >
      </a-table>
    </a-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import axios from 'axios'

const loading = ref(false)
const courseList = ref([])

// 表格列定义
const columns = [
  {
    title: '课程名称',
    dataIndex: 'subject_name',
    width: '30%'
  },
  {
    title: '授课教师',
    dataIndex: 'teacher_name',
    width: '25%',
    customRender: ({ record }) => `${record.teacher_name} (${record.teacher_title})`
  },
  {
    title: '学时',
    dataIndex: 'class_hours',
    width: '20%'
  },
  {
    title: '学分',
    dataIndex: 'credits',
    width: '25%'
  }
]

// 获取课程列表
const fetchCourses = async () => {
  loading.value = true
  try {
    const studentId = localStorage.getItem('userId')
    const response = await axios.get(`/student-courses/${studentId}`)
    if (response.data.success) {
      courseList.value = response.data.data
    }
  } catch (error) {
    console.error('获取课程列表失败:', error)
    message.error('获取课程列表失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchCourses()
})
</script>

<style scoped>
.my-courses {
  padding: 24px;
  background: #f0f2f5;
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}
</style> 