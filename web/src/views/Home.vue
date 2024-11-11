<template>
  <div class="home-container">
    <h1 class="welcome-title">欢迎来到教学管理系统</h1>
    <p class="welcome-subtitle">{{ welcomeMessage }}</p>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const role = localStorage.getItem('role')
const welcomeMessage = computed(() => {
  return role === 'teacher' ? '您可以在这里管理课程、成绩和学生信息' : '您可以在这里进行选课、查看成绩等操作'
})
</script>

<style scoped>
.home-container {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 60vh;
  text-align: center;
}

.welcome-title {
  font-size: 36px;
  color: #1890ff;
  margin-bottom: 16px;
}

.welcome-subtitle {
  font-size: 18px;
  color: rgba(0, 0, 0, 0.45);
}
</style> 