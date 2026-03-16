import { useMemo, useState } from 'react';
import { useToast } from './ToastContainer';
import ConfirmDialog from './ConfirmDialog';
import { transactionsAPI } from '../services/api';
import { formatDate } from '../utils/dateUtils';

function DashboardOverview({ transactions, user, refreshTransactions, loading, setCurrentView }) {
  const [showSyncModal, setShowSyncModal] = useState(false);
  const [syncStats, setSyncStats] = useState(null);
  const [loadingStats, setLoadingStats] = useState(false);
  const [confirmDialog, setConfirmDialog] = useState({ isOpen: false, onConfirm: null, title: '', message: '' });
  const toast = useToast();

  const handleOpenSyncModal = async () => {
    setShowSyncModal(true);
    if (user.role === 'admin') {
      setLoadingStats(true);
      try {
        const response = await transactionsAPI.debugSync();
        setSyncStats(response.data);
      } catch (error) {
        console.error('Error loading sync stats:', error);
      }
      setLoadingStats(false);
    }
  };

  const handleSyncFromSheets = async (force = false) => {
    setShowSyncModal(false);
    await refreshTransactions(force);
  };

  const handleSyncToSheets = async (force = false) => {
    setShowSyncModal(false);
    try {
      const response = await transactionsAPI.syncToSheets(force);
      console.log('✅ Sync to Sheets completed:', response.data);
      toast.success(
        `Sincronización completada\n\nTransacciones sincronizadas: ${response.data.synced_count}\nOmitidas (ya existían): ${response.data.skipped_count}\n\nTotal en PostgreSQL: ${response.data.total_db}\nTotal en Google Sheets: ${response.data.total_sheets}`,
        7000
      );
      // Refresh to show updated data
      await refreshTransactions(false);
    } catch (error) {
      console.error('❌ Error syncing to Sheets:', error);
      toast.error(`Error al sincronizar: ${error.response?.data?.detail || error.message}`, 7000);
    }
  };

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
              📊 PostgreSQL + Sheets Sync
            </span>
          </p>
        </div>
        <div className="flex items-center gap-4">
          {user.role === 'admin' && (
            <button
              onClick={handleOpenSyncModal}
              disabled={loading}
              className="flex items-center gap-2 px-4 py-2 bg-finly-primary text-white rounded-lg hover:bg-finly-primaryHover transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
              title="Sincronizar datos desde Google Sheets (Solo Admin)"
            >
              <span className={loading ? 'animate-spin' : ''}>🔄</span>
              {loading ? 'Sincronizando...' : 'Sincronizar desde Sheets'}
            </button>
          )}
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
                      {t.detalle || 'Sin detalle'} • {formatDate(t.fecha)}
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

      {/* Sync Modal */}
      {showSyncModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl shadow-2xl p-8 max-w-2xl w-full mx-4">
            <h2 className="text-2xl font-bold text-finly-text mb-4">
              Sincronización con Google Sheets
            </h2>
            <p className="text-sm text-finly-textSecondary mb-6">
              PostgreSQL es la base de datos principal. Google Sheets funciona como backup y para compartir datos.
            </p>
            
            {loadingStats ? (
              <div className="text-center py-8">
                <span className="animate-spin text-4xl">🔄</span>
                <p className="mt-4 text-finly-textSecondary">Cargando estadísticas...</p>
              </div>
            ) : syncStats && (
              <div className="mb-6 p-4 bg-gray-50 rounded-lg">
                <h3 className="font-semibold text-finly-text mb-3">📊 Estado Actual:</h3>
                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <p className="text-finly-textSecondary">En Google Sheets:</p>
                    <p className="text-2xl font-bold text-finly-text">{syncStats.total_in_sheets}</p>
                  </div>
                  <div>
                    <p className="text-finly-textSecondary">En PostgreSQL:</p>
                    <p className="text-2xl font-bold text-finly-text">{syncStats.total_in_db}</p>
                  </div>
                  <div>
                    <p className="text-finly-textSecondary">Solo en Sheets:</p>
                    <p className="text-xl font-bold text-blue-600">{syncStats.only_in_sheets}</p>
                  </div>
                  <div>
                    <p className="text-finly-textSecondary">Solo en DB:</p>
                    <p className="text-xl font-bold text-orange-600">{syncStats.only_in_db}</p>
                  </div>
                </div>
              </div>
            )}

            <div className="space-y-6">
              {/* Sheets → PostgreSQL */}
              <div className="border-2 border-blue-200 rounded-lg p-4 bg-blue-50">
                <h3 className="font-bold text-blue-900 mb-3 flex items-center gap-2">
                  <span>📥</span> Desde Google Sheets → PostgreSQL
                </h3>
                <div className="space-y-2">
                  <button
                    onClick={() => handleSyncFromSheets(false)}
                    className="w-full flex items-center justify-between p-3 border-2 border-blue-400 rounded-lg hover:bg-blue-100 transition bg-white"
                  >
                    <div className="text-left">
                      <p className="font-semibold text-finly-text">Sincronización Normal</p>
                      <p className="text-xs text-finly-textSecondary">
                        Agrega solo transacciones nuevas desde Sheets
                      </p>
                    </div>
                    <span className="text-2xl">🔄</span>
                  </button>

                  {user.role === 'admin' && (
                    <button
                      onClick={() => {
                        setConfirmDialog({
                          isOpen: true,
                          title: 'Sincronización Forzada desde Sheets',
                          message: 'Esto ELIMINARÁ todas las transacciones de PostgreSQL y las recargará desde Google Sheets.\n\n¿Estás seguro de continuar?',
                          onConfirm: () => handleSyncFromSheets(true)
                        });
                      }}
                      className="w-full flex items-center justify-between p-3 border-2 border-red-400 rounded-lg hover:bg-red-50 transition bg-white"
                    >
                      <div className="text-left">
                        <p className="font-semibold text-red-700">Forzar Reemplazo Total</p>
                        <p className="text-xs text-red-600">
                          ⚠️ Reemplaza TODO con datos de Sheets
                        </p>
                      </div>
                      <span className="text-2xl">🔥</span>
                    </button>
                  )}
                </div>
              </div>

              {/* PostgreSQL → Sheets */}
              <div className="border-2 border-green-200 rounded-lg p-4 bg-green-50">
                <h3 className="font-bold text-green-900 mb-3 flex items-center gap-2">
                  <span>📤</span> Desde PostgreSQL → Google Sheets
                </h3>
                <div className="space-y-2">
                  <button
                    onClick={() => handleSyncToSheets(false)}
                    className="w-full flex items-center justify-between p-3 border-2 border-green-400 rounded-lg hover:bg-green-100 transition bg-white"
                  >
                    <div className="text-left">
                      <p className="font-semibold text-finly-text">Sincronización Normal</p>
                      <p className="text-xs text-finly-textSecondary">
                        Agrega solo transacciones nuevas a Sheets
                      </p>
                    </div>
                    <span className="text-2xl">⬆️</span>
                  </button>

                  {user.role === 'admin' && (
                    <button
                      onClick={() => {
                        setConfirmDialog({
                          isOpen: true,
                          title: 'Sincronización Forzada a Sheets',
                          message: 'Esto ELIMINARÁ todas las transacciones de Google Sheets y las recargará desde PostgreSQL.\n\n¿Estás seguro de continuar?',
                          onConfirm: () => handleSyncToSheets(true)
                        });
                      }}
                      className="w-full flex items-center justify-between p-3 border-2 border-red-400 rounded-lg hover:bg-red-50 transition bg-white"
                    >
                      <div className="text-left">
                        <p className="font-semibold text-red-700">Forzar Reemplazo Total</p>
                        <p className="text-xs text-red-600">
                          ⚠️ Reemplaza TODO en Sheets con datos de DB
                        </p>
                      </div>
                      <span className="text-2xl">🔥</span>
                    </button>
                  )}
                </div>
              </div>

              <button
                onClick={() => setShowSyncModal(false)}
                className="w-full p-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition font-semibold"
              >
                Cancelar
              </button>
            </div>
          </div>
        </div>
      )}

      <ConfirmDialog
        isOpen={confirmDialog.isOpen}
        onClose={() => setConfirmDialog({ ...confirmDialog, isOpen: false })}
        onConfirm={confirmDialog.onConfirm}
        title={confirmDialog.title}
        message={confirmDialog.message}
        type="danger"
        confirmText="Continuar"
      />
    </div>
  );
}

export default DashboardOverview;
