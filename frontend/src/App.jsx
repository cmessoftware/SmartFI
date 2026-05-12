import { useState, useEffect } from 'react';
import Login from './components/Login';
import Dashboard from './components/Dashboard';
import Sidebar from './components/Sidebar';
import { ToastProvider } from './components/ToastContainer';
import { transactionsAPI, authAPI } from './services/api';

function App() {
  const [user, setUser] = useState(null);
  const [currentView, setCurrentView] = useState('dashboard');
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(false);

  const getTransactionsCacheKey = (userData) => {
    const userId = userData?.id;
    return userId ? `transactions_cache_user_${userId}` : 'transactions_cache';
  };

  useEffect(() => {
    // One-time migration: clean old localStorage keys
    if (!localStorage.getItem('migrated_to_sheets')) {
      const oldKeys = ['transactions'];
      oldKeys.forEach(key => {
        if (localStorage.getItem(key)) {
          console.log(`🧹 Cleaning old localStorage key: ${key}`);
          localStorage.removeItem(key);
        }
      });
      localStorage.setItem('migrated_to_sheets', 'true');
    }
    
    // Check if user is already logged in and validate token before loading protected data
    const bootstrapSession = async () => {
      const storedUser = localStorage.getItem('user');
      const storedToken = localStorage.getItem('token');
      if (!storedUser || !storedToken) {
        return;
      }

      try {
        const meResponse = await authAPI.getCurrentUser();
        const userData = meResponse?.data || JSON.parse(storedUser);
        setUser(userData);
        localStorage.setItem('user', JSON.stringify(userData));
        // Load transactions from backend (no sync on startup)
        loadTransactionsFromDB(userData);
      } catch (_error) {
        // Session is no longer valid: clean local auth and stay on login view
        localStorage.removeItem('user');
        localStorage.removeItem('token');
        localStorage.removeItem('refresh_token');
        setUser(null);
      }
    };

    bootstrapSession();
  }, []);

  // Load transactions from PostgreSQL only (no sync)
  const loadTransactionsFromDB = async (userDataOverride = null) => {
    try {
      setLoading(true);
      const effectiveUser = userDataOverride || user;
      const cacheKey = getTransactionsCacheKey(effectiveUser);
      
      // Try to load from localStorage cache first (for instant UI)
      const cachedTransactions = localStorage.getItem(cacheKey);
      if (cachedTransactions) {
        setTransactions(JSON.parse(cachedTransactions));
        console.log('⚡ Loaded from cache');
      }
      
      // Fetch from PostgreSQL (source of truth)
      const response = await transactionsAPI.getTransactions();
      const backendTransactions = response.data || [];
      
      setTransactions(backendTransactions);
      // Update cache
      localStorage.setItem(cacheKey, JSON.stringify(backendTransactions));
      console.log(`✅ Loaded ${backendTransactions.length} transactions from PostgreSQL`);
      
    } catch (error) {
      console.error('❌ Error loading transactions:', error);
      // Only show alert if we don't have cached data
      const effectiveUser = userDataOverride || user;
      const cacheKey = getTransactionsCacheKey(effectiveUser);
      const cachedTransactions = localStorage.getItem(cacheKey);
      if (!cachedTransactions) {
        console.warn('No cached data available. Unable to load transactions.');
      }
    } finally {
      setLoading(false);
    }
  };

  // Load transactions WITH sync from Google Sheets (admin only)
  const loadTransactions = async (force = false) => {
    try {
      setLoading(true);
      const cacheKey = getTransactionsCacheKey(user);
      
      // Sync from Google Sheets to PostgreSQL (admin only)
      if (user && user.roles && user.roles.includes('ADMIN')) {
        try {
          console.log(`🔄 Syncing from Google Sheets to PostgreSQL${force ? ' (FORCE MODE)' : ''}...`);
          const syncResponse = await transactionsAPI.syncFromSheets(force);
          console.log(`✅ Sync completed:`, syncResponse.data);
        } catch (syncError) {
          // If sync fails, continue to load from DB
          console.warn('⚠️ Could not sync from Google Sheets:', syncError.response?.data?.detail || syncError.message);
        }
      }
      
      // Fetch from PostgreSQL (source of truth)
      const response = await transactionsAPI.getTransactions();
      const backendTransactions = response.data || [];
      
      setTransactions(backendTransactions);
      // Update cache
      localStorage.setItem(cacheKey, JSON.stringify(backendTransactions));
      console.log(`✅ Loaded ${backendTransactions.length} transactions from PostgreSQL`);
      
    } catch (error) {
      console.error('❌ Error loading transactions:', error);
      // Only show alert if we don't have cached data
      const cacheKey = getTransactionsCacheKey(user);
      const cachedTransactions = localStorage.getItem(cacheKey);
      if (!cachedTransactions) {
        console.warn('No cached data available. Unable to load transactions.');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleLogin = (userData, token, refreshToken) => {
    setUser(userData);
    localStorage.setItem('user', JSON.stringify(userData));
    localStorage.setItem('token', token);
    if (refreshToken) {
      localStorage.setItem('refresh_token', refreshToken);
    }
    // Load transactions immediately after login
    loadTransactionsFromDB(userData);
  };

  const handleLogout = async () => {
    try {
      await authAPI.logout();
    } catch (e) {
      // ignore — token might already be expired
    }
    setUser(null);
    localStorage.removeItem('user');
    localStorage.removeItem('token');
    localStorage.removeItem('refresh_token');
    // Clean visible in-memory data on logout to avoid cross-user confusion.
    setTransactions([]);
  };

  const addTransaction = async (newTransaction) => {
    try {
      // Send to PostgreSQL (primary storage)
      const response = await transactionsAPI.saveTransaction(newTransaction);
      const savedId = response.data?.id;
      console.log(`✅ Transaction ${savedId} saved to PostgreSQL`);
      
      // Update local state with real DB id
      const savedTransaction = { ...newTransaction, id: savedId };
      const updatedTransactions = [...transactions, savedTransaction];
      setTransactions(updatedTransactions);
      localStorage.setItem(getTransactionsCacheKey(user), JSON.stringify(updatedTransactions));
    } catch (error) {
      console.error('❌ Error saving transaction:', error);
      throw error; // Let component show error to user
    }
  };

  const addMultipleTransactions = async (newTransactions) => {
    try {
      // Send to PostgreSQL (primary storage)
      const response = await transactionsAPI.importCSV(newTransactions);
      console.log('✅ CSV import result:', response.data);

      // Reload from source of truth to avoid local mismatch on partial imports
      await loadTransactionsFromDB();
    } catch (error) {
      console.error('❌ Error importing transactions:', error);
      throw error;
    }
  };

  const updateTransaction = async (id, updatedTransaction) => {
    try {
      // Update in PostgreSQL
      await transactionsAPI.updateTransaction(id, updatedTransaction);
      console.log(`✅ Transaction ${id} updated in PostgreSQL`);

      // Reload from source of truth to avoid front-only state drift.
      await loadTransactionsFromDB();
    } catch (error) {
      console.error('❌ Error updating transaction:', error);
      throw error;
    }
  };

  const deleteTransaction = async (id) => {
    try {
      // Delete from PostgreSQL
      await transactionsAPI.deleteTransaction(id);
      console.log(`✅ Transaction ${id} deleted from PostgreSQL`);
      
      // Reload all data to refresh debt statuses if transaction was linked
      await loadTransactionsFromDB();
    } catch (error) {
      console.error('❌ Error deleting transaction:', error);
      throw error;
    }
  };

  if (!user) {
    return (
      <ToastProvider>
        <Login onLogin={handleLogin} />
      </ToastProvider>
    );
  }

  return (
    <ToastProvider>
      <div className="flex h-screen bg-finly-bg">
        <Sidebar 
          user={user} 
          currentView={currentView} 
          setCurrentView={setCurrentView}
          onLogout={handleLogout}
        />
        <main className="flex-1 overflow-y-auto">
          <Dashboard 
            currentView={currentView}
            user={user}
            transactions={transactions}
            addTransaction={addTransaction}
            addMultipleTransactions={addMultipleTransactions}
            updateTransaction={updateTransaction}
            deleteTransaction={deleteTransaction}
            refreshTransactions={loadTransactions}
            loading={loading}
            setCurrentView={setCurrentView}
          />
        </main>
      </div>
    </ToastProvider>
  );
}

export default App;
