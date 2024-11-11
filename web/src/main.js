import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import pinia from './stores'
import Antd from 'ant-design-vue'
// import 'ant-design-vue/dist/reset.css'
import './assets/styles/main.less'

const app = createApp(App)

app.use(pinia)
app.use(router)
app.use(Antd)

app.mount('#app')

router.isReady().then(() => {
    console.log('路由已就绪')
}) 