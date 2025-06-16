<template>
  <div class="users-container">
    <div class="header">
      <a-space>
        <a-select
          v-model:value="currentRole"
          style="width: 120px"
          @change="handleRoleChange"
        >
          <a-select-option value="student">学生管理</a-select-option>
          <a-select-option value="teacher">教师管理</a-select-option>
        </a-select>
        <a-button type="primary" @click="showModal()">
          <template #icon><plus-outlined /></template>
          新增{{ currentRole === "student" ? "学生" : "教师" }}
        </a-button>
      </a-space>
    </div>

    <!-- 添加筛选表单 -->
    <a-form layout="inline" class="filter-form">
      <a-form-item label="姓名">
        <a-input v-model:value="filters.name" placeholder="请输入姓名" allowClear />
      </a-form-item>
      <a-form-item label="邮箱">
        <a-input v-model:value="filters.email" placeholder="请输入邮箱" allowClear />
      </a-form-item>
      <template v-if="currentRole === 'student'">
        <a-form-item label="学号">
          <a-input v-model:value="filters.student_id" placeholder="请输入学号" allowClear />
        </a-form-item>
        <a-form-item label="院系">
          <a-select
            v-model:value="filters.department_id"
            style="width: 200px"
            placeholder="请选择院系"
            allowClear
          >
            <a-select-option
              v-for="dept in departments"
              :key="dept.department_id"
              :value="dept.department_id"
            >
              {{ dept.department_name }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="专业">
          <a-select
            v-model:value="filters.major_id"
            style="width: 200px"
            placeholder="请选择专业"
            allowClear
          >
            <a-select-option
              v-for="major in majors"
              :key="major.major_id"
              :value="major.major_id"
            >
              {{ major.major_name }}
            </a-select-option>
          </a-select>
        </a-form-item>
      </template>
      <template v-else>
        <a-form-item label="工号">
          <a-input v-model:value="filters.teacher_id" placeholder="请输入工号" allowClear />
        </a-form-item>
        <a-form-item label="院系">
          <a-select
            v-model:value="filters.department_id"
            style="width: 200px"
            placeholder="请选择院系"
            allowClear
          >
            <a-select-option
              v-for="dept in departments"
              :key="dept.department_id"
              :value="dept.department_id"
            >
              {{ dept.department_name }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="职称">
          <a-input v-model:value="filters.title" placeholder="请输入职称" allowClear />
        </a-form-item>
      </template>
      <a-form-item>
        <a-space>
          <a-button type="primary" @click="handleSearch">查询</a-button>
          <a-button @click="handleReset">重置</a-button>
        </a-space>
      </a-form-item>
    </a-form>

    <a-table
      :columns="columns"
      :data-source="users"
      :loading="loading"
      :pagination="pagination"
      @change="handleTableChange"
      row-key="id"
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
      </template>
    </a-table>

    <a-modal
      v-model:visible="modalVisible"
      :title="modalTitle"
      @ok="handleModalOk"
      @cancel="handleModalCancel"
    >
      <a-form
        ref="formRef"
        :model="formState"
        :rules="rules"
        :label-col="{ span: 6 }"
        :wrapper-col="{ span: 16 }"
      >
        <a-form-item label="姓名" name="name">
          <a-input v-model:value="formState.name" />
        </a-form-item>
        <a-form-item label="性别" name="gender">
          <a-select v-model:value="formState.gender">
            <a-select-option value="男">男</a-select-option>
            <a-select-option value="女">女</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="邮箱" name="email">
          <a-input v-model:value="formState.email" />
        </a-form-item>
        <a-form-item label="地址" name="address">
          <a-input v-model:value="formState.address" />
        </a-form-item>
        <template v-if="currentRole === 'student'">
          <a-form-item label="学号" name="student_id">
            <a-input
              v-model:value="formState.student_id"
              :disabled="!!formState.id"
            />
          </a-form-item>
          <a-form-item label="院系" name="department_id">
            <a-select v-model:value="formState.department_id">
              <a-select-option
                v-for="dept in departments"
                :key="dept.department_id"
                :value="dept.department_id"
              >
                {{ dept.department_name }}
              </a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item label="专业" name="major_id">
            <a-select v-model:value="formState.major_id">
              <a-select-option
                v-for="major in majors"
                :key="major.major_id"
                :value="major.major_id"
              >
                {{ major.major_name }}
              </a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item label="班级" name="class_id">
            <a-select v-model:value="formState.class_id">
              <a-select-option
                v-for="cls in classes"
                :key="cls.class_id"
                :value="cls.class_id"
              >
                {{ cls.class_name }}
              </a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item label="入学日期" name="enrollment_date">
            <a-date-picker
              v-model:value="formState.enrollment_date"
              style="width: 100%"
            />
          </a-form-item>
          <a-form-item label="学位" name="degree">
            <a-input v-model:value="formState.degree" />
          </a-form-item>
          <a-form-item label="学期" name="semester">
            <a-input-number
              v-model:value="formState.semester"
              :min="1"
              :max="8"
            />
          </a-form-item>
        </template>
        <template v-else>
          <a-form-item label="工号" name="teacher_id">
            <a-input
              v-model:value="formState.teacher_id"
              :disabled="!!formState.id"
            />
          </a-form-item>
          <a-form-item label="院系" name="department_id">
            <a-select v-model:value="formState.department_id">
              <a-select-option
                v-for="dept in departments"
                :key="dept.department_id"
                :value="dept.department_id"
              >
                {{ dept.department_name }}
              </a-select-option>
            </a-select>
          </a-form-item>
          <a-form-item label="职称" name="title">
            <a-input v-model:value="formState.title" />
          </a-form-item>
          <a-form-item label="入职日期" name="entry_date">
            <a-date-picker
              v-model:value="formState.entry_date"
              style="width: 100%"
            />
          </a-form-item>
        </template>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from "vue";
import { message } from "ant-design-vue";
import { PlusOutlined } from "@ant-design/icons-vue";
import axios from "axios";
import dayjs from "dayjs";

const currentRole = ref("student");
const users = ref([]);
const loading = ref(false);
const modalVisible = ref(false);
const formRef = ref(null);
const departments = ref([]);
const majors = ref([]);
const classes = ref([]);

const formState = ref({
  id: null,
  name: "",
  gender: "男",
  email: "",
  address: "",
  // 学生特有字段
  student_id: "",
  department_id: "",
  major_id: "",
  class_id: "",
  enrollment_date: null,
  degree: "",
  semester: 1,
  // 教师特有字段
  teacher_id: "",
  title: "",
  entry_date: null,
});

const rules = {
  name: [{ required: true, message: "请输入姓名" }],
  gender: [{ required: true, message: "请选择性别" }],
  email: [
    { required: true, message: "请输入邮箱" },
    { type: "email", message: "请输入有效的邮箱地址" },
  ],
  address: [{ required: true, message: "请输入地址" }],
  student_id: [{ required: true, message: "请输入学号" }],
  teacher_id: [{ required: true, message: "请输入工号" }],
  department_id: [{ required: true, message: "请选择院系" }],
};

const columns = computed(() => {
  const baseColumns = [
    {
      title: "姓名",
      dataIndex: "name",
      key: "name",
    },
    {
      title: "性别",
      dataIndex: "gender",
      key: "gender",
    },
    {
      title: "邮箱",
      dataIndex: "email",
      key: "email",
    },
    {
      title: "地址",
      dataIndex: "address",
      key: "address",
    },
  ];

  if (currentRole.value === "student") {
    return [
      {
        title: "学号",
        dataIndex: "student_id",
        key: "student_id",
      },
      ...baseColumns,
      {
        title: "院系",
        dataIndex: "department_name",
        key: "department_name",
      },
      {
        title: "专业",
        dataIndex: "major_name",
        key: "major_name",
      },
      {
        title: "班级",
        dataIndex: "class_name",
        key: "class_name",
      },
      {
        title: "入学日期",
        dataIndex: "enrollment_date",
        key: "enrollment_date",
      },
      {
        title: "学位",
        dataIndex: "degree",
        key: "degree",
      },
      {
        title: "学期",
        dataIndex: "semester",
        key: "semester",
      },
      {
        title: "操作",
        key: "action",
        fixed: "right",
        width: 120,
      },
    ];
  } else {
    return [
      {
        title: "工号",
        dataIndex: "teacher_id",
        key: "teacher_id",
      },
      ...baseColumns,
      {
        title: "院系",
        dataIndex: "department_name",
        key: "department_name",
      },
      {
        title: "职称",
        dataIndex: "title",
        key: "title",
      },
      {
        title: "入职日期",
        dataIndex: "entry_date",
        key: "entry_date",
      },
      {
        title: "操作",
        key: "action",
        fixed: "right",
        width: 120,
      },
    ];
  }
});

const pagination = ref({
  current: 1,
  pageSize: 10,
  total: 0,
});

const modalTitle = computed(() => {
  if (!formState.value.id) {
    return `新增${currentRole.value === "student" ? "学生" : "教师"}`;
  }
  return `编辑${currentRole.value === "student" ? "学生" : "教师"}`;
});

const filters = ref({
  name: '',
  email: '',
  student_id: '',
  teacher_id: '',
  department_id: '',
  major_id: '',
  title: ''
})

// 获取用户列表
const fetchUsers = async () => {
  loading.value = true;
  try {
    const res = await axios.get("/users", {
      params: {
        role: currentRole.value,
        page: pagination.value.current,
        pageSize: pagination.value.pageSize,
        ...filters.value
      },
    });
    users.value = res.data.data.items;
    pagination.value.total = res.data.data.total;
  } catch (error) {
    message.error("获取用户列表失败");
  } finally {
    loading.value = false;
  }
};

// 获取院系列表
const fetchDepartments = async () => {
  try {
    const res = await axios.get("/departments");
    departments.value = res.data.data;
  } catch (error) {
    message.error("获取院系列表失败");
  }
};

// 获取专业列表
const fetchMajors = async () => {
  try {
    const res = await axios.get("/majors");
    majors.value = res.data.data;
  } catch (error) {
    message.error("获取专业列表失败");
  }
};

// 获取班级列表
const fetchClasses = async () => {
  try {
    const res = await axios.get("/classes");
    classes.value = res.data.data;
  } catch (error) {
    message.error("获取班级列表失败");
  }
};

// 角色切换
const handleRoleChange = () => {
  pagination.value.current = 1;
  fetchUsers();
};

// 表格变化
const handleTableChange = (pag) => {
  pagination.value.current = pag.current;
  pagination.value.pageSize = pag.pageSize;
  fetchUsers();
};

const showType = ref("add");
// 显示模态框
const showModal = (record) => {
  if (record) {
    formState.value = { ...record };
    // 日期字段转 dayjs
    if (record.enrollment_date) {
      formState.value.enrollment_date = dayjs(record.enrollment_date);
    }
    if (record.entry_date) {
      formState.value.entry_date = dayjs(record.entry_date);
    }
    showType.value = "edit";
  } else {
    showType.value = "add";
    formState.value = {
      id: null,
      name: "",
      gender: "男",
      email: "",
      address: "",
      student_id: "",
      teacher_id: "",
      department_id: "",
      major_id: "",
      class_id: "",
      enrollment_date: null,
      degree: "",
      semester: 1,
      title: "",
      entry_date: null,
    };
  }
  modalVisible.value = true;
};

// 模态框确认
const handleModalOk = async () => {
  try {
    await formRef.value.validate();
    const data = { ...formState.value, role: currentRole.value };
    if (showType.value === "edit") {
      debugger;
      await axios.put(
        `/users/${
          currentRole.value === "student" ? data.student_id : data.teacher_id
        }`,
        data
      );
      message.success("更新成功");
    } else {
      // 默认密码处理
      if (!data.password) {
        data.password = '123456'
      }
      await axios.post("/users", data);
      message.success("创建成功");
    }
    modalVisible.value = false;
    fetchUsers();
  } catch (error) {
    message.error("操作失败");
  }
};

// 模态框取消
const handleModalCancel = () => {
  modalVisible.value = false;
  formRef.value?.resetFields();
};

// 删除用户
const handleDelete = async (record) => {
  try {
    await axios.delete(`/users/${record.id}`, {
      params: { role: currentRole.value },
    });
    message.success("删除成功");
    fetchUsers();
  } catch (error) {
    message.error("删除失败");
  }
};

// 处理搜索
const handleSearch = () => {
  pagination.value.current = 1
  fetchUsers()
}

// 处理重置
const handleReset = () => {
  filters.value = {
    name: '',
    email: '',
    student_id: '',
    teacher_id: '',
    department_id: '',
    major_id: '',
    title: ''
  }
  pagination.value.current = 1
  fetchUsers()
}

onMounted(() => {
  fetchUsers();
  fetchDepartments();
  fetchMajors();
  fetchClasses();
});
</script>

<style scoped>
.users-container {
  padding: 24px;
}

.header {
  margin-bottom: 16px;
}

.danger {
  color: #ff4d4f;
}

.filter-form {
  margin-bottom: 16px;
  padding: 24px;
  background: #fff;
  border-radius: 2px;
}
</style>
