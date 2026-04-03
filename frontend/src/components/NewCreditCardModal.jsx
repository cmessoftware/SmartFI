import { useState } from 'react';
import { creditCardAPI } from '../services/api';
import { useToast } from './ToastContainer';

export default function NewCreditCardModal({ isOpen, onClose, onSuccess }) {
  const toast = useToast();
  const [formData, setFormData] = useState({
    card_name: '',
    bank_name: '',
    closing_day: '',
    due_day: '',
    currency: 'USD',
    credit_limit: '',
    is_active: true,
    notes: ''
  });
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!formData.card_name.trim()) {
      toast.warning('Ingrese el nombre de la tarjeta');
      return;
    }

    if (!formData.bank_name.trim()) {
      toast.warning('Ingrese el nombre del banco');
      return;
    }

    const closingDay = parseInt(formData.closing_day);
    const dueDay = parseInt(formData.due_day);

    if (!closingDay || closingDay < 1 || closingDay > 31) {
      toast.warning('El día de cierre debe estar entre 1 y 31');
      return;
    }

    if (!dueDay || dueDay < 1 || dueDay > 31) {
      toast.warning('El día de vencimiento debe estar entre 1 y 31');
      return;
    }

    setLoading(true);
    try {
      const payload = {
        ...formData,
        closing_day: closingDay,
        due_day: dueDay,
        credit_limit: formData.credit_limit ? parseFloat(formData.credit_limit) : null
      };

      await creditCardAPI.createCreditCard(payload);
      toast.success('Tarjeta de crédito creada correctamente');
      
      // Reset form
      setFormData({
        card_name: '',
        bank_name: '',
        closing_day: '',
        due_day: '',
        currency: 'USD',
        credit_limit: '',
        is_active: true,
        notes: ''
      });
      
      onSuccess();
      onClose();
    } catch (error) {
      const msg = error.response?.data?.detail || 'Error al crear tarjeta de crédito';
      toast.error(msg);
      console.error('Error creating credit card:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    if (loading) return;
    setFormData({
      card_name: '',
      bank_name: '',
      closing_day: '',
      due_day: '',
      currency: 'USD',
      credit_limit: '',
      is_active: true,
      notes: ''
    });
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b px-6 py-4 flex justify-between items-center">
          <h2 className="text-2xl font-bold text-finly-text">Nueva Tarjeta de Crédito</h2>
          <button
            onClick={handleClose}
            disabled={loading}
            className="text-gray-400 hover:text-gray-600 text-2xl"
          >
            ×
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Nombre de la Tarjeta */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Nombre de la Tarjeta *
              </label>
              <input
                type="text"
                name="card_name"
                value={formData.card_name}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent"
                placeholder="Ej: Visa Platinum"
                required
              />
            </div>

            {/* Banco */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Banco *
              </label>
              <input
                type="text"
                name="bank_name"
                value={formData.bank_name}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent"
                placeholder="Ej: Banco Nacional"
                required
              />
            </div>

            {/* Día de Cierre */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Día de Cierre (1-31) *
              </label>
              <input
                type="number"
                name="closing_day"
                value={formData.closing_day}
                onChange={handleChange}
                min="1"
                max="31"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent"
                placeholder="15"
                required
              />
            </div>

            {/* Día de Vencimiento */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Día de Vencimiento (1-31) *
              </label>
              <input
                type="number"
                name="due_day"
                value={formData.due_day}
                onChange={handleChange}
                min="1"
                max="31"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent"
                placeholder="25"
                required
              />
            </div>

            {/* Moneda */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Moneda
              </label>
              <select
                name="currency"
                value={formData.currency}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent"
              >
                <option value="USD">USD</option>
                <option value="EUR">EUR</option>
                <option value="MXN">MXN</option>
                <option value="COP">COP</option>
                <option value="ARS">ARS</option>
              </select>
            </div>

            {/* Límite de Crédito */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Límite de Crédito (Opcional)
              </label>
              <input
                type="number"
                name="credit_limit"
                value={formData.credit_limit}
                onChange={handleChange}
                step="0.01"
                min="0"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent"
                placeholder="5000.00"
              />
            </div>

            {/* Notas */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Notas
              </label>
              <textarea
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                rows="3"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent"
                placeholder="Notas adicionales..."
              />
            </div>

            {/* Tarjeta Activa */}
            <div className="md:col-span-2">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  name="is_active"
                  checked={formData.is_active}
                  onChange={handleChange}
                  className="w-4 h-4 text-finly-primary rounded focus:ring-finly-primary"
                />
                <span className="text-sm text-gray-700">Tarjeta activa</span>
              </label>
            </div>
          </div>

          {/* Buttons */}
          <div className="flex gap-3 mt-6 pt-4 border-t">
            <button
              type="button"
              onClick={handleClose}
              disabled={loading}
              className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors disabled:opacity-50"
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={loading}
              className="flex-1 px-4 py-2 bg-finly-primary text-white rounded-lg hover:bg-finly-primary-dark transition-colors disabled:opacity-50 font-medium"
            >
              {loading ? 'Creando...' : 'Crear Tarjeta'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
