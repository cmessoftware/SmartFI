import axios from 'axios';

// Read API URL from runtime config (window.ENV) or build-time env variable or default to localhost
const API_URL = window.ENV?.VITE_API_URL || import.meta.env.VITE_API_URL || 'http://localhost:8000';

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

// Handle token expiration — try refresh before giving up
// Use a queue to prevent concurrent refresh calls from racing
let isRefreshing = false;
let failedQueue = [];

const processQueue = (error, token = null) => {
  failedQueue.forEach(({ resolve, reject }) => {
    if (error) {
      reject(error);
    } else {
      resolve(token);
    }
  });
  failedQueue = [];
};

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    if (error.response?.status === 401 && !originalRequest._retry) {
      // If a refresh is already in progress, queue this request
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        }).then((token) => {
          originalRequest.headers.Authorization = `Bearer ${token}`;
          return api(originalRequest);
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      const refreshToken = localStorage.getItem('refresh_token');
      if (refreshToken) {
        try {
          const res = await axios.post(`${API_URL}/api/auth/refresh`, { refresh_token: refreshToken });
          const newToken = res.data.access_token;
          localStorage.setItem('token', newToken);
          processQueue(null, newToken);
          originalRequest.headers.Authorization = `Bearer ${newToken}`;
          return api(originalRequest);
        } catch (refreshError) {
          processQueue(refreshError, null);
          // refresh failed — log out
        } finally {
          isRefreshing = false;
        }
      }
      isRefreshing = false;
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      localStorage.removeItem('refresh_token');
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
  logout: () => api.post('/api/auth/logout'),
  changePassword: (currentPassword, newPassword) =>
    api.post('/api/auth/change-password', { current_password: currentPassword, new_password: newPassword }),
};

export const transactionsAPI = {
  getCategories: () => api.get('/api/categories'),
  createCategory: (name) => api.post('/api/categories', { name }),
  deleteCategory: (id) => api.delete(`/api/categories/${id}`),
  getTransactionTypes: () => api.get('/api/transaction-types'),
  getNecessityTypes: () => api.get('/api/necessity-types'),
  saveTransaction: (transaction) => api.post('/api/transactions', transaction),
  getTransactions: () => api.get('/api/transactions'),
  importCSV: (data) => api.post('/api/transactions/import', data),
  migrateFromLocalStorage: (data) => api.post('/api/transactions/migrate', data),
  syncFromSheets: (force = false) => api.post(`/api/transactions/sync-from-sheets?force=${force}`),
  syncToSheets: (force = false) => api.post(`/api/transactions/sync-to-sheets?force=${force}`),
  debugSync: () => api.get('/api/transactions/debug-sync'),
  updateTransaction: (id, transaction) => api.put(`/api/transactions/${id}`, transaction),
  deleteTransaction: (id) => api.delete(`/api/transactions/${id}`),
};

export const adminAPI = {
  // Users
  getUsers: () => api.get('/api/admin/users'),
  getUser: (id) => api.get(`/api/admin/users/${id}`),
  createUser: (user) => api.post('/api/admin/users', user),
  updateUser: (id, user) => api.put(`/api/admin/users/${id}`, user),
  activateUser: (id) => api.patch(`/api/admin/users/${id}/activate`),
  deactivateUser: (id) => api.patch(`/api/admin/users/${id}/deactivate`),
  unlockUser: (id) => api.patch(`/api/admin/users/${id}/unlock`),
  resetPassword: (id, newPassword) => api.post(`/api/admin/users/${id}/reset-password`, { new_password: newPassword }),
  // Roles
  getRoles: () => api.get('/api/admin/roles'),
  createRole: (role) => api.post('/api/admin/roles', role),
  updateRole: (id, role) => api.put(`/api/admin/roles/${id}`, role),
  deleteRole: (id) => api.delete(`/api/admin/roles/${id}`),
  getPermissions: () => api.get('/api/admin/roles/permissions/all'),
  // Settings
  getSetting: (key) => api.get(`/api/settings/${key}`),
  updateSetting: (key, value) => api.put(`/api/settings/${key}`, { value }),
  // Clone data
  cloneUserData: (data) => api.post('/api/admin/clone-data', data),
};

export const monthClosingAPI = {
  getAll: () => api.get('/api/month-closings'),
  getStatus: (year, month) => api.get(`/api/month-closings/${year}/${month}`),
  closeMonth: (year, month) => api.post(`/api/month-closings/${year}/${month}`),
  reopenMonth: (year, month) => api.delete(`/api/month-closings/${year}/${month}`),
};

export const debtsAPI = {
  getDebts: () => api.get('/api/budget-items'),
  getDebtSummary: (month, year) => {
    const params = new URLSearchParams();
    if (month) params.append('month', month);
    if (year) params.append('year', year);
    const qs = params.toString();
    return api.get(`/api/budget-items/summary${qs ? `?${qs}` : ''}`);
  },
  getDebt: (id) => api.get(`/api/budget-items/${id}`),
  createDebt: (debt) => api.post('/api/budget-items', debt),
  updateDebt: (id, debt) => api.put(`/api/budget-items/${id}`, debt),
  deleteDebt: (id) => api.delete(`/api/budget-items/${id}`),
  cloneMonth: (sourceMonth, sourceYear, targetMonth, targetYear) =>
    api.post('/api/debts/clone-month', {
      source_month: sourceMonth,
      source_year: sourceYear,
      target_month: targetMonth,
      target_year: targetYear,
    }),
};

export const creditCardAPI = {
  getCreditCards: (activeOnly = true) => api.get(`/api/credit-cards?active_only=${activeOnly}`),
  getCreditCard: (id) => api.get(`/api/credit-cards/${id}`),
  createCreditCard: (card) => api.post('/api/credit-cards', card),
  updateCreditCard: (id, card) => api.put(`/api/credit-cards/${id}`, card),
  deleteCreditCard: (id) => api.delete(`/api/credit-cards/${id}`),
  getCardSummary: (id) => api.get(`/api/credit-cards/${id}/summary`),
  getMonthlyPurchasesTotal: (month, year) => api.get(`/api/credit-cards/monthly-purchases-total?month=${month}&year=${year}`),
  createPurchase: (purchase) => api.post('/api/credit-cards/purchases', purchase),
  updatePurchase: (id, purchase) => api.put(`/api/credit-cards/purchases/${id}`, purchase),
  deletePurchase: (id) => api.delete(`/api/credit-cards/purchases/${id}`),
  getCardPurchases: (cardId) => api.get(`/api/credit-cards/${cardId}/purchases`),
  getPurchasesSummary: (cardId) => api.get(`/api/credit-cards/${cardId}/purchases-summary`),
  getInstallmentSchedule: (planId) => api.get(`/api/installment-plans/${planId}/schedule`),
  payInstallment: (installmentId, payment) => api.put(`/api/installments/${installmentId}/pay`, payment),
  unpayInstallment: (installmentId) => api.put(`/api/installments/${installmentId}/unpay`),
  bulkImportPurchases: (cardId, purchases) => api.post(`/api/credit-cards/${cardId}/import-csv`, purchases),
  getCardPeriodInstallments: (cardId, year, month) => api.get(`/api/credit-cards/${cardId}/period-installments?year=${year}&month=${month}`),
  registerCardPeriodBudget: (cardId, year, month, paymentType = 'total', minimumPayment = 0) => api.post(`/api/credit-cards/${cardId}/register-period-budget`, { year, month, payment_type: paymentType, minimum_payment: minimumPayment }),
  updatePeriodConfig: (cardId, year, month, closingDay, dueDay) => api.put(`/api/credit-cards/${cardId}/period-config`, { year, month, closing_day: closingDay, due_day: dueDay }),
  getPeriodForDate: (cardId, purchaseDate) => api.get(`/api/credit-cards/${cardId}/period-for-date?purchase_date=${purchaseDate}`),
};

export default api;
