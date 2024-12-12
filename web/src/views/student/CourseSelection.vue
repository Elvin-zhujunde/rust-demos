<template>
  <div class="course-selection">
    <a-card :bordered="false">
      <template #title>
        <div class="card-title">
          <h2>选课</h2>
          <div class="card-title-right">
            <a-button type="primary" @click="showClassCourses">
              应用班级课表
            </a-button>
          </div>
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
            <a-button
              v-if="!record.is_selected"
              type="primary"
              size="small"
              :disabled="record.student_count >= record.max_students"
              @click="handleSelect(record)"
            >
              选课
            </a-button>
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
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { message } from "ant-design-vue";
import axios from "axios";
import CourseSchedule from "@/components/CourseSchedule.vue";

const loading = ref(false);
const courseList = ref([]);
const classCourseVisible = ref(false);
const scheduleRef = ref(null);
const applying = ref(false);
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
    const response = await axios.get(
      `/available-courses?student_id=${studentId}`
    );
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

// 选课
const handleSelect = async (course) => {
  course.loading = true;
  try {
    const studentId = localStorage.getItem("userId");
    const response = await axios.post("/select-course", {
      student_id: studentId,
      course_id: course.course_id,
    });

    if (response.data.success) {
      message.success("选课成功");
      await fetchCourses(); // 刷新课程列表
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

onMounted(() => {
  fetchCourses();
});
</script>

<style lang="less" scoped>
.course-selection {
  padding: 24px;
  background: #f0f2f5;
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}
.card-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
