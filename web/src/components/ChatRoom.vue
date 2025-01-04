<template>
  <div class="chat-room">
    <div class="chat-header">
      <h3>课程聊天室</h3>
      <el-button type="text" @click="$emit('close')">关闭</el-button>
    </div>
    
    <div class="chat-messages" ref="messageContainer">
      <div v-for="msg in messages" :key="msg.message_id" 
           :class="['message', { 'my-message': isMyMessage(msg) }]">
        <div class="message-header">
          <span class="sender-name">{{ msg.sender_name }}</span>
          <span class="message-time">{{ formatTime(msg.created_at) }}</span>
        </div>
        <div class="message-content">{{ msg.content }}</div>
      </div>
    </div>
    
    <div class="chat-input">
      <el-input
        v-model="newMessage"
        placeholder="输入消息..."
        @keyup.enter="sendMessage"
      >
        <template #append>
          <el-button @click="sendMessage">发送</el-button>
        </template>
      </el-input>
    </div>
  </div>
</template>

<script>
import { io } from 'socket.io-client'
import { ref, onMounted, onUnmounted } from 'vue'
import { ElMessage } from 'element-plus'

export default {
  name: 'ChatRoom',
  props: {
    courseId: {
      type: String,
      required: true
    },
    userId: {
      type: String,
      required: true
    },
    userType: {
      type: String,
      required: true
    }
  },
  
  setup(props) {
    const socket = ref(null)
    const messages = ref([])
    const newMessage = ref('')
    const messageContainer = ref(null)

    const scrollToBottom = () => {
      if (messageContainer.value) {
        setTimeout(() => {
          messageContainer.value.scrollTop = messageContainer.value.scrollHeight
        }, 100)
      }
    }

    const connectSocket = () => {
      socket.value = io('http://localhost:8088', {
        transports: ['websocket']
      })

      socket.value.on('connect', () => {
        console.log('WebSocket连接成功')
        socket.value.emit('joinRoom', {
          courseId: props.courseId,
          userId: props.userId,
          userType: props.userType
        })
      })

      socket.value.on('history', (data) => {
        messages.value = data
        scrollToBottom()
      })

      socket.value.on('message', (message) => {
        messages.value.push(message)
        scrollToBottom()
      })

      socket.value.on('error', (error) => {
        console.error('WebSocket错误:', error)
        ElMessage.error(error.message || '发送消息失败')
      })
    }

    const sendMessage = () => {
      if (!newMessage.value.trim()) return
      
      socket.value.emit('message', {
        courseId: props.courseId,
        userId: props.userId,
        userType: props.userType,
        content: newMessage.value.trim()
      })
      
      newMessage.value = ''
    }

    const isMyMessage = (message) => {
      return message.sender_id === props.userId && message.sender_type === props.userType
    }

    const formatTime = (timestamp) => {
      const date = new Date(timestamp)
      return date.toLocaleString('zh-CN', {
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    onMounted(() => {
      connectSocket()
    })

    onUnmounted(() => {
      if (socket.value) {
        socket.value.emit('leaveRoom', {
          courseId: props.courseId
        })
        socket.value.disconnect()
      }
    })

    return {
      messages,
      newMessage,
      messageContainer,
      sendMessage,
      isMyMessage,
      formatTime
    }
  }
}
</script>

<style scoped>
.chat-room {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0,0,0,0.1);
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 20px;
  border-bottom: 1px solid #eee;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
}

.message {
  margin-bottom: 15px;
  max-width: 70%;
}

.my-message {
  margin-left: auto;
  text-align: right;
}

.message-header {
  margin-bottom: 5px;
  font-size: 12px;
  color: #999;
}

.sender-name {
  font-weight: bold;
  margin-right: 10px;
}

.message-content {
  background: #f4f4f4;
  padding: 10px;
  border-radius: 4px;
  word-break: break-word;
}

.my-message .message-content {
  background: #ecf5ff;
}

.chat-input {
  padding: 20px;
  border-top: 1px solid #eee;
}
</style> 