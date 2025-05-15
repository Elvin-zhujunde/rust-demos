<template>
  <div class="course-comments">
    <div class="comment-list">
      <div v-if="comments.length === 0" class="no-comments">暂无评论</div>
      <div
        v-else
        v-for="comment in comments"
        :key="comment.comment_id"
        class="comment-item"
      >
        <div class="comment-header">
          <span class="student-name"
            >{{ comment.student_name }} : {{ comment.rating }}</span
          >
          <span class="comment-time">{{ formatTime(comment.created_at) }}</span>
        </div>
        <div class="comment-rating">
          <a-rate :value="getRating(comment.rating)" disabled />
        </div>
        <div class="comment-content">{{ comment.content }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from "vue";
import axios from "axios";
import dayjs from "dayjs";

const props = defineProps({
  courseId: {
    type: [String, Number],
    required: true,
  },
});

const comments = ref([]);
const loading = ref(false);

const getRating = (rating) => {
  if (rating < 20) {
    return 1;
  } else if (rating < 40) {
    return 2;
  } else if (rating < 60) {
    return 3;
  } else if (rating < 80) {
    return 4;
  } else {
    return 5;
  }
};

// 获取评论列表
const fetchComments = async () => {
  loading.value = true;
  try {
    const response = await axios.get(`/course/${props.courseId}/comments`);
    if (response.data.success) {
      comments.value = response.data.data;
    }
  } catch (error) {
    console.error("获取评论失败:", error);
  } finally {
    loading.value = false;
  }
};

// 格式化时间
const formatTime = (timestamp) => {
  return dayjs(timestamp).format("YYYY-MM-DD HH:mm");
};

// 监听课程ID变化
watch(
  () => props.courseId,
  () => {
    fetchComments();
  }
);

onMounted(() => {
  fetchComments();
});
</script>

<style lang="less" scoped>
.course-comments {
  padding: 20px;
  max-height: 500px;
  overflow-y: auto;

  .no-comments {
    text-align: center;
    color: #999;
    padding: 20px;
  }

  .comment-item {
    padding: 16px;
    border-bottom: 1px solid #f0f0f0;
    margin-bottom: 16px;

    &:last-child {
      border-bottom: none;
      margin-bottom: 0;
    }

    .comment-header {
      display: flex;
      justify-content: space-between;
      margin-bottom: 8px;

      .student-name {
        font-weight: 500;
        color: #1890ff;
      }

      .comment-time {
        color: #999;
        font-size: 12px;
      }
    }

    .comment-rating {
      margin-bottom: 8px;
    }

    .comment-content {
      color: #333;
      line-height: 1.6;
    }
  }
}
</style>
