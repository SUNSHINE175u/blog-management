<template>
  <el-card>
    <template #header>评论管理</template>
    <el-table :data="comments" v-loading="loading">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="nickname" label="昵称" width="120" />
      <el-table-column prop="content" label="内容" min-width="200" />
      <el-table-column prop="articleId" label="文章ID" width="90" />
      <el-table-column label="时间" width="120">
        <template #default="{ row }">{{ formatDate(row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="100">
        <template #default="{ row }">
          <el-button link type="danger" @click="handleDelete(row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessageBox, ElMessage } from 'element-plus'
import { adminApi } from '../../api'
import { formatDate } from '../../utils/markdown'

const comments = ref([])
const loading = ref(false)

async function loadData() {
  loading.value = true
  try {
    comments.value = await adminApi.comments()
  } finally {
    loading.value = false
  }
}

async function handleDelete(id) {
  await ElMessageBox.confirm('确定删除该评论？', '提示', { type: 'warning' })
  await adminApi.deleteComment(id)
  ElMessage.success('删除成功')
  loadData()
}

onMounted(loadData)
</script>
