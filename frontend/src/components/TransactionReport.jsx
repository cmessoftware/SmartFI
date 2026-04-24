import { Chart as ChartJS, ArcElement, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend } from 'chart.js';
import { Pie, Bar } from 'react-chartjs-2';
import { useMemo, useState, useEffect } from 'react';
import ConfirmDialog from './ConfirmDialog';
import CSVImport from './CSVImport';
import { formatDate, toISODate } from '../utils/dateUtils';
import { exportToCsv } from '../utils/csvExport';
import { debtsAPI } from '../services/api';

ChartJS.register(ArcElement, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

const parseComparableDate = (value) => {
  const iso = toISODate(value);
  const date = new Date(`${iso}T00:00:00`);
  return Number.isNaN(date.getTime()) ? 0 : date.getTime();
};

function TransactionReport({ transactions, onEdit, onDelete, onBulkDelete, addMultipleTransactions, onGoToNewTransaction, canEdit = false, isAdmin = false }) {
  const chartColors = ['#6366F1', '#8B5CF6', '#EC4899', '#F59E0B', '#22C55E', '#3B82F6', '#EF4444'];
  const MONTH_NAMES = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
  const now = new Date();
  
  // Filtros y ordenamiento
  const [filterType, setFilterType] = useState('all');
  const [filterCategory, setFilterCategory] = useState('all');
  const [filterBudget, setFilterBudget] = useState('all'); // all, vinculado, no_vinculado, o debt_id específico
  const [filterMonth, setFilterMonth] = useState(new Date().getMonth() + 1); // 1-12, default mes actual
  const [filterYear, setFilterYear] = useState(new Date().getFullYear());
  const [sortBy, setSortBy] = useState('date');
  const [sortOrder, setSortOrder] = useState('desc');
  const [confirmDialog, setConfirmDialog] = useState({ isOpen: false, onConfirm: null, transaction: null });
  const [bulkConfirmDialogOpen, setBulkConfirmDialogOpen] = useState(false);
  const [selectedTransactionIds, setSelectedTransactionIds] = useState([]);
  const [isBulkDeleting, setIsBulkDeleting] = useState(false);
  const [showSelectedOnly, setShowSelectedOnly] = useState(false);
  const [debts, setDebts] = useState([]);
  const [filterDetail, setFilterDetail] = useState('');
  const [showCSVImport, setShowCSVImport] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);
  const PAGE_SIZE = 10;

  const handleSort = (field) => {
    if (sortBy === field) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(field);
      setSortOrder('desc');
    }
  };

  // Cargar presupuestos
  useEffect(() => {
    const loadDebts = async () => {
      try {
        const response = await debtsAPI.getDebts();
        setDebts(response.data || []);
      } catch (error) {
        console.error('Error al cargar presupuestos:', error);
      }
    };
    loadDebts();
  }, []);

  // Obtener categorías únicas
  const categories = useMemo(() => {
    const uniqueCategories = [...new Set(transactions.map(t => t.category))];
    return uniqueCategories.sort();
  }, [transactions]);

  // Aplicar filtros y ordenamiento
  const filteredAndSortedTransactions = useMemo(() => {
    let filtered = [...transactions];

    // Aplicar filtros
    if (filterType !== 'all') {
      filtered = filtered.filter(t => t.type === filterType);
    }
    if (filterCategory !== 'all') {
      filtered = filtered.filter(t => t.category === filterCategory);
    }
    // Filtro por mes
    filtered = filtered.filter(t => {
      const iso = toISODate(t.date);
      if (!iso) return false;
      const [year, month] = iso.split('-').map(Number);
      return year === filterYear && month === filterMonth;
    });

    // Filtro por detalle
    if (filterDetail.trim()) {
      const q = filterDetail.trim().toLowerCase();
      filtered = filtered.filter(t => (t.detail || '').toLowerCase().includes(q));
    }

    if (filterBudget === 'vinculado') {
      filtered = filtered.filter(t => t.debt_id !== null && t.debt_id !== undefined);
    } else if (filterBudget === 'no_vinculado') {
      filtered = filtered.filter(t => t.debt_id === null || t.debt_id === undefined);
    } else if (filterBudget !== 'all') {
      // Filtrar por debt_id específico
      const debtId = parseInt(filterBudget);
      filtered = filtered.filter(t => t.debt_id === debtId);
    }

    // Aplicar ordenamiento
    filtered.sort((a, b) => {
      let compareValue = 0;
      
      switch (sortBy) {
        case 'date':
          compareValue = parseComparableDate(a.date) - parseComparableDate(b.date);
          break;
        case 'type':
          compareValue = a.type.localeCompare(b.type);
          break;
        case 'category':
          compareValue = a.category.localeCompare(b.category);
          break;
        case 'amount':
          compareValue = (parseFloat(a.amount) || 0) - (parseFloat(b.amount) || 0);
          break;
        default:
          compareValue = 0;
      }

      return sortOrder === 'asc' ? compareValue : -compareValue;
    });

    return filtered;
  }, [transactions, filterType, filterCategory, filterDetail, filterBudget, filterMonth, filterYear, sortBy, sortOrder]);

  // Reset page when filters change
  useEffect(() => {
    setCurrentPage(1);
  }, [filterType, filterCategory, filterDetail, filterBudget, filterMonth, filterYear, sortBy, sortOrder, showSelectedOnly]);

  // Años disponibles para el filtro
  const availableYears = useMemo(() => {
    const years = new Set(transactions.map(t => {
      const iso = toISODate(t.date);
      return iso ? parseInt(iso.split('-')[0]) : null;
    }).filter(Boolean));
    years.add(new Date().getFullYear());
    return [...years].sort((a, b) => b - a);
  }, [transactions]);

  useEffect(() => {
    // Keep selection in sync with currently visible rows
    const visibleIds = new Set(filteredAndSortedTransactions.map((t) => t.id));
    setSelectedTransactionIds((prev) => prev.filter((id) => visibleIds.has(id)));
  }, [filteredAndSortedTransactions]);

  const handleEdit = (transaction) => {
    if (onEdit) {
      onEdit(transaction);
    }
  };

  const handleDelete = (transaction) => {
    if (onDelete) {
      setConfirmDialog({
        isOpen: true,
        transaction,
        onConfirm: () => {
          onDelete(transaction);
        }
      });
    }
  };

  const toggleTransactionSelection = (transactionId) => {
    setSelectedTransactionIds((prev) => {
      if (prev.includes(transactionId)) {
        return prev.filter((id) => id !== transactionId);
      }
      return [...prev, transactionId];
    });
  };

  const toggleSelectAllVisible = () => {
    const visibleIds = filteredAndSortedTransactions.map((t) => t.id);
    const allSelected = visibleIds.length > 0 && visibleIds.every((id) => selectedTransactionIds.includes(id));

    if (allSelected) {
      setSelectedTransactionIds((prev) => prev.filter((id) => !visibleIds.includes(id)));
      return;
    }

    setSelectedTransactionIds((prev) => {
      const merged = new Set([...prev, ...visibleIds]);
      return Array.from(merged);
    });
  };

  const handleBulkDeleteConfirm = async () => {
    if (!onBulkDelete || selectedTransactionIds.length === 0) {
      setBulkConfirmDialogOpen(false);
      return;
    }

    try {
      setIsBulkDeleting(true);
      await onBulkDelete(selectedTransactionIds);
      setSelectedTransactionIds([]);
    } finally {
      setIsBulkDeleting(false);
      setBulkConfirmDialogOpen(false);
    }
  };

  const categoryData = useMemo(() => {
    const gastos = filteredAndSortedTransactions.filter(t => t.type === 'Gasto');
    const grouped = gastos.reduce((acc, t) => {
      acc[t.category] = (acc[t.category] || 0) + (parseFloat(t.amount) || 0);
      return acc;
    }, {});

    return {
      labels: Object.keys(grouped),
      datasets: [{
        label: 'Gastos por Categoría',
        data: Object.values(grouped),
        backgroundColor: chartColors,
        borderWidth: 2,
        borderColor: '#fff'
      }]
    };
  }, [filteredAndSortedTransactions]);

  const presupuestoVsAsignadoData = useMemo(() => {
    // Filtrar presupuestos por mes/año seleccionado
    const filteredDebts = debts.filter(debt => {
      const iso = toISODate(debt.fecha_vencimiento || debt.fecha);
      if (!iso) return false;
      const [year, month] = iso.split('-').map(Number);
      return year === filterYear && month === filterMonth;
    });

    // Agrupar presupuestos por categoría
    const categoriaGroups = filteredDebts.reduce((acc, debt) => {
      const cat = debt.categoria || 'Sin categoría';
      if (!acc[cat]) {
        acc[cat] = {
          presupuestado: 0,
          asignado: 0
        };
      }
      acc[cat].presupuestado += Number(debt.monto_total || 0);
      acc[cat].asignado += Number(debt.monto_ejecutado || 0);
      return acc;
    }, {});

    const categorias = Object.keys(categoriaGroups).sort();
    const coloresAleatorios = ['#6366F1', '#8B5CF6', '#EC4899', '#F59E0B', '#10B981', '#3B82F6', '#EF4444', '#8B5CF6'];

    return {
      labels: categorias,
      datasets: [
        {
          label: 'Presupuestado',
          data: categorias.map(cat => categoriaGroups[cat].presupuestado),
          backgroundColor: categorias.map((_, idx) => coloresAleatorios[idx % coloresAleatorios.length]),
          borderWidth: 1,
          borderColor: '#fff'
        },
        {
          label: 'Asignado',
          data: categorias.map(cat => categoriaGroups[cat].asignado),
          backgroundColor: categorias.map(cat => {
            const { presupuestado, asignado } = categoriaGroups[cat];
            return asignado <= presupuestado ? '#10B981' : '#EF4444'; // Verde si dentro, rojo si se pasó
          }),
          borderWidth: 1,
          borderColor: '#fff'
        }
      ]
    };
  }, [debts, filterMonth, filterYear]);

  const stats = useMemo(() => {
    const ingresos = filteredAndSortedTransactions
      .filter(t => t.type === 'Ingreso')
      .reduce((sum, t) => sum + (parseFloat(t.amount) || 0), 0);
    const gastos = filteredAndSortedTransactions
      .filter(t => t.type === 'Gasto')
      .reduce((sum, t) => sum + (parseFloat(t.amount) || 0), 0);
    const balance = ingresos - gastos;

    return { ingresos, gastos, balance };
  }, [filteredAndSortedTransactions]);

  const handleExportCsv = () => {
    const debtMap = new Map((debts || []).map((d) => [d.id, d]));
    const rows = filteredAndSortedTransactions.map((t) => {
      const linkedDebt = t.debt_id ? debtMap.get(t.debt_id) : null;
      return {
        date: formatDate(t.date),
        type: t.type,
        category: t.category,
        amount: parseFloat(t.amount) || 0,
        necessity: t.necessity || '',
        payment_method: t.payment_method || '',
        detail: t.detail || '',
        debt_id: t.debt_id ?? '',
        presupuesto: linkedDebt?.detalle || ''
      };
    });

    const exported = exportToCsv({
      filename: `reporte_transacciones_${new Date().toISOString().split('T')[0]}.csv`,
      headers: ['date', 'type', 'category', 'amount', 'necessity', 'payment_method', 'detail', 'debt_id', 'presupuesto'],
      rows
    });

    if (!exported) {
      console.warn('No hay datos para exportar');
    }
  };

  const allDisplayedTransactions = useMemo(() => {
    if (!showSelectedOnly) return filteredAndSortedTransactions;
    return filteredAndSortedTransactions.filter((t) => selectedTransactionIds.includes(t.id));
  }, [filteredAndSortedTransactions, selectedTransactionIds, showSelectedOnly]);

  const totalPages = Math.max(1, Math.ceil(allDisplayedTransactions.length / PAGE_SIZE));
  const displayedTransactions = useMemo(() => {
    const start = (currentPage - 1) * PAGE_SIZE;
    return allDisplayedTransactions.slice(start, start + PAGE_SIZE);
  }, [allDisplayedTransactions, currentPage]);

  const visibleIds = displayedTransactions.map((t) => t.id);
  const allVisibleSelected = visibleIds.length > 0 && visibleIds.every((id) => selectedTransactionIds.includes(id));

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-finly-text">Reportes</h2>

      {/* Selector de Mes con navegación */}
      <div className="bg-white rounded-xl shadow-md p-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <button
            onClick={() => {
              if (filterMonth === 1) {
                setFilterMonth(12);
                setFilterYear(prev => prev - 1);
              } else {
                setFilterMonth(prev => prev - 1);
              }
            }}
            className="p-2 rounded-lg hover:bg-gray-100 transition text-lg"
          >
            ◀
          </button>
          <div className="flex items-center gap-2">
            <select
              value={filterMonth}
              onChange={(e) => setFilterMonth(parseInt(e.target.value))}
              className="px-3 py-2 border border-gray-200 rounded-lg text-finly-text font-semibold focus:ring-2 focus:ring-finly-primary focus:outline-none"
            >
              {MONTH_NAMES.map((name, idx) => (
                <option key={idx + 1} value={idx + 1}>{name}</option>
              ))}
            </select>
            <select
              value={filterYear}
              onChange={(e) => setFilterYear(parseInt(e.target.value))}
              className="px-3 py-2 border border-gray-200 rounded-lg text-finly-text font-semibold focus:ring-2 focus:ring-finly-primary focus:outline-none"
            >
              {availableYears.map(y => (
                <option key={y} value={y}>{y}</option>
              ))}
            </select>
          </div>
          <button
            onClick={() => {
              if (filterMonth === 12) {
                setFilterMonth(1);
                setFilterYear(prev => prev + 1);
              } else {
                setFilterMonth(prev => prev + 1);
              }
            }}
            className="p-2 rounded-lg hover:bg-gray-100 transition text-lg"
          >
            ▶
          </button>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-lg font-bold text-finly-text">
            📅 {MONTH_NAMES[filterMonth - 1]} {filterYear}
          </span>
          {(filterMonth !== now.getMonth() + 1 || filterYear !== now.getFullYear()) && (
            <button
              onClick={() => { setFilterMonth(now.getMonth() + 1); setFilterYear(now.getFullYear()); }}
              className="text-xs px-3 py-1 bg-finly-primary text-white rounded-full hover:bg-finly-primaryHover transition"
            >
              Hoy
            </button>
          )}
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white rounded-xl shadow-md p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-finly-textSecondary">Ingresos</p>
              <p className="text-3xl font-bold text-finly-income mt-2">
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
              <p className="text-3xl font-bold text-finly-expense mt-2">
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
              <p className={`text-3xl font-bold mt-2 ${
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
      </div>

      {/* Charts */}
      {transactions.length > 0 ? (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white rounded-xl shadow-md p-6">
            <h3 className="text-lg font-bold text-finly-text mb-4">
              Gastos por Categoría
            </h3>
            <div className="h-80 flex items-center justify-center">
              <Pie 
                data={categoryData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: {
                      position: 'bottom',
                    }
                  }
                }}
              />
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-md p-6">
            <h3 className="text-lg font-bold text-finly-text mb-4">
              📊 Presupuestado vs Asignado por Categoría
            </h3>
            <div className="h-80">
              <Bar 
                data={presupuestoVsAsignadoData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: {
                      display: true,
                      position: 'top'
                    },
                    tooltip: {
                      callbacks: {
                        label: function(context) {
                          const label = context.dataset.label || '';
                          const value = context.parsed.y || 0;
                          return label + ': $' + value.toLocaleString('es-AR');
                        }
                      }
                    }
                  },
                  scales: {
                    y: {
                      beginAtZero: true,
                      ticks: {
                        callback: function(value) {
                          return '$' + value.toLocaleString('es-AR');
                        }
                      }
                    }
                  }
                }}
              />
            </div>
          </div>
        </div>
      ) : (
        <div className="bg-white rounded-xl shadow-md p-12 text-center">
          <p className="text-finly-textSecondary text-lg">
            No hay transacciones para mostrar. Agrega algunas transacciones para ver los reportes.
          </p>
        </div>
      )}

      {/* Transaction List */}
      {transactions.length > 0 && (
        <div className="bg-white rounded-xl shadow-md p-6">
          <div className="flex flex-wrap justify-between items-center gap-3 mb-6">
            <div className="flex flex-wrap items-center gap-3">
              {canEdit && onGoToNewTransaction && (
                <button
                  onClick={onGoToNewTransaction}
                  className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
                >
                  + Nuevo Item
                </button>
              )}
              {canEdit && addMultipleTransactions && (
                <button
                  onClick={() => setShowCSVImport(v => !v)}
                  className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-colors flex items-center space-x-2"
                >
                  <span>📥</span>
                  <span>{showCSVImport ? 'Cerrar Importar' : 'Importar CSV'}</span>
                </button>
              )}
              <button
                onClick={handleExportCsv}
                disabled={filteredAndSortedTransactions.length === 0}
                className="bg-emerald-600 text-white px-4 py-2 rounded-lg hover:bg-emerald-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center space-x-2"
              >
                <span>📤</span>
                <span>Exportar CSV</span>
              </button>
              {canEdit && (
                <label className="text-sm text-gray-600 inline-flex items-center gap-2 px-2">
                  <input
                    type="checkbox"
                    checked={showSelectedOnly}
                    onChange={(e) => setShowSelectedOnly(e.target.checked)}
                  />
                  Mostrar solo seleccionadas
                </label>
              )}
              {canEdit && (
                <button
                  onClick={() => setBulkConfirmDialogOpen(true)}
                  disabled={selectedTransactionIds.length === 0 || isBulkDeleting}
                  className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  Eliminar seleccionadas ({selectedTransactionIds.length})
                </button>
              )}
              <button
                onClick={() => {
                  setFilterType('all');
                  setFilterCategory('all');
                  setFilterBudget('all');
                  setFilterDetail('');
                  setFilterMonth(new Date().getMonth() + 1);
                  setFilterYear(new Date().getFullYear());
                  setSortBy('date');
                  setSortOrder('desc');
                  setCurrentPage(1);
                }}
                className="text-sm text-finly-primary hover:text-finly-secondary font-semibold transition"
              >
                Limpiar Filtros
              </button>
            </div>
            <span className="text-lg font-bold text-finly-text">
              Transacciones ({allDisplayedTransactions.length})
            </span>
          </div>
          {/* Importación CSV inline */}
          {showCSVImport && (
            <div className="bg-gray-50 rounded-lg p-4 mb-6">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold">Importar Transacciones desde CSV</h3>
                <button
                  onClick={() => setShowCSVImport(false)}
                  className="text-gray-600 hover:text-gray-800"
                >
                  ✕ Cerrar
                </button>
              </div>
              <CSVImport addMultipleTransactions={addMultipleTransactions} />
            </div>
          )}

          {/* Filtros y Ordenamiento */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mb-6 p-4 bg-gray-50 rounded-lg">
            {/* Filtro por Tipo */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Filtrar por Tipo
              </label>
              <select
                value={filterType}
                onChange={(e) => setFilterType(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary text-sm"
              >
                <option value="all">Todos</option>
                <option value="Ingreso">Ingresos</option>
                <option value="Gasto">Gastos</option>
              </select>
            </div>

            {/* Filtro por Categoría */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Filtrar por Categoría
              </label>
              <select
                value={filterCategory}
                onChange={(e) => setFilterCategory(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary text-sm"
              >
                <option value="all">Todas</option>
                {categories.map(cat => (
                  <option key={cat} value={cat}>{cat}</option>
                ))}
              </select>
            </div>

            {/* Filtro por Presupuesto */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Presupuesto
              </label>
              <select
                value={filterBudget}
                onChange={(e) => setFilterBudget(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary text-sm"
              >
                <option value="all">Todas</option>
                <option value="vinculado">📊 Vinculadas</option>
                <option value="no_vinculado">⭕ No vinculadas</option>
                {debts.length > 0 && (
                  <optgroup label="Por Presupuesto">
                    {debts.map(debt => (
                      <option key={debt.id} value={debt.id}>
                        {debt.detalle} - ${debt.monto_total.toLocaleString('es-AR')}
                      </option>
                    ))}
                  </optgroup>
                )}
              </select>
            </div>

            {/* Filtro por Detalle */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Detalle
              </label>
              <input
                type="text"
                value={filterDetail}
                onChange={(e) => setFilterDetail(e.target.value)}
                placeholder="Buscar texto"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary text-sm"
              />
            </div>

            {/* Ordenar por */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Ordenar por
              </label>
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary text-sm"
              >
                <option value="date">Fecha</option>
                <option value="type">Tipo</option>
                <option value="category">Categoría</option>
                <option value="amount">Monto</option>
              </select>
            </div>

            {/* Orden */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Orden
              </label>
              <select
                value={sortOrder}
                onChange={(e) => setSortOrder(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary text-sm"
              >
                <option value="desc">
                  {sortBy === 'date' ? 'Más reciente primero' : 
                   sortBy === 'amount' ? 'Mayor a menor' : 
                   'Z a A'}
                </option>
                <option value="asc">
                  {sortBy === 'date' ? 'Más antiguo primero' : 
                   sortBy === 'amount' ? 'Menor a mayor' : 
                   'A a Z'}
                </option>
              </select>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200">
                  {canEdit && (
                    <th className="text-center py-3 px-4 text-sm font-semibold text-finly-text w-12">
                      <input
                        type="checkbox"
                        checked={allVisibleSelected}
                        onChange={toggleSelectAllVisible}
                        aria-label="Seleccionar todas las transacciones visibles"
                      />
                    </th>
                  )}
                  <th 
                    className="text-left py-3 px-4 text-sm font-semibold text-finly-text cursor-pointer hover:bg-gray-100 select-none"
                    onClick={() => handleSort('date')}
                    title="Ordenar por fecha"
                  >
                    <div className="flex items-center gap-1">
                      <span>Fecha</span>
                      {sortBy === 'date' && (
                        <span className="text-blue-600">
                          {sortOrder === 'asc' ? '↑' : '↓'}
                        </span>
                      )}
                    </div>
                  </th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Tipo</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Categoría</th>
                  <th className="text-right py-3 px-4 text-sm font-semibold text-finly-text">Monto</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Detalle</th>
                  <th className="text-center py-3 px-4 text-sm font-semibold text-finly-text">Presupuesto</th>
                  {canEdit && <th className="text-center py-3 px-4 text-sm font-semibold text-finly-text">Acciones</th>}
                </tr>
              </thead>
              <tbody>
                {displayedTransactions.map((t, idx) => (
                  <tr key={t.id || idx} className="border-b border-gray-100 hover:bg-gray-50">
                    {canEdit && (
                      <td className="py-3 px-4 text-center">
                        <input
                          type="checkbox"
                          checked={selectedTransactionIds.includes(t.id)}
                          onChange={() => toggleTransactionSelection(t.id)}
                          aria-label={`Seleccionar transacción ${t.id}`}
                        />
                      </td>
                    )}
                    <td className="py-3 px-4 text-sm text-finly-text">{formatDate(t.date)}</td>
                    <td className="py-3 px-4">
                      <span className={`inline-block px-2 py-1 rounded text-xs font-semibold ${
                        t.type === 'Ingreso' 
                          ? 'bg-green-100 text-green-700' 
                          : 'bg-red-100 text-red-700'
                      }`}>
                        {t.type}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-sm text-finly-text">{t.category}</td>
                    <td className={`py-3 px-4 text-sm text-right font-semibold ${
                      t.type === 'Ingreso' ? 'text-finly-income' : 'text-finly-expense'
                    }`}>
                      ${(parseFloat(t.amount) || 0).toLocaleString('es-AR', { minimumFractionDigits: 2 })}
                    </td>
                    <td className="py-3 px-4 text-sm text-finly-textSecondary">{t.detail || '-'}</td>
                    <td className="py-3 px-4 text-center">
                      {t.debt_id ? (
                        <span className="inline-block px-2 py-1 rounded text-xs font-semibold bg-purple-100 text-purple-700" title={`Vinculado a presupuesto ID: ${t.debt_id}`}>
                          📊 Vinculado
                        </span>
                      ) : (
                        <span className="text-gray-400 text-xs">-</span>
                      )}
                    </td>
                    {canEdit && (
                      <td className="py-3 px-4 text-center">
                        <div className="flex justify-center gap-2">
                          <button
                            onClick={() => handleEdit(t)}
                            className="text-finly-primary hover:text-finly-secondary p-1.5 rounded hover:bg-finly-primary/10 transition-colors"
                            title="Editar transacción"
                          >
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                              <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
                            </svg>
                          </button>
                          <button
                            onClick={() => handleDelete(t)}
                            className="text-red-600 hover:text-red-700 p-1.5 rounded hover:bg-red-50 transition-colors"
                            title="Eliminar transacción"
                          >
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                              <path fillRule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clipRule="evenodd" />
                            </svg>
                          </button>
                        </div>
                      </td>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Paginación */}
          {totalPages > 1 && (
            <div className="flex items-center justify-between mt-4 pt-4 border-t border-gray-200">
              <p className="text-sm text-finly-textSecondary">
                Mostrando {(currentPage - 1) * PAGE_SIZE + 1}-{Math.min(currentPage * PAGE_SIZE, allDisplayedTransactions.length)} de {allDisplayedTransactions.length}
              </p>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
                  disabled={currentPage === 1}
                  className="px-3 py-1 text-sm border border-gray-300 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition"
                >
                  ← Anterior
                </button>
                {Array.from({ length: totalPages }, (_, i) => i + 1)
                  .filter(page => page === 1 || page === totalPages || Math.abs(page - currentPage) <= 2)
                  .reduce((acc, page, idx, arr) => {
                    if (idx > 0 && page - arr[idx - 1] > 1) {
                      acc.push(<span key={`dots-${page}`} className="text-gray-400 text-sm">...</span>);
                    }
                    acc.push(
                      <button
                        key={page}
                        onClick={() => setCurrentPage(page)}
                        className={`px-3 py-1 text-sm rounded-lg transition ${
                          page === currentPage
                            ? 'bg-finly-primary text-white'
                            : 'border border-gray-300 hover:bg-gray-100'
                        }`}
                      >
                        {page}
                      </button>
                    );
                    return acc;
                  }, [])}
                <button
                  onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
                  disabled={currentPage === totalPages}
                  className="px-3 py-1 text-sm border border-gray-300 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed transition"
                >
                  Siguiente →
                </button>
              </div>
            </div>
          )}
        </div>
      )}

      <ConfirmDialog
        isOpen={confirmDialog.isOpen}
        onClose={() => setConfirmDialog({ ...confirmDialog, isOpen: false })}
        onConfirm={confirmDialog.onConfirm}
        title="Eliminar Transacción"
        message={confirmDialog.transaction ? 
          `¿Estás seguro de eliminar esta transacción?\n\nFecha: ${formatDate(confirmDialog.transaction.date)}\nMonto: $${confirmDialog.transaction.amount}\nDetalle: ${confirmDialog.transaction.detail || 'Sin detalle'}` 
          : ''
        }
        type="danger"
        confirmText="Eliminar"
      />

      <ConfirmDialog
        isOpen={bulkConfirmDialogOpen}
        onClose={() => {
          if (!isBulkDeleting) {
            setBulkConfirmDialogOpen(false);
          }
        }}
        onConfirm={handleBulkDeleteConfirm}
        title="Eliminar Transacciones Seleccionadas"
        message={`¿Estás seguro de eliminar ${selectedTransactionIds.length} transacción(es) seleccionada(s)?`}
        type="danger"
        confirmText={isBulkDeleting ? 'Eliminando...' : 'Eliminar seleccionadas'}
      />
    </div>
  );
}

export default TransactionReport;
