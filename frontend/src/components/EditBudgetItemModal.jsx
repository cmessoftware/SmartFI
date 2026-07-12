import { useState, useEffect, useMemo } from 'react';
import { toISODate } from '../utils/dateUtils';

const getCategoryOption = (category) => {
  if (category == null) return null;

  if (typeof category === 'string') {
    const value = category.trim();
    if (!value) return null;
    return { value, label: value };
  }

  if (typeof category === 'object') {
    const raw = category.name ?? category.label ?? category.value ?? category.categoria ?? category.id;
    const value = raw != null ? String(raw).trim() : '';
    if (!value) return null;
    return { value, label: value };
  }

  const value = String(category).trim();
  return value ? { value, label: value } : null;
};

function EditBudgetItemModal({ debt, onSave, onClose, categories }) {
  const tiposGasto = [
    'Servicios', 'Alimentacion', 'Transporte', 'Vivienda', 'Educacion',
    'Salud', 'Entretenimiento', 'Seguros', 'Impuestos', 'Prestamo', 'Tarjeta', 'Otro'
  ];

  const tiposIngreso = [
    'Sueldos', 'Honorarios', 'Alquileres', 'Inversiones', 'Freelance', 'Ventas', 'Reintegros', 'Otro'
  ];

  const [formData, setFormData] = useState({
    fecha: '',
    tipo: 'Prestamo',
    categoria: 'Personal',
    monto_total: '',
    detalle: '',
    fecha_vencimiento: '',
    tipo_presupuesto: 'OBLIGATION',
    tipo_flujo: 'Gasto',
    expense_type: 'VARIABLE',
    monto_ejecutado: '0',
    estimated_payment: ''
  });

  const categoryOptions = useMemo(() => {
    const map = new Map();
    if (Array.isArray(categories)) {
      for (const category of categories) {
        const option = getCategoryOption(category);
        if (!option) continue;
        const key = option.value.toLowerCase();
        if (!map.has(key)) {
          map.set(key, option);
        }
      }
    }

    if (debt?.categoria) {
      const current = getCategoryOption(debt.categoria);
      if (current) {
        map.set(current.value.toLowerCase(), current);
      }
    }

    if (!map.size) {
      map.set('otro', { value: 'Otro', label: 'Otro' });
    }

    return Array.from(map.values()).sort((a, b) => a.label.localeCompare(b.label, 'es', { sensitivity: 'base' }));
  }, [categories, debt]);

  useEffect(() => {
    if (!debt) return;

    setFormData({
      fecha: toISODate(debt.fecha),
      tipo: debt.tipo,
      categoria: debt.categoria,
      monto_total: debt.monto_total.toString(),
      detalle: debt.detalle || '',
      fecha_vencimiento: toISODate(debt.fecha_vencimiento) || '',
      tipo_presupuesto: debt.tipo_presupuesto || 'OBLIGATION',
      tipo_flujo: debt.tipo_flujo || 'Gasto',
      expense_type: debt.expense_type || 'VARIABLE',
      monto_ejecutado: (debt.monto_ejecutado || debt.monto_pagado || 0).toString(),
      estimated_payment: (debt.estimated_payment != null ? debt.estimated_payment : debt.monto_total).toString()
    });
  }, [debt]);

  const handleChange = (e) => {
    const { name, value } = e.target;

    if (name === 'tipo_flujo') {
      setFormData((prev) => ({
        ...prev,
        tipo_flujo: value,
        tipo: value === 'Ingreso' ? tiposIngreso[0] : tiposGasto[0]
      }));
      return;
    }

    if (name === 'monto_total') {
      setFormData((prev) => ({
        ...prev,
        monto_total: value,
        estimated_payment: (!prev.estimated_payment || prev.estimated_payment === prev.monto_total)
          ? value
          : prev.estimated_payment
      }));
      return;
    }

    setFormData((prev) => ({ ...prev, [name]: value }));
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
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600 transition-colors">
            <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Fecha *</label>
              <input type="date" name="fecha" value={formData.fecha} onChange={handleChange} required className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all" />
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Tipo de {formData.tipo_flujo} *</label>
              <select name="tipo" value={formData.tipo} onChange={handleChange} required className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all">
                {(formData.tipo_flujo === 'Ingreso' ? tiposIngreso : tiposGasto).map((tipo) => (
                  <option key={tipo} value={tipo}>{tipo}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Recurrencia *</label>
              <select name="expense_type" value={formData.expense_type} onChange={handleChange} required className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all">
                <option value="FIJO">Fijo</option>
                <option value="VARIABLE">Variable</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Categoria *</label>
              <select name="categoria" value={formData.categoria} onChange={handleChange} required className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all">
                {categoryOptions.map((cat) => (
                  <option key={cat.value} value={cat.value}>{cat.label}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Monto Total *</label>
              <input type="number" name="monto_total" value={formData.monto_total} onChange={handleChange} step="0.01" min="0" required className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all" />
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Monto a Pagar</label>
              <input type="number" name="estimated_payment" value={formData.estimated_payment} onChange={handleChange} step="0.01" min="0" placeholder={formData.monto_total || '0.00'} className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all" />
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Tipo de Presupuesto *</label>
              <select name="tipo_presupuesto" value={formData.tipo_presupuesto} onChange={handleChange} required className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all">
                <option value="OBLIGATION">Obligacion (Deuda/Compromiso)</option>
                <option value="VARIABLE">Variable (Presupuesto Flexible)</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Tipo de Flujo *</label>
              <select name="tipo_flujo" value={formData.tipo_flujo} onChange={handleChange} required className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all">
                <option value="Gasto">Gasto</option>
                <option value="Ingreso">Ingreso</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Fecha de Vencimiento</label>
              <input type="date" name="fecha_vencimiento" value={formData.fecha_vencimiento} onChange={handleChange} className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all" />
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Monto Ejecutado (Read-only)</label>
              <input type="number" name="monto_ejecutado" value={formData.monto_ejecutado} readOnly className="w-full px-4 py-2 border border-gray-300 rounded-lg bg-gray-100 text-gray-600 cursor-not-allowed" />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-finly-text mb-2">Detalle</label>
            <textarea name="detalle" value={formData.detalle} onChange={handleChange} rows={3} className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent transition-all resize-none" placeholder="Descripcion del item de presupuesto (opcional)" />
          </div>

          <div className="flex gap-3 pt-4">
            <button type="button" onClick={onClose} className="flex-1 px-6 py-3 border border-gray-300 rounded-lg text-gray-700 font-semibold hover:bg-gray-50 transition-colors">Cancelar</button>
            <button type="submit" className="flex-1 px-6 py-3 bg-finly-primary rounded-lg text-white font-semibold hover:bg-finly-secondary transition-colors">Guardar Cambios</button>
          </div>
        </form>
      </div>
    </div>
  );
}

export default EditBudgetItemModal;
