<template>
  <div class="courses-container">
    <div class="header">
      <a-button type="primary" @click="showModal()">新增课程</a-button>
      <a-button style="margin-left: 8px;" type="primary" @click="setTime()">设置选课时间</a-button>
    </div>
    <a-table
      :columns="columns"
      :data-source="courses"
      :loading="loading"
      rowKey="course_id"
      bordered
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'action'">
          <a-space>
            <a @click="showModal(record)">编辑</a>
            <a-popconfirm
              title="确定要删除吗？"
              @confirm="handleDelete(record)"
            >
              <a class="danger">删除</a>
            </a-popconfirm>
          </a-space>
        </template>
        <template v-else-if="column.key === 'week_time'">
          <span>
            周{{ weekDayText[record.week_day] }} 第{{
              record.start_section
            }}节起 连{{ record.section_count }}节
          </span>
        </template>
      </template>
    </a-table>

    <a-modal
      v-model:visible="modalVisible"
      :title="modalTitle"
      @ok="handleOk"
      @cancel="handleCancel"
      :destroyOnClose="true"
    >
      <a-form
        :model="formState"
        :rules="rules"
        ref="formRef"
        :label-col="{ span: 6 }"
        :wrapper-col="{ span: 16 }"
      >
        <a-form-item label="课程名称" name="subject_id">
          <a-select
            v-model:value="formState.subject_id"
            placeholder="请选择课程"
          >
            <a-select-option
              v-for="s in subjects"
              :key="s.subject_id"
              :value="s.subject_id"
              >{{ s.subject_name }}</a-select-option
            >
          </a-select>
        </a-form-item>
        <a-form-item label="授课教师" name="teacher_id">
          <a-select
            v-model:value="formState.teacher_id"
            placeholder="请选择教师"
          >
            <a-select-option
              v-for="t in teachers"
              :key="t.teacher_id"
              :value="t.teacher_id"
              >{{ t.name }}</a-select-option
            >
          </a-select>
        </a-form-item>
        <a-form-item label="学分" name="credits">
          <a-input-number
            v-model:value="formState.credits"
            :min="1"
            :max="4"
            @change="onCreditsChange"
          />
        </a-form-item>
        <a-form-item label="学时" name="class_hours">
          <a-input v-model:value="formState.class_hours" disabled />
        </a-form-item>
        <a-form-item label="上课时间" required>
          <a-space>
            <a-select v-model:value="formState.week_day" placeholder="星期">
              <a-select-option
                v-for="(txt, val) in weekDayText"
                :key="val"
                :value="val"
                >周{{ txt }}</a-select-option
              >
            </a-select>
            <a-select
              v-model:value="formState.start_section"
              placeholder="起始节"
            >
              <a-select-option v-for="i in 6" :key="i" :value="i"
                >第{{ i }}节</a-select-option
              >
            </a-select>
            <a-select
              v-model:value="formState.section_count"
              placeholder="连续节数"
            >
              <a-select-option v-for="i in [1, 2, 3]" :key="i" :value="i"
                >连{{ i }}节</a-select-option
              >
            </a-select>
          </a-space>
        </a-form-item>
        <a-form-item label="教室" name="classroom_id">
          <a-select
            v-model:value="formState.classroom_id"
            placeholder="请选择教室"
          >
            <a-select-option
              v-for="c in classrooms"
              :key="c.classroom_id"
              :value="c.classroom_id"
              >{{ c.building }}{{ c.room_number }}</a-select-option
            >
          </a-select>
        </a-form-item>
        <a-form-item label="最大容量" name="max_students">
          <a-input-number v-model:value="formState.max_students" :min="1" />
        </a-form-item>
      </a-form>
    </a-modal>
    <a-modal
      v-model:visible="setTimeModalVisible"
      title="设置选课时间"
      @ok="handleSetTimeOk"
      @cancel="setTimeModalVisible = false"
    >
      <a-form :model="setTimeForm" :rules="setTimeRules" ref="setTimeFormRef">
        <a-form-item label="选课开始时间" name="start_time">
          <a-date-picker v-model:value="setTimeForm.start_time" />
        </a-form-item>
        <a-form-item label="选课结束时间" name="end_time">
          <a-date-picker v-model:value="setTimeForm.end_time" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { message } from "ant-design-vue";
import axios from "axios";

