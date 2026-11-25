<template>
  <div class="front-layout">
    <header class="site-header">
      <div class="container header-inner">
        <router-link to="/" class="site-title">我的博客</router-link>
        <nav class="site-nav">
          <router-link to="/">首页</router-link>
          <router-link to="/about">关于</router-link>
          <router-link to="/admin/login" class="admin-link">管理</router-link>
        </nav>
      </div>
    </header>
    <main class="site-main container">
      <router-view />
    </main>
    <footer class="site-footer">
      <div class="container">
        <p>© 2026 我的博客 · 毕设项目</p>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.front-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.site-header {
  background: #fff;
  border-bottom: 1px solid #eee;
  padding: 20px 0;
}

.header-inner {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.site-title {
  font-size: 22px;
  font-weight: 600;
  color: #333;
  text-decoration: none;
}

.site-title:hover {
  text-decoration: none;
  color: #409eff;
}

.site-nav a {
  margin-left: 24px;
  color: #666;
  text-decoration: none;
  font-size: 15px;
}

.site-nav a:hover,
.site-nav a.router-link-active {
  color: #409eff;
}

.admin-link {
  color: #999 !important;
  font-size: 13px !important;
}

.site-main {
  flex: 1;
  padding: 32px 20px;
}

.site-footer {
  background: #fff;
  border-top: 1px solid #eee;
  padding: 24px 0;
  text-align: center;
  color: #999;
  font-size: 14px;
}
</style>
