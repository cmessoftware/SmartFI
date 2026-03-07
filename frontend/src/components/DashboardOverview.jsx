import { useMemo } from 'react';

function DashboardOverview({ transactions, user, refreshTransactions, loading, setCurrentView }) {
  const stats = useMemo(() => {
    const ingresos = transactions
      .filter(t => t.tipo === 'Ingreso')
      .reduce((sum, t) => sum + (parseFloat(t.monto) || 0), 0);
    const gastos = transactions
      .filter(t => t.tipo === 'Gasto')
      .reduce((sum, t) => sum + (parseFloat(t.monto) || 0), 0);
    const balance = ingresos - gastos;
    const totalTransacciones = transactions.length;

    return { ingresos, gastos, balance, totalTransacciones };
  }, [transactions]);

  const recentTransactions = useMemo(() => {
    return transactions.slice(-5).reverse();
  }, [transactions]);

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-finly-text">
            Bienvenido, {user.full_name || user.username}
          </h1>
          <p className="text-finly-textSecondary mt-2 flex items-center gap-2">
            Panel de control de finanzas personales
            <span className="text-xs bg-green-100 text-green-700 px-2 py-1 rounded-full flex items-center gap-1">
              📊 Google Sheets
            </span>
          </p>
        </div>
        <div className="flex items-center gap-4">
          <button
            onClick={refreshTransactions}
            disabled={loading}
            className="flex items-center gap-2 px-4 py-2 bg-finly-primary text-white rounded-lg hover:bg-finly-primaryHover transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            title="Refrescar datos desde Google Sheets"
          >
            <span className={loading ? 'animate-spin' : ''}>🔄</span>
            {loading ? 'Cargando...' : 'Refrescar'}
          </button>
          <div className="text-right">
            <p className="text-sm text-finly-textSecondary">Fecha actual</p>
            <p className="text-lg font-semibold text-finly-text">
              {new Date().toLocaleDateString('es-AR', { 
                weekday: 'long', 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric' 
              })}
            </p>
          </div>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white rounded-xl shadow-md p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-finly-textSecondary">Ingresos</p>
              <p className="text-2xl font-bold text-finly-income mt-2">
                ${stats.ingresos.toLocaleString('es-AR', { minimumFractionDigits: 2 })}
              </p>
            </div>
            <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center text-2xl">
              📈
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-md p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-finly-textSecondary">Gastos</p>
              <p className="text-2xl font-bold text-finly-expense mt-2">
                ${stats.gastos.toLocaleString('es-AR', { minimumFractionDigits: 2 })}
              </p>
            </div>
            <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center text-2xl">
              📉
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-md p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-finly-textSecondary">Balance</p>
              <p className={`text-2xl font-bold mt-2 ${
                stats.balance >= 0 ? 'text-finly-income' : 'text-finly-expense'
              }`}>
                ${stats.balance.toLocaleString('es-AR', { minimumFractionDigits: 2 })}
              </p>
            </div>
            <div className={`w-12 h-12 rounded-full flex items-center justify-center text-2xl ${
              stats.balance >= 0 ? 'bg-blue-100' : 'bg-orange-100'
            }`}>
              💰
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-md p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-finly-textSecondary">Transacciones</p>
              <p className="text-2xl font-bold text-finly-text mt-2">
                {stats.totalTransacciones}
              </p>
            </div>
            <div className="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center text-2xl">
              📊
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-xl shadow-md p-6">
        <h2 className="text-xl font-bold text-finly-text mb-4">Acciones Rápidas</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div 
            onClick={() => setCurrentView('add')}
            className="border-2 border-finly-primary border-dashed rounded-lg p-4 text-center hover:bg-finly-dropzone transition cursor-pointer"
          >
            <div className="text-3xl mb-2">➕</div>
            <p className="text-sm font-semibold text-finly-text">Cargar Gasto</p>
          </div>
          <div 
            onClick={() => setCurrentView('add')}
            className="border-2 border-green-400 border-dashed rounded-lg p-4 text-center hover:bg-green-50 transition cursor-pointer"
          >
            <div className="text-3xl mb-2">💵</div>
            <p className="text-sm font-semibold text-finly-text">Cargar Ingreso</p>
          </div>
          <div 
            onClick={() => setCurrentView('import')}
            className="border-2 border-blue-400 border-dashed rounded-lg p-4 text-center hover:bg-blue-50 transition cursor-pointer"
          >
            <div className="text-3xl mb-2">📁</div>
            <p className="text-sm font-semibold text-finly-text">Importar CSV</p>
          </div>
          <div 
            onClick={() => setCurrentView('reports')}
            className="border-2 border-purple-400 border-dashed rounded-lg p-4 text-center hover:bg-purple-50 transition cursor-pointer"
          >
            <div className="text-3xl mb-2">📈</div>
            <p className="text-sm font-semibold text-finly-text">Ver Reportes</p>
          </div>
        </div>
      </div>

      {/* Recent Transactions */}
      {recentTransactions.length > 0 ? (
        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-xl font-bold text-finly-text mb-4">
            Transacciones Recientes
          </h2>
          <div className="space-y-3">
            {recentTransactions.map((t, idx) => (
              <div 
                key={t.id || idx} 
                className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition"
              >
                <div className="flex items-center space-x-4">
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center ${
                    t.tipo === 'Ingreso' ? 'bg-green-100' : 'bg-red-100'
                  }`}>
                    {t.tipo === 'Ingreso' ? '📈' : '📉'}
                  </div>
                  <div>
                    <p className="font-semibold text-finly-text">{t.categoria}</p>
                    <p className="text-sm text-finly-textSecondary">
                      {t.detalle || 'Sin detalle'} • {t.fecha}
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <p className={`text-lg font-bold ${
                    t.tipo === 'Ingreso' ? 'text-finly-income' : 'text-finly-expense'
                  }`}>
                    {t.tipo === 'Ingreso' ? '+' : '-'}${(parseFloat(t.monto) || 0).toLocaleString('es-AR', { minimumFractionDigits: 2 })}
                  </p>
                  <span className={`inline-block px-2 py-1 rounded text-xs font-semibold ${
                    t.tipo === 'Ingreso' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                  }`}>
                    {t.tipo}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : (
        <div className="bg-white rounded-xl shadow-md p-12 text-center">
          <div className="text-6xl mb-4">📊</div>
          <h3 className="text-xl font-bold text-finly-text mb-2">
            ¡Comienza a gestionar tus finanzas!
          </h3>
          <p className="text-finly-textSecondary">
            No hay transacciones aún. Agrega tu primera transacción para comenzar.
          </p>
        </div>
      )}
    </div>
  );
}

export default DashboardOverview;
