# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Spring Boot 3.2.5** backend for a blog management system (graduation project). It provides REST APIs for article management, categories, tags, comments, and JWT-based admin authentication. The frontend is a Vue 3 + Vite SPA in the sibling `../blog-frontend/` directory — this is a monorepo (backend, frontend, and `../sql/init.sql` together); see `../CLAUDE.md` for the whole-project overview.

- **Java**: 17
- **Build tool**: Maven
- **ORM**: MyBatis-Plus 3.5.6
- **Database**: MySQL
- **Authentication**: JWT (jjwt 0.12.5)

## Build & Run Commands

```bash
# Compile
mvn clean compile

# Run the application (starts on port 8081)
mvn spring-boot:run

# Build JAR
mvn clean package

# The packaged JAR can be run with:
java -jar target/blog-backend-1.0.0.jar
```

## Development Setup

1. **Database**: MySQL must be running on `localhost:3306` with a database named `blog_db`. Credentials come from `blog-backend/.env` (`DB_USERNAME` / `DB_PASSWORD`, git-ignored — copy `.env.example` to create it), which `application.yml` imports via `spring.config.import: optional:file:.env[.properties]`. The `root / 123456` values in `application.yml` are fallback defaults used only when `.env` is absent.
2. **Secrets**: `.env` also supplies `JWT_SECRET`, which has **no default** — startup fails with `Could not resolve placeholder 'JWT_SECRET'` if it is missing. It must be ≥32 characters because `JwtUtil.getKey()` uses `Keys.hmacShaKeyFor()`, which rejects shorter keys with `WeakKeyException`. Rotating it invalidates all previously issued tokens.
3. **CORS**: Configured to allow all origins (`*`) — the frontend runs separately (typically on port 5173).
4. **No tests**: This project does not have a test suite.

## Architecture

### Layered Structure

The project follows a standard Spring layered architecture:

```
Controller → Service → Mapper → Entity
```

| Package | Purpose |
|---------|---------|
| `com.blog.controller` | REST endpoints — three controllers split by audience |
| `com.blog.service` | Business logic, transaction boundaries |
| `com.blog.mapper` | MyBatis-Plus data access interfaces |
| `com.blog.entity` | Database entity POJOs with MyBatis-Plus annotations |
| `com.blog.dto` | Request/response DTOs and VO objects |
| `com.blog.common` | `Result<T>` wrapper, `BusinessException`, `GlobalExceptionHandler` |
| `com.blog.config` | `WebConfig` (CORS + interceptors), `MybatisPlusConfig` (pagination + auto-fill) |
| `com.blog.util` | `JwtUtil` for token generation/validation |
| `com.blog.interceptor` | `JwtInterceptor` — extracts `userId` from token into request attributes |

### Controllers & Route Split

| Controller | Base Path | Auth | Purpose |
|-----------|-----------|------|---------|
| `FrontController` | `/api/**` | None | Public-facing: article list/detail, categories, tags, comments |
| `AuthController` | `/api/auth/**` | None | Login, get current user info |
| `AdminController` | `/api/admin/**` | JWT required | CRUD for articles, categories, tags, comments; stats; recycle bin |

The `JwtInterceptor` is registered in `WebConfig` and protects `/api/admin/**`, excluding `/api/auth/**`.

### Key Patterns

**Uniform API Response**: Every endpoint returns `Result<T>`:
- Success: `Result.success(data)` → `{ code: 200, message: "success", data: ... }`
- Error: `Result.error(message)` → `{ code: 500, message: ... }`
- Business errors throw `BusinessException` → caught by `GlobalExceptionHandler` → `code: 400`

**Authentication Flow**:
1. Admin calls `POST /api/auth/login` → receives JWT token
2. Frontend sends token in `Authorization: Bearer <token>` header
3. `JwtInterceptor` validates token and sets `userId` as a request attribute
4. Admin controllers read `userId` from `HttpServletRequest.getAttribute("userId")`

**MyBatis-Plus Configuration** (`MybatisPlusConfig`):
- Pagination interceptor for MySQL
- Auto-fill `createTime` on insert, `updateTime` on insert/update
- Logical delete is enabled globally: field `deleted`, value `1` = deleted, `0` = active

**Entity Conventions**:
- `@TableId(type = IdType.AUTO)` for auto-increment primary keys
- `@TableLogic` on `deleted` field for soft deletes
- `@TableField(fill = ...)` for timestamp auto-fill
- Lombok `@Data` for getters/setters

### Soft Delete & Recycle Bin

Articles support soft delete via MyBatis-Plus `@TableLogic`. Deleted articles can be:
- Listed via `GET /api/admin/recycle/articles`
- Restored via `PUT /api/admin/articles/{id}/restore`
- Permanently deleted via `DELETE /api/admin/articles/{id}/permanent`

Custom mapper methods (`selectDeletedPage`, `restoreById`, `physicalDeleteById`) handle deleted-record queries and hard deletion.

### Article-Tag Many-to-Many

Articles and Tags are linked via the `article_tag` junction table (`ArticleTag` entity). The `ArticleService` manages these relationships manually in `saveTags()` and updates them within `@Transactional` boundaries during article create/update.

### VO Assembly

`ArticleService.toVO()` assembles `ArticleVO` from `Article` + related entities (category name, author nickname, tags). Content is omitted in list views (`withContent=false`) and included in detail views.
