<template>
  <div class="dashboard">
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card shadow="hover"><div class="stat-num">{{ stats.articleCount || 0 }}</div><div class="stat-label">已发布文章</div></el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover"><div class="stat-num">{{ stats.draftCount || 0 }}</div><div class="stat-label">草稿</div></el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover"><div class="stat-num">{{ stats.categoryCount || 0 }}</div><div class="stat-label">分类</div></el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover"><div class="stat-num">{{ stats.commentCount || 0 }}</div><div class="stat-label">评论</div></el-card>
      </el-col>
    </el-row>
    <el-card style="margin-top: 20px">
      <template #header>快捷操作</template>
      <el-button type="primary" @click="$router.push('/admin/article/edit')">写新文章</el-button>
      <el-button @click="$router.push('/admin/articles')">管理文章</el-button>
      <el-button @click="$router.push('/admin/comments')">管理评论</el-button>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { adminApi } from '../../api'

const stats = ref({})

onMounted(async () => {
  stats.value = await adminApi.stats()
})
</script>

<style scoped>
.stat-num {
  font-size: 32px;
  font-weight: 600;
  color: #409eff;
  text-align: center;
}

.stat-label {
  text-align: center;
  color: #999;
  margin-top: 8px;
  font-size: 14px;
}
</style>
