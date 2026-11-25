<template>
  <el-container class="admin-layout">
    <el-aside width="220px" class="aside">
      <div class="logo">博客管理</div>
      <el-menu :default-active="route.path" router background-color="#304156" text-color="#bfcbd9" active-text-color="#409eff">
        <el-menu-item index="/admin/dashboard">
          <span>仪表盘</span>
        </el-menu-item>
        <el-menu-item index="/admin/articles">
          <span>文章管理</span>
        </el-menu-item>
        <el-menu-item index="/admin/article/edit">
          <span>写文章</span>
        </el-menu-item>
        <el-menu-item index="/admin/categories">
          <span>分类管理</span>
        </el-menu-item>
        <el-menu-item index="/admin/tags">
          <span>标签管理</span>
        </el-menu-item>
        <el-menu-item index="/admin/comments">
          <span>评论管理</span>
        </el-menu-item>
        <el-menu-item index="/admin/recycle">
          <span>回收站</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header class="header">
        <span>{{ userStore.userInfo?.nickname || '管理员' }}</span>
        <div>
          <el-button link @click="goFront">查看前台</el-button>
          <el-button link type="danger" @click="logout">退出</el-button>
        </div>
      </el-header>
      <el-main class="main">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '../../stores/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

onMounted(() => {
  userStore.fetchUserInfo()
})

function goFront() {
  window.open('/', '_blank')
}

function logout() {
  userStore.logout()
  router.push('/admin/login')
}
</script>

<style scoped>
.admin-layout {
  min-height: 100vh;
}

.aside {
  background: #304156;
}

.logo {
  height: 60px;
  line-height: 60px;
  text-align: center;
  color: #fff;
  font-size: 18px;
  font-weight: 600;
}

.header {
  background: #fff;
  border-bottom: 1px solid #eee;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.main {
  background: #f0f2f5;
}
</style>
