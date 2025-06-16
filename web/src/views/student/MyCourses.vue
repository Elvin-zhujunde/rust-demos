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

      <!-- 课程状态切换 -->
      <a-tabs v-model:activeKey="activeTab">
        <a-tab-pane key="ongoing" tab="进行中的课程">
          <div class="course-grid">
            <a-row :gutter="[16, 16]">
              <a-col
                :span="6"
                v-for="course in ongoingCourses"
                :key="course.course_id"
              >
                <a-card
                  hoverable
                  class="course-card"
                  @click="goToCourseDetail(course)"
                >
                  <template #cover>
                    <div
                      class="course-card-header"
                      :class="getTimeClass(course.start_section)"
                    >
                      {{ course.week_day_text }} {{ course.section_text }}
                    </div>
                  </template>
                  <a-card-meta :title="course.subject_name">
                    <template #description>
                      <div class="course-info">
                        <p>
                          教师：{{ course.teacher_name }} ({{
                            course.teacher_title
                          }})
                        </p>
                        <p>教室：{{ course.classroom_name }}</p>
                        <p>
                          课程容量：{{ course.student_count }}/{{
                            course.max_students
                          }}
                        </p>
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
        </a-tab-pane>

        <a-tab-pane key="completed" tab="已完成的课程">
          <div class="course-grid">
            <a-row :gutter="[16, 16]">
              <a-col
                :span="6"
                v-for="course in completedCourses"
                :key="course.course_id"
              >
                <a-card
                  hoverable
                  class="course-card"
                  @click="goToCourseDetail(course)"
                >
                  <template #cover>
                    <div class="course-card-header completed">
                      {{ course.week_day_text }} {{ course.section_text }}
                    </div>
                  </template>
                  <a-card-meta :title="course.subject_name">
                    <template #description>
                      <div class="course-info">
                        <p>
                          教师：{{ course.teacher_name }} ({{
                            course.teacher_title
                          }})
                        </p>
                        <p>教室：{{ course.classroom_name }}</p>
                        <p>
                          课程容量：{{ course.student_count }}/{{
                            course.max_students
                          }}
                        </p>
                        <p>学分：{{ course.credits }}</p>
                        <p>
                          状态：{{ course.status === 1 ? "待评价" : "已评价" }}
                        </p>
                      </div>
                    </template>
                  </a-card-meta>
                  <div class="card-actions">
                    <a-button
                      v-if="course.status === 1"
                      type="primary"
                      size="small"
                      @click.stop="showEvaluationModal(course)"
                    >
                      评价课程
                    </a-button>
                    <a-tag v-else color="green">已评价</a-tag>
                  </div>
                </a-card>
              </a-col>
            </a-row>
          </div>
        </a-tab-pane>
      </a-tabs>
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

    <!-- 评价课程弹窗 -->
    <a-modal
      v-model:open="evaluationVisible"
      title="课程评价"
      @ok="submitEvaluation"
      :confirmLoading="evaluationLoading"
    >
      <div class="evaluation-form">
        <div class="rating-section">
          <span class="label">课程评分：</span>
          <a-input-number
            v-model:value="evaluationForm.rating"
            :min="0"
            :max="100"
            :step="1"
            style="width: 120px"
          />
        </div>
        <div class="rating-section">
          <span class="label">课程评级：</span>
          <a-select v-model:value="evaluationForm.level" style="width: 120px;">
            <a-select-option value="jack">优秀</a-select-option>
            <a-select-option value="lucy">良好</a-select-option>
            <a-select-option value="1">及格</a-select-option>
            <a-select-option value="Yiminghe">不及格</a-select-option>
            <a-select-option value="bad">较差</a-select-option>
          </a-select>
        </div>

        <div class="content-section">
          <span class="label">对老师的改进建议</span>
          <a-textarea
            v-model:value="evaluationForm.content"
            :rows="4"
            placeholder="请输入您对本课程的评价..."
          />
        </div>
      </div>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { message } from "ant-design-vue";
