# API Specification: G-Blog X

## 1. Authentication Endpoints

### 1.1 Login
- **URL**: `POST /api/v1/auth/login`
- **Request Body**:
  ```json
  { "username": "admin", "password": "password" }
  ```
- **Response**:
  ```json
  {
    "accessToken": "eyJhbG...",
    "refreshToken": "eyJhbG...",
    "expiresIn": 900
  }
  ```

### 1.2 Token Refresh
- **URL**: `POST /api/v1/auth/refresh`
- **Request Body**:
  ```json
  { "refreshToken": "eyJhbG..." }
  ```
- **Response**:
  ```json
  {
    "accessToken": "eyJhbG...",
    "refreshToken": "eyJhbG..."
  }
  ```

## 2. Posts Endpoints

### 2.1 List Posts
- **URL**: `GET /api/v1/posts`
- **Response**:
  ```json
  {
    "data": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "title": "Modern DevSecOps",
        "summary": "Exploring the G-Blog X stack...",
        "status": "published"
      }
    ]
  }
  ```

### 2.2 Create Post
- **URL**: `POST /api/v1/posts`
- **Auth**: `ADMIN` role required.
- **Request Body**:
  ```json
  {
    "title": "New Post",
    "content": "Full markdown content here...",
    "status": "draft"
  }
  ```

## 3. Monitoring Endpoints
- **Liveness**: `GET /actuator/health/liveness`
- **Readiness**: `GET /actuator/health/readiness`
- **Prometheus Metrics**: `GET /actuator/prometheus`
