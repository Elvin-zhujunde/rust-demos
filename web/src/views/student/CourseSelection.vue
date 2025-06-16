<template>
  <div class="course-selection">
    <a-card :bordered="false">
      <template #title>
        <div class="card-title">
          <h2>
            选课&nbsp;&nbsp;&nbsp;&nbsp;({{
              formatTime(setTimeForm?.start_time) || ""
            }}
            - {{ formatTime(setTimeForm?.end_time) || "" }})
          </h2>
          <div class="card-title-right">
            <a-button type="primary" @click="showClassCourses">
              应用班级课表
            </a-button>
          </div>
        </div>
      </template>

      <!-- 推荐课程部分 -->
      <a-collapse
        v-model:activeKey="activeCollapseKey"
        class="recommendation-section"
      >
        <a-collapse-panel
          key="1"
          :header="'课程推荐 (' + recommendedCourses.length + ')'"
        >
          <div class="recommendation-cards">
            <a-row :gutter="[16, 16]">
              <a-col
                :span="8"
                v-for="course in recommendedCourses"
                :key="course.course_id"
              >
                <a-card hoverable class="recommendation-card">
                  <template #title>
                    <div class="recommendation-card-title">
                      {{ course.subject_name }}
                      <a-tag
                        :color="
                          course.recommendation_reason === '同班同学热选课程'
                            ? 'red'
                            : 'blue'
                        "
                      >
                        {{ course.recommendation_reason }}
                      </a-tag>
                    </div>
                  </template>
                  <div class="recommendation-card-content">
                    <p>
                      <strong>教师：</strong>{{ course.teacher_name }} ({{
                        course.teacher_title
                      }})
                    </p>
                    <p><strong>时间：</strong>{{ course.course_time }}</p>
                    <p><strong>教室：</strong>{{ course.classroom_display }}</p>
                    <p><strong>学分：</strong>{{ course.credits }}</p>
                    <p>
                      <strong>容量：</strong>{{ course.student_count }}/{{
                        course.max_students
                      }}
                    </p>
                  </div>
                  <template #actions>
                    <a-button
                      type="primary"
                      :disabled="
                        course.student_count >= course.max_students ||
                        cantSelect
                      "
                      @click="handleSelect(course)"
                      :loading="course.loading"
                    >
                      {{
                        course.student_count >= course.max_students
                          ? "已满"
                          : "选课"
                      }}
                    </a-button>
                  </template>
                </a-card>
              </a-col>
            </a-row>
          </div>
        </a-collapse-panel>
      </a-collapse>

      <!-- 添加搜索表单 -->
      <div class="search-form">
        <a-form layout="inline" :model="searchForm">
          <a-form-item label="课程名称">
            <a-input
              v-model:value="searchForm.subject_name"
              placeholder="请输入课程名称"
              allowClear
            />
          </a-form-item>
          <a-form-item label="授课教师">
            <a-input
              v-model:value="searchForm.teacher_name"
              placeholder="请输入教师姓名"
              allowClear
            />
          </a-form-item>
          <a-form-item label="上课时间">
            <a-select
              v-model:value="searchForm.week_day"
              style="width: 100px"
              placeholder="星期"
              allowClear
            >
              <a-select-option value="1">周一</a-select-option>
              <a-select-option value="2">周二</a-select-option>
              <a-select-option value="3">周三</a-select-option>
              <a-select-option value="4">周四</a-select-option>
              <a-select-option value="5">周五</a-select-option>
            </a-select>
            <a-select
              v-model:value="searchForm.start_section"
              style="width: 160px; margin-left: 8px"
              placeholder="节次"
              allowClear
            >
              <a-select-option :value="1">上午第1节 (08:00)</a-select-option>
              <a-select-option :value="2">上午第2节 (09:40)</a-select-option>
              <a-select-option :value="3">下午第1节 (14:00)</a-select-option>
              <a-select-option :value="4">下午第2节 (15:40)</a-select-option>
              <a-select-option :value="5">晚上第1节 (18:00)</a-select-option>
              <a-select-option :value="6">晚上第2节 (19:40)</a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item>
            <a-button type="primary" @click="handleSearch">搜索</a-button>
            <a-button style="margin-left: 8px" @click="handleReset"
              >重置</a-button
            >
          </a-form-item>
        </a-form>
      </div>

      <a-table
        :columns="columns"
        :data-source="courseList"
        :loading="loading"
        rowKey="course_id"
      >
        <!-- 课程时间列 -->
        <template #bodyCell="{ column, record }">
          <template v-if="column.dataIndex === 'course_time'">
            {{ record.week_day_text }} {{ record.section_text }}
          </template>

          <!-- 课程容量列 -->
          <template v-if="column.dataIndex === 'capacity'">
            {{ record.student_count }}/{{ record.max_students }}
          </template>

          <!-- 操作列 -->
          <template v-if="column.dataIndex === 'action'">
            <div class="action-buttons">
              <a-button
                v-if="!record.is_selected"
                type="primary"
                size="small"
                :disabled="
                  record.student_count >= record.max_students || cantSelect
                "
                @click="handleSelect(record)"
              >
                选课
              </a-button>
              <a-button
                type="link"
                size="small"
                @click="showCourseComments(record)"
              >
                查看评论
              </a-button>
            </div>
          </template>
        </template>
      </a-table>
    </a-card>

    <!-- 班级课表弹窗 -->
    <a-modal
      v-model:open="classCourseVisible"
      title="班级课表"
      width="1000px"
      @ok="applyClassCourses"
    >
      <CourseSchedule
        v-if="classCourseVisible"
        ref="scheduleRef"
        :class-courses="true"
        :student-id="studentId"
      />
      <template #footer>
        <a-button key="back" @click="classCourseVisible = false">取消</a-button>
        <a-button
          key="submit"
          type="primary"
          :loading="applying"
          @click="applyClassCourses"
        >
          应用班级课表
        </a-button>
      </template>
    </a-modal>

    <!-- 评论弹窗 -->
    <a-modal
      v-model:visible="showComments"
      :title="currentCourse?.subject_name + ' - 课程评论'"
      :footer="null"
      width="100%"
      wrap-class-name="full-modal"
    >
      <CourseComments :course-id="currentCourse?.course_id" />
    </a-modal>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { message } from "ant-design-vue";
