<template>
  <el-card>
    <template #header>{{ isEdit ? '编辑文章' : '写文章' }}</template>

    <el-form :model="form" label-width="80px">
      <el-form-item label="标题">
        <el-input v-model="form.title" placeholder="文章标题" />
      </el-form-item>
      <el-form-item label="摘要">
        <el-input v-model="form.summary" type="textarea" :rows="2" placeholder="文章摘要" />
      </el-form-item>
      <el-form-item label="分类">
        <el-select v-model="form.categoryId" placeholder="选择分类" clearable style="width: 200px">
          <el-option v-for="c in categories" :key="c.id" :label="c.name" :value="c.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="标签">
        <el-select v-model="form.tagIds" multiple placeholder="选择标签" style="width: 100%">
          <el-option v-for="t in tags" :key="t.id" :label="t.name" :value="t.id" />
        </el-select>
      </el-form-item>
      <el-form-item label="内容">
        <MdEditor v-model="form.content" style="height: 500px" no-upload-img />
      </el-form-item>
      <el-form-item label="状态">
        <el-radio-group v-model="form.status">
          <el-radio :value="0">草稿</el-radio>
          <el-radio :value="1">发布</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleSave" :loading="saving">保存</el-button>
        <el-button @click="$router.back()">返回</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { MdEditor } from 'md-editor-v3'
import 'md-editor-v3/lib/style.css'
import { adminApi } from '../../api'

const route = useRoute()
const router = useRouter()
const isEdit = computed(() => !!route.params.id)

const form = ref({
  title: '',
  summary: '',
  content: '',
  coverImage: '',
  categoryId: null,
  tagIds: [],
  status: 1
})
const categories = ref([])
const tags = ref([])
const saving = ref(false)

async function loadMeta() {
  categories.value = await adminApi.categories()
  tags.value = await adminApi.tags()
}

async function loadArticle() {
  if (!isEdit.value) return
  const data = await adminApi.articleDetail(route.params.id)
  form.value = {
    title: data.title,
    summary: data.summary,
    content: data.content,
    coverImage: data.coverImage,
    categoryId: data.categoryId,
    tagIds: data.tags ? data.tags.map(t => t.id) : [],
    status: data.status
  }
}

async function handleSave() {
  if (!form.value.title.trim() || !form.value.content.trim()) {
    ElMessage.warning('请填写标题和内容')
    return
  }
  saving.value = true
  try {
    if (isEdit.value) {
      await adminApi.updateArticle(route.params.id, form.value)
      ElMessage.success('更新成功')
    } else {
      await adminApi.createArticle(form.value)
      ElMessage.success('创建成功')
    }
    router.push('/admin/articles')
  } finally {
    saving.value = false
  }
}

onMounted(async () => {
  await loadMeta()
  await loadArticle()
})
</script>
