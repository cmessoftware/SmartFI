import { useState, useEffect } from 'react';
import { debtsAPI } from '../services/api';
import { useToast } from './ToastContainer';

const getInitialDate = (yearMonth) => {
  if (typeof yearMonth === 'string' && /^\d{4}-\d{2}$/.test(yearMonth)) {
    return `${yearMonth}-01`;
  }
  return new Date().toISOString().split('T')[0];
};

const buildInitialFormData = (yearMonth) => ({
  debt_name: '',
  debt_type: 'PERSONAL',
  debt_source: 'BANCO',
  creditor: '',
  fecha: getInitialDate(yearMonth),
  fecha_vencimiento: '',
  monto_total: '',
  annual_interest_rate: '',
  total_installments: '',
  current_installment: '',
  pending_installments: '',
  notes: '',
  tipo_presupuesto: 'OBLIGATION',
  tipo_flujo: 'Ingreso',
  expense_type: 'VARIABLE',
  estimated_payment: ''
});

const DEBT_TYPE_OPTIONS = [
  { value: 'PERSONAL', label: 'Personal' },
  { value: 'PRESTAMO', label: 'Prestamo' },
  { value: 'HIPOTECA', label: 'Hipoteca' },
  { value: 'TARJETA', label: 'Tarjeta' },
  { value: 'OTRO', label: 'Otro' },
];

const DEBT_SOURCE_OPTIONS = [
  { value: 'BANCO', label: 'Banco' },
  { value: 'FINTECH', label: 'Fintech' },
  { value: 'INDIVIDUO', label: 'Individuo' },
  { value: 'EMPRESA', label: 'Empresa' },
  { value: 'OTRO', label: 'Otro' },
];

export default function NewDebtModal({ isOpen, onClose, onSuccess, yearMonth, onCreateDebt }) {
  const toast = useToast();
  const [formData, setFormData] = useState(() => buildInitialFormData(yearMonth));
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (isOpen) {
      setFormData(buildInitialFormData(yearMonth));
    }
  }, [isOpen, yearMonth]);

  const handleChange = (e) => {
    const { name, value } = e.target;

    if (name === 'monto_total') {
      setFormData((prev) => ({
        ...prev,
        monto_total: value,
        estimated_payment: (!prev.estimated_payment || prev.estimated_payment === prev.monto_total)
          ? value
          : prev.estimated_payment,
      }));
      return;
    }

    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const toNullableNumber = (value) => {
    if (value === '' || value === null || value === undefined) return null;
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!formData.debt_name || !formData.debt_name.trim()) {
      toast.warning('Ingrese un nombre para la deuda');
      return;
    }

    if (!formData.monto_total || parseFloat(formData.monto_total) <= 0) {
      toast.warning('Ingrese un monto valido');
      return;
    }

    const totalInstallments = toNullableNumber(formData.total_installments);
    const currentInstallment = toNullableNumber(formData.current_installment);
    if (totalInstallments != null && currentInstallment != null && currentInstallment > totalInstallments) {
      toast.warning('La cuota actual no puede ser mayor al total de cuotas');
      return;
    }

    setLoading(true);
    try {
      const createDebt = onCreateDebt || debtsAPI.createDebt;
      await createDebt({
        ...formData,
        annual_interest_rate: toNullableNumber(formData.annual_interest_rate),
        total_installments: totalInstallments,
        current_installment: currentInstallment,
        pending_installments: toNullableNumber(formData.pending_installments),
      });

      toast.success('Deuda creada correctamente');
      setFormData(buildInitialFormData(yearMonth));
      onSuccess();
      onClose();
    } catch (error) {
      toast.error('Error al crear deuda');
      console.error('Error creating debt:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    if (loading) return;
    setFormData(buildInitialFormData(yearMonth));
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-3xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b px-6 py-4 flex justify-between items-center">
          <h2 className="text-2xl font-bold text-finly-text">Nueva Deuda</h2>
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
              <label className="block text-sm font-medium text-finly-text mb-2">Nombre de la deuda *</label>
              <input
                type="text"
                name="debt_name"
                value={formData.debt_name}
                onChange={handleChange}
                placeholder="Ej: Prestamo auto"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Tipo de deuda *</label>
              <select
                name="debt_type"
                value={formData.debt_type}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              >
                {DEBT_TYPE_OPTIONS.map((option) => (
                  <option key={option.value} value={option.value}>{option.label}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Fuente de la deuda *</label>
              <select
                name="debt_source"
                value={formData.debt_source}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              >
                {DEBT_SOURCE_OPTIONS.map((option) => (
                  <option key={option.value} value={option.value}>{option.label}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Acreedor / Entidad</label>
              <input
                type="text"
                name="creditor"
                value={formData.creditor}
                onChange={handleChange}
                placeholder="Ej: Banco Nacion"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Fecha de toma de deuda *</label>
              <input
                type="date"
                name="fecha"
                value={formData.fecha}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              />
              <p className="text-xs text-gray-500 mt-1">Corresponde a la fecha en que se tomo la deuda.</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Fecha de primera cuota</label>
              <input
                type="date"
                name="fecha_vencimiento"
                value={formData.fecha_vencimiento}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
              />
              <p className="text-xs text-gray-500 mt-1">Si se omite, se proyecta desde el mes siguiente a la toma.</p>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Monto total (ARS) *</label>
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
              <label className="block text-sm font-medium text-finly-text mb-2">Tasa de interes anual (%)</label>
              <input
                type="number"
                name="annual_interest_rate"
                value={formData.annual_interest_rate}
                onChange={handleChange}
                step="0.01"
                min="0"
                placeholder="Ej: 48.50"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Total de cuotas</label>
              <input
                type="number"
                name="total_installments"
                value={formData.total_installments}
                onChange={handleChange}
                step="0.01"
                min="0"
                placeholder="Ej: 12"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">Cuota actual (X)</label>
              <input
                type="number"
                name="current_installment"
                value={formData.current_installment}
                onChange={handleChange}
                step="0.01"
                min="0"
                placeholder="Ej: 3"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
              />
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-finly-text mb-2">Cuotas pendientes</label>
              <input
                type="number"
                name="pending_installments"
                value={formData.pending_installments}
                onChange={handleChange}
                step="0.01"
                min="0"
                placeholder="Opcional (se calcula automaticamente si se omite)"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
              />
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-medium text-finly-text mb-2">Comentarios</label>
              <textarea
                name="notes"
                value={formData.notes}
                onChange={handleChange}
                rows="3"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                placeholder="Notas adicionales de la deuda..."
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
              {loading ? 'Guardando...' : 'Guardar Deuda'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
