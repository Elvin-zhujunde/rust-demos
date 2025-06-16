import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import Antd from 'ant-design-vue'
import 'ant-design-vue/dist/reset.css'
import axios from 'axios'

const app = createApp(App)
const pinia = createPinia()

// 配置axios默认值
axios.defaults.baseURL = 'http://localhost:8088'
axios.defaults.timeout = 5000

app.use(router)
app.use(Antd)
app.use(pinia)
app.mount('#app')

router.isReady().then(() => {
    console.log('路由已就绪')
})