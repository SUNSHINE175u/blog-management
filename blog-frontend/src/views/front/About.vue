<template>
  <div class="about-page">
    <article class="about-card">
      <h1>关于我</h1>
      <p>你好，欢迎来到我的博客！</p>
      <p>这是一个基于 Spring Boot 3 + Vue 3 构建的简洁博客系统，作为毕业设计项目。</p>
      <h2>技术栈</h2>
      <ul>
        <li>后端：Java 17、Spring Boot 3、MyBatis-Plus、MySQL</li>
        <li>前端：Vue 3、Vite、Element Plus、Markdown</li>
      </ul>
      <h2>功能</h2>
      <ul>
        <li>文章发布与管理（支持 Markdown）</li>
        <li>分类与标签</li>
        <li>评论功能</li>
        <li>草稿与回收站（逻辑删除）</li>
      </ul>
    </article>
  </div>
</template>

<style scoped>
.about-card {
  background: #fff;
  padding: 32px;
  border-radius: 4px;
  border: 1px solid #eee;
  max-width: 720px;
}

h1 {
  font-size: 28px;
  margin-bottom: 16px;
}

h2 {
  font-size: 18px;
  margin: 24px 0 12px;
}

p {
  color: #555;
  margin-bottom: 12px;
}

ul {
  padding-left: 24px;
  color: #555;
}

li {
  margin-bottom: 6px;
}
</style>
