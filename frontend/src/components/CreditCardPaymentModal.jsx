import { useState, useEffect } from 'react';
import { debtsAPI } from '../services/api';

export default function CreditCardPaymentModal({
  isOpen,
  onClose,
  onSubmit,
  cardName,
  periodYear,
  periodMonth,
  totalDue,
  totalPaid,
  budgetItemId,
  editingPayment,
}) {
  const [amount, setAmount] = useState('');
  const [debtId, setDebtId] = useState('');
  const [detail, setDetail] = useState('');
  const [date, setDate] = useState(new Date().toISOString().split('T')[0]);
  const [paymentMethod, setPaymentMethod] = useState('Transferencia');
  const [debts, setDebts] = useState([]);
  const [loading, setLoading] = useState(false);

  const isEditing = !!editingPayment;
  const pendiente = Math.max(0, totalDue - totalPaid + (isEditing ? editingPayment.amount : 0));

  useEffect(() => {
    if (isOpen) {
      loadDebts();
      if (editingPayment) {
        setAmount(String(editingPayment.amount));
        setDetail(editingPayment.detail || '');
        setDate(editingPayment.date || new Date().toISOString().split('T')[0]);
        setPaymentMethod(editingPayment.payment_method || 'Transferencia');
        setDebtId(budgetItemId ? String(budgetItemId) : '');
      } else {
        setAmount('');
        setDetail('');
        setDate(new Date().toISOString().split('T')[0]);
        setPaymentMethod('Transferencia');
        setDebtId(budgetItemId ? String(budgetItemId) : '');
      }
    }
  }, [isOpen, budgetItemId, editingPayment]);

  const loadDebts = async () => {
    try {
      const response = await debtsAPI.getDebts();
      const allDebts = (response.data || []).sort((a, b) => {
        const labelA = (a.detalle || `Presupuesto ${a.tipo || ''}`).trim().toLowerCase();
        const labelB = (b.detalle || `Presupuesto ${b.tipo || ''}`).trim().toLowerCase();
        return labelA.localeCompare(labelB, 'es');
      });
      setDebts(allDebts);
    } catch (error) {
      console.error('Error loading budget items:', error);
    }
  };

  const formatCurrency = (val) =>
    new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' }).format(val);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const parsedAmount = parseFloat(amount);
    if (!parsedAmount || parsedAmount <= 0) return;

    setLoading(true);
    try {
      const transaction = {
        date,
        type: 'Gasto',
        category: 'Tarjeta de Crédito',
        amount: parsedAmount,
        necessity: 'Necesario',
        payment_method: paymentMethod,
        detail: detail || `Pago ${cardName} (${String(periodMonth).padStart(2, '0')}/${periodYear})`,
        debt_id: debtId ? parseInt(debtId) : null,
        timestamp: new Date().toISOString(),
      };
      if (isEditing) {
        transaction.id = editingPayment.id;
      }
      await onSubmit(transaction, isEditing);
    } finally {
      setLoading(false);
    }
  };

  if (!isOpen) return null;

  // Filter debts for the period month
  const periodKey = `${periodYear}-${String(periodMonth).padStart(2, '0')}`;
  const debtsForMonth = debts.filter(
    (d) => d.fecha_vencimiento && d.fecha_vencimiento.substring(0, 7) === periodKey
  );

  // Separate: suggested (Tarjeta de Crédito category) vs others
  const suggestedDebts = debtsForMonth.filter(
    (d) => d.categoria === 'Tarjeta de Crédito' && d.tipo_flujo === 'Gasto'
  );
  const otherDebts = debtsForMonth.filter(
    (d) => !(d.categoria === 'Tarjeta de Crédito' && d.tipo_flujo === 'Gasto')
  );

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg">
        {/* Header */}
        <div className={`bg-gradient-to-r ${isEditing ? 'from-blue-600 to-blue-700' : 'from-green-600 to-green-700'} rounded-t-2xl p-5`}>
          <h2 className="text-xl font-bold text-white">{isEditing ? '✏️ Editar Pago de Tarjeta' : '💳 Registrar Pago de Tarjeta'}</h2>
          <p className="text-green-100 text-sm mt-1">
            {cardName} — {String(periodMonth).padStart(2, '0')}/{periodYear}
          </p>
        </div>

        {/* Summary */}
        <div className="px-6 pt-4 pb-2">
          <div className="grid grid-cols-3 gap-3 text-center">
            <div className="bg-gray-50 rounded-lg p-2">
              <p className="text-xs text-gray-500">Total</p>
              <p className="font-bold text-gray-800 text-sm">{formatCurrency(totalDue)}</p>
            </div>
            <div className="bg-green-50 rounded-lg p-2">
              <p className="text-xs text-gray-500">Pagado</p>
              <p className="font-bold text-green-600 text-sm">{formatCurrency(totalPaid)}</p>
            </div>
            <div className="bg-red-50 rounded-lg p-2">
              <p className="text-xs text-gray-500">Pendiente</p>
              <p className="font-bold text-red-600 text-sm">{formatCurrency(pendiente)}</p>
            </div>
          </div>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 pt-3 space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Fecha</label>
              <input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Monto (ARS) *</label>
              <input
                type="number"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                step="0.01"
                min="0.01"
                placeholder={pendiente > 0 ? pendiente.toFixed(2) : '0.00'}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
                required
                autoFocus
              />
            </div>
          </div>

          {/* Quick amount buttons */}
          {pendiente > 0 && (
            <div className="flex gap-2">
              <button
                type="button"
                onClick={() => setAmount(pendiente.toFixed(2))}
                className="px-3 py-1 text-xs bg-green-100 text-green-700 rounded-full hover:bg-green-200 transition-colors"
              >
                Pendiente: {formatCurrency(pendiente)}
              </button>
              <button
                type="button"
                onClick={() => setAmount(totalDue.toFixed(2))}
                className="px-3 py-1 text-xs bg-blue-100 text-blue-700 rounded-full hover:bg-blue-200 transition-colors"
              >
                Total: {formatCurrency(totalDue)}
              </button>
            </div>
          )}

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Forma de Pago</label>
            <select
              value={paymentMethod}
              onChange={(e) => setPaymentMethod(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
            >
              <option value="Transferencia">Transferencia</option>
              <option value="Débito">Débito</option>
              <option value="Efectivo">Efectivo</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Item de Presupuesto
              {budgetItemId && (
                <span className="ml-2 text-xs text-green-600">✅ Período registrado</span>
              )}
            </label>
            <select
              value={debtId}
              onChange={(e) => setDebtId(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
            >
              <option value="">-- Sin asignar --</option>
              {suggestedDebts.length > 0 && (
                <optgroup label="🎯 Tarjeta de Crédito">
                  {suggestedDebts.map((debt) => {
                    const ejecutado = debt.monto_ejecutado ?? debt.monto_pagado ?? 0;
                    const remaining = debt.monto_total - ejecutado;
                    return (
                      <option key={debt.id} value={debt.id}>
                        {debt.detalle || `${debt.tipo} - ${debt.categoria}`} - Resta: {formatCurrency(remaining)}
                      </option>
                    );
                  })}
                </optgroup>
              )}
              {otherDebts.length > 0 && (
                <optgroup label="📋 Otros items de presupuesto">
                  {otherDebts.map((debt) => {
                    const ejecutado = debt.monto_ejecutado ?? debt.monto_pagado ?? 0;
                    const remaining = debt.monto_total - ejecutado;
                    const flujoIcon = debt.tipo_flujo === 'Gasto' ? '💸' : '💰';
                    return (
                      <option key={debt.id} value={debt.id}>
                        {flujoIcon} {debt.detalle || `${debt.tipo} - ${debt.categoria}`} - Resta: {formatCurrency(remaining)}
                      </option>
                    );
                  })}
                </optgroup>
              )}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Detalle (opcional)</label>
            <input
              type="text"
              value={detail}
              onChange={(e) => setDetail(e.target.value)}
              maxLength={50}
              placeholder={`Pago ${cardName}`}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>

          {/* Actions */}
          <div className="flex justify-end gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="px-5 py-2.5 rounded-lg font-medium text-gray-600 bg-gray-100 hover:bg-gray-200 transition-colors"
              disabled={loading}
            >
              Cancelar
            </button>
            <button
              type="submit"
              disabled={loading || !amount || parseFloat(amount) <= 0}
              className={`px-5 py-2.5 rounded-lg font-medium text-white ${isEditing ? 'bg-blue-600 hover:bg-blue-700' : 'bg-green-600 hover:bg-green-700'} transition-colors disabled:opacity-50 disabled:cursor-not-allowed shadow-md`}
            >
              {loading ? '⏳ Guardando...' : isEditing ? '✅ Guardar Cambios' : '✅ Registrar Pago'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
