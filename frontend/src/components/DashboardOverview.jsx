import { useMemo, useState, useEffect } from 'react';
import { useToast } from './ToastContainer';
import ConfirmDialog from './ConfirmDialog';
import { transactionsAPI, debtsAPI, creditCardAPI, monthClosingAPI } from '../services/api';
import { formatDate, toISODate } from '../utils/dateUtils';

const MONTH_NAMES = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
];

function DashboardOverview({ transactions, user, refreshTransactions, loading, setCurrentView }) {
  const now = new Date();
  const [selectedMonth, setSelectedMonth] = useState(now.getMonth() + 1);
  const [selectedYear, setSelectedYear] = useState(now.getFullYear());
  const [showSyncModal, setShowSyncModal] = useState(false);
  const [syncStats, setSyncStats] = useState(null);
  const [loadingStats, setLoadingStats] = useState(false);
  const [confirmDialog, setConfirmDialog] = useState({ isOpen: false, onConfirm: null, title: '', message: '' });
  const [debtSummary, setDebtSummary] = useState(null);
  const [ccPurchasesTotal, setCcPurchasesTotal] = useState(0);
  const [monthClosingStatus, setMonthClosingStatus] = useState(null);
  const [closingLoading, setClosingLoading] = useState(false);
  const toast = useToast();

  // Filtrar transacciones por mes/año seleccionado
  const filteredTransactions = useMemo(() => {
    return transactions.filter(t => {
      const iso = toISODate(t.date);
      if (!iso) return false;
      const [year, month] = iso.split('-').map(Number);
      return year === selectedYear && month === selectedMonth;
    });
  }, [transactions, selectedMonth, selectedYear]);

  // Cargar resumen de presupuesto filtrado por mes
  useEffect(() => {
    const loadDebtSummary = async () => {
      try {
        const response = await debtsAPI.getDebtSummary(selectedMonth, selectedYear);
        setDebtSummary(response.data);
      } catch (error) {
        console.error('Error al cargar resumen de presupuesto:', error);
      }
    };
    loadDebtSummary();
  }, [transactions, selectedMonth, selectedYear]);

  // Cargar total de compras de tarjeta de crédito del mes
  useEffect(() => {
    const loadCcPurchasesTotal = async () => {
      try {
        const response = await creditCardAPI.getMonthlyPurchasesTotal(selectedMonth, selectedYear);
        setCcPurchasesTotal(response.data.total || 0);
      } catch (error) {
        console.error('Error al cargar total de compras TC:', error);
        setCcPurchasesTotal(0);
      }
    };
    loadCcPurchasesTotal();
  }, [selectedMonth, selectedYear]);

  // Load month closing status
  useEffect(() => {
    const loadClosingStatus = async () => {
      try {
        const response = await monthClosingAPI.getStatus(selectedYear, selectedMonth);
        setMonthClosingStatus(response.data);
      } catch (error) {
        console.error('Error al cargar estado de cierre:', error);
        setMonthClosingStatus(null);
      }
    };
    loadClosingStatus();
  }, [selectedMonth, selectedYear]);

  const handleCloseMonth = async () => {
    setClosingLoading(true);
    try {
      const response = await monthClosingAPI.closeMonth(selectedYear, selectedMonth);
      setMonthClosingStatus({ closed: true, ...response.data });
      toast.success(
        `Mes cerrado. Balance: $${response.data.balance.toLocaleString('es-AR', { minimumFractionDigits: 2 })}. ` +
        (response.data.balance !== 0 ? 'Se creó transacción de arrastre en el mes siguiente.' : '')
      , 7000);
      await refreshTransactions(false);
    } catch (error) {
      const detail = error.response?.data?.detail || 'Error al cerrar el mes';
      toast.error(detail);
    } finally {
      setClosingLoading(false);
    }
  };

  const handleReopenMonth = async () => {
    setClosingLoading(true);
    try {
      await monthClosingAPI.reopenMonth(selectedYear, selectedMonth);
      setMonthClosingStatus({ closed: false });
      toast.success('Mes reabierto. La transacción de arrastre fue eliminada.');
      await refreshTransactions(false);
    } catch (error) {
      const detail = error.response?.data?.detail || 'Error al reabrir el mes';
      toast.error(detail);
    } finally {
      setClosingLoading(false);
    }
  };

  const handleOpenSyncModal = async () => {
    setShowSyncModal(true);
    if ((user.roles || []).includes('ADMIN')) {
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
    const ingresos = filteredTransactions
      .filter(t => t.type === 'Ingreso')
      .reduce((sum, t) => sum + (parseFloat(t.amount) || 0), 0);
    const gastos = filteredTransactions
      .filter(t => t.type === 'Gasto')
      .reduce((sum, t) => sum + (parseFloat(t.amount) || 0), 0);
    
    // Gastos reales = gastos en transacciones + compras de tarjeta no vinculadas
    const gastosReales = gastos + ccPurchasesTotal;
    const balance = ingresos - gastosReales;
    const totalTransacciones = filteredTransactions.length;

    // Balance Pendiente Obligatorio = Ingresos - (Gastos Reales + Presupuesto Obligatorio Pendiente)
    const obligationPending = debtSummary?.obligation_pending || 0;
    const balancePendienteObligatorio = ingresos - (gastosReales + obligationPending);

    // Balance Pendiente Variable = Ingresos - (Gastos Reales + Presupuesto Variable Pendiente)
    const variablePending = debtSummary?.variable_pending || 0;
    const balancePendienteVariable = ingresos - (gastosReales + variablePending);

    return { 
      ingresos, 
      gastos: gastosReales,
      gastosTxn: gastos,
      gastosTarjeta: ccPurchasesTotal,
      balance, 
      totalTransacciones, 
      obligationPending,
      variablePending,
      balancePendienteObligatorio, 
      balancePendienteVariable 
    };
  }, [filteredTransactions, debtSummary, ccPurchasesTotal]);

  const recentTransactions = useMemo(() => {
    return filteredTransactions.slice(-5).reverse();
  }, [filteredTransactions]);

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-finly-text">
            Bienvenido, {user.first_name || user.username}
          </h1>
          <p className="text-finly-textSecondary mt-2 flex items-center gap-2">
            Panel de control de finanzas personales
            <span className="text-xs bg-green-100 text-green-700 px-2 py-1 rounded-full flex items-center gap-1">
              📊 PostgreSQL + Sheets Sync
            </span>
          </p>
        </div>
        <div className="flex items-center gap-4">
          {(user.roles || []).includes('ADMIN') && (
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
        </div>
      </div>

      {/* Month/Year Selector */}
      <div className="bg-white rounded-xl shadow-md p-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <button
            onClick={() => {
              if (selectedMonth === 1) {
                setSelectedMonth(12);
                setSelectedYear(prev => prev - 1);
              } else {
                setSelectedMonth(prev => prev - 1);
              }
            }}
            className="p-2 rounded-lg hover:bg-gray-100 transition text-lg"
          >
            ◀
          </button>
          <div className="flex items-center gap-2">
            <select
              value={selectedMonth}
              onChange={(e) => setSelectedMonth(parseInt(e.target.value))}
              className="px-3 py-2 border border-gray-200 rounded-lg text-finly-text font-semibold focus:ring-2 focus:ring-finly-primary focus:outline-none"
            >
              {MONTH_NAMES.map((name, idx) => (
                <option key={idx + 1} value={idx + 1}>{name}</option>
              ))}
            </select>
            <select
              value={selectedYear}
              onChange={(e) => setSelectedYear(parseInt(e.target.value))}
              className="px-3 py-2 border border-gray-200 rounded-lg text-finly-text font-semibold focus:ring-2 focus:ring-finly-primary focus:outline-none"
            >
              {Array.from({ length: 5 }, (_, i) => now.getFullYear() - 2 + i).map(y => (
                <option key={y} value={y}>{y}</option>
              ))}
            </select>
          </div>
          <button
            onClick={() => {
              if (selectedMonth === 12) {
                setSelectedMonth(1);
                setSelectedYear(prev => prev + 1);
              } else {
                setSelectedMonth(prev => prev + 1);
              }
            }}
            className="p-2 rounded-lg hover:bg-gray-100 transition text-lg"
          >
            ▶
          </button>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-lg font-bold text-finly-text">
            📅 {MONTH_NAMES[selectedMonth - 1]} {selectedYear}
          </span>
          {monthClosingStatus?.closed && !monthClosingStatus?.is_stale && (
            <span className="text-xs px-3 py-1 bg-green-100 text-green-700 rounded-full font-semibold">
              ✅ Mes Cerrado
            </span>
          )}
          {monthClosingStatus?.closed && monthClosingStatus?.is_stale && (
            <span className="text-xs px-3 py-1 bg-amber-100 text-amber-700 rounded-full font-semibold">
              ⚠️ Cierre desactualizado
            </span>
          )}
          {(selectedMonth !== now.getMonth() + 1 || selectedYear !== now.getFullYear()) && (
            <button
              onClick={() => { setSelectedMonth(now.getMonth() + 1); setSelectedYear(now.getFullYear()); }}
              className="text-xs px-3 py-1 bg-finly-primary text-white rounded-full hover:bg-finly-primaryHover transition"
            >
              Hoy
            </button>
          )}
          {(user.roles || []).includes('ADMIN') && (
            monthClosingStatus?.closed ? (
              <>
                {monthClosingStatus?.is_stale && (
                  <button
                    onClick={() => setConfirmDialog({
                      isOpen: true,
                      title: 'Re-cerrar Mes',
                      message: `Hubo cambios desde el último cierre. ¿Re-cerrar ${MONTH_NAMES[selectedMonth - 1]} ${selectedYear}? Se recalculará el balance y actualizará la transacción de arrastre.`,
                      onConfirm: handleCloseMonth
                    })}
                    disabled={closingLoading}
                    className="text-xs px-3 py-1 bg-amber-600 text-white rounded-full hover:bg-amber-700 transition disabled:opacity-50"
                  >
                    {closingLoading ? '...' : '🔄 Re-cerrar Mes'}
                  </button>
                )}
                <button
                  onClick={() => setConfirmDialog({
                    isOpen: true,
                    title: 'Reabrir Mes',
                    message: `¿Reabrir ${MONTH_NAMES[selectedMonth - 1]} ${selectedYear}? Se eliminará la transacción de arrastre al mes siguiente.`,
                    onConfirm: handleReopenMonth
                  })}
                  disabled={closingLoading}
                  className="text-xs px-3 py-1 bg-yellow-500 text-white rounded-full hover:bg-yellow-600 transition disabled:opacity-50"
                >
                  {closingLoading ? '...' : '🔓 Reabrir Mes'}
                </button>
              </>
            ) : (
              <button
                onClick={() => setConfirmDialog({
                  isOpen: true,
                  title: 'Cerrar Mes',
                  message: `¿Cerrar ${MONTH_NAMES[selectedMonth - 1]} ${selectedYear}? El balance se trasladará como "Saldo mes anterior" al mes siguiente.`,
                  onConfirm: handleCloseMonth
                })}
                disabled={closingLoading}
                className="text-xs px-3 py-1 bg-emerald-600 text-white rounded-full hover:bg-emerald-700 transition disabled:opacity-50"
              >
                {closingLoading ? '...' : '🔒 Cerrar Mes'}
              </button>
            )
          )}
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
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
              {stats.gastosTarjeta > 0 && (
                <div className="mt-1 text-xs text-finly-textSecondary">
                  <span>💳 TC: ${stats.gastosTarjeta.toLocaleString('es-AR', { minimumFractionDigits: 0 })}</span>
                  <span className="mx-1">|</span>
                  <span>💵 Otros: ${stats.gastosTxn.toLocaleString('es-AR', { minimumFractionDigits: 0 })}</span>
                </div>
              )}
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
              <p className="text-xs text-finly-textSecondary">Balance Pendiente</p>
              <p className="text-xs font-semibold text-finly-text">Obligatorio</p>
              <p className={`text-xl font-bold mt-1 ${
                stats.balancePendienteObligatorio >= 0 ? 'text-finly-income' : 'text-finly-expense'
              }`}>
                ${stats.balancePendienteObligatorio.toLocaleString('es-AR', { minimumFractionDigits: 2 })}
              </p>
            </div>
            <div className={`w-10 h-10 rounded-full flex items-center justify-center text-xl ${
              stats.balancePendienteObligatorio >= 0 ? 'bg-purple-100' : 'bg-red-100'
            }`}>
              🎯
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-md p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-xs text-finly-textSecondary">Balance Pendiente</p>
              <p className="text-xs font-semibold text-finly-text">Variable</p>
              <p className={`text-xl font-bold mt-1 ${
                stats.balancePendienteVariable >= 0 ? 'text-finly-income' : 'text-finly-expense'
              }`}>
                ${stats.balancePendienteVariable.toLocaleString('es-AR', { minimumFractionDigits: 2 })}
              </p>
            </div>
            <div className={`w-10 h-10 rounded-full flex items-center justify-center text-xl ${
              stats.balancePendienteVariable >= 0 ? 'bg-teal-100' : 'bg-yellow-100'
            }`}>
              📊
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
            <div className="w-12 h-12 bg-indigo-100 rounded-full flex items-center justify-center text-2xl">
              📋
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
                    t.type === 'Ingreso' ? 'bg-green-100' : 'bg-red-100'
                  }`}>
                    {t.type === 'Ingreso' ? '📈' : '📉'}
                  </div>
                  <div>
                    <p className="font-semibold text-finly-text">{t.category}</p>
                    <p className="text-sm text-finly-textSecondary">
                      {t.detail || 'Sin detalle'} • {formatDate(t.date)}
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <p className={`text-lg font-bold ${
                    t.type === 'Ingreso' ? 'text-finly-income' : 'text-finly-expense'
                  }`}>
                    {t.type === 'Ingreso' ? '+' : '-'}${(parseFloat(t.amount) || 0).toLocaleString('es-AR', { minimumFractionDigits: 2 })}
                  </p>
                  <span className={`inline-block px-2 py-1 rounded text-xs font-semibold ${
                    t.type === 'Ingreso' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                  }`}>
                    {t.type}
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

                  {(user.roles || []).includes('ADMIN') && (
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

                  {(user.roles || []).includes('ADMIN') && (
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
