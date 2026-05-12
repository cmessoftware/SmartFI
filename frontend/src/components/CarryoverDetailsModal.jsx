import { useEffect, useState } from 'react';
import { monthsAPI } from '../services/api';

export default function CarryoverDetailsModal({ yearMonth, onClose }) {
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    let mounted = true;
    const load = async () => {
      setLoading(true);
      setError(null);
      try {
        const res = await monthsAPI.getCarryover(yearMonth);
        if (mounted) {
          setData(res.data);
        }
      } catch (err) {
        if (mounted) {
          setError('No hay detalle de carryover para este mes.');
        }
      } finally {
        if (mounted) {
          setLoading(false);
        }
      }
    };

    load();
    return () => {
      mounted = false;
    };
  }, [yearMonth]);

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl p-6 max-w-md w-full mx-4">
        <h2 className="text-lg font-semibold text-gray-900 mb-2">Detalle de carryover</h2>
        <p className="text-sm text-gray-600 mb-4">Mes objetivo: {yearMonth}</p>

        {loading && <p className="text-sm text-gray-500">Cargando...</p>}

        {!loading && error && (
          <div className="mb-4 p-3 bg-yellow-50 border border-yellow-200 rounded text-sm text-yellow-700">
            {error}
          </div>
        )}

        {!loading && data && (
          <div className="space-y-2 text-sm">
            <p>Mes origen: <strong>{data.source_month}</strong></p>
            <p>
              Monto trasladado:{' '}
              <strong className={data.balance_amount >= 0 ? 'text-green-700' : 'text-red-700'}>
                {new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' }).format(data.balance_amount || 0)}
              </strong>
            </p>
            <p>Tipo: <strong>{data.balance_type}</strong></p>
            <p>Fecha: <strong>{data.carryover_date ? new Date(data.carryover_date).toLocaleString('es-AR') : '-'}</strong></p>
            <p>ID transacción: <strong>{data.transaction_id || '-'}</strong></p>
          </div>
        )}

        <div className="flex justify-end mt-6">
          <button
            onClick={onClose}
            className="px-4 py-2 text-sm text-gray-700 border border-gray-300 rounded hover:bg-gray-50"
          >
            Cerrar
          </button>
        </div>
      </div>
    </div>
  );
}
