<template>
  <div class="student-management">
    <a-card :bordered="false">
      <template #title>
        <h2>学生管理</h2>
      </template>

      <a-table
        :columns="columns"
        :data-source="studentList"
        :loading="loading"
        :pagination="false"
        row-key="student_id"
      >
        <!-- 使用 v-slot:bodyCell 替代 slots -->
        <template #bodyCell="{ column, record }">
          <!-- GPA列 -->
          <template v-if="column.dataIndex === 'gpa'">
            {{ Number(record.gpa).toFixed(2) || '-' }}
          </template>
          
          <!-- 入学日期列 -->
          <template v-if="column.dataIndex === 'enrollment_date'">
            {{ formatDate(record.enrollment_date) }}
          </template>

          <!-- 操作列 -->
          <template v-if="column.dataIndex === 'action'">
            <a-space>
              <a-button type="link" @click="handleEdit(record)">
                编辑
              </a-button>
              <a-button type="link" @click="showCourseDetails(record)">
                查看选课详情
              </a-button>
            </a-space>
          </template>
        </template>
      </a-table>

      <!-- 选课详情弹窗 -->
      <a-modal
        v-model:open="detailVisible"
        title="选课详情"
        width="800px"
        :footer="null"
        :destroyOnClose="true"
      >
        <a-spin :spinning="detailLoading">
          <a-descriptions :column="2" bordered>
            <a-descriptions-item label="学号">
              {{ selectedStudent?.student_id }}
            </a-descriptions-item>
            <a-descriptions-item label="姓名">
              {{ selectedStudent?.name }}
            </a-descriptions-item>
            <a-descriptions-item label="班级">
              {{ selectedStudent?.class_name }}
            </a-descriptions-item>
            <a-descriptions-item label="选课数量">
              {{ selectedStudent?.course_count }}
            </a-descriptions-item>
          </a-descriptions>

          <a-divider />

          <a-table
            :columns="courseColumns"
            :data-source="courseDetails"
            :pagination="false"
            size="small"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.dataIndex === 'selection_date'">
                {{ formatDate(record.selection_date) }}
              </template>
            </template>
          </a-table>
        </a-spin>
      </a-modal>

      <!-- 添加编辑学生信息的弹窗 -->
      <a-modal
        v-model:open="editVisible"
        title="修改学生信息"
        @ok="handleEditSubmit"
        :confirmLoading="editLoading"
      >
        <a-form
          :model="editForm"
          :rules="rules"
          ref="editFormRef"
          :label-col="{ span: 6 }"
          :wrapper-col="{ span: 16 }"
        >
          <a-form-item label="学号" name="student_id">
            <span>{{ editForm.student_id }}</span>
          </a-form-item>
          
          <a-form-item label="姓名" name="name">
            <a-input v-model:value="editForm.name" />
          </a-form-item>
          
          <a-form-item label="性别" name="gender">
            <a-radio-group v-model:value="editForm.gender">
              <a-radio value="男">男</a-radio>
              <a-radio value="女">女</a-radio>
            </a-radio-group>
          </a-form-item>
          
          <a-form-item label="院系" name="department_id">
            <a-select
              v-model:value="editForm.department_id"
              @change="handleDepartmentChange"
            >
              <a-select-option
                v-for="dept in departments"
                :key="dept.department_id"
                :value="dept.department_id"
              >
                {{ dept.department_name }}
              </a-select-option>
            </a-select>
          </a-form-item>
          
          <a-form-item label="专业" name="major_id">
            <a-select
              v-model:value="editForm.major_id"
              @change="handleMajorChange"
              :disabled="!editForm.department_id"
            >
              <a-select-option
                v-for="major in majors"
                :key="major.major_id"
                :value="major.major_id"
              >
                {{ major.major_name }}
              </a-select-option>
            </a-select>
          </a-form-item>
          
          <a-form-item label="班级" name="class_id">
            <a-select
              v-model:value="editForm.class_id"
              :disabled="!editForm.major_id"
            >
              <a-select-option
                v-for="cls in classes"
                :key="cls.class_id"
                :value="cls.class_id"
              >
                {{ cls.class_name }}
              </a-select-option>
            </a-select>
          </a-form-item>
        </a-form>
      </a-modal>
    </a-card>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue'
import { message } from 'ant-design-vue'
import axios from 'axios'

const loading = ref(false)
const detailLoading = ref(false)
const studentList = ref([])
const detailVisible = ref(false)
const selectedStudent = ref(null)
const courseDetails = ref([])

// 编辑相关的状态
const editVisible = ref(false)
const editLoading = ref(false)
const editFormRef = ref(null)
const departments = ref([])
const majors = ref([])
const classes = ref([])

const editForm = reactive({
  student_id: '',
  name: '',
  gender: '',
  department_id: '',
  major_id: '',
  class_id: ''
})

const rules = {
  name: [{ required: true, message: '请输入姓名' }],
  gender: [{ required: true, message: '请选择性别' }],
  department_id: [{ required: true, message: '请选择院系' }],
  major_id: [{ required: true, message: '请选择专业' }],
  class_id: [{ required: true, message: '请选择班级' }]
}

