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

export default function DebtManager({ canEdit, isAdmin = false }) {
  const chartColors = ['#6366F1', '#8B5CF6', '#EC4899', '#F59E0B', '#22C55E', '#3B82F6', '#EF4444'];
  const [debts, setDebts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [summary, setSummary] = useState(null);
  const [newModalOpen, setNewModalOpen] = useState(false);
  const [showCSVImport, setShowCSVImport] = useState(false);
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
  const [sortField, setSortField] = useState('fecha');
  const [sortDirection, setSortDirection] = useState('desc');
  const toast = useToast();

  // Cargar deudas y resumen
  useEffect(() => {
    loadDebts();
    loadSummary();
    loadCategories();
  }, []);

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

  const loadSummary = async () => {
    try {
      const response = await debtsAPI.getDebtSummary();
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
    const allIds = displayedDebts.map((debt) => debt.id);
    const allSelected = allIds.length > 0 && allIds.every((id) => selectedDebtIds.includes(id));

    if (allSelected) {
      setSelectedDebtIds([]);
      return;
    }

    setSelectedDebtIds(allIds);
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

  const displayedDebts = useMemo(() => {
    let filtered = [...debts];

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

  const budgetCategoryData = useMemo(() => {
    const grouped = displayedDebts.reduce((acc, debt) => {
      const category = debt.categoria || 'Sin categoría';
      acc[category] = (acc[category] || 0) + Number(debt.monto_total || 0);
      return acc;
    }, {});

    return {
      labels: Object.keys(grouped),
      datasets: [
        {
          label: 'Presupuesto por Categoría',
          data: Object.values(grouped),
          backgroundColor: chartColors,
          borderWidth: 2,
          borderColor: '#fff'
        }
      ]
    };
  }, [displayedDebts]);

  const budgetDateData = useMemo(() => {
    const grouped = displayedDebts.reduce((acc, debt) => {
      const dateKey = toISODate(debt.fecha_vencimiento || debt.fecha);
      const amount = Number(debt.monto_total || 0);
      acc[dateKey] = (acc[dateKey] || 0) + amount;
      return acc;
    }, {});

    const sortedDates = Object.keys(grouped).sort();

    return {
      labels: sortedDates.map((date) => formatDate(date)),
      datasets: [
        {
          label: 'Presupuesto por Fecha',
          data: sortedDates.map((date) => grouped[date]),
          backgroundColor: '#F59E0B'
        }
      ]
    };
  }, [displayedDebts]);

  const totalPorPagar = summary
    ? Number(summary.pending_amount || 0) + Number(summary.partial_amount || 0) + Number(summary.overdue_amount || 0)
    : 0;

  const allDebtsSelected = displayedDebts.length > 0 && displayedDebts.every((debt) => selectedDebtIds.includes(debt.id));

  return (
    <div className="space-y-6">
      {/* Resumen de deudas */}
      {summary && (
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <p className="text-sm text-gray-600">Items Presupuesto</p>
            <p className="text-2xl font-bold text-gray-900">{summary.total_debts}</p>
          </div>
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <p className="text-sm text-gray-600">Total por Pagar</p>
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
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white rounded-xl shadow-md p-6">
            <h3 className="text-lg font-bold text-finly-text mb-4">
              Presupuesto por Categoría
            </h3>
            <div className="h-80 flex items-center justify-center">
              <Pie
                data={budgetCategoryData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: {
                      position: 'bottom'
                    }
                  }
                }}
              />
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-md p-6">
            <h3 className="text-lg font-bold text-finly-text mb-4">
              Presupuesto por Fecha
            </h3>
            <div className="h-80">
              <Bar
                data={budgetDateData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: {
                      display: false
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
          {isAdmin && canEdit && (
            <label className="text-sm text-gray-600 inline-flex items-center gap-2 px-2">
              <input
                type="checkbox"
                checked={showSelectedOnly}
                onChange={(e) => setShowSelectedOnly(e.target.checked)}
              />
              Mostrar solo seleccionados
            </label>
          )}
          {isAdmin && canEdit && (
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
                {isAdmin && canEdit && (
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
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Ejecutado</th>
                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Progreso</th>
                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Estado</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Vencimiento</th>
                {canEdit && <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Acciones</th>}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {displayedDebts.length === 0 ? (
                <tr>
                  <td colSpan={isAdmin && canEdit ? "13" : canEdit ? "12" : "11"} className="px-4 py-8 text-center text-gray-500">
                    {debts.length === 0 ? 'No hay items de presupuesto registrados' : 'No hay resultados para los filtros aplicados'}
                  </td>
                </tr>
              ) : (
                displayedDebts.map((debt) => {
                  const montoEjecutado = debt.monto_ejecutado ?? debt.monto_pagado ?? 0;
                  const percentage = debt.monto_total > 0 
                    ? (montoEjecutado / debt.monto_total) * 100 
                    : 0;
                  const remaining = debt.monto_total - montoEjecutado;
                  const tipoPresupuesto = debt.tipo_presupuesto || 'OBLIGATION';
                  const tipoFlujo = debt.tipo_flujo || 'Gasto';

                  return (
                    <tr key={debt.id} className="hover:bg-gray-50">
                      {isAdmin && canEdit && (
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