import { useRouter } from "vue-router";
import axios from "axios";
import CourseSchedule from "@/components/CourseSchedule.vue";

const router = useRouter();
const loading = ref(false);
const courseList = ref([]);
const scheduleVisible = ref(false);
const scheduleRef = ref(null);
const studentId = ref(localStorage.getItem("userId"));
const activeTab = ref("ongoing");

// 评价相关
const evaluationVisible = ref(false);
const evaluationLoading = ref(false);
const currentCourse = ref(null);
const evaluationForm = ref({
  rating: 0,
  content: "",
});

// 计算属性：进行中的课程
const ongoingCourses = computed(() => {
  return courseList.value.filter((course) => course.status === 0);
});

// 计算属性：已完成的课程
const completedCourses = computed(() => {
  return courseList.value.filter((course) => course.status > 0);
});

// 获取课程列表
const fetchCourses = async () => {
  loading.value = true;
  try {
    const studentId = localStorage.getItem("userId");
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
  if (course.status !== 0) {
    message.error("已结束的课程不能退课");
    return;
  }

  course.loading = true;
  try {
    const studentId = localStorage.getItem("userId");
    const response = await axios.post("/drop-course", {
      student_id: studentId,
      course_id: course.course_id,
    });

    if (response.data.success) {
      message.success("退课成功");
      await fetchCourses(); // 刷新课程列表
    }
  } catch (error) {
    console.error("退课失败:", error);
    message.error(error.response?.data?.message || "退课失败");
  } finally {
    course.loading = false;
  }
};

// 显示评价弹窗
const showEvaluationModal = (course) => {
  currentCourse.value = course;
  evaluationForm.value = {
    rating: 0,
    content: "",
  };
  evaluationVisible.value = true;
};

// 提交课程评价
const submitEvaluation = async () => {
  if (!evaluationForm.value.rating) {
    message.warning("请选择评分");
    return;
  }
  if (!evaluationForm.value.content.trim()) {
    message.warning("请输入评价内容");
    return;
  }

  evaluationLoading.value = true;
  try {
    const response = await axios.post("/course-evaluation", {
      student_id: studentId.value,
      course_id: currentCourse.value.course_id,
      teacher_id: currentCourse.value.teacher_id,
      rating: evaluationForm.value.rating,
      content: evaluationForm.value.content,
    });

    if (response.data.success) {
      message.success("评价提交成功");
      evaluationVisible.value = false;
      await fetchCourses(); // 刷新课程列表
    }
  } catch (error) {
    console.error("评价提交失败:", error);
    message.error(error.response?.data?.message || "评价提交失败");
  } finally {
    evaluationLoading.value = false;
  }
};

// 显示课表
const showSchedule = () => {
  scheduleVisible.value = true;
};

// 跳转到课程详情页
const goToCourseDetail = (course) => {
  router.push({
    name: "CourseDetail",
    params: { id: course.course_id },
  });
};

// 根据上课时间获取卡片头部的样式类
const getTimeClass = (startSection) => {
  const timeClasses = {
    1: "morning-1",
    2: "morning-2",
    3: "afternoon-1",
    4: "afternoon-2",
    5: "evening-1",
    6: "evening-2",
  };
  return timeClasses[startSection] || "morning-1";
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

    &.completed {
      background-color: #8c8c8c;
    }
  }

  .morning-1 {
    background-color: #1890ff;
  }
  .morning-2 {
    background-color: #52c41a;
  }
  .afternoon-1 {
    background-color: #722ed1;
  }
  .afternoon-2 {
    background-color: #eb2f96;
  }
  .evening-1 {
    background-color: #fa8c16;
  }
  .evening-2 {
    background-color: #13c2c2;
  }

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

.evaluation-form {
  .rating-section {
    margin-bottom: 16px;
  }

  .content-section {
    .label {
      display: block;
      margin-bottom: 8px;
    }
  }

  .label {
    font-weight: bold;
  }
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}

:deep(.ant-modal-body) {
  padding: 24px;
}

:deep(.ant-card-meta-title) {
  white-space: normal;
  line-height: 1.5;
}
</style>
