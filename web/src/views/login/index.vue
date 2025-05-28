<template>
  <div class="login-container">
    <div class="carousel-container">
      <a-carousel class="carousel" autoplay>
        <div class="carousel-item">
          <img src="@/assets/images/banner1.jpg" alt="教学管理" />
          <div class="carousel-content">
            <h2>智慧教学管理</h2>
            <p>打造现代化教学体验</p>
          </div>
        </div>
        <div class="carousel-item">
          <img src="@/assets/images/banner2.jpg" alt="课程管理" />
          <div class="carousel-content">
            <h2>高效课程管理</h2>
            <p>便捷的课程管理系统</p>
          </div>
        </div>
        <div class="carousel-item">
          <img src="@/assets/images/banner3.jpg" alt="学习体验" />
          <div class="carousel-content">
            <h2>优质学习体验</h2>
            <p>为师生提供优质服务</p>
          </div>
        </div>
      </a-carousel>
    </div>

    <div class="login-content">
      <div class="login-box">
        <h2>教学管理系统</h2>
        <a-form :model="formData" @finish="handleSubmit">
          <a-form-item
            name="name"
            :rules="[{ required: true, message: '请输入姓名' }]"
          >
            <a-input v-model:value="formData.name" placeholder="请输入姓名">
              <template #prefix>
                <user-outlined />
              </template>
            </a-input>
          </a-form-item>

          <a-form-item
            name="code"
            :rules="[{ required: true, message: '请输入学号/教工号' }]"
          >
            <a-input
              v-model:value="formData.code"
              placeholder="请输入学号/教工号"
            >
              <template #prefix>
                <number-outlined />
              </template>
            </a-input>
          </a-form-item>

          <a-form-item
            name="password"
            :rules="[{ required: true, message: '请输入密码' }]"
          >
            <a-input-password
              v-model:value="formData.password"
              placeholder="请输入密码"
            >
              <template #prefix>
                <lock-outlined />
              </template>
            </a-input-password>
          </a-form-item>

          <a-form-item name="role">
            <a-radio-group v-model:value="formData.role">
              <a-radio value="student">学生</a-radio>
              <a-radio value="teacher">教师</a-radio>
              <a-radio value="admin">管理员</a-radio>
            </a-radio-group>
          </a-form-item>

          <a-form-item>
            <a-button
              type="primary"
              html-type="submit"
              block
              :loading="loading"
            >
              登录
            </a-button>
          </a-form-item>

          <div class="form-footer">
            还没有账号？ <router-link to="/register">去注册</router-link>
          </div>
        </a-form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from "vue";
import { useRouter } from "vue-router";
import { message } from "ant-design-vue";
import {
  UserOutlined,
  LockOutlined,
  NumberOutlined,
} from "@ant-design/icons-vue";
import axios from "axios";

const router = useRouter();
const loading = ref(false);

const formData = reactive({
  name: "",
  code: "",
  password: "",
  role: "student",
});

const handleSubmit = async () => {
  try {
    loading.value = true;
    // 判断是否为管理员
    if (formData.name === "admin" && formData.password === "123456") {
      localStorage.setItem("role", "admin");
      localStorage.setItem("roleCode", "admin");
      localStorage.setItem("userId", "admin");
      localStorage.setItem("name", "admin");
      message.success("登录成功");
      await router.push("/admin/home");
      return
    }
    const response = await axios.post("/login", formData);

    if (response.data.success) {
      localStorage.setItem("role", response.data.role);
      localStorage.setItem("roleCode", response.data.roleCode);
      localStorage.setItem("userId", response.data.userId);
      localStorage.setItem("name", response.data.name);
      message.success("登录成功");
      // 根据角色跳转到不同页面
      if (response.data.role === "admin") {
        await router.push("/admin/home");
      } else {
        await router.push("/home");
      }
    } else {
      message.error(response.data.message || "登录失败");
    }
  } catch (error) {
    console.error("登录错误:", error);
    message.error(error.response?.data?.message || "登录失败，请检查网络连接");
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.login-container {
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
  color: white;

  font-size: 48px;
  margin-bottom: 16px;
}

.carousel-content p {
  font-size: 24px;
}

.login-content {
  position: absolute;
  top: 0;
  right: 0;
  width: 500px;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.login-box {
  width: 400px;
  padding: 40px;
  background: rgba(255, 255, 255, 0.301);
  border-radius: 8px;
  backdrop-filter: blur(10px);

  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

h2 {
  text-align: center;
  margin-bottom: 32px;
  color: rgba(0, 0, 0, 0.85);
  font-size: 28px;
  font-weight: bold;
}

:deep(.ant-input-affix-wrapper) {
  height: 44px;
  border-radius: 4px;
}

:deep(.ant-btn) {
  height: 44px;
  font-size: 16px;
  border-radius: 4px;
}

:deep(.ant-radio-group) {
  display: flex;
  justify-content: center;
  gap: 32px;
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
