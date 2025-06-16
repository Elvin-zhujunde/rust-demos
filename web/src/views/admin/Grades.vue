<template>
  <div class="grades-container">
    <!-- 筛选表单 -->
    <a-form layout="inline" class="filter-form">
      <a-form-item label="课程">
        <a-input
          v-model:value="filters.course_name"
          placeholder="请输入课程名称"
          allowClear
        />
      </a-form-item>
      <a-form-item label="学生">
        <a-input
          v-model:value="filters.student_name"
          placeholder="请输入学生姓名"
          allowClear
        />
      </a-form-item>
      <a-form-item label="学号">
        <a-input
          v-model:value="filters.student_id"
          placeholder="请输入学号"
          allowClear
        />
      </a-form-item>
      <a-form-item label="成绩区间">
        <a-space>
          <a-input-number
            v-model:value="filters.min_score"
            :min="0"
            :max="100"
            placeholder="最低分"
          />
          <span>-</span>
          <a-input-number
            v-model:value="filters.max_score"
            :min="0"
            :max="100"
            placeholder="最高分"
          />
        </a-space>
      </a-form-item>
      <a-form-item>
        <a-space>
          <a-button type="primary" @click="handleSearch">查询</a-button>
          <a-button @click="handleReset">重置</a-button>
        </a-space>
      </a-form-item>
    </a-form>

    <!-- 成绩表格 -->
    <a-table
      :columns="columns"
      :data-source="grades"
      :loading="loading"
      :pagination="pagination"
      @change="handleTableChange"
      row-key="id"
    >
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'action'">
          <a-space>
            <a @click="showModal(record)">编辑</a>
          </a-space>
        </template>
      </template>
    </a-table>

    <!-- 编辑成绩弹窗 -->
    <a-modal
      v-model:visible="modalVisible"
      title="编辑成绩"
      @ok="handleModalOk"
      @cancel="handleModalCancel"
    >
      <a-form
        ref="formRef"
        :model="formState"
        :rules="rules"
        :label-col="{ span: 6 }"
        :wrapper-col="{ span: 16 }"
      >
        <a-form-item label="学生姓名">
          <span>{{ formState.student_name }}</span>
        </a-form-item>
        <a-form-item label="学号">
          <span>{{ formState.student_id }}</span>
        </a-form-item>
        <a-form-item label="课程">
          <span>{{ formState.course_name }}</span>
        </a-form-item>
        <a-form-item label="成绩" name="score">
          <a-input-number
            v-model:value="formState.grade"
            :min="0"
            :max="100"
            style="width: 100%"
          />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import axios from 'axios'

// 表格列定义
const columns = [
  {
    title: '课程名称',
    dataIndex: 'course_name',
    key: 'course_name',
  },
  {
    title: '学分',
    dataIndex: 'credits',
    key: 'credits',
    width: 80,
  },
  {
    title: '学时',
    dataIndex: 'class_hours',
    key: 'class_hours',
    width: 80,
  },
  {
    title: '授课教师',
    dataIndex: 'teacher_name',
    key: 'teacher_name',
    width: 100,
  },
  {
    title: '职称',
    dataIndex: 'teacher_title',
    key: 'teacher_title',
    width: 100,
  },
  {
    title: '学生姓名',
    dataIndex: 'student_name',
    key: 'student_name',
  },
  {
    title: '学号',
    dataIndex: 'student_id',
    key: 'student_id',
  },
  {
    title: '成绩',
    dataIndex: 'grade',
    key: 'grade',
    width: 80,
  },
  {
    title: '操作',
    key: 'action',
    fixed: 'right',
    width: 120,
  },
]

// 数据定义
const loading = ref(false)
const grades = ref([])
const modalVisible = ref(false)
const formRef = ref(null)

// 筛选条件
const filters = ref({
  course_name: '',
  student_name: '',
  student_id: '',
  min_score: undefined,
  max_score: undefined,
})

// 表单数据
const formState = ref({
  id: null,
  student_name: '',
  student_id: '',
  course_name: '',
  grade: undefined,
  comment: '',
})

// 表单验证规则
const rules = {
  grade: [
    { required: true, message: '请输入成绩' },
    { type: 'number', min: 0, max: 100, message: '成绩必须在0-100之间' },
  ],
}

// 分页配置
const pagination = ref({
  current: 1,
  pageSize: 10,
  total: 0,
})

// 获取成绩列表
const fetchGrades = async () => {
  loading.value = true
  try {
    const res = await axios.get('/grades/admin', {
      params: {
        page: pagination.value.current,
        pageSize: pagination.value.pageSize,
        ...filters.value,
      },
    })
    grades.value = res.data.data.items
    pagination.value.total = res.data.data.total
  } catch (error) {
    message.error('获取成绩列表失败')
  } finally {
    loading.value = false
  }
}

// 处理搜索
const handleSearch = () => {
  pagination.value.current = 1
  fetchGrades()
}

// 处理重置
const handleReset = () => {
  filters.value = {
    course_name: '',
    student_name: '',
    student_id: '',
    min_score: undefined,
    max_score: undefined,
  }
  pagination.value.current = 1
  fetchGrades()
}

// 处理表格变化
const handleTableChange = (pag) => {
  pagination.value.current = pag.current
  pagination.value.pageSize = pag.pageSize
  fetchGrades()
}

// 显示编辑弹窗
const showModal = (record) => {
  formState.value = { ...record }
  modalVisible.value = true
}

// 处理弹窗确认
const handleModalOk = async () => {
  try {
    await formRef.value.validate()
    await axios.post(`/update-grade`, {
      grade: formState.value.grade,
      course_id:formState.value.course_id,
      student_id: formState.value.student_id,
    })
    message.success('更新成功')
    modalVisible.value = false
    fetchGrades()
  } catch (error) {
    message.error('更新失败')
  }
}

// 处理弹窗取消
const handleModalCancel = () => {
  modalVisible.value = false
  formRef.value?.resetFields()
}

onMounted(() => {
  fetchGrades()
})
</script>

<style scoped>
.grades-container {
  padding: 24px;
}

.filter-form {
  margin-bottom: 16px;
  padding: 24px;
  background: #fff;
  border-radius: 2px;
}
</style>
