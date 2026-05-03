# Database Schema Specification: G-Blog X

## 1. Overview
The database uses **PostgreSQL 15** as the primary engine. All identifiers use **UUID v4** to ensure scalability and ease of data migration across microservices.

## 2. Table Definitions

### 2.1 `posts`
| Column | Type | Constraints |
| :--- | :--- | :--- |
| `id` | UUID | PRIMARY KEY |
| `title` | VARCHAR(255) | NOT NULL |
| `slug` | VARCHAR(255) | UNIQUE, NOT NULL |
| `content` | TEXT | |
| `status` | VARCHAR(50) | DEFAULT 'draft' |
| `created_at` | TIMESTAMP | DEFAULT NOW() |

### 2.2 `comments`
| Column | Type | Constraints |
| :--- | :--- | :--- |
| `id` | UUID | PRIMARY KEY |
| `post_id` | UUID | FOREIGN KEY (posts.id) |
| `author` | VARCHAR(100) | NOT NULL |
| `content` | TEXT | NOT NULL |

## 3. Indexing Strategy
- **`idx_posts_slug`**: B-Tree index on `slug` for fast article lookup.
- **`idx_comments_post_id`**: Hash index on `post_id` for fast comment retrieval (optimized in `PostController`).

## 4. Migration Plan
All schema changes are managed by **Flyway**.
- **Location**: `src/main/resources/db/migration`
- **Initial Schema**: `V1__init.sql`
- **Verification**: Flyway baseline is enabled for production environments to handle existing data.
