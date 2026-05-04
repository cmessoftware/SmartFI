import { useState } from 'react';
import { monthsAPI } from '../services/api';

const MONTH_NAMES = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
];

export default function ClosePeriodModal({ yearMonth, onClose, onClosed }) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [snapshot, setSnapshot] = useState(null);

  const [year, month] = yearMonth.split('-').map(Number);
  const monthName = MONTH_NAMES[month - 1];

  const handleConfirm = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await monthsAPI.closeMonth(yearMonth);
      setSnapshot(res.data?.snapshot || null);
      onClosed(res.data);
    } catch (err) {
      setError(err.response?.data?.detail || 'Error al cerrar el mes');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl p-6 max-w-md w-full mx-4">
        <h2 className="text-lg font-semibold text-gray-900 mb-2">
          Cerrar mes: {monthName} {year}
        </h2>
        <p className="text-sm text-gray-600 mb-4">
          Al cerrar el período, las transacciones de este mes quedarán bloqueadas para usuarios no administradores.
          Se creará un snapshot con el balance actual.
        </p>

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
            disabled={loading}
            className="px-4 py-2 text-sm text-white bg-red-600 rounded hover:bg-red-700 disabled:opacity-50"
          >
            {loading ? 'Cerrando...' : 'Confirmar cierre'}
          </button>
        </div>
      </div>
    </div>
  );
}
