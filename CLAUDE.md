# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a graduation-project blog management system with a Spring Boot 3 backend and Vue 3 frontend, organized as a monorepo:

```
├── blog-backend/    # Spring Boot 3.2.5 REST API (port 8081)
├── blog-frontend/   # Vue 3 + Vite SPA (port 5173)
└── sql/init.sql     # MySQL database initialization script
```

**Default admin credentials:** `admin` / `123456`

## Development Setup

1. **MySQL**: Run `sql/init.sql` to create the `blog_db` database with sample data. The script drops and recreates all tables.
2. **Backend**: Copy `blog-backend/.env.example` to `blog-backend/.env` and set `DB_USERNAME`, `DB_PASSWORD` and `JWT_SECRET` there. `.env` is git-ignored. `application.yml` keeps only the `root / 123456` fallback defaults for the datasource; `JWT_SECRET` has no default, so the backend refuses to start until `.env` supplies it (≥32 characters).
3. **Frontend**: The Vite dev server proxies `/api` requests to `http://localhost:8080` (see `vite.config.js`). If the backend runs on a different port, update the proxy target.

## Build & Run Commands

### Backend (`blog-backend/`)

```bash
# Compile
mvn clean compile

# Run (port 8081, per application.yml)
mvn spring-boot:run

# Build JAR
mvn clean package

# Run packaged JAR
java -jar target/blog-backend-1.0.0.jar
```

**No test suite exists** in the backend — `mvn test` will report zero tests.

### Frontend (`blog-frontend/`)

```bash
# Install dependencies (if needed)
npm install

# Dev server (port 5173)
npm run dev

# Production build
npm run build

# Preview production build
npm run preview
```

## High-Level Architecture

### Backend: Three-Controller Route Split

The backend divides its API surface into three controllers by audience and auth requirements:

| Controller | Base Path | Auth | Purpose |
|---|---|---|---|
| `FrontController` | `/api/**` | None | Public: article list/detail, categories, tags, comments |
| `AuthController` | `/api/auth/**` | None | Login (`POST /api/auth/login`), current user info |
| `AdminController` | `/api/admin/**` | JWT required | CRUD for articles/categories/tags/comments; stats; recycle bin |

The `JwtInterceptor` is registered in `WebConfig` and protects `/api/admin/**`, excluding `/api/auth/**`. On valid token, it extracts `userId` from the JWT payload and sets it as a request attribute (`request.setAttribute("userId", ...)`), which admin controllers read via `HttpServletRequest.getAttribute("userId")`.

**CORS** is configured globally in `WebConfig` with `allowedOriginPatterns("*")` and `allowCredentials(true)` — suitable for local dev but should be tightened for production.

### Backend: MyBatis-Plus Conventions

- **Logical delete** is enabled globally via `application.yml`: field `deleted`, value `1` = deleted, `0` = active. The `ArticleMapper` has custom methods (`selectDeletedPage`, `restoreById`, `physicalDeleteById`) for querying and managing deleted records.
- **Auto-fill timestamps**: `MybatisPlusConfig` implements `MetaObjectHandler` to set `createTime` on insert and `updateTime` on insert/update.
- **Pagination**: `MybatisPlusInterceptor` adds MySQL pagination support. All list endpoints use `Page<>` objects.

### Backend: Uniform API Response

Every endpoint returns `Result<T>`:
- Success: `Result.success(data)` → `{ code: 200, message: "success", data: ... }`
- Error: `Result.error(message)` → `{ code: 500, message: ... }`
- Business validation errors throw `BusinessException` → caught by `GlobalExceptionHandler` → `{ code: 400, message: ... }`
- Auth failure (invalid/missing JWT) → HTTP 401 with `{ code: 401, message: "未登录或登录已过期" }`

### Backend: Article-Tag Many-to-Many

Articles and tags are linked via the `article_tag` junction table (`ArticleTag` entity). `ArticleService` manages these relationships manually: `saveTags()` inserts junction records, and `update()` deletes existing junction records before re-inserting. Both `create()` and `update()` are `@Transactional`.

### Frontend: Router & Layout Structure

The Vue router uses `createWebHistory` with two root-level layouts:

- **`FrontLayout`** (`/`): Public-facing blog — home, article detail, category/tag filters, about
- **`AdminLayout`** (`/admin`): Protected management dashboard with sidebar navigation

Route guards check `meta.requiresAuth` and redirect to `/admin/login` if no token is in `localStorage`.

### Frontend: Auth & API Layer

- **Pinia store** (`stores/user.js`): Holds `token` and `userInfo`. Token is synced with `localStorage`.
- **Axios instance** (`api/request.js`): Base URL `/api`, auto-injects `Authorization: Bearer <token>` from `localStorage`, and intercepts responses:
  - Non-200 `code` triggers `ElMessage.error()`
  - `code === 401` clears token and redirects to login
  - Successful responses return `res.data` (the inner `data` field), so callers receive the payload directly
- **API modules** (`api/index.js`): Organized as `authApi`, `frontApi`, `adminApi` objects

### Frontend: Markdown Pipeline

- **Editing**: Uses `md-editor-v3` (a Vue 3 markdown editor component) in the article edit page
- **Rendering**: Uses `markdown-it` (configured in `utils/markdown.js`) for displaying article content on the detail page

## Key File Mapping

| Concern | Backend | Frontend |
|---|---|---|
| Auth/JWT | `JwtInterceptor`, `JwtUtil`, `AuthController` | `stores/user.js`, `api/request.js`, `views/admin/Login.vue` |
| Article CRUD | `ArticleService`, `ArticleMapper`, `AdminController` | `views/admin/ArticleList.vue`, `views/admin/ArticleEdit.vue` |
| Public article list | `FrontController.articles()` | `views/front/Home.vue` |
| Recycle bin | `ArticleService.listDeleted()`, `restore()`, `permanentDelete()` | `views/admin/RecycleBin.vue` |
| Comments | `CommentService`, `CommentMapper` | `views/front/ArticleDetail.vue`, `views/admin/CommentManage.vue` |
