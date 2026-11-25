<template>
  <el-card>
    <template #header>
      <div class="header-bar">
        <span>标签管理</span>
        <el-button type="primary" @click="openDialog()">新增标签</el-button>
      </div>
    </template>

    <el-table :data="tags">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="name" label="名称" />
      <el-table-column label="操作" width="160">
        <template #default="{ row }">
          <el-button link type="primary" @click="openDialog(row)">编辑</el-button>
          <el-button link type="danger" @click="handleDelete(row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog v-model="dialogVisible" :title="form.id ? '编辑标签' : '新增标签'" width="400px">
      <el-form :model="form" label-width="60px">
        <el-form-item label="名称"><el-input v-model="form.name" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </el-card>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessageBox, ElMessage } from 'element-plus'
import { adminApi } from '../../api'

const tags = ref([])
const dialogVisible = ref(false)
const form = ref({ id: null, name: '' })

async function loadData() {
  tags.value = await adminApi.tags()
}

function openDialog(row) {
  form.value = row ? { ...row } : { id: null, name: '' }
  dialogVisible.value = true
}

async function handleSave() {
  if (!form.value.name.trim()) {
    ElMessage.warning('请输入标签名称')
    return
  }
  if (form.value.id) {
    await adminApi.updateTag(form.value.id, form.value)
  } else {
    await adminApi.createTag(form.value)
  }
  ElMessage.success('保存成功')
  dialogVisible.value = false
  loadData()
}

async function handleDelete(id) {
  await ElMessageBox.confirm('确定删除该标签？', '提示', { type: 'warning' })
  await adminApi.deleteTag(id)
  ElMessage.success('删除成功')
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
</style>
