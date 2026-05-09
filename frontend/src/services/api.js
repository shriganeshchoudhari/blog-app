import axios from 'axios';

const API_BASE_URL = '/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for JWT token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const authApi = {
  login: (credentials) => api.post('/v1/auth/login', credentials),
  register: (userData) => api.post('/v1/auth/register', userData),
  verifyToken: () => api.get('/v1/auth/verify'),
};

export const postApi = {
  getAllPosts: () => api.get('/v1/posts'),
  getPostById: (id) => api.get(`/v1/posts/${id}`),
  createPost: (post) => api.post('/v1/posts', post),
  updatePost: (id, post) => api.put(`/v1/posts/${id}`, post),
  deletePost: (id) => api.delete(`/v1/posts/${id}`),
  getPostsByCategory: (categoryId) => api.get(`/v1/posts/category/${categoryId}`),
  getPostsByTag: (tagId) => api.get(`/v1/posts/tag/${tagId}`),
};

export const commentApi = {
  getCommentsByPost: (postId) => api.get(`/v1/posts/${postId}/comments`),
  createComment: (postId, comment) => api.post(`/v1/posts/${postId}/comments`, comment),
  deleteComment: (postId, commentId) => api.delete(`/v1/posts/${postId}/comments/${commentId}`),
};

export default api;
