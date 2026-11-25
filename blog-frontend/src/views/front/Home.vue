<template>
  <div class="home">
    <div class="search-bar">
      <el-input
        v-model="keyword"
        placeholder="搜索文章..."
        clearable
        @keyup.enter="search"
        @clear="search"
      >
        <template #append>
          <el-button @click="search">搜索</el-button>
        </template>
      </el-input>
    </div>

    <div class="content-wrap">
      <div class="article-list">
        <article v-for="item in articles" :key="item.id" class="article-item">
          <h2>
            <router-link :to="`/article/${item.id}`">{{ item.title }}</router-link>
          </h2>
          <p class="summary">{{ item.summary || '暂无摘要' }}</p>
          <div class="meta">
            <span>{{ formatDate(item.createTime) }}</span>
            <span v-if="item.categoryName"> · {{ item.categoryName }}</span>
            <span> · 阅读 {{ item.viewCount }}</span>
          </div>
          <div class="tags" v-if="item.tags && item.tags.length">
            <router-link
              v-for="tag in item.tags"
              :key="tag.id"
              :to="`/tag/${tag.id}`"
              class="tag"
            >{{ tag.name }}</router-link>
          </div>
        </article>
        <el-empty v-if="!loading && articles.length === 0" description="暂无文章" />
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

      <aside class="sidebar">
        <div class="sidebar-block">
          <h3>分类</h3>
          <ul>
            <li v-for="cat in categories" :key="cat.id">
              <router-link :to="`/category/${cat.id}`">{{ cat.name }}</router-link>
            </li>
          </ul>
        </div>
        <div class="sidebar-block">
          <h3>标签</h3>
          <div class="tag-cloud">
            <router-link
              v-for="tag in tags"
              :key="tag.id"
              :to="`/tag/${tag.id}`"
              class="tag"
            >{{ tag.name }}</router-link>
          </div>
        </div>
        <div class="sidebar-block">
          <h3>最新文章</h3>
          <ul>
            <li v-for="item in latest" :key="item.id">
              <router-link :to="`/article/${item.id}`">{{ item.title }}</router-link>
            </li>
          </ul>
        </div>
      </aside>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { frontApi } from '../../api'
import { formatDate } from '../../utils/markdown'

const articles = ref([])
const categories = ref([])
const tags = ref([])
const latest = ref([])
const keyword = ref('')
const page = ref(1)
const pageSize = 8
const total = ref(0)
const loading = ref(false)

async function loadArticles() {
  loading.value = true
  try {
    const data = await frontApi.articles({
      page: page.value,
      size: pageSize,
      keyword: keyword.value || undefined
    })
    articles.value = data.records
    total.value = data.total
  } finally {
    loading.value = false
  }
}

function search() {
  page.value = 1
  loadArticles()
}

onMounted(async () => {
  loadArticles()
  categories.value = await frontApi.categories()
  tags.value = await frontApi.tags()
  latest.value = await frontApi.latest(5)
})
</script>

<style scoped>
.search-bar {
  margin-bottom: 24px;
}

.content-wrap {
  display: flex;
  gap: 32px;
}

.article-list {
  flex: 1;
  min-width: 0;
}

.article-item {
  background: #fff;
  padding: 24px;
  margin-bottom: 16px;
  border-radius: 4px;
  border: 1px solid #eee;
}

.article-item h2 {
  font-size: 20px;
  margin-bottom: 8px;
}

.article-item h2 a {
  color: #333;
  text-decoration: none;
}

.article-item h2 a:hover {
  color: #409eff;
}

.summary {
  color: #666;
  font-size: 14px;
  margin-bottom: 12px;
}

.meta {
  color: #999;
  font-size: 13px;
  margin-bottom: 8px;
}

.tags .tag,
.tag-cloud .tag {
  display: inline-block;
  background: #f0f0f0;
  color: #666;
  padding: 2px 10px;
  border-radius: 3px;
  font-size: 12px;
  margin-right: 8px;
  margin-bottom: 4px;
  text-decoration: none;
}

.tags .tag:hover,
.tag-cloud .tag:hover {
  background: #409eff;
  color: #fff;
  text-decoration: none;
}

.pagination {
  margin-top: 24px;
  display: flex;
  justify-content: center;
}

.sidebar {
  width: 240px;
  flex-shrink: 0;
}

.sidebar-block {
  background: #fff;
  padding: 16px;
  margin-bottom: 16px;
  border-radius: 4px;
  border: 1px solid #eee;
}

.sidebar-block h3 {
  font-size: 15px;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #eee;
}

.sidebar-block ul {
  list-style: none;
}

.sidebar-block li {
  margin-bottom: 8px;
}

.sidebar-block a {
  color: #666;
  font-size: 14px;
  text-decoration: none;
}

.sidebar-block a:hover {
  color: #409eff;
}

.tag-cloud {
  display: flex;
  flex-wrap: wrap;
}

@media (max-width: 768px) {
  .content-wrap {
    flex-direction: column;
  }
  .sidebar {
    width: 100%;
  }
}
</style>
