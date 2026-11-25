import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    component: () => import('../views/front/FrontLayout.vue'),
    children: [
      { path: '', name: 'Home', component: () => import('../views/front/Home.vue') },
      { path: 'article/:id', name: 'ArticleDetail', component: () => import('../views/front/ArticleDetail.vue') },
      { path: 'category/:id', name: 'Category', component: () => import('../views/front/Category.vue') },
      { path: 'tag/:id', name: 'Tag', component: () => import('../views/front/Tag.vue') },
      { path: 'about', name: 'About', component: () => import('../views/front/About.vue') }
    ]
  },
  { path: '/admin/login', name: 'AdminLogin', component: () => import('../views/admin/Login.vue') },
  {
    path: '/admin',
    component: () => import('../views/admin/AdminLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      { path: '', redirect: '/admin/dashboard' },
      { path: 'dashboard', name: 'Dashboard', component: () => import('../views/admin/Dashboard.vue') },
      { path: 'articles', name: 'ArticleList', component: () => import('../views/admin/ArticleList.vue') },
      { path: 'article/edit/:id?', name: 'ArticleEdit', component: () => import('../views/admin/ArticleEdit.vue') },
      { path: 'categories', name: 'CategoryManage', component: () => import('../views/admin/CategoryManage.vue') },
      { path: 'tags', name: 'TagManage', component: () => import('../views/admin/TagManage.vue') },
      { path: 'comments', name: 'CommentManage', component: () => import('../views/admin/CommentManage.vue') },
      { path: 'recycle', name: 'RecycleBin', component: () => import('../views/admin/RecycleBin.vue') }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  if (to.meta.requiresAuth) {
    const token = localStorage.getItem('token')
    if (!token) {
      next('/admin/login')
      return
    }
  }
  next()
})

export default router
