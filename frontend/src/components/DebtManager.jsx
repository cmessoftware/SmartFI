import { useState, useEffect } from 'react';
import { debtsAPI } from '../services/api';
import { useToast } from './ToastContainer';
import ConfirmDialog from './ConfirmDialog';
import { formatDate, toISODate } from '../utils/dateUtils';

export default function DebtManager({ canEdit }) {
  const [debts, setDebts] = useState([]);
  const [summary, setSummary] = useState(null);
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [editingDebt, setEditingDebt] = useState(null);
  const [deleteDialog, setDeleteDialog] = useState({ isOpen: false, debtId: null, debtName: '' });
  const toast = useToast();

  // Formulario
  const [formData, setFormData] = useState({
    fecha: new Date().toISOString().split('T')[0],
    tipo: 'Préstamo',
    categoria: 'Personal',
    monto_total: '',
    monto_pagado: '0',
    detalle: '',
    fecha_vencimiento: ''
  });

  // Cargar deudas y resumen
  useEffect(() => {
    loadDebts();
    loadSummary();
  }, []);

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

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!formData.monto_total || parseFloat(formData.monto_total) <= 0) {
      toast.warning('Ingrese un monto válido');
      return;
    }

    try {
      if (editingDebt) {
        await debtsAPI.updateDebt(editingDebt.id, formData);
       toast.success('Item de presupuesto actualizado correctamente');
      } else {
        await debtsAPI.createDebt(formData);
        toast.success('Item de presupuesto creado correctamente');
      }
      
      resetForm();
      loadDebts();
      loadSummary();
    } catch (error) {
      toast.error(editingDebt ? 'Error al actualizar item' : 'Error al crear item');
      console.error('Error saving debt:', error);
    }
  };

  const handleEdit = (debt) => {
    if (!canEdit) return;
    
    setEditingDebt(debt);
    setFormData({
      fecha: toISODate(debt.fecha),
      tipo: debt.tipo,
      categoria: debt.categoria,
      monto_total: debt.monto_total.toString(),
      monto_pagado: debt.monto_pagado.toString(),
      detalle: debt.detalle || '',
      fecha_vencimiento: toISODate(debt.fecha_vencimiento) || ''
    });
    setIsFormOpen(true);
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

  const resetForm = () => {
    setEditingDebt(null);
    setFormData({
      fecha: new Date().toISOString().split('T')[0],
      tipo: 'Préstamo',
      categoria: 'Personal',
      monto_total: '',
      monto_pagado: '0',
      detalle: '',
      fecha_vencimiento: ''
    });
    setIsFormOpen(false);
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
            <p className="text-sm text-gray-600">Monto Total</p>
            <p className="text-2xl font-bold text-blue-600">{formatCurrency(summary.total_amount)}</p>
          </div>
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <p className="text-sm text-gray-600">Pendiente</p>
            <p className="text-2xl font-bold text-yellow-600">{formatCurrency(summary.pending_amount)}</p>
          </div>
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <p className="text-sm text-gray-600">Vencidas</p>
            <p className="text-2xl font-bold text-red-600">{summary.overdue_count}</p>
          </div>
        </div>
      )}

      {/* Botón agregar deuda */}
      {canEdit && !isFormOpen && (
        <button
          onClick={() => setIsFormOpen(true)}
          className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
        >
          + Nuevo Item
        </button>
      )}

      {/* Formulario */}
      {isFormOpen && (
        <div className="bg-white p-6 rounded-lg shadow-md border">
          <h3 className="text-lg font-semibold mb-4">
            {editingDebt ? 'Editar Item' : 'Nuevo Item'}
          </h3>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Fecha
                </label>
                <input
                  type="date"
                  name="fecha"
                  value={formData.fecha}
                  onChange={handleInputChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Tipo
                </label>
                <select
                  name="tipo"
                  value={formData.tipo}
                  onChange={handleInputChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                  required
                >
                  <option value="Préstamo">Préstamo</option>
                  <option value="Tarjeta">Tarjeta</option>
                  <option value="Servicio">Servicio</option>
                  <option value="Otro">Otro</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Categoría
                </label>
                <select
                  name="categoria"
                  value={formData.categoria}
                  onChange={handleInputChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                  required
                >
                  <option value="Personal">Personal</option>
                  <option value="Vivienda">Vivienda</option>
                  <option value="Transporte">Transporte</option>
                  <option value="Educación">Educación</option>
                  <option value="Salud">Salud</option>
                  <option value="Otro">Otro</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Monto Total
                </label>
                <input
                  type="number"
                  name="monto_total"
                  value={formData.monto_total}
                  onChange={handleInputChange}
                  step="0.01"
                  min="0"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                  required
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Monto Pagado
                  <span className="text-xs text-gray-500 ml-2">(Solo lectura - actualizar desde Gastos)</span>
                </label>
                <input
                  type="number"
                  name="monto_pagado"
                  value={formData.monto_pagado}
                  onChange={handleInputChange}
                  step="0.01"
                  min="0"
                  readOnly
                  disabled
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg bg-gray-50 cursor-not-allowed"
                  title="El monto pagado se actualiza automáticamente desde las transacciones vinculadas"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Fecha Vencimiento (Opcional)
                </label>
                <input
                  type="date"
                  name="fecha_vencimiento"
                  value={formData.fecha_vencimiento}
                  onChange={handleInputChange}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                />
              </div>

              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Detalle
                </label>
                <textarea
                  name="detalle"
                  value={formData.detalle}
                  onChange={handleInputChange}
                  rows="2"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500"
                  placeholder="Descripción del item de presupuesto..."
                />
              </div>
            </div>

            <div className="flex gap-2 justify-end">
              <button
                type="button"
                onClick={resetForm}
                className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
              >
                Cancelar
              </button>
              <button
                type="submit"
                className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
              >
                {editingDebt ? 'Actualizar' : 'Guardar'}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Lista de deudas */}
      <div className="bg-white rounded-lg shadow-md border overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Fecha</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tipo</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Categoría</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Detalle</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Monto Total</th>
                <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase">Pagado</th>
                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Progreso</th>
                <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Estado</th>
                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Vencimiento</th>
                {canEdit && <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase">Acciones</th>}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {debts.length === 0 ? (
                <tr>
                  <td colSpan={canEdit ? "10" : "9"} className="px-4 py-8 text-center text-gray-500">
                    No hay items de presupuesto registrados
                  </td>
                </tr>
              ) : (
                debts.map((debt) => {
                  const percentage = debt.monto_total > 0 
                    ? (debt.monto_pagado / debt.monto_total) * 100 
                    : 0;
                  const remaining = debt.monto_total - debt.monto_pagado;

                  return (
                    <tr key={debt.id} className="hover:bg-gray-50">
                      <td className="px-4 py-3 text-sm text-gray-900">{formatDate(debt.fecha)}</td>
                      <td className="px-4 py-3 text-sm text-gray-600">{debt.tipo}</td>
                      <td className="px-4 py-3 text-sm text-gray-600">{debt.categoria}</td>
                      <td className="px-4 py-3 text-sm text-gray-600">{debt.detalle || '-'}</td>
                      <td className="px-4 py-3 text-sm text-right font-medium text-gray-900">
                        {formatCurrency(debt.monto_total)}
                      </td>
                      <td className="px-4 py-3 text-sm text-right text-blue-600">
                        {formatCurrency(debt.monto_pagado)}
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
    </div>
  );
}
