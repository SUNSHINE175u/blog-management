<template>
  <div class="category-page">
    <h2>分类：{{ categoryName }}</h2>
    <div class="article-list">
      <article v-for="item in articles" :key="item.id" class="article-item">
        <h3>
          <router-link :to="`/article/${item.id}`">{{ item.title }}</router-link>
        </h3>
        <p class="summary">{{ item.summary || '暂无摘要' }}</p>
        <div class="meta">
          <span>{{ formatDate(item.createTime) }}</span>
          <span> · 阅读 {{ item.viewCount }}</span>
        </div>
      </article>
      <el-empty v-if="!loading && articles.length === 0" description="该分类下暂无文章" />
    </div>
    <div class="pagination" v-if="total > 0">
      <el-pagination
        background
        layout="prev, pager, next"
        :total="total"
        :page-size="pageSize"
        v-model:current-page="page"
        @current-change="loadArticles"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { frontApi } from '../../api'
import { formatDate } from '../../utils/markdown'

const route = useRoute()
const articles = ref([])
const categoryName = ref('')
const page = ref(1)
const pageSize = 10
const total = ref(0)
const loading = ref(false)

async function loadArticles() {
  loading.value = true
  try {
    const categoryId = route.params.id
    const cats = await frontApi.categories()
    const cat = cats.find(c => c.id == categoryId)
    categoryName.value = cat ? cat.name : '未知分类'
    const data = await frontApi.articles({
      page: page.value,
      size: pageSize,
      categoryId
    })
    articles.value = data.records
    total.value = data.total
  } finally {
    loading.value = false
  }
}

onMounted(loadArticles)
</script>

<style scoped>
h2 {
  margin-bottom: 24px;
  font-size: 22px;
}

.article-item {
  background: #fff;
  padding: 20px;
  margin-bottom: 12px;
  border-radius: 4px;
  border: 1px solid #eee;
}

.article-item h3 a {
  color: #333;
  text-decoration: none;
}

.article-item h3 a:hover {
  color: #409eff;
}

.summary {
  color: #666;
  font-size: 14px;
  margin: 8px 0;
}

.meta {
  color: #999;
  font-size: 13px;
}

.pagination {
  margin-top: 24px;
  display: flex;
  justify-content: center;
}
</style>
