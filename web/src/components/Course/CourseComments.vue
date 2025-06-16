<template>
  <div class="course-comments">
    <!-- 筛选表单 -->
    <a-form layout="inline" class="filter-form">
      <a-form-item label="学生姓名">
        <a-input
          v-model:value="filters.student_name"
          placeholder="请输入学生姓名"
          allowClear
        />
      </a-form-item>
      <a-form-item label="评分区间">
        <a-space>
          <a-input-number
            v-model:value="filters.min_rating"
            :min="1"
            :max="5"
            placeholder="最低星"
          />
          <span>-</span>
          <a-input-number
            v-model:value="filters.max_rating"
            :min="1"
            :max="5"
            placeholder="最高星"
          />
        </a-space>
      </a-form-item>
      <a-form-item label="时间区间">
        <a-range-picker
          v-model:value="filters.time_range"
          style="width: 260px"
        />
      </a-form-item>
      <a-form-item>
        <a-button type="primary" @click="handleFilter">筛选</a-button>
        <a-button style="margin-left: 12px" @click="handleReset">重置</a-button>
      </a-form-item>
    </a-form>

    <!-- 评论表格 -->
    <a-table
      :columns="columns"
      :data-source="filteredComments"
      :loading="loading"
      row-key="comment_id"
      :pagination="{ pageSize: 10 }"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'rating'">
          <a-rate :value="record.rating" disabled />
        </template>
        
        <template v-else-if="column.key === 'created_at'">
          {{ formatTime(record.created_at) }}
        </template>

      </template>
    </a-table>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed } from "vue";
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

// 表格列定义
const columns = [
  { title: "学生姓名", dataIndex: "student_name", key: "student_name" },
  { title: "评星", dataIndex: "rating", key: "rating", width: 300 },
  { title: "分数", dataIndex: "content", key: "content", ellipsis: true },
  { title: "时间", dataIndex: "created_at", key: "created_at", width: 300 },
];

// 筛选条件
const filters = ref({
  student_name: "",
  min_rating: undefined,
  max_rating: undefined,
  time_range: [],
});

// 评分转换（原始数据如有百分制转星级，可在此处理）
const getStar = (rating) => {
  if (rating > 5) return Math.round(rating / 20); // 兼容百分制
  return rating;
};

// 前端筛选
const filteredComments = computed(() => {
  return comments.value
    .filter((item) => {
      // 姓名筛选
      if (
        filters.value.student_name &&
        !item.student_name.includes(filters.value.student_name)
      ) {
        return false;
      }
      // 评分筛选
      const star = getStar(item.rating);
      if (filters.value.min_rating && star < filters.value.min_rating) {
        return false;
      }
      if (filters.value.max_rating && star > filters.value.max_rating) {
        return false;
      }
      // 时间筛选
      if (filters.value.time_range && filters.value.time_range.length === 2) {
        const t = dayjs(item.created_at);
        if (
          t.isBefore(filters.value.time_range[0]) ||
          t.isAfter(filters.value.time_range[1])
        ) {
          return false;
        }
      }
      return true;
    })
    .map((item) => ({ ...item, rating: getStar(item.rating) }));
});

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

const handleFilter = () => {
  // 触发computed刷新
  filters.value = { ...filters.value };
};

const handleReset = () => {
  filters.value = {
    student_name: "",
    min_rating: undefined,
    max_rating: undefined,
    time_range: [],
  };
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
  margin: 0 auto;

  .filter-form {
    margin-bottom: 16px;
    background: #fff;
    padding: 16px 24px;
    border-radius: 4px;
  }
}
</style>
