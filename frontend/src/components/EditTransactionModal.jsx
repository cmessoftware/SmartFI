import { useState, useEffect } from 'react';
import { toISODate } from '../utils/dateUtils';

function EditTransactionModal({ transaction, onSave, onClose, categories, necessityTypes, debts = [] }) {
  const [formData, setFormData] = useState({
    fecha: '',
    tipo: 'Gasto',
    categoria: '',
    monto: '',
    necesidad: '',
    detalle: '',
    debt_id: ''
  });

  useEffect(() => {
    if (transaction) {
      setFormData({
        fecha: toISODate(transaction.fecha) || '',
        tipo: transaction.tipo || 'Gasto',
        categoria: transaction.categoria || '',
        monto: transaction.monto || '',
        necesidad: transaction.necesidad || '',
        detalle: transaction.detalle || '',
        debt_id: transaction.debt_id ?? ''
      });
    }
  }, [transaction]);

  const handleChange = (e) => {
    const { name, value } = e.target;

    setFormData({
      ...formData,
      [name]: value
    });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onSave({
      ...transaction,
      ...formData,
      monto: parseFloat(formData.monto),
      debt_id: formData.debt_id ? parseInt(formData.debt_id, 10) : null
    });
  };

  // Filtrar debts por tipo de flujo coincidente
  const suggestedDebts = debts
    .filter((debt) => debt.tipo_flujo === formData.tipo)
    .sort((a, b) => {
      const labelA = (a.detalle || `Presupuesto ${a.tipo || ''}`).trim().toLowerCase();
      const labelB = (b.detalle || `Presupuesto ${b.tipo || ''}`).trim().toLowerCase();
      return labelA.localeCompare(labelB, 'es');
    });

  const otherDebts = debts
    .filter((debt) => debt.tipo_flujo !== formData.tipo)
    .sort((a, b) => {
      const labelA = (a.detalle || `Presupuesto ${a.tipo || ''}`).trim().toLowerCase();
      const labelB = (b.detalle || `Presupuesto ${b.tipo || ''}`).trim().toLowerCase();
      return labelA.localeCompare(labelB, 'es');
    });

  if (!transaction) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex justify-between items-center">
          <h2 className="text-2xl font-bold text-finly-text">Editar Transacción</h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Fecha */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Fecha *
              </label>
              <input
                type="date"
                name="fecha"
                value={formData.fecha}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all"
              />
            </div>

            {/* Tipo */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Tipo *
              </label>
              <select
                name="tipo"
                value={formData.tipo}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all"
              >
                <option value="Gasto">Gasto</option>
                <option value="Ingreso">Ingreso</option>
              </select>
            </div>

            {/* Categoría */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Categoría *
              </label>
              <select
                name="categoria"
                value={formData.categoria}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all"
              >
                <option value="">Selecciona una categoría</option>
                {categories.map(cat => (
                  <option key={cat} value={cat}>{cat}</option>
                ))}
              </select>
            </div>

            {/* Monto */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Monto *
              </label>
              <input
                type="number"
                name="monto"
                value={formData.monto}
                onChange={handleChange}
                step="0.01"
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all"
              />
            </div>

            {/* Necesidad */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Necesidad *
              </label>
              <select
                name="necesidad"
                value={formData.necesidad}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all"
              >
                <option value="">Selecciona una opción</option>
                {necessityTypes.map(type => (
                  <option key={type} value={type}>{type}</option>
                ))}
              </select>
            </div>

            {/* Vinculación con presupuesto en edición - para gastos e ingresos */}
            {debts.length > 0 && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-finly-text mb-2">
                  Asociar a Item de Presupuesto (Opcional)
                  {formData.categoria && (
                    <span className="ml-2 text-xs font-normal text-blue-600">
                      💡 Sugerencia: {formData.tipo === 'Gasto' ? 'gastos' : 'ingresos'} en categoría "{formData.categoria}"
                    </span>
                  )}
                </label>
                <select
                  name="debt_id"
                  value={formData.debt_id}
                  onChange={handleChange}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all"
                >
                  <option value="">-- Sin asignar --</option>
                  {suggestedDebts.length > 0 && (
                    <optgroup label="🎯 Sugeridos por tipo de flujo">
                      {suggestedDebts.map((debt) => {
                        const montoEjecutado = debt.monto_ejecutado ?? debt.monto_pagado ?? 0;
                        const remaining = Number(debt.monto_total) - montoEjecutado;
                        const tipoPresupuesto = debt.tipo_presupuesto || 'OBLIGATION';
                        const tipoBadge = tipoPresupuesto === 'OBLIGATION' ? '🔴' : '🔵';
                        const flujoIcon = debt.tipo_flujo === 'Gasto' ? '💸' : '💰';
                        return (
                          <option key={debt.id} value={debt.id}>
                            {tipoBadge} {flujoIcon} {debt.detalle || `${debt.tipo} - ${debt.categoria}`} - Resta: ${remaining.toFixed(2)}
                          </option>
                        );
                      })}
                    </optgroup>
                  )}
                  {otherDebts.length > 0 && (
                    <optgroup label="📋 Otros items de presupuesto">
                      {otherDebts.map((debt) => {
                        const montoEjecutado = debt.monto_ejecutado ?? debt.monto_pagado ?? 0;
                        const remaining = Number(debt.monto_total) - montoEjecutado;
                        const tipoPresupuesto = debt.tipo_presupuesto || 'OBLIGATION';
                        const tipoBadge = tipoPresupuesto === 'OBLIGATION' ? '🔴' : '🔵';
                        const flujoIcon = debt.tipo_flujo === 'Gasto' ? '💸' : '💰';
                        return (
                          <option key={debt.id} value={debt.id}>
                            {tipoBadge} {flujoIcon} {debt.detalle || `${debt.tipo} - ${debt.categoria}`} - Resta: ${remaining.toFixed(2)}
                          </option>
                        );
                      })}
                    </optgroup>
                  )}
                </select>
                <p className="text-xs text-finly-textSecondary mt-1">
                  Seleccione un item de presupuesto si esta transacción corresponde al mismo
                </p>
              </div>
            )}
          </div>

          {/* Detalle */}
          <div>
            <label className="block text-sm font-medium text-finly-text mb-2">
              Detalle
            </label>
            <textarea
              name="detalle"
              value={formData.detalle}
              onChange={handleChange}
              rows={3}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all resize-none"
              placeholder="Información adicional (opcional)"
            />
          </div>

          {/* Botones */}
          <div className="flex gap-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-6 py-3 border border-gray-300 rounded-lg text-gray-700 font-semibold hover:bg-gray-50 transition-colors"
            >
              Cancelar
            </button>
            <button
              type="submit"
              className="flex-1 px-6 py-3 bg-finly-primary rounded-lg text-white font-semibold hover:bg-finly-secondary transition-colors"
            >
              Guardar Cambios
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default EditTransactionModal;
