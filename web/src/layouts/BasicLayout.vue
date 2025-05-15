<template>
  <a-layout class="layout">
    <a-layout-sider v-model:collapsed="collapsed" collapsible>
      <div class="logo">
        <span v-if="!collapsed">教学管理系统</span>
        <span v-else>TMS</span>
      </div>
      <a-menu v-model:selectedKeys="selectedKeys" theme="dark" mode="inline">
        <!-- 公共菜单项 -->
        <a-menu-item key="home">
          <home-outlined />
          <span>首页</span>
          <router-link to="/home" />
        </a-menu-item>

        <!-- 学生菜单 -->
        <template v-if="userRole === 'student'">
          <a-menu-item key="course-selection">
            <book-outlined />
            <span>选课管理</span>
            <router-link to="/course-selection" />
          </a-menu-item>
          <a-menu-item key="my-courses">
            <schedule-outlined />
            <span>我的课程</span>
            <router-link to="/my-courses" />
          </a-menu-item>
          <a-menu-item key="ai-assistant">
            <robot-outlined />
            <span>AI 助手</span>
            <router-link to="/ai-assistant" />
          </a-menu-item>
        </template>

        <!-- 教师菜单 -->
        <template v-if="userRole === 'teacher'">
          <a-menu-item key="teaching-courses">
            <read-outlined />
            <span>授课管理</span>
            <router-link to="/teaching-courses" />
          </a-menu-item>

          <a-menu-item key="student-management">
            <team-outlined />
            <span>学生管理</span>
            <router-link to="/student-management" />
          </a-menu-item>
        </template>

        <!-- 个人信息 -->
        <a-menu-item key="profile">
          <user-outlined />
          <span>个人信息</span>
          <router-link to="/profile" />
        </a-menu-item>
      </a-menu>
    </a-layout-sider>

    <a-layout>
      <a-layout-header class="header">
        <div class="header-right">
          <span class="welcome">欢迎，{{ userName }}</span>
          <a-popconfirm
            title="确定要退出登录吗？"
            @confirm="handleLogout"
            ok-text="确定"
            cancel-text="取消"
          >
            <a-button type="link">退出登录</a-button>
          </a-popconfirm>
        </div>
      </a-layout-header>

      <a-layout-content class="content">
        <router-view></router-view>
      </a-layout-content>

      <a-layout-footer class="footer">
        教学管理系统 ©2024 Created by Your Team
      </a-layout-footer>
    </a-layout>
  </a-layout>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import { message } from "ant-design-vue";
import {
  HomeOutlined,
  BookOutlined,
  ScheduleOutlined,
  BarChartOutlined,
  ReadOutlined,
  EditOutlined,
  TeamOutlined,
  UserOutlined,
  RobotOutlined,
} from "@ant-design/icons-vue";

const router = useRouter();
const collapsed = ref(false);
const selectedKeys = ref(["home"]);

const userRole = ref(localStorage.getItem("role"));
const userName = ref(localStorage.getItem("name"));

const handleLogout = async () => {
  try {
    // 清除本地存储的用户信息
    localStorage.clear();

    // 显示退出成功提示
    message.success("退出登录成功");

    // 跳转到登录页
    await router.push("/login");
  } catch (error) {
    console.error("退出登录错误:", error);
    message.error("退出登录失败");
  }
};
</script>

<style scoped>
.layout {
  min-height: 100vh;
}

.logo {
  height: 64px;
  line-height: 64px;
  text-align: center;
  color: white;
  font-size: 18px;
  font-weight: bold;
  overflow: hidden;
}

.header {
  background: #fff;
  padding: 0 24px;
  display: flex;
  justify-content: flex-end;
  align-items: center;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.welcome {
  font-size: 14px;
  color: rgba(0, 0, 0, 0.65);
}

.content {
  margin: 24px;
  background: #fff;
  min-height: 280px;
  border-radius: 4px;
}

.footer {
  text-align: center;
  color: rgba(0, 0, 0, 0.45);
}
</style>
