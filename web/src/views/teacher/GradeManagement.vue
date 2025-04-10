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

      <!-- 成绩统计 -->
      <div class="grade-statistics">
        <a-row :gutter="16">
          <a-col :span="6">
            <a-card class="stat-card pass-rate">
              <statistic
                title="通过率"
                :value="gradeStatistics.passRate"
                :precision="1"
                suffix="%"
                :value-style="{ color: '#3f8600' }"
              >
                <template #prefix>
                  <rise-outlined />
                </template>
              </statistic>
            </a-card>
          </a-col>
          <a-col :span="6">
            <a-card class="stat-card excellent">
              <statistic
                title="优秀"
                :value="gradeStatistics.excellentCount"
                :suffix="`人 (${gradeStatistics.excellentRate}%)`"
                :value-style="{ color: '#cf1322' }"
              >
                <template #prefix>
                  <trophy-outlined />
                </template>
              </statistic>
            </a-card>
          </a-col>
          <a-col :span="6">
            <a-card class="stat-card good">
              <statistic
                title="良好"
                :value="gradeStatistics.goodCount"
                :suffix="`人 (${gradeStatistics.goodRate}%)`"
                :value-style="{ color: '#1890ff' }"
              >
                <template #prefix>
                  <like-outlined />
                </template>
              </statistic>
            </a-card>
          </a-col>
          <a-col :span="6">
            <a-card class="stat-card average">
              <statistic
                title="一般"
                :value="gradeStatistics.averageCount"
                :suffix="`人 (${gradeStatistics.averageRate}%)`"
                :value-style="{ color: '#faad14' }"
              >
                <template #prefix>
                  <check-outlined />
                </template>
              </statistic>
            </a-card>
          </a-col>
        </a-row>
      </div>

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
import { ref, onMounted, computed } from 'vue'
import { message, Statistic } from 'ant-design-vue'
import { useRouter, useRoute } from 'vue-router'
import { 
  ArrowLeftOutlined,
  RiseOutlined,
  TrophyOutlined,
  LikeOutlined,
  CheckOutlined
} from '@ant-design/icons-vue'
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

// 成绩统计计算
const gradeStatistics = computed(() => {
  const totalStudents = gradeList.value.length
  if (totalStudents === 0) return {
    passRate: 0,
    excellentCount: 0,
    excellentRate: 0,
    goodCount: 0,
    goodRate: 0,
    averageCount: 0,
    averageRate: 0
  }

  const grades = gradeList.value.map(item => Number(item.grade) || 0)
  
  // 统计各等级人数
  const excellent = grades.filter(grade => grade >= 86).length
  const good = grades.filter(grade => grade >= 73 && grade < 86).length
  const average = grades.filter(grade => grade >= 60 && grade < 73).length
  const passing = grades.filter(grade => grade >= 60).length

  // 计算百分比
  const passRate = (passing / totalStudents) * 100
  const excellentRate = (excellent / totalStudents) * 100
  const goodRate = (good / totalStudents) * 100
  const averageRate = (average / totalStudents) * 100

  return {
    passRate: Number(passRate.toFixed(1)),
    excellentCount: excellent,
    excellentRate: Number(excellentRate.toFixed(1)),
    goodCount: good,
    goodRate: Number(goodRate.toFixed(1)),
    averageCount: average,
    averageRate: Number(averageRate.toFixed(1))
  }
})

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

.grade-statistics {
  margin-bottom: 24px;
  
  .stat-card {
    text-align: center;
    border-radius: 8px;
    
    &.pass-rate {
      :deep(.ant-statistic-title) {
        color: #3f8600;
      }
    }
    
    &.excellent {
      :deep(.ant-statistic-title) {
        color: #cf1322;
      }
    }
    
    &.good {
      :deep(.ant-statistic-title) {
        color: #1890ff;
      }
    }
    
    &.average {
      :deep(.ant-statistic-title) {
        color: #faad14;
      }
    }
  }
}
</style> 