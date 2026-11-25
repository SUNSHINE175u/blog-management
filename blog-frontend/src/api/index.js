import request from './request'

export const authApi = {
  login: data => request.post('/auth/login', data),
  info: () => request.get('/auth/info')
}

export const frontApi = {
  articles: params => request.get('/articles', { params }),
  latest: limit => request.get('/articles/latest', { params: { limit } }),
  articleDetail: id => request.get(`/articles/${id}`),
  categories: () => request.get('/categories'),
  tags: () => request.get('/tags'),
  comments: id => request.get(`/articles/${id}/comments`),
  addComment: (id, data) => request.post(`/articles/${id}/comments`, data)
}

export const adminApi = {
  stats: () => request.get('/admin/stats'),
  articles: params => request.get('/admin/articles', { params }),
  articleDetail: id => request.get(`/admin/articles/${id}`),
  createArticle: data => request.post('/admin/articles', data),
  updateArticle: (id, data) => request.put(`/admin/articles/${id}`, data),
  deleteArticle: id => request.delete(`/admin/articles/${id}`),
  recycleArticles: params => request.get('/admin/recycle/articles', { params }),
  restoreArticle: id => request.put(`/admin/articles/${id}/restore`),
  permanentDelete: id => request.delete(`/admin/articles/${id}/permanent`),
  categories: () => request.get('/admin/categories'),
  createCategory: data => request.post('/admin/categories', data),
  updateCategory: (id, data) => request.put(`/admin/categories/${id}`, data),
  deleteCategory: id => request.delete(`/admin/categories/${id}`),
  tags: () => request.get('/admin/tags'),
  createTag: data => request.post('/admin/tags', data),
  updateTag: (id, data) => request.put(`/admin/tags/${id}`, data),
  deleteTag: id => request.delete(`/admin/tags/${id}`),
  comments: () => request.get('/admin/comments'),
  deleteComment: id => request.delete(`/admin/comments/${id}`)
}
