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
            <a-button type="danger" size="small" @click="handleDrop(record)">
              退课
            </a-button>
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
        :student-id="studentId"
      />
    </a-modal>
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { message } from "ant-design-vue";
import axios from "axios";
import CourseSchedule from "@/components/CourseSchedule.vue";

const loading = ref(false);
const courseList = ref([]);
const scheduleVisible = ref(false);
const scheduleRef = ref(null);
const studentId = ref(localStorage.getItem("userId"));

// 表格列定义
const columns = [
  {
    title: "课程名称",
    dataIndex: "subject_name",
    width: "20%",
  },
  {
    title: "授课教师",
    dataIndex: "teacher_name",
    width: "15%",
    customRender: ({ record }) =>
      `${record.teacher_name} (${record.teacher_title})`,
  },
  {
    title: "上课时间",
    dataIndex: "course_time",
    width: "15%",
  },
  {
    title: "学时",
    dataIndex: "class_hours",
    width: "10%",
  },
  {
    title: "学分",
    dataIndex: "credits",
    width: "10%",
  },
  {
    title: "课程容量",
    dataIndex: "capacity",
    width: "15%",
  },
  {
    title: "操作",
    dataIndex: "action",
    width: "15%",
  },
];

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

// 显示课表
const showSchedule = () => {
  scheduleVisible.value = true;
};

onMounted(() => {
  fetchCourses();
});
</script>

<style scoped>
.my-courses {
  padding: 24px;
  background: #f0f2f5;
}

.card-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}

:deep(.ant-modal-body) {
  padding: 0;
}
</style>