// 学生表格列定义
const columns = [
  {
    title: '学号',
    dataIndex: 'student_id',
    width: '10%'
  },
  {
    title: '姓名',
    dataIndex: 'name',
    width: '8%'
  },
  {
    title: '性别',
    dataIndex: 'gender',
    width: '6%'
  },
  {
    title: '院系',
    dataIndex: 'department_name',
    width: '12%'
  },
  {
    title: '专业',
    dataIndex: 'major_name',
    width: '15%'
  },
  {
    title: '班级',
    dataIndex: 'class_name',
    width: '12%'
  },
  {
    title: '入学日期',
    dataIndex: 'enrollment_date',
    width: '10%'
  },
  {
    title: '学期',
    dataIndex: 'semester',
    width: '6%'
  },
  {
    title: '选课数',
    dataIndex: 'course_count',
    width: '7%'
  },
  {
    title: 'GPA',
    dataIndex: 'gpa',
    width: '7%'
  },
  {
    title: '操作',
    dataIndex: 'action',
    width: '7%',
    fixed: 'right'
  }
]

// 课程详情表格列定义
const courseColumns = [
  {
    title: '课程名称',
    dataIndex: 'subject_name',
    width: '30%'
  },
  {
    title: '学分',
    dataIndex: 'credits',
    width: '20%'
  },
  {
    title: '选课时间',
    dataIndex: 'selection_date',
    width: '25%'
  },
  {
    title: '成绩',
    dataIndex: 'grade',
    width: '25%'
  }
]

// 格式化日期
const formatDate = (date) => {
  if (!date) return '-'
  return new Date(date).toLocaleDateString('zh-CN')
}

// 获取学生列表
const fetchStudents = async () => {
  loading.value = true
  try {
    const teacherId = localStorage.getItem('userId')
    const response = await axios.get(`/teacher-students/${teacherId}`)
    if (response.data.success) {
      studentList.value = response.data.data
    }
  } catch (error) {
    console.error('获取学生列表失败:', error)
    message.error('获取学生列表失败')
  } finally {
    loading.value = false
  }
}

// 查看选课详情
const showCourseDetails = async (student) => {
  selectedStudent.value = student
  detailVisible.value = true
  detailLoading.value = true
  
  try {
    const teacherId = localStorage.getItem('userId')
    const response = await axios.get(`/teacher-student-courses/${teacherId}/${student.student_id}`)
    if (response.data.success) {
      courseDetails.value = response.data.data
    }
  } catch (error) {
    console.error('获取选课详情失败:', error)
    message.error('获取选课详情失败')
  } finally {
    detailLoading.value = false
  }
}

// 获取院系列表
const fetchDepartments = async () => {
  try {
    const response = await axios.get('/departments')
    if (response.data.success) {
      departments.value = response.data.data
    }
  } catch (error) {
    console.error('获取院系列表失败:', error)
    message.error('获取院系列表失败')
  }
}

// 获取专业列表
const fetchMajors = async (departmentId) => {
  try {
    const response = await axios.get('/majors', {
      params: { department_id: departmentId }
    })
    if (response.data.success) {
      majors.value = response.data.data
    }
  } catch (error) {
    console.error('获取专业列表失败:', error)
    message.error('获取专业列表失败')
  }
}

// 获取班级列表
const fetchClasses = async (majorId) => {
  try {
    const response = await axios.get('/classes', {
      params: { major_id: majorId }
    })
    if (response.data.success) {
      classes.value = response.data.data
    }
  } catch (error) {
    console.error('获取班级列表失败:', error)
    message.error('获取班级列表失败')
  }
}

// 处理院系变化
const handleDepartmentChange = async (value) => {
  editForm.major_id = ''
  editForm.class_id = ''
  majors.value = []
  classes.value = []
  if (value) {
    await fetchMajors(value)
  }
}

// 处理专业变化
const handleMajorChange = async (value) => {
  editForm.class_id = ''
  classes.value = []
  if (value) {
    await fetchClasses(value)
  }
}

// 打开编辑弹窗
const handleEdit = async (record) => {
  editForm.student_id = record.student_id
  editForm.name = record.name
  editForm.gender = record.gender
  editForm.department_id = record.department_id
  editForm.major_id = record.major_id
  editForm.class_id = record.class_id
  
  await fetchDepartments()
  if (record.department_id) {
    await fetchMajors(record.department_id)
  }
  if (record.major_id) {
    await fetchClasses(record.major_id)
  }
  
  editVisible.value = true
}

// 提交编辑
const handleEditSubmit = async () => {
  try {
    await editFormRef.value.validate()
    editLoading.value = true
    
    const response = await axios.put(`/student/${editForm.student_id}`, {
      name: editForm.name,
      gender: editForm.gender,
      department_id: editForm.department_id,
      major_id: editForm.major_id,
      class_id: editForm.class_id
    })
    
    if (response.data.success) {
      message.success('更新成功')
      editVisible.value = false
      await fetchStudents() // 刷新学生列表
    }
  } catch (error) {
    console.error('更新学生信息失败:', error)
    message.error(error.response?.data?.message || '更新失败')
  } finally {
    editLoading.value = false
  }
}

onMounted(() => {
  fetchStudents()
})
</script>

<style scoped>
.student-management {
  padding: 24px;
  background: #f0f2f5;
}

:deep(.ant-card-head-title h2) {
  margin: 0;
}

:deep(.ant-descriptions) {
  margin-bottom: 20px;
}

:deep(.ant-table-wrapper) {
  margin-top: 16px;
}
</style> 