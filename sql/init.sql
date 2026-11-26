-- 博客系统数据库初始化脚本
-- 请在 SQLyog / Navicat 中执行本脚本（会重建 blog_db 及全部表与数据）
-- 默认管理员：admin / 123456

CREATE DATABASE IF NOT EXISTS blog_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE blog_db;

-- 按依赖顺序删除
DROP TABLE IF EXISTS `comment`;
DROP TABLE IF EXISTS `article_tag`;
DROP TABLE IF EXISTS `article`;
DROP TABLE IF EXISTS `tag`;
DROP TABLE IF EXISTS `category`;
DROP TABLE IF EXISTS `user`;

-- ==================== 用户表 ====================
CREATE TABLE `user` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `username`    VARCHAR(50)  NOT NULL COMMENT '用户名',
    `password`    VARCHAR(100) NOT NULL COMMENT '密码（明文，毕设简化）',
    `nickname`    VARCHAR(50)  DEFAULT NULL COMMENT '昵称',
    `avatar`      VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
    `create_time` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

INSERT INTO `user` (`username`, `password`, `nickname`) VALUES
('admin', '123456', '博主');

-- ==================== 分类表 ====================
CREATE TABLE `category` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `name`        VARCHAR(50)  NOT NULL COMMENT '分类名称',
    `description` VARCHAR(200) DEFAULT NULL COMMENT '描述',
    `create_time` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分类表';

INSERT INTO `category` (`name`, `description`) VALUES
('技术笔记', '编程语言、框架与工程实践'),
('学习心得', '学习路线、方法与复盘总结');