import axios from "axios";
import CourseSchedule from "@/components/CourseSchedule.vue";
import CourseComments from "@/components/Course/CourseComments.vue";
import dayjs from "dayjs";
const loading = ref(false);
const courseList = ref([]);
const classCourseVisible = ref(false);
const scheduleRef = ref(null);
const applying = ref(false);
const studentId = ref(localStorage.getItem("userId"));
const activeCollapseKey = ref(["1"]); // 默认展开推荐面板
const recommendedCourses = ref([]);

const cantSelect = computed(() => {
  return (
    Date.now() > new Date(setTimeForm.value?.end_time).getTime() ||
    Date.now() < new Date(setTimeForm.value?.start_time).getTime()
  );
});
// 表格列定义
const columns = [
  {
    title: "课程名称",
    dataIndex: "subject_name",
    width: "18%",
  },
  {
    title: "授课教师",
    dataIndex: "teacher_name",
    width: "12%",
    customRender: ({ record }) =>
      `${record.teacher_name} (${record.teacher_title})`,
  },
  {
    title: "上课时间",
    dataIndex: "course_time",
    width: "15%",
  },
  {
    title: "教室",
    dataIndex: "classroom_name",
    width: "12%",
  },
  {
    title: "学时",
    dataIndex: "class_hours",
    width: "8%",
  },
  {
    title: "学分",
    dataIndex: "credits",
    width: "8%",
  },
  {
    title: "课程容量",
    dataIndex: "capacity",
    width: "12%",
  },
  {
    title: "操作",
    dataIndex: "action",
    width: "20%",
  },
];

// 添加搜索表单数据
const searchForm = ref({
  subject_name: "",
  teacher_name: "",
  week_day: undefined,
  start_section: undefined,
});

