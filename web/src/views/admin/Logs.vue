<template>
  <div class="logs">
    <a-card :bordered="false">
      <template #title>
        <h2>操作日志</h2>
      </template>

      <a-table
        :columns="columns"
        :data-source="logList"
        :loading="loading"
        :pagination="{
          total: total,
          current: currentPage,
          pageSize: pageSize,
          onChange: handlePageChange,
          showTotal: (total) => `共 ${total} 条记录`
        }"
        row-key="log_id"
      >
        <template #bodyCell="{ column, record }">
          <!-- 操作时间列 -->
          <template v-if="column.dataIndex === 'operation_time'">
            {{ formatDateTime(record.operation_time) }}
          </template>
          
          <!-- 操作类型列 -->
          <template v-if="column.dataIndex === 'operation_type'">
            <a-tag :color="getOperationTypeColor(record.operation_type)">
              {{ record.operation_type }}
            </a-tag>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import axios from 'axios'

const loading = ref(false)
const logList = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const columns = [
  {
    title: '操作时间',
    dataIndex: 'operation_time',
    width: '20%'
  },
  {
    title: '用户ID',
    dataIndex: 'user_id',
    width: '15%'
  },
  {
    title: '操作类型',
    dataIndex: 'operation_type',
    width: '10%'
  },
  {
    title: '操作表',
    dataIndex: 'table_name',
    width: '15%'
  },
  {
    title: '记录ID',
    dataIndex: 'record_id',
    width: '15%'
  },
  {
    title: '描述',
    dataIndex: 'description',
    width: '25%'
  }
]

// 格式化日期时间
const formatDateTime = (date) => {
  if (!date) return '-'
  return new Date(date).toLocaleString('zh-CN')
}

// 获取操作类型对应的颜色
const getOperationTypeColor = (type) => {
  const colors = {
    create: 'success',
    update: 'warning',
    delete: 'error',
    select: 'processing'
  }
  return colors[type] || 'default'
}

// 获取日志列表
const fetchLogs = async (page = 1) => {
  loading.value = true
  try {
    const response = await axios.get('/logs', {
      params: {
        page,
        pageSize: pageSize.value
      }
    })
    
    if (response.data.success) {
      logList.value = response.data.data.list
      total.value = response.data.data.total
      currentPage.value = page
    }
  } catch (error) {
    console.error('获取日志列表失败:', error)
    message.error('获取日志列表失败')
  } finally {
    loading.value = false
  }
}

// 处理分页变化
const handlePageChange = (page) => {
  fetchLogs(page)
}

onMounted(() => {
  fetchLogs(1)
})
</script>

<style scoped>
.logs {
  padding: 24px;
  background: #f0f2f5;
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}
</style> 