-- ==================== 标签表 ====================
CREATE TABLE `tag` (
    `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `name`        VARCHAR(50) NOT NULL COMMENT '标签名称',
    `create_time` DATETIME    DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='标签表';

INSERT INTO `tag` (`name`) VALUES
('Java'),
('Vue'),
('Spring Boot'),
('MySQL'),
('前端'),
('后端'),
('JWT'),
('Markdown'),
('毕设');

-- ==================== 文章表 ====================
CREATE TABLE `article` (
    `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `title`        VARCHAR(200) NOT NULL COMMENT '标题',
    `summary`      VARCHAR(500) DEFAULT NULL COMMENT '摘要',
    `content`      LONGTEXT     NOT NULL COMMENT 'Markdown正文',
    `cover_image`  VARCHAR(255) DEFAULT NULL COMMENT '封面图URL',
    `category_id`  BIGINT       DEFAULT NULL COMMENT '分类ID',
    `author_id`    BIGINT       NOT NULL COMMENT '作者ID',
    `status`       TINYINT      NOT NULL DEFAULT 0 COMMENT '状态：0草稿 1已发布',
    `view_count`   INT          NOT NULL DEFAULT 0 COMMENT '阅读量',
    `deleted`      TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0未删除 1已删除',
    `create_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_status_deleted` (`status`, `deleted`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文章表';

INSERT INTO `article` (`title`, `summary`, `content`, `category_id`, `author_id`, `status`, `view_count`, `deleted`, `create_time`) VALUES

('欢迎使用博客系统', '基于 Spring Boot 3 与 Vue 3 的毕设博客，支持文章、分类、标签、评论与回收站。', '# 欢迎使用博客系统\n\n这是一个基于 **Spring Boot 3** + **Vue 3** 构建的前后端分离博客系统，界面简洁，适合作为计算机相关专业毕业设计。\n\n## 功能特性\n\n- 前台：文章列表与详情、分类/标签筛选、关键词搜索、评论\n- 后台：登录鉴权、仪表盘统计、文章 CRUD、草稿发布、回收站\n- 编辑器：Markdown 写作与本地上传图片\n\n## 技术栈一览\n\n| 端 | 技术 |\n|----|------|\n| 后端 | Java 17、Spring Boot 3、MyBatis-Plus、MySQL、JWT |\n| 前端 | Vue 3、Vite、Element Plus、Pinia、md-editor-v3 |\n\n## 快速体验\n\n1. 执行本 SQL 初始化数据库\n2. 启动 `blog-backend`（端口 8081）\n3. 启动 `blog-frontend`（端口 5173）\n4. 后台地址：`/admin/login`，账号 `admin` / `123456`\n\n祝你使用愉快，答辩顺利！', 1, 1, 1, 328, 0, '2025-08-15 09:30:00'),

('Vue 3 组合式 API 实战笔记', '从 ref、computed 到 Pinia 状态管理，梳理 Vue 3 日常开发中最常用的写法。', '# Vue 3 组合式 API 实战\n\nVue 3 推荐使用 **Composition API** 组织组件逻辑，相比 Options API 更利于逻辑复用与 TypeScript 配合。\n\n## 响应式基础\n\n```javascript\nimport { ref, computed } from ''vue''\n\nconst count = ref(0)\nconst double = computed(() => count.value * 2)\n\nfunction increment() {\n  count.value++\n}\n```\n\n## 生命周期\n\n常用 `onMounted` 拉取列表数据，`onUnmounted` 清理定时器。\n\n## Pinia 状态管理\n\n```javascript\nimport { defineStore } from ''pinia''\n\nexport const useUserStore = defineStore(''user'', () => {\n  const token = ref('''')\n  return { token }\n})\n```\n\n## 与本项目的结合\n\n前台文章列表、后台登录态都通过 Pinia + Axios 拦截器统一管理 Token。\n\n> 建议：小组件用组合式 API，复杂页面可拆成 composables 文件。', 1, 1, 1, 215, 0, '2025-08-22 14:20:00'),

('Spring Boot 3 项目分层与职责', 'Controller、Service、Mapper 各层做什么，毕设后端如何保持结构清晰。', '# Spring Boot 3 项目分层\n\n毕设博客后端采用经典三层架构，职责边界清晰，便于答辩时讲解。\n\n## 各层职责\n\n| 层级 | 包路径示例 | 职责 |\n|------|------------|------|\n| Controller | `com.blog.controller` | 接收 HTTP 请求、参数校验、返回 `Result` |\n| Service | `com.blog.service` | 业务逻辑、事务、组装 VO |\n| Mapper | `com.blog.mapper` | 数据库访问，继承 `BaseMapper` |\n\n## 统一响应\n\n```java\npublic class Result<T> {\n    private int code;\n    private String message;\n    private T data;\n}\n```\n\n前后端约定 `code === 200` 为成功，异常由 `GlobalExceptionHandler` 统一处理。\n\n## 配置类\n\n- `WebConfig`：跨域、注册 JWT 拦截器\n- `MybatisPlusConfig`：分页插件\n- `application.yml`：数据源与 JWT 密钥\n\n分层清楚后，新增「标签管理」等功能只需按层扩展，不会写成「Controller 里写 SQL」。', 1, 1, 1, 186, 0, '2025-09-03 10:15:00'),

('MyBatis-Plus 在本项目中的用法', 'CRUD、分页查询、逻辑删除与 Lambda 条件构造器的实战总结。', '# MyBatis-Plus 用法总结\n\nMyBatis-Plus 在保留 MyBatis 灵活性的同时，大幅简化单表操作。\n\n## 1. 基础 CRUD\n\nMapper 继承 `BaseMapper<Article>` 即可使用 `insert`、`selectById`、`updateById` 等方法。\n\n## 2. 分页\n\n```java\nPage<Article> page = new Page<>(pageNum, pageSize);\nLambdaQueryWrapper<Article> wrapper = new LambdaQueryWrapper<>();\nwrapper.eq(Article::getStatus, 1)\n       .orderByDesc(Article::getCreateTime);\narticleMapper.selectPage(page, wrapper);\n```\n\n## 3. 逻辑删除\n\n实体 `deleted` 字段标注 `@TableLogic`：\n\n- 调用 `deleteById` 时自动置 `deleted = 1`\n- 普通查询自动带上 `deleted = 0` 条件\n- 回收站需自定义查询已删除记录\n\n## 4. 自动填充\n\n`createTime`、`updateTime` 通过 MetaObjectHandler 或字段注解自动维护。\n\n## 实践建议\n\n简单单表用 Wrapper；多表关联、复杂统计可写 XML 或 `@Select`。\n\n本博客的文章列表、评论管理都大量依赖分页 + 条件构造器。', 1, 1, 1, 142, 0, '2025-09-10 16:40:00'),

('JWT 身份认证完整流程', '从登录接口到拦截器校验，说明本系统 Token 的生成、传递与过期处理。', '# JWT 身份认证流程\n\n前后端分离项目通常用 JWT 代替 Session，本系统后台接口均依赖 Token 鉴权。\n\n## 流程图（文字版）\n\n1. 用户 POST `/api/auth/login` 提交用户名密码\n2. `AuthService` 校验通过后，`JwtUtil` 生成 Token（载荷含 `userId`）\n3. 前端将 Token 存入 `localStorage`，Axios 请求头携带：`Authorization: Bearer <token>`\n4. 访问 `/api/admin/**` 时，`JwtInterceptor` 解析并校验 Token\n5. 校验通过后将 `userId` 写入 `request` 属性，供 Controller 使用\n\n## 关键配置\n\n```yaml\nblog:\n  jwt:\n    secret: ${JWT_SECRET}   # 从 blog-backend/.env 注入，禁止硬编码\n    expiration: 86400000\n```\n\n## 安全注意\n\n- 生产环境必须更换 `secret`，且不要提交到公开仓库\n- Token 过期应引导用户重新登录\n- 前台 `/api/articles` 等接口无需 Token，注意路径放行规则\n\n答辩时可画一张「登录 → 存 Token → 带 Header 请求」的流程图，很加分。', 1, 1, 1, 267, 0, '2025-09-18 11:00:00'),

('前后端分离架构设计思路', '接口划分、模块边界、部署方式，梳理本毕设的整体架构。', '# 前后端分离架构设计\n\n## 为什么前后端分离\n\n- 前后端可并行开发、独立部署\n- 一套 API 可服务 Web、移动端\n- 职责清晰：后端专注数据与业务，前端专注交互与展示\n\n## 本系统模块划分\n\n### 前台（访客）\n\n- 文章列表 / 详情 / 搜索\n- 分类、标签筛选\n- 发表评论\n\n### 后台（管理员）\n\n- 仪表盘统计\n- 文章管理（发布、草稿、回收站）\n- 分类、标签、评论管理\n\n## 接口风格\n\nRESTful 风格路径，如：\n\n- `GET /api/articles` — 前台文章列表\n- `GET /api/admin/articles` — 后台文章列表（含草稿）\n- `PUT /api/admin/articles/{id}/restore` — 从回收站恢复\n\n## 部署建议\n\n开发环境：Vite 代理到 `localhost:8081`。\n\n生产环境：Nginx 托管前端静态资源，反向代理 `/api` 到 Spring Boot。\n\n架构图画清楚「浏览器 → Nginx → 前端/后端 → MySQL」，答辩时一目了然。', 1, 1, 1, 198, 0, '2025-09-25 09:45:00'),

('Element Plus 后台页面搭建要点', '管理后台中表格、分页、表单校验与消息提示的典型写法。', '# Element Plus 后台搭建\n\n本博客后台使用 Element Plus 快速搭建管理界面。\n\n## 布局结构\n\n```html\n<el-container>\n  <el-aside width="200px">侧边菜单</el-aside>\n  <el-container>\n    <el-header>顶栏</el-header>\n    <el-main>内容区</el-main>\n  </el-container>\n</el-container>\n```\n\n## 表格 + 分页\n\n列表页通常：\n\n1. `onMounted` 请求 `GET /api/admin/articles?page=1&size=10`\n2. 绑定 `el-table` 的 `:data`\n3. `el-pagination` 的 `@current-change` 重新拉取数据\n\n## 表单校验\n\n```javascript\nconst rules = {\n  title: [{ required: true, message: ''请输入标题'', trigger: ''blur'' }]\n}\nawait formRef.value.validate()\n```\n\n## 交互细节\n\n- 删除前 `ElMessageBox.confirm` 二次确认\n- 操作成功 `ElMessage.success(''保存成功'')`\n- 加载中 `v-loading` 防止重复提交\n\n后台 UI 不必花哨，**一致、清晰、反馈及时** 就是最好的体验。', 1, 1, 1, 113, 0, '2025-10-05 15:30:00'),

('MySQL 索引与慢查询优化入门', '结合博客场景讲解索引类型、最左前缀与 EXPLAIN 的基本用法。', '# MySQL 索引入门\n\n博客系统文章表、评论表在数据量增大后，查询性能依赖合理索引。\n\n## 本项目的索引设计\n\n`article` 表已建立：\n\n- `idx_category_id` — 按分类筛选\n- `idx_status_deleted` — 已发布且未删除列表\n- `idx_create_time` — 按时间排序\n\n## 最左前缀原则\n\n联合索引 `(status, deleted)` 可支持：\n\n- 只查 `status`\n- 同时查 `status + deleted`\n\n但单独查 `deleted` 往往用不上该索引。\n\n## EXPLAIN 示例\n\n```sql\nEXPLAIN SELECT * FROM article\nWHERE status = 1 AND deleted = 0\nORDER BY create_time DESC\nLIMIT 10;\n```\n\n关注 `type`（最好 `ref` 或 `range`）、`key`（是否走索引）、`rows`（扫描行数）。\n\n## 实践建议\n\n- 不要给每个字段都加索引，写入会变慢\n- 列表查询字段与 WHERE / ORDER BY 对齐设计索引\n- 分页深页可用「上次最大 id」替代 `OFFSET` 过大\n\n毕设数据量小可能感受不到差异，但答辩提到索引设计会显得有工程意识。', 1, 1, 1, 89, 0, '2025-10-12 10:20:00'),

('Markdown 写作与排版规范', '写技术博客时标题层级、代码块、列表与摘要字段的实用建议。', '# Markdown 写作规范\n\n本系统正文与摘要分离：**列表页展示 summary，详情页渲染 Markdown content**。\n\n## 标题层级\n\n一篇文章建议只有一个 `#` 一级标题（通常与文章 title 一致或作为开篇）。\n\n正文从 `##` 开始，避免跳级。\n\n## 代码块\n\n标明语言以启用高亮：\n\n```java\n@RestController\n@RequestMapping("/api")\npublic class FrontController { }\n```\n\n## 列表与表格\n\n- 无序列表适合罗列特性\n- 表格适合对比技术栈、字段说明\n\n## 图片\n\n上传后插入路径，如 `/uploads/2025/photo.png`，前台 markdown-it 会正确渲染。\n\n## 摘要怎么写\n\n`summary` 建议 50～150 字：\n\n- 说明文章解决什么问题\n- 不要复制正文第一段\n- 不要堆砌关键词\n\n好的 Markdown 让前台阅读体验接近专业技术博客。', 2, 1, 1, 76, 0, '2025-10-20 13:10:00'),

('从 Java 基础到 Spring Boot：我的学习路线', '记录大二到大三如何循序渐进学后端，以及踩过的坑。', '# 我的 Java 学习路线\n\n## 阶段一：语言基础（约 2 个月）\n\n- 语法、集合、IO、多线程基础\n- 小练习：学生管理系统（控制台版）\n\n## 阶段二：数据库与 Web 入门（约 2 个月）\n\n- MySQL 增删改查、联表、索引概念\n- Servlet / JDBC 理解 HTTP 与数据库交互\n\n## 阶段三：框架实战（约 3 个月）\n\n- Spring Boot 快速搭建 REST API\n- MyBatis-Plus 简化持久层\n- 做一个完整 CRUD 小项目\n\n## 阶段四：前后端协作\n\n- 学 Vue 3 基础，能调自己的接口\n- 理解 JWT、跨域、统一返回格式\n\n## 踩坑记录\n\n1. **只看不写** — 看视频不写代码，一周就忘\n2. **项目过大** — 一开始就想做商城，迟迟无法完工\n3. **忽视 Git** — 改崩了无法回退\n\n## 给学弟学妹的话\n\n毕设博客规模适中，能覆盖分层、鉴权、CRUD、前端展示，性价比很高。\n\n每天 1～2 小时坚持比周末突击 10 小时更有效。', 2, 1, 1, 134, 0, '2025-11-02 08:50:00'),

('【草稿】Spring Boot 集成 Redis 缓存（未完成）', '草稿示例：介绍文章列表缓存思路，前台不会展示，可在后台继续编辑后发布。', '# Spring Boot 集成 Redis 缓存（草稿）\n\n> 本文尚未发布，用于演示草稿功能。\n\n## 目标\n\n- 缓存热门文章列表，降低数据库压力\n- 设置合理过期时间，避免脏读\n\n## 待实现步骤\n\n- [ ] 引入 `spring-boot-starter-data-redis`\n- [ ] 配置 `application.yml` 连接信息\n- [ ] `ArticleService.listPublic` 增加 `@Cacheable`\n- [ ] 文章更新/删除时 `@CacheEvict` 清理缓存\n\n## 注意点\n\n- Key 设计要包含分页与筛选参数\n- 开发环境可先不启用，用条件配置开关', 1, 1, 0, 0, 0, '2025-12-01 20:00:00'),

('旧版单体部署笔记（已归档）', '早期尝试 JSP 单体部署的记录，已移入回收站作逻辑删除演示。', '# 旧版单体部署笔记\n\n> 此文已逻辑删除，仅在后台「回收站」中可见，用于演示恢复与永久删除。\n\n早期曾尝试用 JSP + Tomcat 单体部署博客，后来改为前后端分离。\n\n## 曾经的做法\n\n- 页面与接口在同一个 WAR 包\n- 静态资源放在 `webapp` 目录\n\n## 为何放弃\n\n- 前后端耦合，改样式容易影响接口\n- 不利于移动端扩展\n- 不符合毕设「现代 Web 架构」的展示需求\n\n## 现状\n\n已全面迁移到 Spring Boot + Vue 3。\n\n此文保留在回收站，需要时可恢复或永久删除。', 1, 1, 1, 23, 1, '2025-07-10 09:00:00');

-- ==================== 文章-标签关联 ====================
CREATE TABLE `article_tag` (
    `id`         BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    `article_id` BIGINT NOT NULL COMMENT '文章ID',
    `tag_id`     BIGINT NOT NULL COMMENT '标签ID',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_article_tag` (`article_id`, `tag_id`),
    KEY `idx_tag_id` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文章标签关联表';

INSERT INTO `article_tag` (`article_id`, `tag_id`) VALUES
(1, 3), (1, 4), (1, 9),
(2, 2), (2, 5),
(3, 1), (3, 3), (3, 6),
(4, 1), (4, 4), (4, 6),
(5, 3), (5, 6), (5, 7),
(6, 3), (6, 5), (6, 6), (6, 9),
(7, 2), (7, 5),
(8, 4), (8, 6),
(9, 8), (9, 9),
(10, 1), (10, 2), (10, 9),
(11, 3), (11, 6),
(12, 3), (12, 6);

-- ==================== 评论表 ====================
CREATE TABLE `comment` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `article_id`  BIGINT       NOT NULL COMMENT '文章ID',
    `nickname`    VARCHAR(50)  NOT NULL COMMENT '评论者昵称',
    `email`       VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    `content`     VARCHAR(500) NOT NULL COMMENT '评论内容',
    `deleted`     TINYINT      NOT NULL DEFAULT 0 COMMENT '逻辑删除：0未删除 1已删除',
    `create_time` DATETIME     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_article_id` (`article_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论表';

INSERT INTO `comment` (`article_id`, `nickname`, `email`, `content`, `create_time`) VALUES
(1, '访客小明', NULL, '博客界面很简洁，喜欢这种风格！', '2025-08-16 10:12:00'),
(1, '技术爱好者', 'fan@example.com', '毕设项目做得很完整，加油！', '2025-08-17 15:30:00'),
(1, '路过的学长', NULL, '答辩演示记得准备一份测试数据。', '2025-09-01 09:00:00'),
(2, '前端同学', 'vue@example.com', '组合式 API 的示例很实用，已收藏。', '2025-08-23 11:20:00'),
(2, 'Vue新手', NULL, 'Pinia 和 Vuex 有什么区别？', '2025-08-24 20:45:00'),
(3, 'Java学习者', NULL, '三层架构讲得很清楚，答辩可以用这张表。', '2025-09-04 14:00:00'),
(4, '数据库爱好者', NULL, '逻辑删除配合回收站的设计很贴近真实业务。', '2025-09-11 16:30:00'),
(5, '答辩选手', 'defense@example.com', 'JWT 流程我准备画成图放在 PPT 里。', '2025-09-19 08:55:00'),
(5, '安全小白', NULL, 'Token 过期时间一天够用了吗？', '2025-09-20 13:10:00'),
(6, '架构观察员', NULL, '模块划分写得很规范，前后台接口分得清楚。', '2025-09-26 10:40:00'),
(7, 'UI设计师', NULL, '后台表格分页和接口参数对上了，体验顺畅。', '2025-10-06 19:00:00'),
(8, 'MySQL入门', NULL, 'EXPLAIN 那段对我很有帮助。', '2025-10-13 12:15:00'),
(9, '写作萌新', NULL, '摘要怎么写终于搞明白了，以前总复制正文。', '2025-10-21 09:30:00'),
(10, '学弟学妹', NULL, '学习路线很真实，不是那种吓人的速成表。', '2025-11-03 21:00:00');
