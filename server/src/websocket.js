const { Server } = require('socket.io')
const chatController = require('./controllers/chatController')

function initWebSocket(server) {
  const io = new Server(server, {
    cors: {
      origin: "*",
      methods: ["GET", "POST"]
    }
  })

  // 存储用户连接信息
  const courseRooms = new Map() // courseId -> Set of socket ids

  io.on('connection', (socket) => {
    console.log('新的WebSocket连接:', socket.id)

    // 加入课程聊天室
    socket.on('joinRoom', async ({ courseId, userId, userType }) => {
      console.log(`用户 ${userId} (${userType}) 加入课程 ${courseId} 的聊天室`)
      
      socket.join(`course_${courseId}`)
      
      if (!courseRooms.has(courseId)) {
        courseRooms.set(courseId, new Set())
      }
      courseRooms.get(courseId).add(socket.id)

      // 获取历史消息
      try {
        const messages = await chatController.getMessages(courseId)
        socket.emit('history', messages)
      } catch (error) {
        console.error('获取历史消息失败:', error)
      }
    })

    // 处理新消息
    socket.on('message', async (data) => {
      const { courseId, userId, userType, content } = data
      console.log(`收到来自用户 ${userId} 的消息:`, content)

      try {
        // 保存消息到数据库
        const message = await chatController.saveMessage({
          courseId,
          senderId: userId,
          senderType: userType,
          content
        })

        // 广播消息给课程聊天室的所有用户
        io.to(`course_${courseId}`).emit('message', message)
      } catch (error) {
        console.error('保存/广播消息失败:', error)
        socket.emit('error', { message: '发送消息失败' })
      }
    })

    // 离开聊天室
    socket.on('leaveRoom', ({ courseId }) => {
      console.log(`Socket ${socket.id} 离开课程 ${courseId} 的聊天室`)
      socket.leave(`course_${courseId}`)
      
      if (courseRooms.has(courseId)) {
        courseRooms.get(courseId).delete(socket.id)
      }
    })

    // 断开连接
    socket.on('disconnect', () => {
      console.log('WebSocket连接断开:', socket.id)
      // 清理用户连接信息
      for (const [courseId, users] of courseRooms.entries()) {
        if (users.has(socket.id)) {
          users.delete(socket.id)
        }
      }
    })
  })

  return io
}

module.exports = initWebSocket 