const courses = ref([]);
const loading = ref(false);
const modalVisible = ref(false);
const formRef = ref(null);
const teachers = ref([]);
const subjects = ref([]);
const classrooms = ref([]);
const formState = ref({});
const editId = ref(null);
const setTimeModalVisible = ref(false);
const setTimeForm = ref({});
const setTimeRules = {
  start_time: [{ required: true, message: "请选择选课开始时间" }],
  end_time: [{ required: true, message: "请选择选课结束时间" }],
};
const setTimeFormRef = ref(null);
const weekDayText = {
  1: "一",
  2: "二",
  3: "三",
  4: "四",
  5: "五",
  6: "六",
  7: "日",
};

const columns = [
  { title: "课程名称", dataIndex: "subject_name", key: "subject_name" },
  { title: "授课教师", dataIndex: "teacher_name", key: "teacher_name" },
  { title: "学时", dataIndex: "class_hours", key: "class_hours" },
  { title: "学分", dataIndex: "credits", key: "credits" },
  { title: "上课时间", key: "week_time" },
  { title: "教室", dataIndex: "classroom_name", key: "classroom_name" },
  { title: "容量", dataIndex: "max_students", key: "max_students" },
  { title: "操作", key: "action", fixed: "right", width: 120 },
];

const rules = {
  subject_id: [{ required: true, message: "请选择课程" }],
  teacher_id: [{ required: true, message: "请选择教师" }],
  class_hours: [{ required: true, message: "请选择学时" }],
  credits: [
    { required: true, message: "请输入学分" },
    { type: "number", min: 1, max: 6, message: "学分范围1-6" },
  ],
  week_day: [{ required: true, message: "请选择星期" }],
  start_section: [{ required: true, message: "请选择起始节" }],
  section_count: [{ required: true, message: "请选择连续节数" }],
  classroom_id: [{ required: true, message: "请选择教室" }],
  max_students: [{ required: true, message: "请输入最大容量" }],
};

const modalTitle = computed(() => (editId.value ? "编辑课程" : "新增课程"));

const fetchCourses = async () => {
  loading.value = true;
  try {
    const res = await axios.get("/admin/courses");
    courses.value = res.data.data;
    courses.value.map((v) => {
      v.credits = Number(v.class_hours) / 16;
      return v;
    });
  } catch (e) {
    message.error("获取课程列表失败");
  } finally {
    loading.value = false;
  }
};
const fetchTeachers = async () => {
  try {
    const res = await axios.get("/teachers");
    teachers.value = res.data.data;
  } catch {}
};
const fetchSubjects = async () => {
  try {
    const res = await axios.get("/subjects");
    subjects.value = res.data.data;
  } catch {}
};
const fetchClassrooms = async () => {
  try {
    const res = await axios.get("/classrooms");
    classrooms.value = res.data.data;
  } catch {}
};

const setTime = () => {
  setTimeModalVisible.value = true;

};
const handleSetTimeOk = async () => {
  try {
    await setTimeFormRef.value.validate();
    localStorage.setItem("setTimeForm", JSON.stringify(setTimeForm.value));
    setTimeModalVisible.value = false;
    message.success("设置选课时间成功");
  } catch {
    message.error("设置选课时间失败");
  }
};

const showModal = (record) => {
  if (record) {
    editId.value = record.course_id;
    formState.value = { ...record };
  } else {
    editId.value = null;
    formState.value = {
      subject_id: "",
      teacher_id: "",
      credits: 1,
      class_hours: "16",
      week_day: "",
      start_section: 1,
      section_count: 1,
      classroom_id: "",
      max_students: 30,
    };
  }
  modalVisible.value = true;
};

const handleOk = async () => {
  try {
    await formRef.value.validate();
    const data = { ...formState.value };
    if (editId.value) {
      await axios.put(`/admin/courses/${editId.value}`, data);
      message.success("编辑成功");
    } else {
      await axios.post("/admin/courses", data);
      message.success("新增成功");
    }
    modalVisible.value = false;
    fetchCourses();
  } catch (e) {
    message.error("操作失败");
  }
};
const handleCancel = () => {
  modalVisible.value = false;
  formRef.value?.resetFields();
};
const handleDelete = async (record) => {
  try {
    await axios.delete(`/admin/courses/${record.course_id}`);
    message.success("删除成功");
    fetchCourses();
  } catch {
    message.error("删除失败");
  }
};

const onCreditsChange = (val) => {
  formState.value.class_hours = String(val * 16);
};

onMounted(() => {
  fetchCourses();
  fetchTeachers();
  fetchSubjects();
  fetchClassrooms();
});
</script>

<style scoped>
.courses-container {
  padding: 24px;
}
.header {
  margin-bottom: 16px;
}
.danger {
  color: #ff4d4f;
}
</style>
