import { useState, useEffect } from 'react';
import { toISODate } from '../utils/dateUtils';

function EditDebtModal({ debt, onSave, onClose, categories }) {
  // Opciones de Tipo según Tipo de Flujo
  const tiposGasto = [
    'Servicios',
    'Alimentación',
    'Transporte',
    'Vivienda',
    'Educación',
    'Salud',
    'Entretenimiento',
    'Seguros',
    'Impuestos',
    'Préstamo',
    'Tarjeta',
    'Otro'
  ];
  
  const tiposIngreso = [
    'Sueldos',
    'Honorarios',
    'Alquileres',
    'Inversiones',
    'Freelance',
    'Ventas',
    'Reintegros',
    'Otro'
  ];
  
  const [formData, setFormData] = useState({
    fecha: '',
    tipo: 'Préstamo',
    categoria: 'Personal',
    monto_total: '',
    detalle: '',
    fecha_vencimiento: '',
    tipo_presupuesto: 'OBLIGATION',
    tipo_flujo: 'Gasto',
    monto_ejecutado: '0',
    estimated_payment: ''
  });

  useEffect(() => {
    if (debt) {
      setFormData({
        fecha: toISODate(debt.fecha),
        tipo: debt.tipo,
        categoria: debt.categoria,
        monto_total: debt.monto_total.toString(),
        detalle: debt.detalle || '',
        fecha_vencimiento: toISODate(debt.fecha_vencimiento) || '',
        tipo_presupuesto: debt.tipo_presupuesto || 'OBLIGATION',
        tipo_flujo: debt.tipo_flujo || 'Gasto',
        monto_ejecutado: (debt.monto_ejecutado || debt.monto_pagado || 0).toString(),
        estimated_payment: (debt.estimated_payment != null ? debt.estimated_payment : debt.monto_total).toString()
      });
    }
  }, [debt]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    
    // Si cambia el tipo_flujo, resetear el campo tipo
    if (name === 'tipo_flujo') {
      setFormData({
        ...formData,
        tipo_flujo: value,
        tipo: value === 'Ingreso' ? tiposIngreso[0] : tiposGasto[0]
      });
    } else if (name === 'monto_total') {
      setFormData({
        ...formData,
        monto_total: value,
        estimated_payment: (!formData.estimated_payment || formData.estimated_payment === formData.monto_total) ? value : formData.estimated_payment
      });
    } else {
      setFormData({
        ...formData,
        [name]: value
      });
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    if (!formData.monto_total || parseFloat(formData.monto_total) <= 0) {
      return;
    }

    onSave({
      ...formData,
      monto_total: parseFloat(formData.monto_total),
      monto_ejecutado: parseFloat(formData.monto_ejecutado),
      estimated_payment: formData.estimated_payment ? parseFloat(formData.estimated_payment) : parseFloat(formData.monto_total)
    });
  };

  if (!debt) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 flex justify-between items-center">
          <h2 className="text-2xl font-bold text-finly-text">Editar Item de Presupuesto</h2>
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
                Tipo de {formData.tipo_flujo} *
              </label>
              <select
                name="tipo"
                value={formData.tipo}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all"
              >
                {formData.tipo_flujo === 'Ingreso' 
                  ? tiposIngreso.map(tipo => (
                      <option key={tipo} value={tipo}>{tipo}</option>
                    ))
                  : tiposGasto.map(tipo => (
                      <option key={tipo} value={tipo}>{tipo}</option>
                    ))
                }
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
                {categories && categories.length > 0 ? (
                  categories.map(cat => (
                    <option key={cat.id || cat} value={cat.name || cat}>{cat.name || cat}</option>
                  ))
                ) : (
                  <>
                    <option value="Personal">Personal</option>
                    <option value="Vivienda">Vivienda</option>
                    <option value="Transporte">Transporte</option>
                    <option value="Educación">Educación</option>
                    <option value="Salud">Salud</option>
                    <option value="Otro">Otro</option>
                  </>
                )}
              </select>
            </div>

            {/* Monto Total */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Monto Total *
              </label>
              <input
                type="number"
                name="monto_total"
                value={formData.monto_total}
                onChange={handleChange}
                step="0.01"
                min="0"
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all"
              />
            </div>

            {/* Monto a Pagar */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Monto a Pagar
                <span className="text-xs text-gray-500 ml-2">(por defecto 100% del total)</span>
              </label>
              <input
                type="number"
                name="estimated_payment"
                value={formData.estimated_payment}
                onChange={handleChange}
                step="0.01"
                min="0"
                placeholder={formData.monto_total || '0.00'}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all"
              />
            </div>

            {/* Tipo de Presupuesto */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Tipo de Presupuesto *
              </label>
              <select
                name="tipo_presupuesto"
                value={formData.tipo_presupuesto}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all"
              >
                <option value="OBLIGATION">🔴 Obligación (Deuda/Compromiso)</option>
                <option value="VARIABLE">🔵 Variable (Presupuesto Flexible)</option>
              </select>
            </div>

            {/* Tipo de Flujo */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Tipo de Flujo *
              </label>
              <select
                name="tipo_flujo"
                value={formData.tipo_flujo}
                onChange={handleChange}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all"
              >
                <option value="Gasto">💸 Gasto</option>
                <option value="Ingreso">💰 Ingreso</option>
              </select>
            </div>

            {/* Fecha de Vencimiento */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Fecha de Vencimiento
              </label>
              <input
                type="date"
                name="fecha_vencimiento"
                value={formData.fecha_vencimiento}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all"
              />
            </div>

            {/* Monto Ejecutado (read-only) */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Monto Ejecutado (Read-only)
              </label>
              <input
                type="number"
                name="monto_ejecutado"
                value={formData.monto_ejecutado}
                readOnly
                className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-100 text-gray-600 cursor-not-allowed"
              />
              <p className="text-xs text-gray-500 mt-1">Se actualiza automáticamente con las transacciones</p>
            </div>
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
              placeholder="Descripción del item de presupuesto (opcional)"
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

export default EditDebtModal;
