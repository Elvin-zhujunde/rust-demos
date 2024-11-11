<template>
  <div class="course-selection">
    <a-card :bordered="false">
      <template #title>
        <h2>选课管理</h2>
      </template>

      <a-table
        :columns="columns"
        :data-source="courseList"
        :loading="loading"
        :pagination="false"
        row-key="course_id"
      >
        <template #bodyCell="{ column, record }">
          <!-- 课程容量列 -->
          <template v-if="column.dataIndex === 'capacity'">
            {{ record.student_count }}/{{ record.max_students }}
          </template>
          
          <!-- 操作列 -->
          <template v-if="column.dataIndex === 'action'">
            <a-button
              v-if="!record.is_selected"
              type="primary"
              size="small"
              :disabled="record.student_count >= record.max_students"
              @click="handleSelect(record)"
              :loading="record.loading"
            >
              选课
            </a-button>
            <a-button
              v-else
              type="primary"
              danger
              size="small"
              @click="handleDrop(record)"
              :loading="record.loading"
            >
              退课
            </a-button>
          </template>
        </template>
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
    width: '25%'
  },
  {
    title: '授课教师',
    dataIndex: 'teacher_name',
    width: '15%',
    customRender: ({ record }) => `${record.teacher_name} (${record.teacher_title})`
  },
  {
    title: '学时',
    dataIndex: 'class_hours',
    width: '10%'
  },
  {
    title: '学分',
    dataIndex: 'credits',
    width: '10%'
  },
  {
    title: '课程容量',
    dataIndex: 'capacity',
    width: '15%'
  },
  {
    title: '操作',
    dataIndex: 'action',
    width: '15%'
  }
]

// 获取课程列表
const fetchCourses = async () => {
  loading.value = true
  try {
    const studentId = localStorage.getItem('userId')
    const response = await axios.get(`/available-courses?student_id=${studentId}`)
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

// 选课
const handleSelect = async (course) => {
  course.loading = true
  try {
    const studentId = localStorage.getItem('userId')
    const response = await axios.post('/select-course', {
      student_id: studentId,
      course_id: course.course_id
    })
    
    if (response.data.success) {
      message.success('选课成功')
      await fetchCourses()  // 刷新课程列表
    }
  } catch (error) {
    console.error('选课失败:', error)
    message.error(error.response?.data?.message || '选课失败')
  } finally {
    course.loading = false
  }
}

// 退课
const handleDrop = async (course) => {
  course.loading = true
  try {
    const studentId = localStorage.getItem('userId')
    const response = await axios.post('/drop-course', {
      student_id: studentId,
      course_id: course.course_id
    })
    
    if (response.data.success) {
      message.success('退课成功')
      await fetchCourses()  // 刷新课程列表
    }
  } catch (error) {
    console.error('退课失败:', error)
    message.error(error.response?.data?.message || '退课失败')
  } finally {
    course.loading = false
  }
}

onMounted(() => {
  fetchCourses()
})
</script>

<style scoped>
.course-selection {
  padding: 24px;
  background: #f0f2f5;
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}
</style> 