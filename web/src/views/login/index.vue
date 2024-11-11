<template>
  <div class="login-container">
    <div class="login-box">
      <h2>教学管理系统</h2>
      <a-form
        :model="formData"
        @finish="handleSubmit"
      >
        <a-form-item
          name="username"
          :rules="[{ required: true, message: '请输入用户名' }]"
        >
          <a-input
            v-model:value="formData.username"
            placeholder="请输入用户名/学号/教工号"
          >
            <template #prefix>
              <user-outlined />
            </template>
          </a-input>
        </a-form-item>

        <a-form-item
          name="password"
          :rules="[{ required: true, message: '请输入密码' }]"
        >
          <a-input-password
            v-model:value="formData.password"
            placeholder="请输入密码"
          >
            <template #prefix>
              <lock-outlined />
            </template>
          </a-input-password>
        </a-form-item>

        <a-form-item name="role">
          <a-radio-group v-model:value="formData.role">
            <a-radio value="student">学生</a-radio>
            <a-radio value="teacher">教师</a-radio>
          </a-radio-group>
        </a-form-item>

        <a-form-item>
          <a-button type="primary" html-type="submit" block :loading="loading">
            登录
          </a-button>
        </a-form-item>

        <div class="form-footer">
          还没有账号？ <router-link to="/register">去注册</router-link>
        </div>
      </a-form>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { UserOutlined, LockOutlined } from '@ant-design/icons-vue'
import axios from 'axios'

const router = useRouter()
const loading = ref(false)

const formData = reactive({
  username: '',
  password: '',
  role: 'student'
})

const handleSubmit = async () => {
  try {
    loading.value = true
    const response = await axios.post('/login', formData)
    
    if (response.data.success) {
      // 保存用户信息到localStorage
      localStorage.setItem('role', response.data.role)
      localStorage.setItem('roleCode', response.data.roleCode)
      localStorage.setItem('userId', response.data.userId)
      localStorage.setItem('name', response.data.name)

      message.success('登录成功')
      
      // 直接跳转到首页
      await router.push('/home')
    } else {
      message.error(response.data.message || '登录失败')
    }
  } catch (error) {
    console.error('登录错误:', error)
    message.error(error.response?.data?.message || '登录失败，请检查网络连接')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f0f2f5;
}

.login-box {
  width: 368px;
  padding: 32px;
  background: white;
  border-radius: 4px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

h2 {
  text-align: center;
  margin-bottom: 24px;
  color: rgba(0, 0, 0, 0.85);
}

:deep(.ant-input-affix-wrapper) {
  height: 40px;
}

:deep(.ant-btn) {
  height: 40px;
}

.ant-form-item:last-child {
  margin-bottom: 0;
}

.form-footer {
  margin-top: 16px;
  text-align: center;
  font-size: 14px;
}

.form-footer a {
  color: #1890ff;
  text-decoration: none;
}

.form-footer a:hover {
  text-decoration: underline;
}
</style> 