<template>
  <div class="teaching-courses">
    <a-card :bordered="false">
      <template #title>
        <h2>授课管理</h2>
      </template>

      <!-- 课程列表 -->
      <a-table
        :columns="courseColumns"
        :data-source="courseList"
        :loading="loading"
        :pagination="false"
        row-key="course_id"
        @expand="handleExpand"
      >
        <!-- 课程容量列 -->
        <template #bodyCell="{ column, record }">
          <template v-if="column.dataIndex === 'capacity'">
            {{ record.student_count }}/{{ record.max_students }}
          </template>
        </template>

        <!-- 展开的学生列表 -->
        <template #expandedRowRender="{ record }">
          <a-table
            :columns="studentColumns"
            :data-source="record.students"
            :pagination="false"
            size="small"
          />
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { message } from 'ant-design-vue'
import axios from 'axios'

const loading = ref(false)
const courseList = ref([])

// 课程表格列定义
const courseColumns = [
  {
    title: '课程名称',
    dataIndex: 'subject_name',
    width: '30%'
  },
  {
    title: '学时',
    dataIndex: 'class_hours',
    width: '15%'
  },
  {
    title: '学分',
    dataIndex: 'credits',
    width: '15%'
  },
  {
    title: '学期',
    dataIndex: 'semester',
    width: '15%'
  },
  {
    title: '选课人数',
    dataIndex: 'capacity',
    width: '25%'
  }
]

// 学生表格列定义
const studentColumns = [
  {
    title: '学号',
    dataIndex: 'student_id',
    width: '15%'
  },
  {
    title: '姓名',
    dataIndex: 'name',
    width: '10%'
  },
  {
    title: '性别',
    dataIndex: 'gender',
    width: '10%'
  },
  {
    title: '院系',
    dataIndex: 'department_name',
    width: '20%'
  },
  {
    title: '专业',
    dataIndex: 'major_name',
    width: '20%'
  },
  {
    title: '班级',
    dataIndex: 'class_name',
    width: '15%'
  },
  {
    title: '选课时间',
    dataIndex: 'selection_date',
    width: '10%',
    customRender: ({ text }) => new Date(text).toLocaleDateString('zh-CN')
  }
]

// 获取课程列表
const fetchCourses = async () => {
  loading.value = true
  try {
    const teacherId = localStorage.getItem('userId')
    const response = await axios.get(`/teacher-courses/${teacherId}`)
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

// 展开行时获取学生列表
const handleExpand = async (expanded, record) => {
  if (expanded && !record.students) {
    try {
      const response = await axios.get(`/course-students/${record.course_id}`)
      if (response.data.success) {
        record.students = response.data.data
      }
    } catch (error) {
      console.error('获取学生列表失败:', error)
      message.error('获取学生列表失败')
    }
  }
}

// 页面加载时获取课程列表
onMounted(() => {
  fetchCourses()
})
</script>

<style scoped>
.teaching-courses {
  padding: 24px;
  background: #f0f2f5;
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}
</style> 