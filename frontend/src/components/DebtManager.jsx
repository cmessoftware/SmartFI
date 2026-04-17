import { useState, useEffect, useMemo } from 'react';
import { Chart as ChartJS, ArcElement, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend } from 'chart.js';
import { Pie, Bar } from 'react-chartjs-2';
import { debtsAPI, transactionsAPI } from '../services/api';
import { useToast } from './ToastContainer';
import ConfirmDialog from './ConfirmDialog';
import { formatDate, toISODate } from '../utils/dateUtils';
import { exportToCsv } from '../utils/csvExport';
import BudgetCSVImport from './BudgetCSVImport';
import EditDebtModal from './EditDebtModal';
import NewDebtModal from './NewDebtModal';

ChartJS.register(ArcElement, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

const MONTH_NAMES = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
];

export default function DebtManager({ canEdit, isAdmin = false }) {
  const now = new Date();
  const chartColors = ['#6366F1', '#8B5CF6', '#EC4899', '#F59E0B', '#22C55E', '#3B82F6', '#EF4444'];
  const [debts, setDebts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [summary, setSummary] = useState(null);
  const [newModalOpen, setNewModalOpen] = useState(false);
  const [showCSVImport, setShowCSVImport] = useState(false);
  const [showCloneMonth, setShowCloneMonth] = useState(false);
  const [cloneSourceMonth, setCloneSourceMonth] = useState(new Date().getMonth() + 1);
  const [cloneSourceYear, setCloneSourceYear] = useState(new Date().getFullYear());
  const [isCloning, setIsCloning] = useState(false);
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [debtToEdit, setDebtToEdit] = useState(null);
  const [deleteDialog, setDeleteDialog] = useState({ isOpen: false, debtId: null, debtName: '' });
  const [bulkDeleteDialogOpen, setBulkDeleteDialogOpen] = useState(false);
  const [selectedDebtIds, setSelectedDebtIds] = useState([]);
  const [isBulkDeleting, setIsBulkDeleting] = useState(false);
  const [showSelectedOnly, setShowSelectedOnly] = useState(false);
  const [filterFechaDesde, setFilterFechaDesde] = useState('');
  const [filterFechaHasta, setFilterFechaHasta] = useState('');
  const [filterTipo, setFilterTipo] = useState('all');
  const [filterCategoria, setFilterCategoria] = useState('all');
  const [filterTipoPresupuesto, setFilterTipoPresupuesto] = useState('all');
  const [filterDetalle, setFilterDetalle] = useState('');
  const [filterMontoMin, setFilterMontoMin] = useState('');
  const [filterMontoMax, setFilterMontoMax] = useState('');
  const [filterMonth, setFilterMonth] = useState(now.getMonth() + 1);
  const [filterYear, setFilterYear] = useState(now.getFullYear());
  const [sortField, setSortField] = useState('fecha');
  const [sortDirection, setSortDirection] = useState('desc');
  const [currentPage, setCurrentPage] = useState(1);
  const PAGE_SIZE = 10;
  const toast = useToast();

  // Cargar deudas y resumen
  useEffect(() => {
    loadDebts();
    loadSummary();
    loadCategories();
  }, []);

  // Recargar summary cuando cambia el mes/año
  useEffect(() => {
    loadSummary(filterMonth, filterYear);
  }, [filterMonth, filterYear]);

  useEffect(() => {
    const existingIds = new Set(debts.map((debt) => debt.id));
    setSelectedDebtIds((prev) => prev.filter((id) => existingIds.has(id)));
  }, [debts]);

  const loadDebts = async () => {
    try {
      const response = await debtsAPI.getDebts();
      setDebts(response.data || []);
    } catch (error) {
      toast.error('Error al cargar presupuesto');
      console.error('Error loading debts:', error);
    }
  };

  const loadSummary = async (month, year) => {
    try {
      const response = await debtsAPI.getDebtSummary(month || filterMonth, year || filterYear);
      setSummary(response.data);
    } catch (error) {
      console.error('Error loading debt summary:', error);
    }
  };

  const loadCategories = async () => {
    try {
      const response = await transactionsAPI.getCategories();
      setCategories(response.data || []);
    } catch (error) {
      console.error('Error loading categories:', error);
      // Fallback defensivo para no bloquear el formulario
      setCategories(['Personal', 'Vivienda', 'Transporte', 'Educación', 'Salud', 'Otro']);
    }
  };

  const handleSort = (field) => {
    if (sortField === field) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortField(field);
      setSortDirection('desc');
    }
  };

  const handleEdit = (debt) => {
    if (!canEdit) return;
    
    setDebtToEdit(debt);
    setEditModalOpen(true);
  };

  const handleSaveEdit = async (updatedData) => {
    try {
      await debtsAPI.updateDebt(debtToEdit.id, updatedData);
      toast.success('Item de presupuesto actualizado correctamente');
      setEditModalOpen(false);
      setDebtToEdit(null);
      loadDebts();
      loadSummary();
    } catch (error) {
      toast.error('Error al actualizar item');
      console.error('Error updating debt:', error);
    }
  };

  const handleCloseEditModal = () => {
    setEditModalOpen(false);
    setDebtToEdit(null);
  };

  const handleDeleteClick = (debt) => {
    if (!canEdit) return;
    
    setDeleteDialog({
      isOpen: true,
      debtId: debt.id,
      debtName: debt.detalle || `Presupuesto de ${debt.monto_total}`
    });
  };

  const handleDeleteConfirm = async () => {
    try {
      await debtsAPI.deleteDebt(deleteDialog.debtId);
      toast.success('Item de presupuesto eliminado correctamente');
      loadDebts();
      loadSummary();
    } catch (error) {
      if (error.response?.status === 400) {
        // Mostrar el mensaje específico del backend
        const message = error.response?.data?.detail || 'No se puede eliminar un item con transacciones asociadas';
        toast.error(message);
      } else {
        toast.error('Error al eliminar item');
      }
      console.error('Error deleting debt:', error);
    }
    setDeleteDialog({ isOpen: false, debtId: null, debtName: '' });
  };

  const toggleDebtSelection = (debtId) => {
    setSelectedDebtIds((prev) => {
      if (prev.includes(debtId)) {
        return prev.filter((id) => id !== debtId);
      }
      return [...prev, debtId];
    });
  };

  const toggleSelectAllDebts = () => {
    const visibleIds = paginatedDebts.map((debt) => debt.id);
    const allSelected = visibleIds.length > 0 && visibleIds.every((id) => selectedDebtIds.includes(id));

    if (allSelected) {
      setSelectedDebtIds((prev) => prev.filter((id) => !visibleIds.includes(id)));
      return;
    }

    setSelectedDebtIds((prev) => {
      const merged = new Set([...prev, ...visibleIds]);
      return Array.from(merged);
    });
  };

  const handleBulkDeleteConfirm = async () => {
    if (selectedDebtIds.length === 0) {
      setBulkDeleteDialogOpen(false);
      return;
    }

    setIsBulkDeleting(true);
    let deletedCount = 0;
    let blockedCount = 0;

    try {
      for (const debtId of selectedDebtIds) {
        try {
          await debtsAPI.deleteDebt(debtId);
          deletedCount += 1;
        } catch (error) {
          blockedCount += 1;
          console.error(`Error deleting debt ${debtId}:`, error);
        }
      }

      await loadDebts();
      await loadSummary();
      setSelectedDebtIds([]);

      if (deletedCount > 0) {
        toast.success(`${deletedCount} item(s) de presupuesto eliminado(s)`);
      }
      if (blockedCount > 0) {
        toast.warning(`${blockedCount} item(s) no se pudieron eliminar (pueden tener transacciones vinculadas)`);
      }
    } finally {
      setIsBulkDeleting(false);
      setBulkDeleteDialogOpen(false);
    }
  };

  const getStatusBadge = (status) => {
    const badges = {
      'PENDIENTE': 'bg-yellow-100 text-yellow-800',
      'Pago parcial': 'bg-blue-100 text-blue-800',
      'PAGADA': 'bg-green-100 text-green-800',
      'VENCIDA': 'bg-red-100 text-red-800'
    };
    return badges[status] || 'bg-gray-100 text-gray-800';
  };

  const getStatusText = (status) => {
    const statusTexts = {
      'PENDIENTE': 'Pendiente',
      'Pago parcial': 'Pago parcial',
      'PAGADA': 'Pagada',
      'VENCIDA': 'Vencida'
    };
    return statusTexts[status] || status;
  };

  const getProgressColor = (percentage) => {
    if (percentage >= 100) return 'bg-green-500';
    if (percentage >= 50) return 'bg-blue-500';
    return 'bg-yellow-500';
  };

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('es-AR', {
      style: 'currency',
      currency: 'ARS'
    }).format(amount);
  };

  const handleExportDebtsCsv = () => {
    const rows = debts.map((debt) => {
      const montoEjecutado = Number(debt.monto_ejecutado ?? debt.monto_pagado ?? 0);
      const percentage = debt.monto_total > 0
        ? (montoEjecutado / Number(debt.monto_total || 0)) * 100
        : 0;

      return {
        id: debt.id,
        fecha: formatDate(debt.fecha),
        tipo: debt.tipo,
        categoria: debt.categoria,
        detalle: debt.detalle || '',
        monto_total: Number(debt.monto_total || 0),
        monto_ejecutado: montoEjecutado,
        monto_pendiente: Number(debt.monto_total || 0) - montoEjecutado,
        progreso_pct: Number(percentage.toFixed(2)),
        status: debt.status,
        fecha_vencimiento: debt.fecha_vencimiento ? formatDate(debt.fecha_vencimiento) : ''
      };
    });

    const exported = exportToCsv({
      filename: `presupuesto_${new Date().toISOString().split('T')[0]}.csv`,
      headers: ['id', 'fecha', 'tipo', 'categoria', 'detalle', 'monto_total', 'monto_pagado', 'monto_pendiente', 'progreso_pct', 'status', 'fecha_vencimiento'],
      rows
    });

    if (!exported) {
      toast.warning('No hay items de presupuesto para exportar');
    }
  };

  const handleCloneMonth = async () => {
    // Target is always the next month from source
    let targetMonth = cloneSourceMonth + 1;
    let targetYear = cloneSourceYear;
    if (targetMonth > 12) {
      targetMonth = 1;
      targetYear += 1;
    }

    setIsCloning(true);
    try {
      const response = await debtsAPI.cloneMonth(cloneSourceMonth, cloneSourceYear, targetMonth, targetYear);
      const data = response.data;
      toast.success(`${data.cloned_count} items clonados al mes ${targetMonth}/${targetYear}`);
      setShowCloneMonth(false);
      loadDebts();
      loadSummary();
    } catch (error) {
      const detail = error?.response?.data?.detail || error.message;
      toast.error(`Error al clonar: ${detail}`);
    } finally {
      setIsCloning(false);
    }
  };

  const displayedDebts = useMemo(() => {
    let filtered = [...debts];

    // Filtrar por mes/año seleccionado
    filtered = filtered.filter((debt) => {
      const iso = toISODate(debt.fecha_vencimiento || debt.fecha);
      if (!iso) return false;
      const [year, month] = iso.split('-').map(Number);
      return year === filterYear && month === filterMonth;
    });

    if (filterFechaDesde) {
      filtered = filtered.filter((debt) => toISODate(debt.fecha) >= filterFechaDesde);
    }

    if (filterFechaHasta) {
      filtered = filtered.filter((debt) => toISODate(debt.fecha) <= filterFechaHasta);
    }

    if (filterTipo !== 'all') {
      filtered = filtered.filter((debt) => debt.tipo === filterTipo);
    }

    if (filterCategoria !== 'all') {
      filtered = filtered.filter((debt) => debt.categoria === filterCategoria);
    }

    if (filterTipoPresupuesto !== 'all') {
      filtered = filtered.filter((debt) => debt.tipo_presupuesto === filterTipoPresupuesto);
    }

    if (filterDetalle.trim()) {
      const q = filterDetalle.trim().toLowerCase();
      filtered = filtered.filter((debt) => (debt.detalle || '').toLowerCase().includes(q));
    }

    if (filterMontoMin !== '') {
      const min = Number(filterMontoMin);
      if (!Number.isNaN(min)) {
        filtered = filtered.filter((debt) => Number(debt.monto_total || 0) >= min);
      }
    }

    if (filterMontoMax !== '') {
      const max = Number(filterMontoMax);
      if (!Number.isNaN(max)) {
        filtered = filtered.filter((debt) => Number(debt.monto_total || 0) <= max);
      }
    }

    if (showSelectedOnly) {
      filtered = filtered.filter((debt) => selectedDebtIds.includes(debt.id));
    }

    // Ordenar
    if (sortField === 'fecha') {
      filtered.sort((a, b) => {
        const dateA = new Date(toISODate(a.fecha));
        const dateB = new Date(toISODate(b.fecha));
        return sortDirection === 'asc' ? dateA - dateB : dateB - dateA;
      });
    }

    return filtered;
  }, [
    debts,
    selectedDebtIds,
    showSelectedOnly,
    filterMonth,
    filterYear,
    filterFechaDesde,
    filterFechaHasta,
    filterTipo,
    filterCategoria,
    filterTipoPresupuesto,
    filterDetalle,
    filterMontoMin,
    filterMontoMax,
    sortField,
    sortDirection
  ]);

  const availableTipos = useMemo(() => {
    return [...new Set(debts.map((d) => d.tipo).filter(Boolean))].sort((a, b) => a.localeCompare(b));
  }, [debts]);

  const availableCategorias = useMemo(() => {
    return [...new Set(debts.map((d) => d.categoria).filter(Boolean))].sort((a, b) => a.localeCompare(b));
  }, [debts]);

  const budgetCategoryGastosData = useMemo(() => {
    const gastos = displayedDebts.filter(debt => debt.tipo_flujo === 'Gasto');
    const grouped = gastos.reduce((acc, debt) => {
      const category = debt.categoria || 'Sin categoría';
      acc[category] = (acc[category] || 0) + Number(debt.monto_total || 0);
      return acc;
    }, {});

    return {
      labels: Object.keys(grouped),
      datasets: [
        {
          label: 'Gastos por Categoría',
          data: Object.values(grouped),
          backgroundColor: chartColors,
          borderWidth: 2,
          borderColor: '#fff'
        }
      ]
    };
  }, [displayedDebts]);

  const budgetCategoryIngresosData = useMemo(() => {
    const ingresos = displayedDebts.filter(debt => debt.tipo_flujo === 'Ingreso');
    const grouped = ingresos.reduce((acc, debt) => {
      const tipoIngreso = debt.tipo || 'Sin clasificar';
      acc[tipoIngreso] = (acc[tipoIngreso] || 0) + Number(debt.monto_total || 0);
      return acc;
    }, {});

    return {
      labels: Object.keys(grouped),
      datasets: [
        {
          label: 'Ingresos por Tipo',
          data: Object.values(grouped),
          backgroundColor: ['#10b981', '#34d399', '#6ee7b7', '#a7f3d0', '#d1fae5', '#ecfdf5'],
          borderWidth: 2,
          borderColor: '#fff'
        }
      ]
    };
  }, [displayedDebts]);

  const asignacionPorFechaData = useMemo(() => {
    const fechas = {};
    
    displayedDebts.forEach(debt => {
      const dateKey = toISODate(debt.fecha_vencimiento || debt.fecha);
      if (!fechas[dateKey]) {
        fechas[dateKey] = { gastos: 0, ingresos: 0 };
      }
      const amount = Number(debt.monto_total || 0);
      if (debt.tipo_flujo === 'Gasto') {
        fechas[dateKey].gastos += amount;
      } else if (debt.tipo_flujo === 'Ingreso') {
        fechas[dateKey].ingresos += amount;
      }
    });

    const sortedDates = Object.keys(fechas).sort();

    return {
      labels: sortedDates.map((date) => formatDate(date)),
      datasets: [
        {
          label: 'Gastos',
          data: sortedDates.map((date) => fechas[date].gastos),
          backgroundColor: '#ef4444',
          borderColor: '#dc2626',
          borderWidth: 1
        },
        {
          label: 'Ingresos',
          data: sortedDates.map((date) => fechas[date].ingresos),
          backgroundColor: '#10b981',
          borderColor: '#059669',
          borderWidth: 1
        }
      ]
    };
  }, [displayedDebts]);

  const vencimientosData = useMemo(() => {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const vencidos = [];
    const proximos = [];
    
    // Filtrar solo Gastos (los Ingresos no tienen estado "Vencida")
    const gastosDebts = displayedDebts.filter(debt => debt.tipo_flujo === 'Gasto');
    
    gastosDebts.forEach(debt => {
      if (debt.estado === 'PAGADA') return;
      
      const fechaVenc = new Date(debt.fecha_vencimiento || debt.fecha);
      fechaVenc.setHours(0, 0, 0, 0);
      
      const diffDays = Math.floor((fechaVenc - today) / (1000 * 60 * 60 * 24));
      
      if (diffDays < 0) {
        vencidos.push({ ...debt, diasVencido: Math.abs(diffDays) });
      } else if (diffDays <= 7) {
        proximos.push({ ...debt, diasRestantes: diffDays });
      }
    });
    
    return {
      vencidos: vencidos.sort((a, b) => b.diasVencido - a.diasVencido),
      proximos: proximos.sort((a, b) => a.diasRestantes - b.diasRestantes)
    };
  }, [displayedDebts]);

  const totalPorPagar = summary
    ? Number(summary.total_estimated_payment || 0)
    : 0;

  const totalPages = Math.max(1, Math.ceil(displayedDebts.length / PAGE_SIZE));
  const paginatedDebts = useMemo(() => {
    const start = (currentPage - 1) * PAGE_SIZE;
    return displayedDebts.slice(start, start + PAGE_SIZE);
  }, [displayedDebts, currentPage]);

  // Reset page when filters change
  useEffect(() => {
    setCurrentPage(1);
  }, [filterMonth, filterYear, filterFechaDesde, filterFechaHasta, filterTipo, filterCategoria, filterTipoPresupuesto, filterDetalle, filterMontoMin, filterMontoMax, showSelectedOnly, sortField, sortDirection]);

  const allDebtsSelected = paginatedDebts.length > 0 && paginatedDebts.every((debt) => selectedDebtIds.includes(debt.id));

  return (
    <div className="space-y-6">
      {/* Selector de Mes/Año */}
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
              {Array.from({ length: 5 }, (_, i) => now.getFullYear() - 2 + i).map(y => (
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

      {/* Resumen de deudas */}
      {summary && (
        <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <p className="text-sm text-gray-600">Items Presupuesto</p>
            <p className="text-2xl font-bold text-gray-900">{summary.total_debts}</p>
          </div>
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <p className="text-sm text-gray-600">Ingresos Presupuestados</p>
            <p className="text-2xl font-bold text-green-600">{formatCurrency(summary.total_ingresos || 0)}</p>
          </div>
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <p className="text-sm text-gray-600">Total Estimado a Pagar</p>
            <p className="text-2xl font-bold text-blue-600">{formatCurrency(totalPorPagar)}</p>
          </div>
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <p className="text-sm text-gray-600">Pendiente no vencido</p>
            <p className="text-2xl font-bold text-yellow-600">{formatCurrency(summary.pending_amount)}</p>
          </div>
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <p className="text-sm text-gray-600">Vencidas</p>
            <p className="text-2xl font-bold text-red-600">{summary.overdue_count}</p>
            <p className="text-sm text-red-500 mt-1">{formatCurrency(summary.overdue_amount)}</p>
          </div>
        </div>
      )}

      {/* Gráficos reutilizados de Reportes para Presupuestos */}
      {displayedDebts.length > 0 && !showCSVImport && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Gráfica de Gastos por Categoría */}
          <div className="bg-white rounded-xl shadow-md p-6">
              <h3 className="text-lg font-bold text-finly-text mb-4">
                💸 Gastos por Categoría
              </h3>
              <div className="h-80 flex items-center justify-center">
                <Pie
                  data={budgetCategoryGastosData}
                  options={{
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                      legend: {
                        position: 'bottom'
                      },
                      tooltip: {
                        callbacks: {
                          label: function(context) {
                            const label = context.label || '';
                            const value = context.parsed || 0;
                            return label + ': $' + value.toLocaleString('es-AR');
                          }
                        }
                      }
                    }
                  }}
                />
              </div>
            </div>

          {/* Gráfica de Ingresos por Tipo */}
          <div className="bg-white rounded-xl shadow-md p-6">
              <h3 className="text-lg font-bold text-finly-text mb-4">
                💰 Ingresos por Tipo
              </h3>
              <div className="h-80 flex items-center justify-center">
                <Pie
                  data={budgetCategoryIngresosData}
                  options={{
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                      legend: {
                        position: 'bottom'
                      },
                      tooltip: {
                        callbacks: {
                          label: function(context) {
                            const label = context.label || '';
                            const value = context.parsed || 0;
                            return label + ': $' + value.toLocaleString('es-AR');
                          }
                        }
                      }
                    }
                  }}
                />
              </div>
            </div>

          {/* Gráfica de Asignación por Fecha - OCULTO */}
          {false && (
          <div className="bg-white rounded-xl shadow-md p-6">
            <h3 className="text-lg font-bold text-finly-text mb-4">
              📊 Asignación por Fecha de Vencimiento
            </h3>
            <div className="h-80">
              <Bar
                data={asignacionPorFechaData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: {
                      position: 'top'
                    },
                    tooltip: {
                      callbacks: {
                        label: function(context) {
                          return context.dataset.label + ': $' + context.parsed.y.toLocaleString('es-AR');
                        }
                      }
                    }
                  },
                  scales: {
                    y: {
                      beginAtZero: true,
                      stacked: false,
                      ticks: {
                        callback: function(value) {
                          return '$' + value.toLocaleString('es-AR');
                        }
                      }
                    },
                    x: {
                      stacked: false
                    }
                  }
                }}
              />
            </div>
          </div>
          )}

          {/* Panel de Vencimientos */}
          <div className="bg-white rounded-xl shadow-md p-6">
            <h3 className="text-lg font-bold text-finly-text mb-4">
              ⏰ Vencimientos
            </h3>
            <div className="h-80 overflow-y-auto space-y-4">
              {/* Items Vencidos */}
              {vencimientosData.vencidos.length > 0 && (
                <div>
                  <h4 className="text-sm font-semibold text-red-600 mb-2 flex items-center gap-2">
                    🔴 Vencidos ({vencimientosData.vencidos.length})
                  </h4>
                  <div className="space-y-2">
                    {vencimientosData.vencidos.slice(0, 5).map(debt => (
                      <div 
                        key={debt.id} 
                        onClick={() => handleEdit(debt)}
                        className="bg-red-50 p-2 rounded border-l-4 border-red-500 cursor-pointer hover:bg-red-100 transition-colors"
                      >
                        <div className="text-xs font-semibold text-gray-900">{debt.detalle || debt.tipo}</div>
                        <div className="text-xs text-red-600">Hace {debt.diasVencido} días</div>
                        <div className="text-xs font-bold text-gray-700">{formatCurrency(debt.monto_total)}</div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Items Por Vencer (próximos 7 días) */}
              {vencimientosData.proximos.length > 0 && (
                <div>
                  <h4 className="text-sm font-semibold text-yellow-600 mb-2 flex items-center gap-2">
                    🟡 Próximos 7 días ({vencimientosData.proximos.length})
                  </h4>
                  <div className="space-y-2">
                    {vencimientosData.proximos.slice(0, 5).map(debt => (
                      <div 
                        key={debt.id} 
                        onClick={() => handleEdit(debt)}
                        className="bg-yellow-50 p-2 rounded border-l-4 border-yellow-500 cursor-pointer hover:bg-yellow-100 transition-colors"
                      >
                        <div className="text-xs font-semibold text-gray-900">{debt.detalle || debt.tipo}</div>
                        <div className="text-xs text-yellow-600">
                          {debt.diasRestantes === 0 ? 'Hoy' : `En ${debt.diasRestantes} días`}
                        </div>
                        <div className="text-xs font-bold text-gray-700">{formatCurrency(debt.monto_total)}</div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Mensaje si no hay vencimientos */}
              {vencimientosData.vencidos.length === 0 && vencimientosData.proximos.length === 0 && (
                <div className="text-center text-gray-500 py-8">
                  <p className="text-sm">✅ No hay items vencidos ni por vencer</p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Acciones */}
      {!showCSVImport && (
        <div className="flex flex-wrap gap-3">
          {canEdit && (
            <>
              <button
                onClick={() => setNewModalOpen(true)}
                className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
              >
                + Nuevo Item
              </button>
              <button
                onClick={() => setShowCSVImport(true)}
                className="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 transition-colors flex items-center space-x-2"
              >
                <span>📥</span>
                <span>Importar CSV</span>
              </button>
              <button
                onClick={() => setShowCloneMonth(true)}
                className="bg-purple-600 text-white px-4 py-2 rounded-lg hover:bg-purple-700 transition-colors flex items-center space-x-2"
              >
                <span>📋</span>
                <span>Clonar Mes</span>
              </button>
            </>
          )}
          <button
            onClick={handleExportDebtsCsv}
            disabled={debts.length === 0}
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
              Mostrar solo seleccionados
            </label>
          )}
          {canEdit && (
            <button
              onClick={() => setBulkDeleteDialogOpen(true)}
              disabled={selectedDebtIds.length === 0 || isBulkDeleting}
              className="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              Eliminar seleccionados ({selectedDebtIds.length})
            </button>
          )}
        </div>
      )}

      {/* Importación CSV */}
      {showCSVImport && (
        <div className="bg-gray-50 rounded-lg p-4">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-lg font-semibold">Importar Presupuestos desde CSV</h3>
            <button
              onClick={() => setShowCSVImport(false)}
              className="text-gray-600 hover:text-gray-800"
            >
              ✕ Cerrar
            </button>
          </div>
          <BudgetCSVImport
            onImportSuccess={() => {
              setShowCSVImport(false);
              loadDebts();
              loadSummary();
            }}
          />
        </div>
      )}

      {/* Modal Clonar Mes */}
      {showCloneMonth && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-xl shadow-2xl max-w-md w-full p-6">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-bold text-gray-900">📋 Clonar Presupuesto</h3>
              <button
                onClick={() => setShowCloneMonth(false)}
                className="text-gray-400 hover:text-gray-600"
              >
                ✕
              </button>
            </div>
            <p className="text-sm text-gray-600 mb-4">
              Clona todos los items del mes seleccionado al mes siguiente, con montos ejecutados en 0.
            </p>
            <div className="grid grid-cols-2 gap-4 mb-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Mes origen</label>
                <select
                  value={cloneSourceMonth}
                  onChange={(e) => setCloneSourceMonth(parseInt(e.target.value))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                >
                  {[1,2,3,4,5,6,7,8,9,10,11,12].map(m => (
                    <option key={m} value={m}>
                      {['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'][m-1]}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Año origen</label>
                <input
                  type="number"
                  min="2020"
                  max="2100"
                  value={cloneSourceYear}
                  onChange={(e) => setCloneSourceYear(parseInt(e.target.value))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
                />
              </div>
            </div>
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-3 mb-4">
              <p className="text-sm text-blue-800">
                Se clonarán al mes: <strong>
                  {['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'][(cloneSourceMonth % 12)]}
                  {' '}{cloneSourceMonth === 12 ? cloneSourceYear + 1 : cloneSourceYear}
                </strong>
              </p>
            </div>
            <div className="flex gap-3">
              <button
                onClick={() => setShowCloneMonth(false)}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition"
              >
                Cancelar
              </button>
              <button
                onClick={handleCloneMonth}
                disabled={isCloning}
                className="flex-1 px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 disabled:opacity-50 transition"
              >
                {isCloning ? 'Clonando...' : 'Clonar'}
              </button>
            </div>
          </div>
        </div>
      )}

      {!showCSVImport && (
        <div className="bg-white rounded-lg shadow-sm border p-4">
          <div className="flex items-center justify-between mb-3">
            <h3 className="text-sm font-semibold text-gray-700">Filtros de Presupuesto</h3>
            <button
              onClick={() => {
                setFilterFechaDesde('');
                setFilterFechaHasta('');
                setFilterTipo('all');
                setFilterCategoria('all');
                setFilterTipoPresupuesto('all');
                setFilterDetalle('');
                setFilterMontoMin('');
                setFilterMontoMax('');
              }}
              className="text-sm text-blue-600 hover:text-blue-800"
            >
              Limpiar filtros
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-8 gap-3">
            <div>
              <label className="block text-xs text-gray-500 mb-1">Fecha desde</label>
              <input
                type="date"
                value={filterFechaDesde}
                onChange={(e) => setFilterFechaDesde(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
              />
            </div>
            <div>
              <label className="block text-xs text-gray-500 mb-1">Fecha hasta</label>
              <input
                type="date"
                value={filterFechaHasta}
                onChange={(e) => setFilterFechaHasta(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
              />
            </div>
            <div>
              <label className="block text-xs text-gray-500 mb-1">Tipo</label>
              <select
                value={filterTipo}
                onChange={(e) => setFilterTipo(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
              >
                <option value="all">Todos</option>
                {availableTipos.map((tipo) => (
                  <option key={tipo} value={tipo}>{tipo}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-xs text-gray-500 mb-1">Categoría</label>
              <select
                value={filterCategoria}
                onChange={(e) => setFilterCategoria(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
              >
                <option value="all">Todas</option>
                {availableCategorias.map((categoria) => (
                  <option key={categoria} value={categoria}>{categoria}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-xs text-gray-500 mb-1">Presupuesto</label>
              <select
                value={filterTipoPresupuesto}
                onChange={(e) => setFilterTipoPresupuesto(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
              >
                <option value="all">Todos</option>
                <option value="OBLIGATION">🔴 Obligación</option>
                <option value="VARIABLE">🔵 Variable</option>
              </select>
            </div>
            <div>
              <label className="block text-xs text-gray-500 mb-1">Detalle</label>
              <input
                type="text"
                value={filterDetalle}
                onChange={(e) => setFilterDetalle(e.target.value)}
                placeholder="Buscar texto"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
              />
            </div>
            <div>
              <label className="block text-xs text-gray-500 mb-1">Monto mín.</label>
              <input
                type="number"
                min="0"
                step="0.01"
                value={filterMontoMin}
                onChange={(e) => setFilterMontoMin(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
              />
            </div>
            <div>
              <label className="block text-xs text-gray-500 mb-1">Monto máx.</label>
              <input
                type="number"
                min="0"
                step="0.01"
                value={filterMontoMax}
                onChange={(e) => setFilterMontoMax(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm"
              />
            </div>
          </div>
        </div>
      )}

      {/* Lista de deudas */}
      <div className="bg-white rounded-lg shadow-md border overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                {canEdit && (
                  <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">
                    <input
                      type="checkbox"
                      checked={allDebtsSelected}
                      onChange={toggleSelectAllDebts}
                      aria-label="Seleccionar todos los items de presupuesto"
                    />
                  </th>
                )}
                <th 
                  className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase cursor-pointer hover:bg-gray-100 select-none"
                  onClick={() => handleSort('fecha')}
                  title="Ordenar por fecha"
                >
                  <div className="flex items-center gap-1">
                    <span>Fecha</span>
                    {sortField === 'fecha' && (
                      <span className="text-blue-600">
                        {sortDirection === 'asc' ? '↑' : '↓'}
                      </span>
                    )}
                  </div>
                </th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tipo</th>
                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Presupuesto</th>
                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Flujo</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Categoría</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Detalle</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Monto Total</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Monto a Pagar</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Ejecutado</th>
                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Progreso</th>
                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Estado</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Vencimiento</th>
                {canEdit && <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Acciones</th>}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {paginatedDebts.length === 0 ? (
                <tr>
                  <td colSpan={canEdit ? "14" : "13"} className="px-4 py-8 text-center text-gray-500">
                    {debts.length === 0 ? 'No hay items de presupuesto registrados' : 'No hay resultados para los filtros aplicados'}
                  </td>
                </tr>
              ) : (
                paginatedDebts.map((debt) => {
                  const montoEjecutado = debt.monto_ejecutado ?? debt.monto_pagado ?? 0;
                  const percentage = debt.total_installments > 0
                    ? ((debt.paid_installments || 0) / debt.total_installments) * 100
                    : debt.monto_total > 0 
                      ? (montoEjecutado / debt.monto_total) * 100 
                      : 0;
                  const remaining = debt.monto_total - (debt.monto_pagado || 0);
                  const tipoPresupuesto = debt.tipo_presupuesto || 'OBLIGATION';
                  const tipoFlujo = debt.tipo_flujo || 'Gasto';

                  return (
                    <tr key={debt.id} className="hover:bg-gray-50">
                      {canEdit && (
                        <td className="px-4 py-3 text-center">
                          <input
                            type="checkbox"
                            checked={selectedDebtIds.includes(debt.id)}
                            onChange={() => toggleDebtSelection(debt.id)}
                            aria-label={`Seleccionar presupuesto ${debt.id}`}
                          />
                        </td>
                      )}
                      <td className="px-4 py-3 text-sm text-gray-900">{formatDate(debt.fecha)}</td>
                      <td className="px-4 py-3 text-sm text-gray-600">{debt.tipo}</td>
                      <td className="px-4 py-3 text-center">
                        <span className={`px-2 py-1 text-xs font-semibold rounded-full ${
                          tipoPresupuesto === 'OBLIGATION' 
                            ? 'bg-purple-100 text-purple-800' 
                            : 'bg-cyan-100 text-cyan-800'
                        }`}>
                          {tipoPresupuesto === 'OBLIGATION' ? 'Obligación' : 'Variable'}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-center">
                        <span className={`px-2 py-1 text-xs font-semibold rounded-full ${
                          tipoFlujo === 'Gasto' 
                            ? 'bg-red-100 text-red-800' 
                            : 'bg-green-100 text-green-800'
                        }`}>
                          {tipoFlujo === 'Gasto' ? '💸 Gasto' : '💰 Ingreso'}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-sm text-gray-600">{debt.categoria}</td>
                      <td className="px-4 py-3 text-sm text-gray-600">{debt.detalle || '-'}</td>
                      <td className="px-4 py-3 text-sm text-right font-medium text-gray-900">
                        {formatCurrency(debt.monto_total)}
                      </td>
                      <td className="px-4 py-3 text-sm text-right text-purple-600">
                        {formatCurrency(debt.estimated_payment != null ? debt.estimated_payment : debt.monto_total)}
                      </td>
                      <td className="px-4 py-3 text-sm text-right text-blue-600">
                        {formatCurrency(montoEjecutado)}
                      </td>
                      <td className="px-4 py-3">
                        <div className="flex flex-col items-center gap-1">
                          <div className="w-full bg-gray-200 rounded-full h-2">
                            <div
                              className={`h-2 rounded-full transition-all ${getProgressColor(percentage)}`}
                              style={{ width: `${Math.min(percentage, 100)}%` }}
                            />
                          </div>
                          <span className="text-xs text-gray-600">
                            {percentage.toFixed(0)}%
                          </span>
                          <span className="text-xs text-gray-500">
                            Resta: {formatCurrency(remaining)}
                          </span>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-center">
                        <span className={`px-2 py-1 text-xs font-semibold rounded-full ${getStatusBadge(debt.status)}`}>
                          {getStatusText(debt.status)}
                          {debt.total_installments > 0 && ` ${debt.paid_installments || 0}/${debt.total_installments}`}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-sm text-gray-600">
                        {debt.fecha_vencimiento ? formatDate(debt.fecha_vencimiento) : '-'}
                      </td>
                      {canEdit && (
                        <td className="px-4 py-3 text-center">
                          <div className="flex gap-2 justify-center">
                            <button
                              onClick={() => handleEdit(debt)}
                              className="text-blue-600 hover:text-blue-800 text-sm font-medium"
                            >
                              Editar
                            </button>
                            <button
                              onClick={() => handleDeleteClick(debt)}
                              className="text-red-600 hover:text-red-800 text-sm font-medium"
                            >
                              Eliminar
                            </button>
                          </div>
                        </td>
                      )}
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Paginación */}
        {totalPages > 1 && (
          <div className="flex items-center justify-between px-4 py-3 border-t border-gray-200">
            <p className="text-sm text-gray-600">
              Mostrando {(currentPage - 1) * PAGE_SIZE + 1}-{Math.min(currentPage * PAGE_SIZE, displayedDebts.length)} de {displayedDebts.length}
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
                          ? 'bg-blue-600 text-white'
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

      {/* Confirm Dialog */}
      <ConfirmDialog
        isOpen={deleteDialog.isOpen}
        onClose={() => setDeleteDialog({ isOpen: false, debtId: null, debtName: '' })}
        onConfirm={handleDeleteConfirm}
        title="Eliminar Item de Presupuesto"
        message={`¿Está seguro de eliminar "${deleteDialog.debtName}"?`}
        type="danger"
      />

      <ConfirmDialog
        isOpen={bulkDeleteDialogOpen}
        onClose={() => {
          if (!isBulkDeleting) {
            setBulkDeleteDialogOpen(false);
          }
        }}
        onConfirm={handleBulkDeleteConfirm}
        title="Eliminar Items Seleccionados"
        message={`¿Está seguro de eliminar ${selectedDebtIds.length} item(s) seleccionados del presupuesto?`}
        type="danger"
        confirmText={isBulkDeleting ? 'Eliminando...' : 'Eliminar seleccionados'}
      />

      {/* Edit Debt Modal */}
      {editModalOpen && (
        <EditDebtModal
          debt={debtToEdit}
          onSave={handleSaveEdit}
          onClose={handleCloseEditModal}
          categories={categories}
        />
      )}

      {/* New Debt Modal */}
      <NewDebtModal
        isOpen={newModalOpen}
        onClose={() => setNewModalOpen(false)}
        onSuccess={() => {
          loadDebts();
          loadSummary();
        }}
      />
    </div>
  );
}