// 获取课程列表
const fetchCourses = async () => {
  loading.value = true;
  try {
    const studentId = localStorage.getItem("userId");
    // 构建查询参数
    const params = new URLSearchParams({
      student_id: studentId,
      ...searchForm.value,
    });

    // 移除未定义的参数
    Object.keys(searchForm.value).forEach((key) => {
      if (!searchForm.value[key]) {
        params.delete(key);
      }
    });

    const response = await axios.get(`/available-courses?${params.toString()}`);
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

// 搜索处理函数
const handleSearch = () => {
  fetchCourses();
};

// 重置搜索条件
const handleReset = () => {
  searchForm.value = {
    subject_name: "",
    teacher_name: "",
    week_day: undefined,
    start_section: undefined,
  };
  fetchCourses();
};

// 获取推荐课程
const fetchRecommendedCourses = async () => {
  try {
    const response = await axios.get(`/recommended-courses/${studentId.value}`);
    if (response.data.success) {
      recommendedCourses.value = response.data.data;
    }
  } catch (error) {
    console.error("获取推荐课程失败:", error);
    message.error("获取推荐课程失败");
  }
};

// 选课成功后的处理
const handleSelectSuccess = async () => {
  await Promise.all([fetchCourses(), fetchRecommendedCourses()]);
};

// 修改选课方法
const handleSelect = async (course) => {
  course.loading = true;
  try {
    const response = await axios.post("/select-course", {
      student_id: studentId.value,
      course_id: course.course_id,
    });

    if (response.data.success) {
      message.success("选课成功");
      await handleSelectSuccess();
    }
  } catch (error) {
    console.error("选课失败:", error);
    message.error(error.response?.data?.message || "选课失败");
  } finally {
    course.loading = false;
  }
};

// 显示班级课表
const showClassCourses = () => {
  classCourseVisible.value = true;
};
// 格式化时间
const formatTime = (timestamp) => {
  return dayjs(timestamp).format("YYYY-MM-DD");
};
// 应用班级课表
const applyClassCourses = async () => {
  applying.value = true;
  try {
    const response = await axios.post("/apply-class-courses", {
      student_id: studentId.value,
    });

    if (response.data.success) {
      message.success("班级课程应用成功");
      classCourseVisible.value = false;
      await fetchCourses(); // 刷新课程列表
    }
  } catch (error) {
    console.error("应用班级课程失败:", error);
    message.error(error.response?.data?.message || "应用班级课程失败");
  } finally {
    applying.value = false;
  }
};

// 添加评论弹窗相关
const showComments = ref(false);
const currentCourse = ref(null);

// 显示课程评论
const showCourseComments = (course) => {
  currentCourse.value = course;
  showComments.value = true;
};
const setTimeForm = ref({});
onMounted(() => {
  fetchCourses();
  fetchRecommendedCourses();
  setTimeForm.value = JSON.parse(localStorage.getItem("setTimeForm"));
  if (setTimeForm) {
    console.log(setTimeForm);
  }
});
</script>

<style lang="less" scoped>
.course-selection {
  padding: 24px;
  background: #f0f2f5;
}

.search-form {
  margin-bottom: 24px;

  :deep(.ant-form-item) {
    margin-bottom: 16px;
  }
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}
.card-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.recommendation-section {
  margin-bottom: 24px;

  .recommendation-cards {
    .recommendation-card {
      height: 100%;

      .recommendation-card-title {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 8px;
      }

      .recommendation-card-content {
        p {
          margin-bottom: 8px;
          &:last-child {
            margin-bottom: 0;
          }
        }
      }

      :deep(.ant-card-actions) {
        background: #fafafa;
      }
    }
  }
}

:deep(.ant-collapse-header) {
  font-weight: bold;
  font-size: 16px;
}

:deep(.ant-tag) {
  margin: 0;
}

.action-buttons {
  display: flex;
  gap: 8px;
  align-items: center;
}
.full-modal {
  .ant-modal {
    max-width: 100%;
    top: 0;
    padding-bottom: 0;
    margin: 0;
  }
  .ant-modal-content {
    display: flex;
    flex-direction: column;
    height: calc(100vh);
  }
  .ant-modal-body {
    flex: 1;
  }
}
</style>
