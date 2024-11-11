<template>
  <a-layout class="layout-container">
    <a-layout-sider>侧边栏</a-layout-sider>
    <a-layout>
      <a-layout-header>头部</a-layout-header>
      <a-layout-content>
        <router-view></router-view>
      </a-layout-content>
    </a-layout>
  </a-layout>
</template>

<script setup>
</script>

<style lang="less" scoped>
.layout-container {
  height: 100%;
}
</style> 