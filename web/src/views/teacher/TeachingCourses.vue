<template>
  <div class="teaching-courses">
    <a-card :bordered="false">
      <template #title>
        <div class="card-title">
          <h2>授课管理</h2>
          <div class="card-title-right">
            <!-- 添加搜索框 -->
            <a-input-search
              v-model:value="searchKeyword"
              placeholder="搜索课程名称"
              style="width: 200px; margin-right: 16px"
              @search="onSearch"
              @change="onSearchChange"
            />
            <a-button type="primary" @click="showSchedule">
              查看我的课表
            </a-button>
          </div>
        </div>
      </template>

      <!-- 课程列表 -->
      <a-table
        :columns="courseColumns"
        :data-source="courseList"
        :loading="loading"
        :pagination="false"
        row-key="course_id"
      >
        <!-- 课程容量列 -->
        <template #bodyCell="{ column, record }">
          <template v-if="column.dataIndex === 'capacity'">
            {{ record.student_count }}/{{ record.max_students }}
          </template>
          
          <!-- 操作列 -->
          <template v-if="column.dataIndex === 'action'">
            <div class="action-buttons">
              <a-button type="primary" size="small" @click="showDetail(record)" style="margin-right: 8px">
                查看详情
              </a-button>
              <a-button type="primary" size="small" @click="goToGradeManagement(record)">
                成绩管理
              </a-button>
            </div>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- 课表弹窗 -->
    <a-modal
      v-model:open="scheduleVisible"
      title="我的课表"
      width="1000px"
      :footer="null"
    >
      <CourseSchedule 
        v-if="scheduleVisible"
        ref="scheduleRef"
        :teacher-id="teacherId"
      />
    </a-modal>

    <!-- 课程详情弹窗 -->
    <a-modal
      v-model:open="detailVisible"
      title="课程详情"
      width="1000px"
      :footer="null"
      :styles="{ top: '20px' }"
    >
      <div v-if="currentCourse" class="course-detail">
        <!-- 课程基本信息 -->
        <div class="course-info">
          <h3>课程信息</h3>
          <a-descriptions :column="3">
            <a-descriptions-item label="课程名称">
              {{ currentCourse.subject_name }}
            </a-descriptions-item>
            <a-descriptions-item label="学时">
              {{ currentCourse.class_hours }}
            </a-descriptions-item>
            <a-descriptions-item label="学分">
              {{ currentCourse.credits }}
            </a-descriptions-item>
            <a-descriptions-item label="上课时间">
              {{ currentCourse.week_day_text }} {{ currentCourse.section_text }}
            </a-descriptions-item>
            <a-descriptions-item label="选课人数">
              {{ currentCourse.student_count }}/{{ currentCourse.max_students }}
            </a-descriptions-item>
            <a-descriptions-item label="学期">
              第{{ currentCourse.semester }}学期
            </a-descriptions-item>
          </a-descriptions>
        </div>

        <!-- 学生名单 -->
        <div class="student-list">
          <h3>学生名单</h3>
          <a-table
            :columns="studentColumns"
            :data-source="studentList"
            :loading="studentLoading"
            :pagination="{ pageSize: 10 }"
            size="small"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.dataIndex === 'selection_date'">
                {{ new Date(record.selection_date).toLocaleDateString('zh-CN') }}
              </template>
            </template>
          </a-table>
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { message } from 'ant-design-vue'
import axios from 'axios'
import CourseSchedule from '@/components/CourseSchedule.vue'
import { useRouter } from 'vue-router'

const loading = ref(false)
const courseList = ref([])
const scheduleVisible = ref(false)
const scheduleRef = ref(null)
const teacherId = ref(localStorage.getItem('userId'))

// 课程详情相关
const detailVisible = ref(false)
const currentCourse = ref(null)
const studentList = ref([])
const studentLoading = ref(false)

// 课程表格列定义
const courseColumns = [
  {
    title: '课程名称',
    dataIndex: 'subject_name',
    width: '25%'
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
    title: '上课时间',
    dataIndex: 'course_time',
    width: '20%',
    customRender: ({ record }) => `${record.week_day_text} ${record.section_text}`
  },
  {
    title: '选课人数',
    dataIndex: 'capacity',
    width: '15%'
  },
  {
    title: '操作',
    dataIndex: 'action',
    width: '20%'
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
    width: '10%'
  }
]

// 搜索相关
const searchKeyword = ref('')

// 获取课程列表
const fetchCourses = async (keyword = '') => {
  loading.value = true
  try {
    const response = await axios.get(`/teacher-courses/${teacherId.value}`, {
      params: {
        keyword
      }
    })
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

// 搜索按钮点击
const onSearch = (value) => {
  fetchCourses(value)
}

// 搜索框输入变化
const onSearchChange = (e) => {
  fetchCourses(e.target.value)
}

// 显示课表
const showSchedule = () => {
  scheduleVisible.value = true
}

// 显示课程详情
const showDetail = async (course) => {
  currentCourse.value = course
  detailVisible.value = true
  await fetchStudentList(course.course_id)
}

// 获取学生名单
const fetchStudentList = async (courseId) => {
  studentLoading.value = true
  try {
    const response = await axios.get(`/course-students/${courseId}`)
    if (response.data.success) {
      studentList.value = response.data.data
    }
  } catch (error) {
    console.error('获取学生名单失败:', error)
    message.error('获取学生名单失败')
  } finally {
    studentLoading.value = false
  }
}

// 跳转到成绩管理
const router = useRouter()
const goToGradeManagement = (course) => {
  router.push({
    name: 'GradeManagement',
    params: { course_id: course.course_id }
  })
}

onMounted(() => {
  fetchCourses()
})
</script>

<style lang="less" scoped>
.teaching-courses {
  padding: 24px;
  background: #f0f2f5;
}

.card-title {
  display: flex;
  justify-content: space-between;
  align-items: center;

  .card-title-right {
    display: flex;
    align-items: center;
  }
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}

:deep(.ant-modal-body) {
  padding: 0;
}

.course-detail {
  padding: 24px;

  .course-info {
    margin-bottom: 24px;
    
    h3 {
      margin-bottom: 16px;
    }
  }

  .student-list {
    h3 {
      margin-bottom: 16px;
    }
  }
}

.action-buttons {
  display: flex;
  gap: 8px;
}
</style> 