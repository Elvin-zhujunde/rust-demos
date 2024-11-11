<template>
  <div class="grade-management">
    <a-card :bordered="false">
      <template #title>
        <h2>成绩管理</h2>
      </template>

      <a-table
        :columns="columns"
        :data-source="gradeList"
        :loading="loading"
        :pagination="false"
        row-key="id"
      >
        <!-- 成绩列自定义渲染 -->
        <template #bodyCell="{ column, record }">
          <template v-if="column.dataIndex === 'grade'">
            <div class="grade-cell">
              <a-input-number
                v-if="record.editing"
                v-model:value="record.tempGrade"
                :min="0"
                :max="100"
                size="small"
                style="width: 80px"
              />
              <template v-else>
                {{ record.grade || '-' }}
              </template>
              <div class="grade-actions">
                <template v-if="record.editing">
                  <a-button type="link" size="small" @click="handleSave(record)">
                    保存
                  </a-button>
                  <a-button type="link" size="small" @click="handleCancel(record)">
                    取消
                  </a-button>
                </template>
                <a-button 
                  v-else 
                  type="link" 
                  size="small" 
                  @click="handleEdit(record)"
                >
                  编辑
                </a-button>
              </div>
            </div>
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
const gradeList = ref([])

// 表格列定义
const columns = [
  {
    title: '课程名称',
    dataIndex: 'subject_name',
    width: '25%'
  },
  {
    title: '学号',
    dataIndex: 'student_id',
    width: '15%'
  },
  {
    title: '学生姓名',
    dataIndex: 'student_name',
    width: '15%'
  },
  {
    title: '班级',
    dataIndex: 'class_name',
    width: '20%'
  },
  {
    title: '成绩',
    dataIndex: 'grade',
    width: '25%'
  }
]

// 获取成绩列表
const fetchGrades = async () => {
  loading.value = true
  try {
    const teacherId = localStorage.getItem('userId')
    const response = await axios.get(`/teacher-grades/${teacherId}`)
    if (response.data.success) {
      // 为每条记录添加唯一id和编辑状态
      gradeList.value = response.data.data.map(item => ({
        ...item,
        id: `${item.course_id}-${item.student_id}`,
        editing: false,
        tempGrade: item.grade
      }))
    }
  } catch (error) {
    console.error('获取成绩列表失败:', error)
    message.error('获取成绩列表失败')
  } finally {
    loading.value = false
  }
}

// 编辑成绩
const handleEdit = (record) => {
  record.editing = true
  record.tempGrade = record.grade
}

// 取消编辑
const handleCancel = (record) => {
  record.editing = false
  record.tempGrade = record.grade
}

// 保存成绩
const handleSave = async (record) => {
  try {
    const response = await axios.post('/update-grade', {
      student_id: record.student_id,
      course_id: record.course_id,
      grade: record.tempGrade
    })

    if (response.data.success) {
      record.grade = record.tempGrade
      record.editing = false
      message.success('成绩更新成功')
    }
  } catch (error) {
    console.error('更新成绩失败:', error)
    message.error(error.response?.data?.message || '更新成绩失败')
  }
}

onMounted(() => {
  fetchGrades()
})
</script>

<style scoped>
.grade-management {
  padding: 24px;
  background: #f0f2f5;
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}

.grade-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.grade-actions {
  display: inline-flex;
  gap: 4px;
}
</style> 