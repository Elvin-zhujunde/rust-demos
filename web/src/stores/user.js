import { defineStore } from 'pinia'

export const useUserStore = defineStore('user', {
  state: () => ({
    role: '',
    roleCode: null,
    userId: '',
    name: ''
  }),
  
  actions: {
    setUserInfo(userInfo) {
      this.role = userInfo.role
      this.roleCode = userInfo.roleCode
      this.userId = userInfo.userId
      this.name = userInfo.name
    },
    
    clearUserInfo() {
      this.role = ''
      this.roleCode = null
      this.userId = ''
      this.name = ''
    }
  }
}) 