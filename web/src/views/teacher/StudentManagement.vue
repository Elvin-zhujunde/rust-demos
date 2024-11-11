<template>
  <div class="student-management">
    <a-card :bordered="false">
      <template #title>
        <h2>学生管理</h2>
      </template>

      <a-table
        :columns="columns"
        :data-source="studentList"
        :loading="loading"
        :pagination="false"
        row-key="student_id"
      >
        <!-- 自定义列渲染 -->
        <template #bodyCell="{ column, record }">
          <!-- GPA列 -->
          <template v-if="column.dataIndex === 'gpa'">
            {{ Number(record.gpa).toFixed(2) || '-' }}
          </template>
          
          <!-- 入学日期列 -->
          <template v-if="column.dataIndex === 'enrollment_date'">
            {{ formatDate(record.enrollment_date) }}
          </template>

          <!-- 操作列 -->
          <template v-if="column.dataIndex === 'action'">
            <a-button 
              type="link" 
              @click="showCourseDetails(record)"
              :loading="record.detailLoading"
            >
              查看选课详情
            </a-button>
          </template>
        </template>
      </a-table>

      <!-- 选课详情弹窗 -->
      <a-modal
        v-model:open="detailVisible"
        title="选课详情"
        width="800px"
        :footer="null"
        :destroyOnClose="true"
      >
        <a-spin :spinning="detailLoading">
          <a-descriptions :column="2" bordered>
            <a-descriptions-item label="学号">
              {{ selectedStudent?.student_id }}
            </a-descriptions-item>
            <a-descriptions-item label="姓名">
              {{ selectedStudent?.name }}
            </a-descriptions-item>
            <a-descriptions-item label="班级">
              {{ selectedStudent?.class_name }}
            </a-descriptions-item>
            <a-descriptions-item label="选课数量">
              {{ selectedStudent?.course_count }}
            </a-descriptions-item>
          </a-descriptions>

          <a-divider />

          <a-table
            :columns="courseColumns"
            :data-source="courseDetails"
            :pagination="false"
            size="small"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.dataIndex === 'selection_date'">
                {{ formatDate(record.selection_date) }}
              </template>
            </template>
          </a-table>
        </a-spin>
      </a-modal>
    </a-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import axios from 'axios'

const loading = ref(false)
const detailLoading = ref(false)
const studentList = ref([])
const detailVisible = ref(false)
const selectedStudent = ref(null)
const courseDetails = ref([])

// 学生表格列定义
const columns = [
  {
    title: '学号',
    dataIndex: 'student_id',
    width: '10%'
  },
  {
    title: '姓名',
    dataIndex: 'name',
    width: '8%'
  },
  {
    title: '性别',
    dataIndex: 'gender',
    width: '6%'
  },
  {
    title: '院系',
    dataIndex: 'department_name',
    width: '12%'
  },
  {
    title: '专业',
    dataIndex: 'major_name',
    width: '15%'
  },
  {
    title: '班级',
    dataIndex: 'class_name',
    width: '12%'
  },
  {
    title: '入学日期',
    dataIndex: 'enrollment_date',
    width: '10%'
  },
  {
    title: '学期',
    dataIndex: 'semester',
    width: '6%'
  },
  {
    title: '选课数',
    dataIndex: 'course_count',
    width: '7%'
  },
  {
    title: 'GPA',
    dataIndex: 'gpa',
    width: '7%'
  },
  {
    title: '操作',
    dataIndex: 'action',
    width: '7%',
    fixed: 'right'
  }
]

// 课程详情表格列定义
const courseColumns = [
  {
    title: '课程名称',
    dataIndex: 'subject_name',
    width: '30%'
  },
  {
    title: '学分',
    dataIndex: 'credits',
    width: '20%'
  },
  {
    title: '选课时间',
    dataIndex: 'selection_date',
    width: '25%'
  },
  {
    title: '成绩',
    dataIndex: 'grade',
    width: '25%'
  }
]

// 格式化日期
const formatDate = (date) => {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('zh-CN')
}

// 获取学生列表
const fetchStudents = async () => {
  loading.value = true
  try {
    const teacherId = localStorage.getItem('userId')
    const response = await axios.get(`/teacher-students/${teacherId}`)
    if (response.data.success) {
      studentList.value = response.data.data
    }
  } catch (error) {
    console.error('获取学生列表失败:', error)
    message.error('获取学生列表失败')
  } finally {
    loading.value = false
  }
}

// 查看选课详情
const showCourseDetails = async (student) => {
  selectedStudent.value = student
  detailVisible.value = true
  detailLoading.value = true
  
  try {
    const teacherId = localStorage.getItem('userId')
    const response = await axios.get(`/teacher-student-courses/${teacherId}/${student.student_id}`)
    if (response.data.success) {
      courseDetails.value = response.data.data
    }
  } catch (error) {
    console.error('获取选课详情失败:', error)
    message.error('获取选课详情失败')
  } finally {
    detailLoading.value = false
  }
}

onMounted(() => {
  fetchStudents()
})
</script>

<style scoped>
.student-management {
  padding: 24px;
  background: #f0f2f5;
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}

:deep(.ant-descriptions) {
  margin-bottom: 20px;
}

:deep(.ant-table-wrapper) {
  margin-top: 16px;
}
</style> 