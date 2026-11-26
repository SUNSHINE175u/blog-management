/**
 * Cloudflare Pages Function：把 /api/* 反向代理到自托管的 Spring Boot 后端。
 *
 * 为什么需要它：
 *   Cloudflare Workers 没有 JVM，Spring Boot 跑不上去，后端只能放在别处。
 *   有了这层代理，浏览器看到的始终是同源请求，于是：
 *     - src/api/request.js 里的 baseURL: '/api' 不用改
 *     - WebConfig 里的 CORS 配置也不再是必需（同源不触发跨域检查）
 *
 * 后端地址通过环境变量 BACKEND_ORIGIN 提供，在 Pages 控制台
 * Settings -> Environment variables 里配置，例如 https://api.example.com
 * （不要带结尾斜杠，也不要带 /api，下面的拼接会保留原始 pathname）
 */
export async function onRequest(context) {
  const { request, env } = context

  const backend = env.BACKEND_ORIGIN
  if (!backend) {
    // 明确报出来，否则只会看到一个难以排查的 502/404
    return new Response('BACKEND_ORIGIN 未配置', { status: 500 })
  }

  const incoming = new URL(request.url)
  // /api/articles?page=1  ->  https://api.example.com/api/articles?page=1
  const target = backend.replace(/\/+$/, '') + incoming.pathname + incoming.search

  const headers = new Headers(request.headers)
  // Host 必须指向真实后端，否则 Nginx 之类的虚拟主机会路由到错误的站点
  headers.set('Host', new URL(target).host)
  // 逐跳头（hop-by-hop）不应该被转发
  headers.delete('connection')
  headers.delete('keep-alive')

  const upstream = await fetch(target, {
    method: request.method,
    headers,
    // GET / HEAD 不能带 body，否则 fetch 会直接抛错
    body: request.method === 'GET' || request.method === 'HEAD' ? undefined : request.body,
    // 不让 Workers 自动跟随重定向，把 3xx 原样交回浏览器
    redirect: 'manual'
  })

  const responseHeaders = new Headers(upstream.headers)
  // Workers 已经自动解压了响应体，但上游的这两个头还停留在压缩前的值。
  // 不删掉的话浏览器会拿到「声称是 gzip 实则是明文」的响应而解析失败。
  responseHeaders.delete('content-encoding')
  responseHeaders.delete('content-length')

  return new Response(upstream.body, {
    status: upstream.status,
    statusText: upstream.statusText,
    headers: responseHeaders
  })
}
