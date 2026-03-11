import { useState, useEffect } from 'react';
import Login from './components/Login';
import Dashboard from './components/Dashboard';
import Sidebar from './components/Sidebar';
import { transactionsAPI } from './services/api';

function App() {
  const [user, setUser] = useState(null);
  const [currentView, setCurrentView] = useState('dashboard');
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(false);

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
    
    // Check if user is already logged in
    const storedUser = localStorage.getItem('user');
    const storedToken = localStorage.getItem('token');
    if (storedUser && storedToken) {
      const userData = JSON.parse(storedUser);
      setUser(userData);
      // Load transactions from backend (no sync on startup)
      loadTransactionsFromDB();
    }
  }, []);

  // Load transactions from PostgreSQL only (no sync)
  const loadTransactionsFromDB = async () => {
    try {
      setLoading(true);
      
      // Try to load from localStorage cache first (for instant UI)
      const cachedTransactions = localStorage.getItem('transactions_cache');
      if (cachedTransactions) {
        setTransactions(JSON.parse(cachedTransactions));
        console.log('⚡ Loaded from cache');
      }
      
      // Fetch from PostgreSQL (source of truth)
      const response = await transactionsAPI.getTransactions();
      const backendTransactions = response.data || [];
      
      setTransactions(backendTransactions);
      // Update cache
      localStorage.setItem('transactions_cache', JSON.stringify(backendTransactions));
      console.log(`✅ Loaded ${backendTransactions.length} transactions from PostgreSQL`);
      
    } catch (error) {
      console.error('❌ Error loading transactions:', error);
      // Only show alert if we don't have cached data
      const cachedTransactions = localStorage.getItem('transactions_cache');
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
      
      // Sync from Google Sheets to PostgreSQL (admin only)
      if (user && user.role === 'admin') {
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
      localStorage.setItem('transactions_cache', JSON.stringify(backendTransactions));
      console.log(`✅ Loaded ${backendTransactions.length} transactions from PostgreSQL`);
      
    } catch (error) {
      console.error('❌ Error loading transactions:', error);
      // Only show alert if we don't have cached data
      const cachedTransactions = localStorage.getItem('transactions_cache');
      if (!cachedTransactions) {
        console.warn('No cached data available. Unable to load transactions.');
      }
    } finally {
      setLoading(false);
    }
  };

  const handleLogin = (userData, token) => {
    setUser(userData);
    localStorage.setItem('user', JSON.stringify(userData));
    localStorage.setItem('token', token);
    // Load transactions immediately after login
    loadTransactionsFromDB();
  };

  const handleLogout = () => {
    setUser(null);
    localStorage.removeItem('user');
    localStorage.removeItem('token');
  };

  const addTransaction = async (newTransaction) => {
    try {
      // Send to PostgreSQL (primary storage)
      await transactionsAPI.saveTransaction(newTransaction);
      console.log('✅ Transaction saved to PostgreSQL');
      
      // Update local state and cache
      const updatedTransactions = [...transactions, newTransaction];
      setTransactions(updatedTransactions);
      localStorage.setItem('transactions_cache', JSON.stringify(updatedTransactions));
    } catch (error) {
      console.error('❌ Error saving transaction:', error);
      throw error; // Let component show error to user
    }
  };

  const addMultipleTransactions = async (newTransactions) => {
    try {
      // Send to PostgreSQL (primary storage)
      await transactionsAPI.importCSV(newTransactions);
      console.log(`✅ ${newTransactions.length} transactions saved to PostgreSQL`);
      
      // Update local state and cache
      const updatedTransactions = [...transactions, ...newTransactions];
      setTransactions(updatedTransactions);
      localStorage.setItem('transactions_cache', JSON.stringify(updatedTransactions));
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
      
      // Update local state and cache
      const updatedTransactions = transactions.map(t => 
        t.id === id ? { ...t, ...updatedTransaction } : t
      );
      setTransactions(updatedTransactions);
      localStorage.setItem('transactions_cache', JSON.stringify(updatedTransactions));
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
      
      // Update local state and cache
      const updatedTransactions = transactions.filter(t => t.id !== id);
      setTransactions(updatedTransactions);
      localStorage.setItem('transactions_cache', JSON.stringify(updatedTransactions));
    } catch (error) {
      console.error('❌ Error deleting transaction:', error);
      throw error;
    }
  };

  if (!user) {
    return <Login onLogin={handleLogin} />;
  }

  return (
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
  );
}

export default App;
