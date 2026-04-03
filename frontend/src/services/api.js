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
  syncToSheets: (force = false) => api.post(`/api/transactions/sync-to-sheets?force=${force}`),
  debugSync: () => api.get('/api/transactions/debug-sync'),
  updateTransaction: (id, transaction) => api.put(`/api/transactions/${id}`, transaction),
  deleteTransaction: (id) => api.delete(`/api/transactions/${id}`),
};

export const adminAPI = {
  getUsers: () => api.get('/api/admin/users'),
  createUser: (user) => api.post('/api/admin/users', user),
  updateUser: (username, user) => api.put(`/api/admin/users/${username}`, user),
  deleteUser: (username) => api.delete(`/api/admin/users/${username}`),
  getSetting: (key) => api.get(`/api/settings/${key}`),
  updateSetting: (key, value) => api.put(`/api/settings/${key}`, { value }),
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
};

export default api;
