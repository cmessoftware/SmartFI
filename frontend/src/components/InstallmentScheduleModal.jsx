import { useState, useEffect } from 'react';
import { creditCardAPI } from '../services/api';
import { useToast } from './ToastContainer';

export default function InstallmentScheduleModal({ isOpen, plan, onClose, onPaymentSuccess, canEdit }) {
  const [schedule, setSchedule] = useState([]);
  const [loading, setLoading] = useState(false);
  const [payingId, setPayingId] = useState(null);
  const toast = useToast();

  useEffect(() => {
    if (isOpen && plan) {
      loadSchedule();
    }
  }, [isOpen, plan]);

  const loadSchedule = async () => {
    if (!plan?.id) return;
    
    setLoading(true);
    try {
      const response = await creditCardAPI.getInstallmentSchedule(plan.id);
      setSchedule(response.data || []);
    } catch (error) {
      toast.error('Error al cargar cronograma de cuotas');
      console.error('Error loading installment schedule:', error);
    } finally {
      setLoading(false);
    }
  };

  const handlePayInstallment = async (installment) => {
    if (!canEdit || installment.status === 'PAID') return;

    setPayingId(installment.id);
    try {
      const paymentData = {
        payment_date: new Date().toISOString().split('T')[0],
        amount_paid: installment.total_installment_amount,
        notes: `Pago cuota ${installment.installment_number}`
      };

      await creditCardAPI.payInstallment(installment.id, paymentData);
      toast.success(`Cuota ${installment.installment_number} marcada como pagada`);
      
      // Reload schedule
      await loadSchedule();
      
      // Trigger parent update
      if (onPaymentSuccess) {
        onPaymentSuccess();
      }
    } catch (error) {
      toast.error('Error al marcar cuota como pagada');
      console.error('Error paying installment:', error);
    } finally {
      setPayingId(null);
    }
  };

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' }).format(amount);
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    const date = new Date(dateString + 'T00:00:00');
    return date.toLocaleDateString('es-ES', { year: 'numeric', month: 'short', day: 'numeric' });
  };

  const getStatusBadge = (status) => {
    const statusConfig = {
      PENDING: { bg: 'bg-yellow-100', text: 'text-yellow-800', label: 'Pendiente' },
      PAID: { bg: 'bg-green-100', text: 'text-green-800', label: 'Pagada' },
      OVERDUE: { bg: 'bg-red-100', text: 'text-red-800', label: 'Vencida' }
    };

    const config = statusConfig[status] || statusConfig.PENDING;
    
    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${config.bg} ${config.text}`}>
        {config.label}
      </span>
    );
  };

  if (!isOpen || !plan) return null;

  const totalPaid = schedule.filter(item => item.status === 'PAID').length;
  const totalPending = schedule.filter(item => item.status === 'PENDING').length;
  const progressPercentage = schedule.length > 0 ? (totalPaid / schedule.length) * 100 : 0;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b px-6 py-4 flex justify-between items-center">
          <div>
            <h2 className="text-2xl font-bold text-finly-text">Cronograma de Cuotas</h2>
            <p className="text-sm text-gray-500 mt-1">
              Plan de {plan.total_installments} cuotas - 
              Tasa: {plan.interest_rate}% anual
            </p>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 text-2xl"
          >
            ×
          </button>
        </div>

        <div className="p-6">
          {/* Progress Summary */}
          <div className="bg-gradient-to-r from-indigo-50 to-purple-50 rounded-lg p-6 mb-6">
            <div className="flex justify-between items-center mb-3">
              <div>
                <p className="text-sm text-gray-600">Progreso del Plan</p>
                <p className="text-2xl font-bold text-indigo-900">
                  {totalPaid} de {schedule.length} cuotas pagadas
                </p>
              </div>
              <div className="text-right">
                <p className="text-sm text-gray-600">Total del Plan</p>
                <p className="text-2xl font-bold text-indigo-900">
                  {formatCurrency(plan.total_amount)}
                </p>
              </div>
            </div>
            
            {/* Progress Bar */}
            <div className="w-full bg-white rounded-full h-3">
              <div
                className="bg-gradient-to-r from-indigo-600 to-purple-600 h-3 rounded-full transition-all duration-500"
                style={{ width: `${progressPercentage}%` }}
              />
            </div>
            
            <div className="flex justify-between mt-2 text-xs text-gray-600">
              <span>{progressPercentage.toFixed(0)}% completado</span>
              <span>{totalPending} cuotas pendientes</span>
            </div>
          </div>

          {/* Schedule Table */}
          {loading ? (
            <div className="text-center py-12">
              <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-finly-primary"></div>
              <p className="text-gray-500 mt-4">Cargando cronograma...</p>
            </div>
          ) : schedule.length === 0 ? (
            <div className="text-center py-12">
              <p className="text-gray-500">No se encontraron cuotas</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Cuota
                    </th>
                    <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Fecha Vencimiento
                    </th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Capital
                    </th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Interés
                    </th>
                    <th className="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Total
                    </th>
                    <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                      Estado
                    </th>
                    {canEdit && (
                      <th className="px-4 py-3 text-center text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Acción
                      </th>
                    )}
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {schedule.map((installment) => (
                    <tr 
                      key={installment.id}
                      className={installment.status === 'PAID' ? 'bg-green-50' : ''}
                    >
                      <td className="px-4 py-3 whitespace-nowrap">
                        <span className="font-medium text-gray-900">
                          #{installment.installment_number}
                        </span>
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-700">
                        {formatDate(installment.due_date)}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-sm text-right text-gray-700">
                        {formatCurrency(installment.principal_amount)}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-sm text-right text-red-600">
                        {formatCurrency(installment.interest_amount)}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-sm text-right font-semibold text-gray-900">
                        {formatCurrency(installment.total_installment_amount)}
                      </td>
                      <td className="px-4 py-3 whitespace-nowrap text-center">
                        {getStatusBadge(installment.status)}
                      </td>
                      {canEdit && (
                        <td className="px-4 py-3 whitespace-nowrap text-center">
                          {installment.status === 'PENDING' ? (
                            <button
                              onClick={() => handlePayInstallment(installment)}
                              disabled={payingId === installment.id}
                              className="text-sm text-white bg-finly-primary hover:bg-finly-primary-dark px-3 py-1 rounded-md transition-colors disabled:opacity-50"
                            >
                              {payingId === installment.id ? 'Procesando...' : 'Marcar Pagada'}
                            </button>
                          ) : (
                            <span className="text-sm text-gray-400">-</span>
                          )}
                        </td>
                      )}
                    </tr>
                  ))}
                </tbody>
                <tfoot className="bg-gray-50 font-semibold">
                  <tr>
                    <td colSpan="2" className="px-4 py-3 text-sm text-gray-900">
                      TOTALES
                    </td>
                    <td className="px-4 py-3 text-sm text-right text-gray-900">
                      {formatCurrency(schedule.reduce((sum, item) => sum + parseFloat(item.principal_amount), 0))}
                    </td>
                    <td className="px-4 py-3 text-sm text-right text-red-600">
                      {formatCurrency(schedule.reduce((sum, item) => sum + parseFloat(item.interest_amount), 0))}
                    </td>
                    <td className="px-4 py-3 text-sm text-right text-gray-900">
                      {formatCurrency(schedule.reduce((sum, item) => sum + parseFloat(item.total_installment_amount), 0))}
                    </td>
                    <td colSpan={canEdit ? 2 : 1}></td>
                  </tr>
                </tfoot>
              </table>
            </div>
          )}

          {/* Close Button */}
          <div className="flex justify-end mt-6 pt-4 border-t">
            <button
              onClick={onClose}
              className="px-6 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg transition-colors font-medium"
            >
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
