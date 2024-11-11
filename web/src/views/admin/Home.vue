<template>
  <div class="admin-home">
    <a-card :bordered="false">
      <template #title>
        <h2>管理员首页</h2>
      </template>

      <a-row :gutter="16">
        <a-col :span="8">
          <a-card>
            <a-statistic
              title="总学生数"
              :value="statistics.studentCount"
              :value-style="{ color: '#3f8600' }"
            >
              <template #prefix>
                <user-outlined />
              </template>
            </a-statistic>
          </a-card>
        </a-col>
        <a-col :span="8">
          <a-card>
            <a-statistic
              title="总教师数"
              :value="statistics.teacherCount"
              :value-style="{ color: '#1890ff' }"
            >
              <template #prefix>
                <solution-outlined />
              </template>
            </a-statistic>
          </a-card>
        </a-col>
        <a-col :span="8">
          <a-card>
            <a-statistic
              title="总课程数"
              :value="statistics.courseCount"
              :value-style="{ color: '#cf1322' }"
            >
              <template #prefix>
                <book-outlined />
              </template>
            </a-statistic>
          </a-card>
        </a-col>
      </a-row>
    </a-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { UserOutlined, SolutionOutlined, BookOutlined } from '@ant-design/icons-vue'
import { message } from 'ant-design-vue'
import axios from 'axios'

const statistics = ref({
  studentCount: 0,
  teacherCount: 0,
  courseCount: 0
})

const fetchStatistics = async () => {
  try {
    const response = await axios.get('/admin/statistics')
    if (response.data.success) {
      statistics.value = response.data.data
    }
  } catch (error) {
    console.error('获取统计数据失败:', error)
    message.error('获取统计数据失败')
  }
}

onMounted(() => {
  fetchStatistics()
})
</script>

<style scoped>
.admin-home {
  padding: 24px;
  background: #f0f2f5;
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}

.ant-row {
  margin-top: 24px;
}

.ant-card {
  text-align: center;
}
</style> 