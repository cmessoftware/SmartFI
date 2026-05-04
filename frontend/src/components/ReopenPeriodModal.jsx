import { useState } from 'react';
import { monthsAPI } from '../services/api';

const MONTH_NAMES = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
];

const MIN_REASON_LENGTH = 10;

export default function ReopenPeriodModal({ yearMonth, onClose, onReopened }) {
  const [reason, setReason] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const [year, month] = yearMonth.split('-').map(Number);
  const monthName = MONTH_NAMES[month - 1];
  const isValid = reason.trim().length >= MIN_REASON_LENGTH;

  const handleConfirm = async () => {
    if (!isValid) return;
    setLoading(true);
    setError(null);
    try {
      const res = await monthsAPI.reopenMonth(yearMonth, reason.trim());
      onReopened(res.data);
    } catch (err) {
      setError(err.response?.data?.detail || 'Error al reabrir el mes');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl p-6 max-w-md w-full mx-4">
        <h2 className="text-lg font-semibold text-gray-900 mb-2">
          Reabrir mes: {monthName} {year}
        </h2>
        <p className="text-sm text-gray-600 mb-4">
          Ingresá el motivo de la reapertura. Las transacciones del mes quedarán desbloqueadas.
        </p>

        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Motivo <span className="text-red-500">*</span>
          </label>
          <textarea
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            rows={3}
            className="w-full border border-gray-300 rounded px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Describí el motivo de la reapertura..."
          />
          <div className="flex justify-between mt-1">
            <span className={`text-xs ${isValid ? 'text-green-600' : 'text-gray-500'}`}>
              {isValid ? '✓ Motivo válido' : `Mínimo ${MIN_REASON_LENGTH} caracteres`}
            </span>
            <span className="text-xs text-gray-400">{reason.length} caracteres</span>
          </div>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded text-sm text-red-700">
            {error}
          </div>
        )}

        <div className="flex gap-3 justify-end">
          <button
            onClick={onClose}
            disabled={loading}
            className="px-4 py-2 text-sm text-gray-700 border border-gray-300 rounded hover:bg-gray-50 disabled:opacity-50"
          >
            Cancelar
          </button>
          <button
            onClick={handleConfirm}
            disabled={loading || !isValid}
            className="px-4 py-2 text-sm text-white bg-yellow-600 rounded hover:bg-yellow-700 disabled:opacity-50"
          >
            {loading ? 'Reabriendo...' : 'Confirmar reapertura'}
          </button>
        </div>
      </div>
    </div>
  );
}
