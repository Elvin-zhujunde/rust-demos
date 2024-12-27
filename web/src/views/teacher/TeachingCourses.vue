<template>
  <div class="teaching-courses">
    <a-card :bordered="false">
      <template #title>
        <div class="card-title">
          <h2>授课管理</h2>
          <div class="card-title-right">
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

      <div class="course-grid">
        <a-row :gutter="[16, 16]">
          <a-col :span="6" v-for="course in courseList" :key="course.course_id">
            <a-card 
              hoverable 
              class="course-card"
              @click="goToCourseDetail(course)"
            >
              <template #cover>
                <div class="course-card-header" :class="getTimeClass(course.start_section)">
                  {{ course.week_day_text }} {{ course.section_text }}
                </div>
              </template>
              <a-card-meta :title="course.subject_name">
                <template #description>
                  <div class="course-info">
                    <p>教室：{{ course.classroom_name }}</p>
                    <p>课程容量：{{ course.student_count }}/{{ course.max_students }}</p>
                    <p>学分：{{ course.credits }}</p>
                    <p>学时：{{ course.class_hours }}</p>
                  </div>
                </template>
              </a-card-meta>
              <div class="card-actions">
                <a-button
                  type="primary"
                  size="small"
                  @click.stop="goToGradeManagement(course)"
                  style="margin-right: 8px"
                >
                  成绩管理
                </a-button>
                <a-button
                  type="primary"
                  size="small"
                  @click.stop="showDetail(course)"
                >
                  学生名单
                </a-button>
              </div>
            </a-card>
          </a-col>
        </a-row>
      </div>
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
      title="学生名单"
      width="1000px"
      :footer="null"
      :styles="{ top: '20px' }"
    >
      <div v-if="currentCourse" class="course-detail">
        <!-- 学生名单 -->
        <div class="student-list">
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
import { useRouter } from 'vue-router'
import CourseSchedule from '@/components/CourseSchedule.vue'

const loading = ref(false)
const courseList = ref([])
const scheduleVisible = ref(false)
const scheduleRef = ref(null)
const teacherId = ref(localStorage.getItem('userId'))
const router = useRouter()

// 课程详情相关
const detailVisible = ref(false)
const currentCourse = ref(null)
const studentList = ref([])
const studentLoading = ref(false)

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
const goToGradeManagement = (course) => {
  router.push({
    name: 'GradeManagement',
    params: { course_id: course.course_id }
  })
}

// 跳转到课程详情页
const goToCourseDetail = (course) => {
  router.push({
    name: 'CourseDetail',
    params: { id: course.course_id }
  });
};

// 根据上课时间获取卡片头部的样式类
const getTimeClass = (startSection) => {
  const timeClasses = {
    1: 'morning-1',
    2: 'morning-2',
    3: 'afternoon-1',
    4: 'afternoon-2',
    5: 'evening-1',
    6: 'evening-2'
  };
  return timeClasses[startSection] || 'morning-1';
};

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

.course-grid {
  margin-top: 16px;
}

.course-card {
  height: 100%;
  transition: all 0.3s;

  &:hover {
    transform: translateY(-4px);
  }

  .course-card-header {
    padding: 16px;
    text-align: center;
    font-weight: bold;
    color: white;
  }

  .morning-1 { background-color: #1890ff; }
  .morning-2 { background-color: #52c41a; }
  .afternoon-1 { background-color: #722ed1; }
  .afternoon-2 { background-color: #eb2f96; }
  .evening-1 { background-color: #fa8c16; }
  .evening-2 { background-color: #13c2c2; }

  .course-info {
    p {
      margin-bottom: 8px;
      &:last-child {
        margin-bottom: 0;
      }
    }
  }

  .card-actions {
    margin-top: 16px;
    display: flex;
    justify-content: flex-end;
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

:deep(.ant-card-meta-title) {
  white-space: normal;
  line-height: 1.5;
}
</style> 