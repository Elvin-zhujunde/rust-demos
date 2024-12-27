<template>
  <div class="my-courses">
    <a-card :bordered="false">
      <template #title>
        <div class="card-title">
          <h2>我的课程</h2>
          <a-button type="primary" @click="showSchedule">
            查看我的课表
          </a-button>
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
                    <p>教师：{{ course.teacher_name }} ({{ course.teacher_title }})</p>
                    <p>教室：{{ course.classroom_name }}</p>
                    <p>课程容量：{{ course.student_count }}/{{ course.max_students }}</p>
                    <p>学分：{{ course.credits }}</p>
                  </div>
                </template>
              </a-card-meta>
              <div class="card-actions">
                <a-button
                  type="danger"
                  size="small"
                  @click.stop="handleDrop(course)"
                  :loading="course.loading"
                >
                  退课
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
        :student-id="studentId"
      />
    </a-modal>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { message } from "ant-design-vue";
import { useRouter } from 'vue-router';
import axios from "axios";
import CourseSchedule from "@/components/CourseSchedule.vue";

const router = useRouter();
const loading = ref(false);
const courseList = ref([]);
const scheduleVisible = ref(false);
const scheduleRef = ref(null);
const studentId = ref(localStorage.getItem("userId"));

// 获取课程列表
const fetchCourses = async () => {
  loading.value = true;
  try {
    const studentId = localStorage.getItem('userId');
    const response = await axios.get(`/student-courses/${studentId}`);
    if (response.data.success) {
      courseList.value = response.data.data;
    }
  } catch (error) {
    console.error("获取课程列表失败:", error);
    message.error("获取课程列表失败");
  } finally {
    loading.value = false;
  }
};

// 退课
const handleDrop = async (course) => {
  course.loading = true;
  try {
    const studentId = localStorage.getItem('userId');
    const response = await axios.post('/drop-course', {
      student_id: studentId,
      course_id: course.course_id,
    });

    if (response.data.success) {
      message.success('退课成功');
      await fetchCourses(); // 刷新课程列表
    }
  } catch (error) {
    console.error('退课失败:', error);
    message.error(error.response?.data?.message || '退课失败');
  } finally {
    course.loading = false;
  }
};

// 显示课表
const showSchedule = () => {
  scheduleVisible.value = true;
};

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
  fetchCourses();
});
</script>

<style lang="less" scoped>
.my-courses {
  padding: 24px;
  background: #f0f2f5;
}

.card-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
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

:deep(.ant-card-meta-title) {
  white-space: normal;
  line-height: 1.5;
}
</style>
