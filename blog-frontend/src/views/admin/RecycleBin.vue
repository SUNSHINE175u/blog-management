<template>
  <el-card>
    <template #header>回收站</template>
    <el-table :data="articles" v-loading="loading">
      <el-table-column prop="title" label="标题" min-width="200" />
      <el-table-column prop="categoryName" label="分类" width="120" />
      <el-table-column label="删除时间" width="120">
        <template #default="{ row }">{{ formatDate(row.updateTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="200" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="handleRestore(row.id)">恢复</el-button>
          <el-button link type="danger" @click="handlePermanentDelete(row.id)">永久删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination
      style="margin-top: 16px; justify-content: flex-end"
      background
      layout="total, prev, pager, next"
      :total="total"
      :page-size="pageSize"
      v-model:current-page="page"
      @current-change="loadData"
    />
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessageBox, ElMessage } from 'element-plus'
import { adminApi } from '../../api'
import { formatDate } from '../../utils/markdown'

const articles = ref([])
const page = ref(1)
const pageSize = 10
const total = ref(0)
const loading = ref(false)

async function loadData() {
  loading.value = true
  try {
    const data = await adminApi.recycleArticles({ page: page.value, size: pageSize })
    articles.value = data.records
    total.value = data.total
  } finally {
    loading.value = false
  }
}

async function handleRestore(id) {
  await adminApi.restoreArticle(id)
  ElMessage.success('恢复成功')
  loadData()
}

async function handlePermanentDelete(id) {
  await ElMessageBox.confirm('永久删除后无法恢复，确定？', '警告', { type: 'error' })
  await adminApi.permanentDelete(id)
  ElMessage.success('已永久删除')
  loadData()
}

onMounted(loadData)
</script>
