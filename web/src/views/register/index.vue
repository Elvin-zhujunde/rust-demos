<template>
  <div class="register-container">
    <div class="carousel-container">
      <a-carousel class="carousel" autoplay>
        <div class="carousel-item">
          <img src="@/assets/images/banner1.jpg" alt="教学管理">
          <div class="carousel-content">
            <h2>智慧教学管理</h2>
            <p>打造现代化教学体验</p>
          </div>
        </div>
        <div class="carousel-item">
          <img src="@/assets/images/banner2.jpg" alt="课程管理">
          <div class="carousel-content">
            <h2>高效课程管理</h2>
            <p>便捷的课程管理系统</p>
          </div>
        </div>
        <div class="carousel-item">
          <img src="@/assets/images/banner3.jpg" alt="学习体验">
          <div class="carousel-content">
            <h2>优质学习体验</h2>
            <p>为师生提供优质服务</p>
          </div>
        </div>
      </a-carousel>
    </div>
    <div class="register-content">
      <div class="register-box">
        <h2>用户注册</h2>
        <a-form
          :model="formData"
          :rules="rules"
          ref="formRef"
          @finish="handleSubmit"
        >
          <!-- 角色选择 -->
          <a-form-item name="role">
            <a-radio-group
              v-model:value="formData.role"
              @change="handleRoleChange"
            >
              <a-radio value="student">学生</a-radio>
              <a-radio value="teacher">教师</a-radio>
            </a-radio-group>
          </a-form-item>

          <!-- 学号/教师编号 -->
          <a-form-item
            :label="formData.role === 'student' ? '学号' : '教师编号'"
            :name="formData.role === 'student' ? 'student_id' : 'teacher_id'"
          >
            <a-input
              v-model:value="
                formData[
                  formData.role === 'student' ? 'student_id' : 'teacher_id'
                ]
              "
            />
          </a-form-item>

          <!-- 通用字段 -->
          <a-form-item label="姓名" name="name">
            <a-input v-model:value="formData.name" />
          </a-form-item>

          <a-form-item label="密码" name="password">
            <a-input v-model:value="formData.password" />
          </a-form-item>

          <a-form-item label="性别" name="gender">
            <a-radio-group v-model:value="formData.gender">
              <a-radio value="男">男</a-radio>
              <a-radio value="女">女</a-radio>
            </a-radio-group>
          </a-form-item>

          <a-form-item label="邮箱" name="email">
            <a-input v-model:value="formData.email" />
          </a-form-item>

          <a-form-item label="地址" name="address">
            <a-input v-model:value="formData.address" />
          </a-form-item>

          <a-form-item label="院系" name="department_id">
            <a-select
              v-model:value="formData.department_id"
              @change="handleDepartmentChange"
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

          <!-- 学生特有字段 -->
          <template v-if="formData.role === 'student'">
            <a-form-item label="专业" name="major_id">
              <a-select
                v-model:value="formData.major_id"
                @change="handleMajorChange"
                :disabled="!formData.department_id"
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

            <a-form-item label="班级" name="class_id">
              <a-select
                v-model:value="formData.class_id"
                :disabled="!formData.major_id"
              >
                <a-select-option
                  v-for="cls in classes"
                  :key="cls.class_id"
                  :value="cls.class_id"
                >
                  {{ cls.class_name }}
                </a-select-option>
              </a-select>
            </a-form-item>
          </template>

          <!-- 教师特有字段 -->
          <template v-else>
            <a-form-item label="职称" name="title">
              <a-select v-model:value="formData.title">
                <a-select-option value="教授">教授</a-select-option>
                <a-select-option value="副教授">副教授</a-select-option>
                <a-select-option value="讲师">讲师</a-select-option>
              </a-select>
            </a-form-item>
          </template>

          <a-form-item>
            <a-button
              type="primary"
              html-type="submit"
              block
              :loading="loading"
            >
              注册
            </a-button>
          </a-form-item>

          <div class="form-footer">
            已有账号？ <router-link to="/login">去登录</router-link>
          </div>
        </a-form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import { useRouter } from "vue-router";
import { message } from "ant-design-vue";
import axios from "axios";

const router = useRouter();
const formRef = ref(null);
const loading = ref(false);
const departments = ref([]);
const majors = ref([]);
const classes = ref([]);

const formData = reactive({
  role: "student",
  student_id: "",
  teacher_id: "",
  name: "",
  password: "",
  gender: "男",
  email: "",
  address: "",
  department_id: "",
  major_id: "",
  class_id: "",
  title: "",
});

