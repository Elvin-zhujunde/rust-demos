<template>
  <div class="course-card">
    <div class="course-title">
      {{ course.subject_name }} &nbsp;
      <span class="capacity" v-if="course.max_students">
        ({{ course.student_count }}/{{ course.max_students }})
      </span>
    </div>
    <div class="course-info">
      <span>教师：{{ course.teacher_name }}</span>
      <span>教室：{{ course.classroom_name || "待定" }}</span>
    </div>
  </div>
</template>

<script setup>
defineProps({
  course: {
    type: Object,
    required: true,
  },
});
</script>

<style lang="less" scoped>
.course-card {
  background: #e6f7ff;
  border: 1px solid #91d5ff;
  border-radius: 4px;
  padding: 12px;
  height: 100%;

  .course-title {
    font-weight: bold;
    margin-bottom: 8px;
    color: #0050b3;
  }

  .course-info {
    font-size: 12px;
    color: #666;

    span {
      display: block;
      margin-bottom: 4px;
    }

    .capacity {
      color: #1890ff;
    }
  }
}
</style>
