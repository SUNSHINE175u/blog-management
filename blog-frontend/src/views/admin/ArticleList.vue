<template>
  <el-card>
    <template #header>
      <div class="header-bar">
        <span>文章管理</span>
        <el-button type="primary" @click="$router.push('/admin/article/edit')">写文章</el-button>
      </div>
    </template>

    <div class="filter-bar">
      <el-input v-model="keyword" placeholder="搜索标题" clearable style="width: 200px" @clear="loadData" @keyup.enter="loadData" />
      <el-select v-model="status" placeholder="状态" clearable style="width: 120px; margin-left: 12px" @change="loadData">
        <el-option label="已发布" :value="1" />
        <el-option label="草稿" :value="0" />
      </el-select>
      <el-button style="margin-left: 12px" @click="loadData">搜索</el-button>
    </div>

    <el-table :data="articles" v-loading="loading" style="margin-top: 16px">
      <el-table-column prop="title" label="标题" min-width="200" />
      <el-table-column prop="categoryName" label="分类" width="120" />
      <el-table-column label="状态" width="90">
        <template #default="{ row }">
          <el-tag :type="row.status === 1 ? 'success' : 'info'" size="small">
            {{ row.status === 1 ? '已发布' : '草稿' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="viewCount" label="阅读" width="80" />
      <el-table-column label="时间" width="120">
        <template #default="{ row }">{{ formatDate(row.createTime) }}</template>
      </el-table-column>
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button link type="primary" @click="$router.push(`/admin/article/edit/${row.id}`)">编辑</el-button>
          <el-button link type="danger" @click="handleDelete(row.id)">删除</el-button>
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
const keyword = ref('')
const status = ref(null)
const page = ref(1)
const pageSize = 10
const total = ref(0)
const loading = ref(false)

async function loadData() {
  loading.value = true
  try {
    const data = await adminApi.articles({
      page: page.value,
      size: pageSize,
      keyword: keyword.value || undefined,
      status: status.value ?? undefined
    })
    articles.value = data.records
    total.value = data.total
  } finally {
    loading.value = false
  }
}

async function handleDelete(id) {
  await ElMessageBox.confirm('确定删除该文章？删除后可在回收站恢复。', '提示', { type: 'warning' })
  await adminApi.deleteArticle(id)
  ElMessage.success('已移入回收站')
  loadData()
}

onMounted(loadData)
</script>

<style scoped>
.header-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.filter-bar {
  display: flex;
  align-items: center;
}
</style>
