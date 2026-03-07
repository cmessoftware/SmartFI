import TransactionForm from './TransactionForm';
import TransactionReport from './TransactionReport';
import CSVImport from './CSVImport';
import AdminPanel from './AdminPanel';
import DashboardOverview from './DashboardOverview';

function Dashboard({ currentView, user, transactions, addTransaction, addMultipleTransactions, refreshTransactions, loading, setCurrentView }) {
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
        <TransactionReport transactions={transactions} />
      )}
      
      {currentView === 'admin' && user.role === 'admin' && (
        <AdminPanel />
      )}
    </div>
  );
}

export default Dashboard;
