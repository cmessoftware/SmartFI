import { useState, useEffect } from 'react';
import { debtsAPI, transactionsAPI } from '../services/api';
import { useToast } from './ToastContainer';

export default function NewDebtModal({ isOpen, onClose, onSuccess }) {
  const toast = useToast();
  const [formData, setFormData] = useState({
    fecha: new Date().toISOString().split('T')[0],
    tipo: 'Préstamo',
    categoria: 'Personal',
    monto_total: '',
    monto_pagado: '0',
    detalle: '',
    fecha_vencimiento: '',
    tipo_presupuesto: 'OBLIGATION',
    tipo_flujo: 'Gasto',
    monto_ejecutado: '0'
  });

  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (isOpen) {
      loadCategories();
    }
  }, [isOpen]);

  const loadCategories = async () => {
    try {
      const response = await transactionsAPI.getCategories();
      setCategories(response.data || []);
    } catch (error) {
      console.error('Error loading categories:', error);
      // Fallback defensivo
      setCategories(['Personal', 'Vivienda', 'Transporte', 'Educación', 'Salud', 'Otro']);
    }
  };

  const handleChange = (e) => {
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

    setLoading(true);
    try {
      await debtsAPI.createDebt(formData);
      toast.success('Item de presupuesto creado correctamente');
      
      // Reset form
      setFormData({
        fecha: new Date().toISOString().split('T')[0],
        tipo: 'Préstamo',
        categoria: 'Personal',
        monto_total: '',
        monto_pagado: '0',
        detalle: '',
        fecha_vencimiento: '',
        tipo_presupuesto: 'OBLIGATION',
        tipo_flujo: 'Gasto',
        monto_ejecutado: '0'
      });
      
      onSuccess();
      onClose();
    } catch (error) {
      toast.error('Error al crear item de presupuesto');
      console.error('Error creating debt:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    if (loading) return;
    setFormData({
      fecha: new Date().toISOString().split('T')[0],
      tipo: 'Préstamo',
      categoria: 'Personal',
      monto_total: '',
      monto_pagado: '0',
      detalle: '',
      fecha_vencimiento: '',
      tipo_presupuesto: 'OBLIGATION',
      tipo_flujo: 'Gasto',
      monto_ejecutado: '0'
    });
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-3xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b px-6 py-4 flex justify-between items-center">
          <h2 className="text-2xl font-bold text-finly-text">
            Nuevo Item de Presupuesto
          </h2>
          <button
            onClick={handleClose}
            disabled={loading}
            className="text-gray-500 hover:text-gray-700 text-2xl disabled:opacity-50"
          >
            ✕
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Fecha *
              </label>
              <input
                type="date"
                name="fecha"
                value={formData.fecha}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Tipo *
              </label>
              <select
                name="tipo"
                value={formData.tipo}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              >
                <option value="Préstamo">Préstamo</option>
                <option value="Tarjeta">Tarjeta</option>
                <option value="Servicio">Servicio</option>
                <option value="Otro">Otro</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Tipo de Presupuesto *
              </label>
              <select
                name="tipo_presupuesto"
                value={formData.tipo_presupuesto}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              >
                <option value="OBLIGATION">Obligación (Deuda/Compromiso)</option>
                <option value="VARIABLE">Variable (Flexible)</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Tipo de Flujo *
              </label>
              <select
                name="tipo_flujo"
                value={formData.tipo_flujo}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              >
                <option value="Gasto">💸 Gasto</option>
                <option value="Ingreso">💰 Ingreso</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Categoría *
              </label>
              <select
                name="categoria"
                value={formData.categoria}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              >
                {categories.length > 0 ? (
                  categories.map((category) => (
                    <option key={category} value={category}>{category}</option>
                  ))
                ) : (
                  <option value="Otro">Otro</option>
                )}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Monto Total (ARS) *
              </label>
              <input
                type="number"
                name="monto_total"
                value={formData.monto_total}
                onChange={handleChange}
                step="0.01"
                min="0"
                placeholder="0.00"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Fecha Vencimiento
                <span className="text-xs text-gray-500 ml-2">(Opcional)</span>
              </label>
              <input
                type="date"
                name="fecha_vencimiento"
                value={formData.fecha_vencimiento}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
              />
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-finly-text mb-2">
                Detalle
              </label>
              <textarea
                name="detalle"
                value={formData.detalle}
                onChange={handleChange}
                rows="3"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                placeholder="Descripción del item de presupuesto..."
              />
            </div>
          </div>

          <div className="mt-6 flex gap-3 justify-end">
            <button
              type="button"
              onClick={handleClose}
              disabled={loading}
              className="px-6 py-3 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors disabled:opacity-50"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={loading}
              className="bg-finly-primary text-white px-6 py-3 rounded-lg hover:bg-finly-secondary transition-colors disabled:opacity-50"
            >
              {loading ? 'Guardando...' : 'Guardar Item'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
