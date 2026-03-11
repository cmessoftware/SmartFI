import axios from 'axios';

// Read API URL from runtime config (window.ENV) or build-time env variable or default to localhost
const API_URL = window.ENV?.VITE_API_URL || import.meta.env.VITE_API_URL || 'http://localhost:8000';

// Debug: Log the API URL being used
console.log('🔧 API_URL configured:', API_URL);
console.log('🔧 window.ENV:', window.ENV);
console.log('🔧 VITE_API_URL env:', import.meta.env.VITE_API_URL);

const api = axios.create({
  baseURL: API_URL,
});

// Add token to requests
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

// Handle token expiration
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/';
    }
    return Promise.reject(error);
  }
);

export const authAPI = {
  login: (username, password) => {
    const formData = new FormData();
    formData.append('username', username);
    formData.append('password', password);
    return api.post('/api/auth/login', formData);
  },
  getCurrentUser: () => api.get('/api/auth/me'),
};

export const transactionsAPI = {
  getCategories: () => api.get('/api/categories'),
  getTransactionTypes: () => api.get('/api/transaction-types'),
  getNecessityTypes: () => api.get('/api/necessity-types'),
  saveTransaction: (transaction) => api.post('/api/transactions', transaction),
  getTransactions: () => api.get('/api/transactions'),
  importCSV: (data) => api.post('/api/transactions/import', data),
  migrateFromLocalStorage: (data) => api.post('/api/transactions/migrate', data),
  syncFromSheets: (force = false) => api.post(`/api/transactions/sync-from-sheets?force=${force}`),
  debugSync: () => api.get('/api/transactions/debug-sync'),
  updateTransaction: (id, transaction) => api.put(`/api/transactions/${id}`, transaction),
  deleteTransaction: (id) => api.delete(`/api/transactions/${id}`),
};

export const adminAPI = {
  getUsers: () => api.get('/api/admin/users'),
  createUser: (user) => api.post('/api/admin/users', user),
  updateUser: (username, user) => api.put(`/api/admin/users/${username}`, user),
  deleteUser: (username) => api.delete(`/api/admin/users/${username}`),
};

export default api;
