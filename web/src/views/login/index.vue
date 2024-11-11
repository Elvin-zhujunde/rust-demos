<template>
  <div class="login-container">
    <a-card class="login-card">
      <a-tabs v-model:activeKey="activeKey" centered>
        <a-tab-pane key="login" tab="登录">
          <a-form
            :model="loginForm"
            @finish="handleLogin"
            layout="vertical"
          >
            <a-form-item
              label="用户名"
              name="username"
              :rules="[{ required: true, message: '请输入用户名' }]"
            >
              <a-input v-model:value="loginForm.username" placeholder="请输入用户名/学号/教师编号" />
            </a-form-item>

            <a-form-item
              label="密码"
              name="password"
              :rules="[{ required: true, message: '请输入密码' }]"
            >
              <a-input-password v-model:value="loginForm.password" placeholder="请输入密码" />
            </a-form-item>

            <a-form-item
              label="角色"
              name="role"
              :rules="[{ required: true, message: '请选择角色' }]"
            >
              <a-radio-group v-model:value="loginForm.role">
                <a-radio value="admin">管理员</a-radio>
                <a-radio value="teacher">教师</a-radio>
                <a-radio value="student">学生</a-radio>
              </a-radio-group>
            </a-form-item>

            <a-form-item>
              <a-button type="primary" html-type="submit" block>登录</a-button>
            </a-form-item>
          </a-form>
        </a-tab-pane>

        <a-tab-pane key="register" tab="注册">
          <a-form
            :model="registerForm"
            @finish="handleRegister"
            layout="vertical"
          >
            <a-form-item
              label="用户名"
              name="username"
              :rules="[{ required: true, message: '请输入用户名' }]"
            >
              <a-input v-model:value="registerForm.username" placeholder="请输入学号/教师编号" />
            </a-form-item>

            <a-form-item
              label="密码"
              name="password"
              :rules="[{ required: true, message: '请输入密码' }]"
            >
              <a-input-password v-model:value="registerForm.password" placeholder="请输入密码" />
            </a-form-item>

            <a-form-item
              label="角色"
              name="role"
              :rules="[{ required: true, message: '请选择角色' }]"
            >
              <a-radio-group v-model:value="registerForm.role">
                <a-radio value="teacher">教师</a-radio>
                <a-radio value="student">学生</a-radio>
              </a-radio-group>
            </a-form-item>

            <a-form-item
              label="姓名"
              name="name"
              :rules="[{ required: true, message: '请输入姓名' }]"
            >
              <a-input v-model:value="registerForm.name" placeholder="请输入姓名" />
            </a-form-item>

            <a-form-item
              label="性别"
              name="gender"
              :rules="[{ required: true, message: '请选择性别' }]"
            >
              <a-radio-group v-model:value="registerForm.gender">
                <a-radio value="男">男</a-radio>
                <a-radio value="女">女</a-radio>
              </a-radio-group>
            </a-form-item>

            <a-form-item
              label="邮箱"
              name="email"
              :rules="[
                { required: true, message: '请输入邮箱' },
                { type: 'email', message: '请输入正确的邮箱格式' }
              ]"
            >
              <a-input v-model:value="registerForm.email" placeholder="请输入邮箱" />
            </a-form-item>

            <a-form-item
              label="地址"
              name="address"
            >
              <a-input v-model:value="registerForm.address" placeholder="请输入地址" />
            </a-form-item>

            <a-form-item
              label="院系"
              name="department_id"
              :rules="[{ required: true, message: '请选择院系' }]"
            >
              <a-select v-model:value="registerForm.department_id" placeholder="请选择院系">
                <a-select-option 
                  v-for="dept in departments" 
                  :key="dept.department_name" 
                  :value="dept.department_id"
                >
                  {{ dept.department_name }}
                </a-select-option>
              </a-select>
            </a-form-item>

            <a-form-item>
              <a-button type="primary" html-type="submit" block>注册</a-button>
            </a-form-item>
          </a-form>
        </a-tab-pane>
      </a-tabs>
    </a-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { message } from 'ant-design-vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()
const activeKey = ref('login')

const loginForm = reactive({
  username: '',
  password: '',
  role: 'student'
})

const registerForm = reactive({
  username: '',
  password: '',
  role: 'student',
  name: '',
  gender: '男',
  email: '',
  address: '',
  department_id: undefined
})

const departments = ref([])

const fetchDepartments = async () => {
  try {
    const res = await fetch('http://localhost:8088/department')
    const data = await res.json()
    if (data.success) {
      departments.value = data.data
    } else {
      message.error('获取院系列表失败')
    }
  } catch (error) {
    console.error('获取院系列表错误:', error)
    message.error('获取院系列表失败')
  }
}

onMounted(() => {
  fetchDepartments()
})

const handleLogin = async (values) => {
  try {
    const res = await fetch('http://localhost:8088/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(values)
    })
    const data = await res.json()
    
    if (data.success) {
      message.success(data.message)
      userStore.setUserInfo({
        role: data.role,
        roleCode: data.roleCode,
        userId: data.userId,
        name: data.name
      })
      router.push('/')
    } else {
      message.error(data.message)
    }
  } catch (error) {
    console.error('登录错误:', error)
    message.error('登录失败，请稍后重试')
  }
}

const handleRegister = async (values) => {
  try {
    const res = await fetch('http://localhost:8088/register', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(values)
    })
    const data = await res.json()
    
    if (data.success) {
      message.success(data.message)
      activeKey.value = 'login'
    } else {
      message.error(data.message)
    }
  } catch (error) {
    console.error('注册错误:', error)
    message.error('注册失败，请稍后重试')
  }
}
</script>

<style lang="less" scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background-color: #f0f2f5;
}

.login-card {
  width: 400px;
  
  :deep(.ant-card-body) {
    padding: 24px;
  }
}
</style> 