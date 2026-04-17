import { useState, useEffect } from 'react';
import TransactionForm from './TransactionForm';
import TransactionReport from './TransactionReport';
import CSVImport from './CSVImport';
import AdminPanel from './AdminPanel';
import DashboardOverview from './DashboardOverview';
import DebtManager from './DebtManager';
import CreditCardManager from './CreditCardManager';
import EditTransactionModal from './EditTransactionModal';
import { useToast } from './ToastContainer';
import { transactionsAPI, debtsAPI } from '../services/api';

function Dashboard({ currentView, user, transactions, addTransaction, addMultipleTransactions, updateTransaction, deleteTransaction, refreshTransactions, loading, setCurrentView }) {
  const [editingTransaction, setEditingTransaction] = useState(null);
  const [categories, setCategories] = useState([]);
  const [necessityTypes, setNecessityTypes] = useState([]);
  const [debts, setDebts] = useState([]);
  const [debtRefreshKey, setDebtRefreshKey] = useState(0);
  const toast = useToast();

  useEffect(() => {
    loadFormData();
  }, []);

  // Reload debts when edit modal opens to ensure fresh data
  useEffect(() => {
    if (editingTransaction) {
      debtsAPI.getDebts()
        .then(res => setDebts(res.data || []))
        .catch(err => console.error('Error reloading debts:', err));
    }
  }, [editingTransaction]);

  const loadFormData = async () => {
    try {
      const [categoriesRes, necessityTypesRes, debtsRes] = await Promise.all([
        transactionsAPI.getCategories(),
        transactionsAPI.getNecessityTypes(),
        debtsAPI.getDebts()
      ]);
      setCategories(categoriesRes.data || []);
      setNecessityTypes(necessityTypesRes.data || []);
      setDebts(debtsRes.data || []);
    } catch (error) {
      console.error('Error loading form data:', error);
    }
  };

  const handleEdit = (transaction) => {
    setEditingTransaction(transaction);
  };

  const handleSaveEdit = async (updatedTransaction) => {
    try {
      await updateTransaction(updatedTransaction.id, updatedTransaction);
      setEditingTransaction(null);
      // Refresh budget data if transaction was linked/unlinked
      setDebtRefreshKey(prev => prev + 1);
      toast.success('Transacción actualizada correctamente');
    } catch (error) {
      toast.error('Error al actualizar la transacción');
      console.error(error);
    }
  };

  const handleDelete = async (transaction) => {
    try {
      await deleteTransaction(transaction.id);
      // Refresh budget data if transaction was linked
      if (transaction.debt_id) {
        setDebtRefreshKey(prev => prev + 1);
      }
      toast.success('Transacción eliminada correctamente');
    } catch (error) {
      toast.error('Error al eliminar la transacción');
      console.error(error);
    }
  };

  const handleBulkDeleteTransactions = async (transactionIds) => {
    if (!Array.isArray(transactionIds) || transactionIds.length === 0) return;

    let deletedCount = 0;
    let failedCount = 0;

    for (const id of transactionIds) {
      try {
        await transactionsAPI.deleteTransaction(id);
        deletedCount += 1;
      } catch (error) {
        failedCount += 1;
        console.error(`Error deleting transaction ${id}:`, error);
      }
    }

    await refreshTransactions();

    // Refresh budget data since some deleted transactions may have been linked
    setDebtRefreshKey(prev => prev + 1);

    if (deletedCount > 0) {
      toast.success(`${deletedCount} transacción(es) eliminada(s) correctamente`);
    }
    if (failedCount > 0) {
      toast.warning(`${failedCount} transacción(es) no se pudieron eliminar`);
    }
  };

  const handleAddTransaction = async (transaction) => {
    await addTransaction(transaction);
    // Refresh budget data if transaction is linked to a budget item
    if (transaction.debt_id) {
      setDebtRefreshKey(prev => prev + 1);
    }
  };

  const userRoles = user?.roles || [];
  const canEdit = user && (userRoles.includes('ADMIN') || userRoles.includes('WRITER'));
  const isAdmin = userRoles.includes('ADMIN');

  return (
    <div className="p-8">
      {currentView === 'dashboard' && (
        <DashboardOverview 
          transactions={transactions} 
          user={user}
          refreshTransactions={refreshTransactions}
          loading={loading}
          setCurrentView={setCurrentView}
        />
      )}
      
      {currentView === 'add' && (
        <TransactionForm addTransaction={handleAddTransaction} />
      )}
      
      {currentView === 'import' && (
        <CSVImport addMultipleTransactions={addMultipleTransactions} />
      )}
      
      {currentView === 'reports' && (
        <TransactionReport 
          transactions={transactions}
          onEdit={handleEdit}
          onDelete={handleDelete}
          onBulkDelete={handleBulkDeleteTransactions}
          canEdit={canEdit}
          isAdmin={isAdmin}
        />
      )}
      
      {currentView === 'admin' && isAdmin && (
        <AdminPanel />
      )}

      {currentView === 'debts' && (
        <DebtManager key={`${currentView}-${debtRefreshKey}`} canEdit={canEdit} isAdmin={isAdmin} />
      )}

      {currentView === 'credit-cards' && (
        <CreditCardManager canEdit={canEdit} isAdmin={isAdmin} setCurrentView={setCurrentView} refreshTransactions={refreshTransactions} />
      )}

      {editingTransaction && (
        <EditTransactionModal
          transaction={editingTransaction}
          onSave={handleSaveEdit}
          onClose={() => setEditingTransaction(null)}
          categories={categories}
          necessityTypes={necessityTypes}
          debts={debts}
        />
      )}
    </div>
  );
}

export default Dashboard;
