<template>
  <div class="article-detail" v-loading="loading">
    <article v-if="article">
      <h1>{{ article.title }}</h1>
      <div class="meta">
        <span>{{ formatDate(article.createTime) }}</span>
        <span v-if="article.categoryName"> · {{ article.categoryName }}</span>
        <span> · 阅读 {{ article.viewCount }}</span>
      </div>
      <div class="tags" v-if="article.tags && article.tags.length">
        <router-link
          v-for="tag in article.tags"
          :key="tag.id"
          :to="`/tag/${tag.id}`"
          class="tag"
        >{{ tag.name }}</router-link>
      </div>
      <div class="markdown-body" v-html="htmlContent"></div>
    </article>

    <section class="comments" v-if="article">
      <h3>评论 ({{ comments.length }})</h3>
      <div class="comment-form">
        <el-input v-model="form.nickname" placeholder="昵称" style="margin-bottom: 8px" />
        <el-input v-model="form.content" type="textarea" :rows="3" placeholder="写下你的评论..." />
        <el-button type="primary" style="margin-top: 8px" @click="submitComment" :loading="submitting">
          发表评论
        </el-button>
      </div>
      <div class="comment-list">
        <div v-for="c in comments" :key="c.id" class="comment-item">
          <div class="comment-author">{{ c.nickname }}</div>
          <div class="comment-time">{{ formatDate(c.createTime) }}</div>
          <div class="comment-content">{{ c.content }}</div>
        </div>
        <el-empty v-if="comments.length === 0" description="暂无评论，来抢沙发吧" :image-size="60" />
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { frontApi } from '../../api'
import { renderMarkdown, formatDate } from '../../utils/markdown'

const route = useRoute()
const article = ref(null)
const comments = ref([])
const loading = ref(false)
const submitting = ref(false)
const form = ref({ nickname: '', content: '' })

const htmlContent = computed(() => renderMarkdown(article.value?.content))

async function loadData() {
  loading.value = true
  try {
    const id = route.params.id
    article.value = await frontApi.articleDetail(id)
    comments.value = await frontApi.comments(id)
  } finally {
    loading.value = false
  }
}

async function submitComment() {
  if (!form.value.nickname.trim() || !form.value.content.trim()) {
    ElMessage.warning('请填写昵称和评论内容')
    return
  }
  submitting.value = true
  try {
    await frontApi.addComment(route.params.id, form.value)
    ElMessage.success('评论成功')
    form.value.content = ''
    comments.value = await frontApi.comments(route.params.id)
  } finally {
    submitting.value = false
  }
}

onMounted(loadData)
</script>

<style scoped>
.article-detail {
  max-width: 720px;
}

article {
  background: #fff;
  padding: 32px;
  border-radius: 4px;
  border: 1px solid #eee;
  margin-bottom: 24px;
}

h1 {
  font-size: 28px;
  margin-bottom: 12px;
  line-height: 1.4;
}

.meta {
  color: #999;
  font-size: 14px;
  margin-bottom: 12px;
}

.tags {
  margin-bottom: 24px;
}

.tag {
  display: inline-block;
  background: #f0f0f0;
  color: #666;
  padding: 2px 10px;
  border-radius: 3px;
  font-size: 12px;
  margin-right: 8px;
  text-decoration: none;
}

.tag:hover {
  background: #409eff;
  color: #fff;
}

.comments {
  background: #fff;
  padding: 24px;
  border-radius: 4px;
  border: 1px solid #eee;
}

.comments h3 {
  margin-bottom: 16px;
  font-size: 18px;
}

.comment-form {
  margin-bottom: 24px;
  padding-bottom: 24px;
  border-bottom: 1px solid #eee;
}

.comment-item {
  padding: 12px 0;
  border-bottom: 1px solid #f5f5f5;
}

.comment-author {
  font-weight: 600;
  font-size: 14px;
}

.comment-time {
  color: #999;
  font-size: 12px;
  margin-bottom: 4px;
}

.comment-content {
  color: #555;
  font-size: 14px;
}
</style>