// 表单验证规则
const rules = {
  student_id: [{ required: true, message: "请输入学号" }],
  teacher_id: [{ required: true, message: "请输入教师编号" }],
  name: [{ required: true, message: "请输入姓名" }],
  password: [{ required: true, message: "请输入密码" }],
  gender: [{ required: true, message: "请选择性别" }],
  email: [
    { required: true, message: "请输入邮箱" },
    { type: "email", message: "请输入有效的邮箱地址" },
  ],
  department_id: [{ required: true, message: "请选择院系" }],
  major_id: [{ required: true, message: "请选择专业" }],
  class_id: [{ required: true, message: "请选择班级" }],
  title: [{ required: true, message: "请选择职称" }],
};

// 获取院系列表
const fetchDepartments = async () => {
  try {
    const response = await axios.get("/departments");
    if (response.data.success) {
      departments.value = response.data.data;
    }
  } catch (error) {
    console.error("获取院系列表失败:", error);
    message.error("获取院系列表失败");
  }
};

// 获取专业列表
const fetchMajors = async (departmentId) => {
  try {
    const response = await axios.get("/majors", {
      params: { department_id: departmentId },
    });
    if (response.data.success) {
      majors.value = response.data.data;
    }
  } catch (error) {
    console.error("获取专业列表失败:", error);
    message.error("获取专业列表失败");
  }
};

// 获取班级列表
const fetchClasses = async (majorId) => {
  try {
    const response = await axios.get("/classes", {
      params: { major_id: majorId },
    });
    if (response.data.success) {
      classes.value = response.data.data;
    }
  } catch (error) {
    console.error("获取班级列表失败:", error);
    message.error("获取班级列表失败");
  }
};

// 处理角色变化
const handleRoleChange = () => {
  formRef.value?.clearValidate();
};

// 处理院系变化
const handleDepartmentChange = async (value) => {
  formData.major_id = "";
  formData.class_id = "";
  majors.value = [];
  classes.value = [];
  if (value) {
    await fetchMajors(value);
  }
};

// 处理专业变化
const handleMajorChange = async (value) => {
  formData.class_id = "";
  classes.value = [];
  if (value) {
    await fetchClasses(value);
  }
};

// 提交注册
const handleSubmit = async () => {
  loading.value = true;
  try {
    const response = await axios.post("/register", formData);
    if (response.data.success) {
      message.success("注册成功");
      router.push("/login");
    }
  } catch (error) {
    console.error("注册失败:", error);
    message.error(error.response?.data?.message || "注册失败");
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  fetchDepartments();
});
</script>

<style scoped>
.register-container {
  position: relative;
  width: 100vw;
  height: 100vh;
  overflow: hidden;
}

.carousel-container {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.carousel {
  height: 100%;
}

.carousel-item {
  position: relative;
  height: 100vh;
}

.carousel-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.carousel-content {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
  color: white;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
}

.carousel-content h2 {
  font-size: 48px;
  margin-bottom: 16px;
}

.carousel-content p {
  font-size: 24px;
}

.register-content {
  position: absolute;
  top: 0;
  right: 0;
  width: 600px;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow-y: auto;
}

.register-box {
  width: 500px;
  padding: 40px;
  background: rgba(255, 255, 255, 0.279);
  border-radius: 8px;
  backdrop-filter: blur(10px);

  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

h2 {
  text-align: center;
  margin-bottom: 32px;
  color: rgba(0, 0, 0, 0.85);
  font-size: 28px;
  font-weight: bold;
}

:deep(.ant-form-item) {
  margin-bottom: 20px;
}

:deep(.ant-input),
:deep(.ant-input-password),
:deep(.ant-select-selector) {
  height: 44px !important;
  border-radius: 4px !important;
}

:deep(.ant-input-affix-wrapper) {
  padding: 0 11px;
}

:deep(.ant-select-selector) {
  display: flex;
  align-items: center;
}

:deep(.ant-radio-group) {
  display: flex;
  justify-content: center;
  gap: 32px;
}

:deep(.ant-btn) {
  height: 44px;
  font-size: 16px;
  border-radius: 4px;
}

.form-footer {
  margin-top: 24px;
  text-align: center;
  font-size: 14px;
}

.form-footer a {
  color: #1890ff;
  text-decoration: none;
  font-weight: 500;
}

.form-footer a:hover {
  text-decoration: underline;
}
</style>
