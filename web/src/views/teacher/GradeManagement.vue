<template>
  <div class="grade-management">
    <a-card :bordered="false">
      <template #title>
        <div class="card-title">
          <div class="title-left">
            <a-button @click="goBack" style="margin-right: 16px">
              <template #icon>
                <arrow-left-outlined />
              </template>
              返回
            </a-button>
            <h2>{{ courseInfo.subject_name }} - 成绩管理</h2>
          </div>
        </div>
      </template>

      <!-- 课程信息 -->
      <a-descriptions :column="3" style="margin-bottom: 24px">
        <a-descriptions-item label="课程名称">
          {{ courseInfo.subject_name }}
        </a-descriptions-item>
        <a-descriptions-item label="学时">
          {{ courseInfo.class_hours }}
        </a-descriptions-item>
        <a-descriptions-item label="学分">
          {{ courseInfo.credits }}
        </a-descriptions-item>
        <a-descriptions-item label="上课时间">
          {{ courseInfo.week_day_text }} {{ courseInfo.section_text }}
        </a-descriptions-item>
        <a-descriptions-item label="选课人数">
          {{ courseInfo.student_count }}/{{ courseInfo.max_students }}
        </a-descriptions-item>
        <a-descriptions-item label="学期">
          第{{ courseInfo.semester }}学期
        </a-descriptions-item>
      </a-descriptions>

      <!-- 成绩列表 -->
      <a-table
        :columns="columns"
        :data-source="gradeList"
        :loading="loading"
        :pagination="{ pageSize: 10 }"
      >
        <template #bodyCell="{ column, record }">
          <!-- 成绩列 -->
          <template v-if="column.dataIndex === 'grade'">
            <a-input-number
              v-if="record.editing"
              v-model:value="record.tempGrade"
              :min="0"
              :max="100"
              :precision="1"
              style="width: 100px"
            />
            <template v-else>
              {{ record.grade || '-' }}
            </template>
          </template>

          <!-- 操作列 -->
          <template v-if="column.dataIndex === 'action'">
            <template v-if="record.editing">
              <a-button type="link" @click="saveGrade(record)">保存</a-button>
              <a-button type="link" @click="cancelEdit(record)">取消</a-button>
            </template>
            <template v-else>
              <a-button type="link" @click="editGrade(record)">编辑</a-button>
            </template>
          </template>
        </template>
      </a-table>
    </a-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import { useRouter, useRoute } from 'vue-router'
import { ArrowLeftOutlined } from '@ant-design/icons-vue'
import axios from 'axios'

const router = useRouter()
const route = useRoute()
const courseId = route.params.course_id

const loading = ref(false)
const courseInfo = ref({})
const gradeList = ref([])

// 表格列定义
const columns = [
  {
    title: '学号',
    dataIndex: 'student_id',
    width: '15%'
  },
  {
    title: '姓名',
    dataIndex: 'name',
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
    width: '20%'
  },
  {
    title: '操作',
    dataIndex: 'action',
    width: '30%'
  }
]

// 获取课程信息和学生成绩列表
const fetchData = async () => {
  loading.value = true
  try {
    // 获取课程信息
    const courseResponse = await axios.get(`/course/${courseId}`)
    if (courseResponse.data.success) {
      courseInfo.value = courseResponse.data.data
    }

    // 获取学生成绩列表
    const gradeResponse = await axios.get(`/course-grades/${courseId}`)
    if (gradeResponse.data.success) {
      gradeList.value = gradeResponse.data.data.map(item => ({
        ...item,
        editing: false,
        tempGrade: item.grade
      }))
    }
  } catch (error) {
    console.error('获取数据失败:', error)
    message.error('获取数据失败')
  } finally {
    loading.value = false
  }
}

// 编辑成绩
const editGrade = (record) => {
  record.editing = true
  record.tempGrade = record.grade
}

// 保存成绩
const saveGrade = async (record) => {
  try {
    const response = await axios.post('/update-grade', {
      student_id: record.student_id,
      course_id: courseId,
      grade: record.tempGrade
    })

    if (response.data.success) {
      record.grade = record.tempGrade
      record.editing = false
      message.success('成绩更新成功')
    }
  } catch (error) {
    console.error('更新成绩失败:', error)
    message.error('更新成绩失败')
  }
}

// 取消编辑
const cancelEdit = (record) => {
  record.editing = false
  record.tempGrade = record.grade
}

// 返回上一页
const goBack = () => {
  router.back()
}

onMounted(() => {
  fetchData()
})
</script>

<style lang="less" scoped>
.grade-management {
  padding: 24px;
  background: #f0f2f5;
}

.card-title {
  .title-left {
    display: flex;
    align-items: center;

    h2 {
      margin: 0;
    }
  }
}
</style> 