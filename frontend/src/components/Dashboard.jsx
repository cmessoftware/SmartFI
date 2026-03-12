import { useState, useEffect } from 'react';
import TransactionForm from './TransactionForm';
import TransactionReport from './TransactionReport';
import CSVImport from './CSVImport';
import AdminPanel from './AdminPanel';
import DashboardOverview from './DashboardOverview';
import EditTransactionModal from './EditTransactionModal';
import { useToast } from './ToastContainer';
import { transactionsAPI } from '../services/api';

function Dashboard({ currentView, user, transactions, addTransaction, addMultipleTransactions, updateTransaction, deleteTransaction, refreshTransactions, loading, setCurrentView }) {
  const [editingTransaction, setEditingTransaction] = useState(null);
  const [categories, setCategories] = useState([]);
  const [necessityTypes, setNecessityTypes] = useState([]);
  const toast = useToast();

  useEffect(() => {
    loadFormData();
  }, []);

  const loadFormData = async () => {
    try {
      const [categoriesRes, necessityTypesRes] = await Promise.all([
        transactionsAPI.getCategories(),
        transactionsAPI.getNecessityTypes()
      ]);
      setCategories(categoriesRes.data || []);
      setNecessityTypes(necessityTypesRes.data || []);
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
      toast.success('Transacción actualizada correctamente');
    } catch (error) {
      toast.error('Error al actualizar la transacción');
      console.error(error);
    }
  };

  const handleDelete = async (transaction) => {
    try {
      await deleteTransaction(transaction.id);
      toast.success('Transacción eliminada correctamente');
    } catch (error) {
      toast.error('Error al eliminar la transacción');
      console.error(error);
    }
  };

  const canEdit = user && (user.role === 'admin' || user.role === 'writer');

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
        <TransactionForm addTransaction={addTransaction} />
      )}
      
      {currentView === 'import' && (
        <CSVImport addMultipleTransactions={addMultipleTransactions} />
      )}
      
      {currentView === 'reports' && (
        <TransactionReport 
          transactions={transactions}
          onEdit={handleEdit}
          onDelete={handleDelete}
          canEdit={canEdit}
        />
      )}
      
      {currentView === 'admin' && user.role === 'admin' && (
        <AdminPanel />
      )}

      {editingTransaction && (
        <EditTransactionModal
          transaction={editingTransaction}
          onSave={handleSaveEdit}
          onClose={() => setEditingTransaction(null)}
          categories={categories}
          necessityTypes={necessityTypes}
        />
      )}
    </div>
  );
}

export default Dashboard;
