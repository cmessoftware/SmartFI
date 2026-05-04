import { useEffect, useMemo, useState } from 'react';
import { monthsAPI } from '../services/api';

const MONTH_NAMES = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
];

const getPrevMonth = (yearMonth) => {
  const [y, m] = yearMonth.split('-').map(Number);
  if (m === 1) return `${y - 1}-12`;
  return `${y}-${String(m - 1).padStart(2, '0')}`;
};

export default function OpenMonthModal({ yearMonth, onClose, onOpened }) {
  const [loading, setLoading] = useState(false);
  const [previewLoading, setPreviewLoading] = useState(true);
  const [error, setError] = useState(null);
  const [preview, setPreview] = useState(null);
  const [includeCarryover, setIncludeCarryover] = useState(true);
  const [includeBudgetClone, setIncludeBudgetClone] = useState(true);

  const [year, month] = yearMonth.split('-').map(Number);
  const monthName = MONTH_NAMES[month - 1];
  const priorMonth = useMemo(() => getPrevMonth(yearMonth), [yearMonth]);

  useEffect(() => {
    let mounted = true;
    const loadPreview = async () => {
      setPreviewLoading(true);
      setError(null);
      try {
        const [statusRes, budgetRes] = await Promise.all([
          monthsAPI.getStatus(priorMonth),
          monthsAPI.getBudgetItems(priorMonth, true),
        ]);

        const prevStatus = statusRes.data;
        const prevSnapshot = statusRes.data?.snapshot || null;
        const previewData = {
          priorMonth,
          priorStatus: prevStatus?.status || 'OPEN',
          priorClosed: prevStatus?.status === 'CLOSED',
          estimatedCarryover: prevSnapshot?.net_balance ?? 0,
          estimatedCloneCount: Array.isArray(budgetRes.data) ? budgetRes.data.length : 0,
        };

        if (mounted) {
          setPreview(previewData);
        }
      } catch (err) {
        if (mounted) {
          setError('No se pudo cargar el preview de apertura.');
        }
      } finally {
        if (mounted) {
          setPreviewLoading(false);
        }
      }
    };

    loadPreview();
    return () => {
      mounted = false;
    };
  }, [priorMonth]);

  const handleConfirm = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await monthsAPI.openMonth({
        year_month: yearMonth,
        include_carryover: includeCarryover,
        include_budget_clone: includeBudgetClone,
      });
      onOpened(res.data);
    } catch (err) {
      const detail = err.response?.data?.detail;
      setError(typeof detail === 'string' ? detail : detail?.message || 'Error al abrir el mes');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg shadow-xl p-6 max-w-lg w-full mx-4">
        <h2 className="text-lg font-semibold text-gray-900 mb-2">
          Abrir mes: {monthName} {year}
        </h2>
        <p className="text-sm text-gray-600 mb-4">
          Podés crear el carryover desde el mes anterior y clonar los items de presupuesto para arrancar más rápido.
        </p>

        <div className="space-y-3 mb-4">
          <label className="flex items-center gap-2 text-sm text-gray-700">
            <input
              type="checkbox"
              checked={includeCarryover}
              onChange={(e) => setIncludeCarryover(e.target.checked)}
            />
            Incluir carryover (Saldo Anterior)
          </label>
          <label className="flex items-center gap-2 text-sm text-gray-700">
            <input
              type="checkbox"
              checked={includeBudgetClone}
              onChange={(e) => setIncludeBudgetClone(e.target.checked)}
            />
            Clonar presupuesto del mes anterior
          </label>
        </div>

        <div className="mb-4 p-3 bg-gray-50 border border-gray-200 rounded-lg">
          <p className="text-xs uppercase tracking-wide text-gray-500 mb-2">Preview de apertura</p>
          {previewLoading ? (
            <p className="text-sm text-gray-500">Cargando preview...</p>
          ) : preview ? (
            <div className="space-y-1 text-sm">
              <p>
                Mes anterior: <strong>{preview.priorMonth}</strong>
              </p>
              <p>
                Estado mes anterior:{' '}
                <strong className={preview.priorClosed ? 'text-green-700' : 'text-red-700'}>
                  {preview.priorStatus}
                </strong>
              </p>
              <p>
                Carryover estimado:{' '}
                <strong>
                  {new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' }).format(preview.estimatedCarryover || 0)}
                </strong>
              </p>
              <p>
                Items a clonar: <strong>{preview.estimatedCloneCount}</strong>
              </p>
            </div>
          ) : (
            <p className="text-sm text-gray-500">Sin datos de preview.</p>
          )}
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
            disabled={loading}
            className="px-4 py-2 text-sm text-white bg-blue-600 rounded hover:bg-blue-700 disabled:opacity-50"
          >
            {loading ? 'Abriendo...' : 'Confirmar apertura'}
          </button>
        </div>
      </div>
    </div>
  );
}
