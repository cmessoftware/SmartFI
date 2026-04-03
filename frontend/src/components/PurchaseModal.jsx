import { useState, useEffect } from 'react';
import { creditCardAPI, adminAPI } from '../services/api';
import { useToast } from './ToastContainer';

export default function PurchaseModal({ isOpen, card, purchase, onClose, onSuccess }) {
  const toast = useToast();
  const isEditMode = !!purchase;

  const getDefaultFormData = () => ({
    description: '',
    amount: '',
    purchase_date: new Date().toISOString().split('T')[0],
    installments: '1',
    interest_rate: '0',
    plan_type: 'MANUAL',
    currency: 'ARS'
  });

  const [formData, setFormData] = useState(getDefaultFormData());
  const [loading, setLoading] = useState(false);
  const [exchangeRate, setExchangeRate] = useState(null);

  useEffect(() => {
    if (purchase) {
      setFormData({
        description: purchase.description || '',
        amount: String(purchase.total_amount || ''),
        purchase_date: purchase.purchase_date || new Date().toISOString().split('T')[0],
        installments: String(purchase.installments || '1'),
        interest_rate: String(purchase.interest_rate || '0'),
        plan_type: 'MANUAL',
        currency: purchase.currency || 'ARS'
      });
    } else {
      setFormData(getDefaultFormData());
    }
  }, [purchase]);

  useEffect(() => {
    if (isOpen) {
      adminAPI.getSetting('dollar_exchange_rate')
        .then(res => setExchangeRate(parseFloat(res.data.value)))
        .catch(() => setExchangeRate(null));
    }
  }, [isOpen]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!formData.description.trim()) {
      toast.warning('Ingrese una descripción de la compra');
      return;
    }

    const amount = parseFloat(formData.amount);
    if (!amount || amount <= 0) {
      toast.warning('Ingrese un monto válido');
      return;
    }

    const installments = parseInt(formData.installments);
    if (!installments || installments < 1) {
      toast.warning('El número de cuotas debe ser al menos 1');
      return;
    }

    const interestRate = parseFloat(formData.interest_rate);
    if (interestRate < 0) {
      toast.warning('La tasa de interés no puede ser negativa');
      return;
    }

    setLoading(true);
    try {
      if (isEditMode) {
        await creditCardAPI.updatePurchase(purchase.id, {
          description: formData.description,
          amount: amount,
          purchase_date: formData.purchase_date,
          installments: installments,
          interest_rate: interestRate,
          category: purchase.category,
          currency: formData.currency
        });
        toast.success('Compra actualizada correctamente');
      } else {
        const payload = {
          card_id: card.id,
          description: formData.description,
          amount: amount,
          purchase_date: formData.purchase_date,
          installments: installments,
          interest_rate: interestRate,
          plan_type: formData.plan_type,
          currency: formData.currency
        };
        await creditCardAPI.createPurchase(payload);
        toast.success('Compra registrada correctamente');
      }
      
      setFormData(getDefaultFormData());
      onSuccess();
      onClose();
    } catch (error) {
      toast.error(isEditMode ? 'Error al actualizar compra' : 'Error al registrar compra');
      console.error('Error saving purchase:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    if (loading) return;
    setFormData(getDefaultFormData());
    onClose();
  };

  const calculateMonthlyPayment = () => {
    const amount = parseFloat(formData.amount);
    const installments = parseInt(formData.installments);
    const interestRate = parseFloat(formData.interest_rate);

    if (!amount || !installments || installments < 1) return null;

    if (interestRate === 0) {
      return amount / installments;
    }

    // Amortización francesa
    const monthlyRate = interestRate / 12 / 100;
    const payment = amount * (monthlyRate * Math.pow(1 + monthlyRate, installments)) / 
                    (Math.pow(1 + monthlyRate, installments) - 1);
    return payment;
  };

  const getTotalWithInterest = () => {
    const monthlyPayment = calculateMonthlyPayment();
    const installments = parseInt(formData.installments);
    if (!monthlyPayment || !installments) return null;
    return monthlyPayment * installments;
  };

  const monthlyPayment = calculateMonthlyPayment();
  const totalWithInterest = getTotalWithInterest();

  if (!isOpen || (!card && !purchase)) return null;

  const cardName = card?.card_name || '';
  const bankName = card?.bank_name || '';

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b px-6 py-4 flex justify-between items-center">
          <div>
            <h2 className="text-2xl font-bold text-finly-text">{isEditMode ? '✏️ Editar Compra' : 'Nueva Compra'}</h2>
            {cardName && <p className="text-sm text-gray-500 mt-1">{cardName} - {bankName}</p>}
          </div>
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
            {/* Descripción */}
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Descripción *
              </label>
              <input
                type="text"
                name="description"
                value={formData.description}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent"
                placeholder="Ej: Laptop HP"
                required
              />
            </div>

            {/* Monto */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Monto *
              </label>
              <input
                type="number"
                name="amount"
                value={formData.amount}
                onChange={handleChange}
                step="0.01"
                min="0.01"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent"
                placeholder="1200.00"
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
                <option value="ARS">🇦🇷 Pesos (ARS)</option>
                <option value="USD">🇺🇸 Dólares (USD)</option>
              </select>
              {formData.currency === 'USD' && exchangeRate && parseFloat(formData.amount) > 0 && (
                <p className="text-xs text-blue-600 mt-1">
                  ≈ {new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' }).format(parseFloat(formData.amount) * exchangeRate)} (cotización: ${exchangeRate})
                </p>
              )}
            </div>

            {/* Fecha de Compra */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Fecha de Compra *
              </label>
              <input
                type="date"
                name="purchase_date"
                value={formData.purchase_date}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent"
                required
              />
            </div>

            {/* Número de Cuotas */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Número de Cuotas *
              </label>
              <input
                type="number"
                name="installments"
                value={formData.installments}
                onChange={handleChange}
                min="1"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent"
                required
              />
            </div>

            {/* Tasa de Interés */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tasa de Interés Anual (%)
              </label>
              <input
                type="number"
                name="interest_rate"
                value={formData.interest_rate}
                onChange={handleChange}
                step="0.01"
                min="0"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent"
                placeholder="0.00"
              />
            </div>

            {/* Tipo de Plan - solo al crear */}
            {!isEditMode && (
            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Tipo de Plan
              </label>
              <select
                name="plan_type"
                value={formData.plan_type}
                onChange={handleChange}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-finly-primary focus:border-transparent"
              >
                <option value="MANUAL">Manual</option>
                <option value="AUTOMATIC">Automático</option>
              </select>
              <p className="text-xs text-gray-500 mt-1">
                Manual: Controlas los pagos | Automático: Se genera plan de cuotas fijas
              </p>
            </div>
            )}
          </div>

          {/* Cálculo de Cuotas */}
          {monthlyPayment && (
            <div className="mt-6 bg-indigo-50 border border-indigo-200 rounded-lg p-4">
              <h3 className="font-semibold text-indigo-900 mb-3">Resumen del Plan de Cuotas</h3>
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <p className="text-gray-600">Cuota Mensual:</p>
                  <p className="text-lg font-bold text-indigo-900">{new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' }).format(monthlyPayment)}</p>
                </div>
                <div>
                  <p className="text-gray-600">Total con Intereses:</p>
                  <p className="text-lg font-bold text-indigo-900">{new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' }).format(totalWithInterest)}</p>
                </div>
                <div>
                  <p className="text-gray-600">Monto Original:</p>
                  <p className="text-sm font-medium">{new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' }).format(parseFloat(formData.amount))}</p>
                </div>
                <div>
                  <p className="text-gray-600">Intereses Totales:</p>
                  <p className="text-sm font-medium text-red-600">
                    {new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' }).format(totalWithInterest - parseFloat(formData.amount))}
                  </p>
                </div>
              </div>
            </div>
          )}

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
              {loading ? (isEditMode ? 'Guardando...' : 'Registrando...') : (isEditMode ? 'Guardar Cambios' : 'Registrar Compra')}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
