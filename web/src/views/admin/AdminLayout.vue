<template>
  <a-layout class="layout">
    <a-layout-sider v-model:collapsed="collapsed" collapsible>
      <div class="logo">
        <span v-if="!collapsed">教学管理系统</span>
        <span v-else>TMS</span>
      </div>
      <a-menu v-model:selectedKeys="selectedKeys" theme="dark" mode="inline">
        <a-menu-item key="home">
          <home-outlined />
          <span>首页</span>
          <router-link to="/admin/home" />
        </a-menu-item>

        <a-menu-item key="logs">
          <history-outlined />
          <span>操作日志</span>
          <router-link to="/admin/logs" />
        </a-menu-item>
        <a-sub-menu key="system">
          <template #title>
            <setting-outlined />
            <span>系统管理</span>
          </template>
          <a-menu-item key="users">
            <bank-outlined />

            <span>用户管理</span>
            <router-link to="/admin/users" />
          </a-menu-item>
          <a-menu-item key="courses">
            <book-outlined />
            <span>课程管理</span>
            <router-link to="/admin/courses" />
          </a-menu-item>

          <a-menu-item key="classrooms">
            <bank-outlined />
            <span>教室管理</span>
            <router-link to="/admin/classrooms" />
          </a-menu-item>
          <a-menu-item key="grades">
            <bank-outlined />

            <span>成绩管理</span>
            <router-link to="/admin/grades" />
          </a-menu-item>
        </a-sub-menu>
      </a-menu>
    </a-layout-sider>

    <a-layout>
      <a-layout-header class="header">
        <div class="header-right">
          <span class="welcome">管理员</span>
          <a-button type="link" @click="handleLogout">退出登录</a-button>
        </div>
      </a-layout-header>

      <a-layout-content class="content">
        <router-view></router-view>
      </a-layout-content>
    </a-layout>
  </a-layout>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";
import {
  HomeOutlined,
  HistoryOutlined,
  SettingOutlined,
  UserOutlined,
  TeamOutlined,
  SafetyOutlined,
  BookOutlined,
  BankOutlined,
} from "@ant-design/icons-vue";

const router = useRouter();
const collapsed = ref(false);
const selectedKeys = ref(["home"]);

const handleLogout = () => {
  const setTimeForm = localStorage.getItem("setTimeForm");
  localStorage.clear();
  localStorage.setItem("setTimeForm", setTimeForm);
  router.push("/login");
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
  padding: 24px;
  background: #fff;
  min-height: 280px;
  border-radius: 4px;
}
</style>
