import { useState, useEffect } from 'react';
import { creditCardAPI } from '../services/api';
import { useToast } from './ToastContainer';
import ConfirmDialog from './ConfirmDialog';
import NewCreditCardModal from './NewCreditCardModal';
import EditCreditCardModal from './EditCreditCardModal';
import PurchaseModal from './PurchaseModal';
import InstallmentScheduleModal from './InstallmentScheduleModal';
import CreditCardCSVImport from './CreditCardCSVImport';

export default function CreditCardManager({ canEdit, isAdmin = false, setCurrentView }) {
  const [cards, setCards] = useState([]);
  const [selectedCard, setSelectedCard] = useState(null);
  const [cardSummary, setCardSummary] = useState(null);
  const [cardPurchases, setCardPurchases] = useState([]);
  const [selectedPurchaseId, setSelectedPurchaseId] = useState(null);
  const [installmentSchedule, setInstallmentSchedule] = useState([]);
  const [showInactive, setShowInactive] = useState(false);
  const [viewMode, setViewMode] = useState('grid'); // 'grid' or 'detail'
  const [newModalOpen, setNewModalOpen] = useState(false);
  const [editModalOpen, setEditModalOpen] = useState(false);
  const [purchaseModalOpen, setPurchaseModalOpen] = useState(false);
  const [scheduleModalOpen, setScheduleModalOpen] = useState(false);
  const [cardToEdit, setCardToEdit] = useState(null);
  const [cardForPurchase, setCardForPurchase] = useState(null);
  const [purchaseToEdit, setPurchaseToEdit] = useState(null);
  const [selectedPlan, setSelectedPlan] = useState(null);
  const [deleteDialog, setDeleteDialog] = useState({ isOpen: false, cardId: null, cardName: '' });
  const [deletePurchaseDialog, setDeletePurchaseDialog] = useState({ isOpen: false, purchaseId: null, purchaseName: '' });
  const [csvImportOpen, setCsvImportOpen] = useState(false);
  const [summaryView, setSummaryView] = useState(false);
  const [purchasesSummary, setPurchasesSummary] = useState(null);
  const [periodData, setPeriodData] = useState(null);
  const [periodYear, setPeriodYear] = useState(null);
  const [periodMonth, setPeriodMonth] = useState(null);
  const [minimumPayment, setMinimumPayment] = useState('');
  const toast = useToast();

  useEffect(() => {
    loadCards();
  }, [showInactive]);

  const loadCards = async () => {
    try {
      const response = await creditCardAPI.getCreditCards(!showInactive);
      setCards(response.data || []);
    } catch (error) {
      toast.error('Error al cargar tarjetas de crédito');
      console.error('Error loading credit cards:', error);
    }
  };

  const handleEdit = (card) => {
    if (!canEdit) return;
    setCardToEdit(card);
    setEditModalOpen(true);
  };

  const handleSaveEdit = async (updatedData) => {
    try {
      await creditCardAPI.updateCreditCard(cardToEdit.id, updatedData);
      toast.success('Tarjeta actualizada correctamente');
      setEditModalOpen(false);
      setCardToEdit(null);
      loadCards();
      if (selectedCard?.id === cardToEdit.id) {
        loadCardSummary(cardToEdit.id);
      }
    } catch (error) {
      toast.error('Error al actualizar tarjeta');
      console.error('Error updating credit card:', error);
    }
  };

  const handleDeleteClick = (card) => {
    if (!canEdit) return;
    setDeleteDialog({
      isOpen: true,
      cardId: card.id,
      cardName: card.card_name
    });
  };

  const handleDeleteConfirm = async () => {
    try {
      await creditCardAPI.deleteCreditCard(deleteDialog.cardId);
      toast.success('Tarjeta eliminada correctamente');
      loadCards();
      if (selectedCard?.id === deleteDialog.cardId) {
        setSelectedCard(null);
      }
    } catch (error) {
      toast.error('Error al eliminar tarjeta');
      console.error('Error deleting credit card:', error);
    }
    setDeleteDialog({ isOpen: false, cardId: null, cardName: '' });
  };

  const handleAddPurchase = (card) => {
    if (!canEdit) return;
    setCardForPurchase(card);
    setPurchaseModalOpen(true);
  };

  const handlePurchaseSuccess = () => {
    loadCards();
    if (selectedCard?.id) {
      loadCardSummary(selectedCard.id);
      loadCardPurchases(selectedCard.id);
    }
  };

  const handleViewSchedule = async (plan) => {
    setSelectedPlan(plan);
    setScheduleModalOpen(true);
  };

  const loadCardSummary = async (cardId) => {
    try {
      const response = await creditCardAPI.getCardSummary(cardId);
      setCardSummary(response.data);
    } catch (error) {
      toast.error('Error al cargar resumen de tarjeta');
      console.error('Error loading card summary:', error);
    }
  };

  const loadCardPurchases = async (cardId) => {
    try {
      const response = await creditCardAPI.getCardPurchases(cardId);
      setCardPurchases(response.data || []);
    } catch (error) {
      toast.error('Error al cargar compras');
      console.error('Error loading card purchases:', error);
    }
  };

  const handleSelectCard = async (card) => {
    setSelectedCard(card);
    setViewMode('detail');
    const now = new Date();
    let currentMonth = now.getMonth() + 1;
    let currentYear = now.getFullYear();
    setPeriodYear(currentYear);
    setPeriodMonth(currentMonth);
    await Promise.all([
      loadCardSummary(card.id),
      loadCardPurchases(card.id),
      loadPeriodData(card.id, currentYear, currentMonth)
    ]);
  };

  const handleBackToGrid = () => {
    setViewMode('grid');
    setSelectedCard(null);
    setCardSummary(null);
    setCardPurchases([]);
    setSelectedPurchaseId(null);
    setInstallmentSchedule([]);
    setPeriodData(null);
    setPeriodYear(null);
    setPeriodMonth(null);
  };

  const handleCardClick = async (card) => {
    if (viewMode === 'grid') {
      await handleSelectCard(card);
    }
  };

  const handleSelectPurchase = async (purchase) => {
    if (selectedPurchaseId === purchase.id) {
      setSelectedPurchaseId(null);
      setInstallmentSchedule([]);
    } else {
      setSelectedPurchaseId(purchase.id);
      if (purchase.installment_plan?.id) {
        await loadInstallmentSchedule(purchase.installment_plan.id);
      } else {
        // Single-cuota purchase without a plan: show synthetic schedule entry
        setInstallmentSchedule([{
          id: `synth-${purchase.id}`,
          installment_number: 1,
          due_date: purchase.purchase_date,
          principal_amount: purchase.total_amount,
          interest_amount: 0,
          total_installment_amount: purchase.total_amount,
          status: 'PENDING'
        }]);
      }
    }
  };

  const loadInstallmentSchedule = async (planId) => {
    try {
      const response = await creditCardAPI.getInstallmentSchedule(planId);
      setInstallmentSchedule(response.data || []);
    } catch (error) {
      toast.error('Error al cargar cronograma de cuotas');
      console.error('Error loading installment schedule:', error);
    }
  };

  const handlePayInstallment = async (installment) => {
    if (!canEdit || installment.status === 'PAID') return;

    try {
      const paymentData = {
        payment_date: new Date().toISOString().split('T')[0],
        amount_paid: installment.total_installment_amount,
        notes: `Pago cuota ${installment.installment_number}`
      };

      await creditCardAPI.payInstallment(installment.id, paymentData);
      toast.success(`Cuota ${installment.installment_number} marcada como pagada`);
      
      // Reload schedule and card data
      if (selectedPurchaseId) {
        const purchase = cardPurchases.find(p => p.id === selectedPurchaseId);
        if (purchase?.installment_plan?.id) {
          await loadInstallmentSchedule(purchase.installment_plan.id);
        }
      }
      if (selectedCard?.id) {
        await loadCardSummary(selectedCard.id);
        await loadCardPurchases(selectedCard.id);
      }
    } catch (error) {
      toast.error('Error al marcar cuota como pagada');
      console.error('Error paying installment:', error);
    }
  };

  const handleUnpayInstallment = async (installment) => {
    if (!canEdit || installment.status !== 'PAID') return;

    try {
      await creditCardAPI.unpayInstallment(installment.id);
      toast.success(`Pago de cuota ${installment.installment_number} revertido`);
      
      // Reload schedule and card data
      if (selectedPurchaseId) {
        const purchase = cardPurchases.find(p => p.id === selectedPurchaseId);
        if (purchase?.installment_plan?.id) {
          await loadInstallmentSchedule(purchase.installment_plan.id);
        }
      }
      if (selectedCard?.id) {
        await loadCardSummary(selectedCard.id);
        await loadCardPurchases(selectedCard.id);
      }
    } catch (error) {
      toast.error('Error al revertir pago de cuota');
      console.error('Error unpaying installment:', error);
    }
  };

  const handleEditPurchase = (purchase) => {
    if (!canEdit) return;
    setPurchaseToEdit(purchase);
    setPurchaseModalOpen(true);
  };

  const handleDeletePurchaseClick = (purchase) => {
    if (!canEdit) return;
    setDeletePurchaseDialog({
      isOpen: true,
      purchaseId: purchase.id,
      purchaseName: purchase.description
    });
  };

  const handleDeletePurchaseConfirm = async () => {
    try {
      await creditCardAPI.deletePurchase(deletePurchaseDialog.purchaseId);
      toast.success('Gasto eliminado correctamente');
      if (selectedPurchaseId === deletePurchaseDialog.purchaseId) {
        setSelectedPurchaseId(null);
        setInstallmentSchedule([]);
      }
      if (selectedCard?.id) {
        await loadCardPurchases(selectedCard.id);
        await loadCardSummary(selectedCard.id);
      }
    } catch (error) {
      toast.error('Error al eliminar gasto');
      console.error('Error deleting purchase:', error);
    }
    setDeletePurchaseDialog({ isOpen: false, purchaseId: null, purchaseName: '' });
  };

  const loadPurchasesSummary = async (cardId) => {
    try {
      const response = await creditCardAPI.getPurchasesSummary(cardId);
      setPurchasesSummary(response.data);
    } catch (error) {
      toast.error('Error al cargar resumen de gastos');
      console.error('Error loading purchases summary:', error);
    }
  };

  const handlePurchaseEditSuccess = async () => {
    if (selectedCard?.id) {
      await loadCardPurchases(selectedCard.id);
    }
  };

  const loadPeriodData = async (cardId, year, month) => {
    try {
      const response = await creditCardAPI.getCardPeriodInstallments(cardId, year, month);
      setPeriodData(response.data);
      setMinimumPayment(String(response.data.minimum_payment || ''));
    } catch (error) {
      setPeriodData(null);
      setMinimumPayment('');
    }
  };

  const handleRegisterPeriodBudget = async (paymentType = 'total') => {
    if (!selectedCard || !periodYear || !periodMonth) return;
    try {
      const minPaymentValue = parseFloat(minimumPayment) || 0;
      const result = await creditCardAPI.registerCardPeriodBudget(selectedCard.id, periodYear, periodMonth, paymentType, minPaymentValue);
      const msg = paymentType === 'minimum' ? 'Pago mínimo registrado' : 'Período registrado en presupuesto';
      toast.success(result.data.action === 'created' ? msg : 'Presupuesto del período actualizado');
      await loadPeriodData(selectedCard.id, periodYear, periodMonth);
    } catch (error) {
      const detail = error.response?.data?.detail || 'Error al registrar presupuesto del período';
      toast.error(detail);
      console.error('Error registering period budget:', error);
    }
  };

  const handlePeriodChange = async (direction) => {
    let newMonth = periodMonth + direction;
    let newYear = periodYear;
    if (newMonth > 12) { newMonth = 1; newYear++; }
    if (newMonth < 1) { newMonth = 12; newYear--; }
    setPeriodYear(newYear);
    setPeriodMonth(newMonth);
    if (selectedCard) {
      await loadPeriodData(selectedCard.id, newYear, newMonth);
    }
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

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' }).format(amount);
  };

  const formatDate = (dateString) => {
    if (!dateString) return '-';
    const date = new Date(dateString + 'T00:00:00');
    return date.toLocaleDateString('es-ES', { year: 'numeric', month: 'short', day: 'numeric' });
  };

  const getCreditUtilization = (card) => {
    const summary = selectedCard?.id === card.id ? selectedCard : null;
    if (!card.credit_limit || !summary) return 0;
    return ((summary.current_debt / card.credit_limit) * 100).toFixed(1);
  };

  // Filter purchases list to only show those relevant to the selected period
  const periodPurchaseIds = new Set(
    (periodData?.installments || []).map(item => item.purchase_id).filter(Boolean)
  );
  const filteredPurchases = periodPurchaseIds.size > 0
    ? cardPurchases.filter(p => periodPurchaseIds.has(p.id))
    : cardPurchases;

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <div className="flex items-center gap-4">
          {viewMode === 'detail' && (
            <button
              onClick={() => { setSummaryView(false); handleBackToGrid(); }}
              className="text-finly-primary hover:text-finly-primary-dark font-medium"
            >
              ← Volver
            </button>
          )}
          <div>
            <h1 className="text-3xl font-bold text-finly-text">💳 Tarjetas de Crédito</h1>
            <p className="text-gray-500 mt-1">
              {viewMode === 'detail' && selectedCard
                ? `${selectedCard.bank_name} - ${selectedCard.card_name}`
                : 'Gestiona tus tarjetas, compras y cuotas'}
            </p>
          </div>
        </div>
        <div className="flex gap-2">
          {viewMode === 'detail' && selectedCard && (
            <button
              onClick={async () => {
                if (!summaryView) await loadPurchasesSummary(selectedCard.id);
                setSummaryView(!summaryView);
              }}
              className={`px-4 py-3 rounded-lg font-medium transition-colors shadow-md ${
                summaryView
                  ? 'bg-indigo-700 text-white'
                  : 'bg-white border border-indigo-600 text-indigo-600 hover:bg-indigo-50'
              }`}
            >
              📊 Resumen Total
            </button>
          )}
          {canEdit && viewMode === 'grid' && (
            <button
              onClick={() => setNewModalOpen(true)}
              className="bg-finly-primary hover:bg-finly-primary-dark text-white px-6 py-3 rounded-lg font-medium transition-colors shadow-md"
            >
              + Nueva Tarjeta
            </button>
          )}
        </div>
      </div>

      {/* GRID VIEW: Selección de tarjetas */}
      {viewMode === 'grid' && (
        <>
          {/* Filters */}
          <div className="bg-white rounded-lg shadow-md p-4 mb-6">
            <div className="flex items-center gap-4">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={showInactive}
                  onChange={(e) => setShowInactive(e.target.checked)}
                  className="w-4 h-4 text-finly-primary rounded focus:ring-finly-primary"
                />
                <span className="text-sm text-gray-700">Mostrar tarjetas inactivas</span>
              </label>
            </div>
          </div>

          {/* Cards Grid */}
          {cards.length === 0 ? (
            <div className="bg-white rounded-lg shadow-md p-12 text-center">
              <div className="text-6xl mb-4">💳</div>
              <p className="text-xl text-gray-500 mb-2">No hay tarjetas registradas</p>
              {canEdit && (
                <p className="text-gray-400">Haz clic en "Nueva Tarjeta" para comenzar</p>
              )}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {cards.map((card) => (
                <div
                  key={card.id}
                  className="bg-gradient-to-br from-indigo-600 to-indigo-800 rounded-xl shadow-lg p-6 text-white cursor-pointer transform transition-all hover:scale-105"
                  onClick={() => handleCardClick(card)}
                >
                  <div className="flex justify-between items-start mb-4">
                    <div>
                      <p className="text-xs opacity-75 uppercase tracking-wide">{card.bank_name}</p>
                      <h3 className="text-xl font-bold">{card.card_name}</h3>
                    </div>
                    <div className="flex gap-2">
                      {canEdit && (
                        <>
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleEdit(card);
                            }}
                            className="p-2 hover:bg-white/20 rounded-lg transition-colors"
                            title="Editar"
                          >
                            ✏️
                          </button>
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleDeleteClick(card);
                            }}
                            className="p-2 hover:bg-white/20 rounded-lg transition-colors"
                            title="Eliminar"
                          >
                            🗑️
                          </button>
                        </>
                      )}
                    </div>
                  </div>

                  <div className="space-y-2">
                    <div className="flex justify-between text-sm">
                      <span className="opacity-75">Cierre:</span>
                      <span className="font-semibold">Día {card.closing_day}</span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="opacity-75">Vencimiento:</span>
                      <span className="font-semibold">Día {card.due_day}</span>
                    </div>
                    {card.credit_limit && (
                      <div className="flex justify-between text-sm">
                        <span className="opacity-75">Límite:</span>
                        <span className="font-semibold">{formatCurrency(card.credit_limit)} {card.currency}</span>
                      </div>
                    )}
                  </div>

                  {!card.is_active && (
                    <div className="mt-3 text-xs text-yellow-300 bg-yellow-900/30 rounded px-2 py-1 text-center">
                      Tarjeta inactiva
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </>
      )}

      {/* DETAIL VIEW: 2 columnas (compras + cronograma) */}
      {viewMode === 'detail' && selectedCard && !summaryView && (
        <>
        {/* Period Budget Registration */}
        {periodData && (
          <div className="bg-white rounded-xl shadow-lg p-6 mb-6">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-bold text-gray-800">📅 Resumen del Período</h3>
              <div className="flex items-center gap-2">
                <button onClick={() => handlePeriodChange(-1)} className="p-1 hover:bg-gray-100 rounded text-gray-600">◀</button>
                <span className="font-semibold text-gray-700 min-w-[140px] text-center capitalize">
                  {new Date(periodYear, periodMonth - 1).toLocaleDateString('es-ES', { month: 'long', year: 'numeric' })}
                </span>
                <button onClick={() => handlePeriodChange(1)} className="p-1 hover:bg-gray-100 rounded text-gray-600">▶</button>
              </div>
            </div>
            <div className="flex items-center justify-between flex-wrap gap-4">
              <div className="flex gap-6">
                <div>
                  <p className="text-sm text-gray-500">Total Resumen</p>
                  <p className="text-2xl font-bold text-gray-800">{formatCurrency(periodData.total_due)}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Pago Mínimo</p>
                  <input
                    type="number"
                    value={minimumPayment}
                    onChange={(e) => setMinimumPayment(e.target.value)}
                    className="w-40 text-lg font-bold text-orange-500 border border-orange-300 rounded-lg px-2 py-1 focus:outline-none focus:ring-2 focus:ring-orange-400"
                    placeholder="Monto mínimo"
                  />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Pagado (Gastos)</p>
                  <p className={`text-2xl font-bold ${periodData.total_paid > 0 ? 'text-green-600' : 'text-gray-400'}`}>{formatCurrency(periodData.total_paid)}</p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Pendiente</p>
                  <p className={`text-2xl font-bold ${(periodData.total_due - periodData.total_paid) > 0 ? 'text-red-600' : 'text-green-600'}`}>
                    {formatCurrency(Math.max(0, periodData.total_due - periodData.total_paid))}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-500">Items</p>
                  <p className="text-2xl font-bold text-indigo-600">{periodData.installment_count}</p>
                </div>
              </div>
              {canEdit && (
                <div className="flex flex-col gap-2">
                  <button
                    onClick={() => handleRegisterPeriodBudget('total')}
                    disabled={periodData.total_due === 0}
                    className={`px-5 py-2.5 rounded-lg font-medium transition-colors shadow-md text-sm ${
                      periodData.total_due === 0
                        ? 'bg-gray-100 text-gray-400 cursor-not-allowed border border-gray-200'
                        : periodData.budget_registered
                          ? 'bg-indigo-100 text-indigo-700 hover:bg-indigo-200 border border-indigo-300'
                          : 'bg-finly-primary hover:bg-finly-primary-dark text-white'
                    }`}
                  >
                    {periodData.budget_registered ? '🔄 Actualizar Total' : '📋 Registrar Total'}
                  </button>
                  <button
                    onClick={() => handleRegisterPeriodBudget('minimum')}
                    disabled={periodData.total_due === 0}
                    className={`px-5 py-2.5 rounded-lg font-medium transition-colors shadow-md text-sm ${
                      periodData.total_due === 0
                        ? 'bg-gray-100 text-gray-400 cursor-not-allowed border border-gray-200'
                        : 'bg-orange-100 text-orange-700 hover:bg-orange-200 border border-orange-300'
                    }`}
                  >
                    📋 Registrar Pago Mínimo
                  </button>
                </div>
              )}
            </div>
          </div>
        )}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* LEFT COLUMN: Card Summary + Purchases List */}
          <div className="space-y-6">
            {/* Card Summary */}
            {cardSummary && (
              <div className="bg-gradient-to-br from-indigo-600 to-indigo-800 rounded-xl shadow-lg p-6 text-white">
                <h3 className="text-xl font-bold mb-4">Resumen de Tarjeta</h3>
                
                <div className="bg-white/10 rounded-lg p-4 mb-4">
                  <div className="flex justify-between items-center mb-2">
                    <span className="text-sm opacity-75">Deuda Actual</span>
                    <span className="text-2xl font-bold">{formatCurrency(cardSummary.current_debt)}</span>
                  </div>
                  {selectedCard.credit_limit && (
                    <>
                      <div className="w-full bg-white/20 rounded-full h-2 mb-2">
                        <div
                          className="bg-yellow-400 h-2 rounded-full transition-all"
                          style={{ width: `${Math.min(((cardSummary.current_debt / selectedCard.credit_limit) * 100), 100)}%` }}
                        />
                      </div>
                      <div className="flex justify-between text-xs">
                        <span className="opacity-75">Disponible: {formatCurrency(cardSummary.available_credit)}</span>
                        <span className="opacity-75">{((cardSummary.current_debt / selectedCard.credit_limit) * 100).toFixed(1)}% usado</span>
                      </div>
                    </>
                  )}
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="bg-white/10 rounded-lg p-3">
                    <p className="opacity-75 text-xs mb-1">Cuotas Pendientes</p>
                    <p className="font-bold text-xl">{cardSummary.pending_installments}</p>
                  </div>
                  <div className="bg-white/10 rounded-lg p-3">
                    <p className="opacity-75 text-xs mb-1">Próximo Pago</p>
                    <p className="font-bold text-xl">
                      {cardSummary.next_due_amount ? formatCurrency(cardSummary.next_due_amount) : '-'}
                    </p>
                  </div>
                </div>

                {canEdit && (
                  <div className="flex gap-2 mt-4">
                    <button
                      onClick={() => {
                        setCardForPurchase(selectedCard);
                        setPurchaseModalOpen(true);
                      }}
                      className="flex-1 bg-white/20 hover:bg-white/30 text-white py-3 rounded-lg font-medium transition-colors"
                    >
                      + Agregar Compra
                    </button>
                    <button
                      onClick={() => setCsvImportOpen(true)}
                      className="bg-white/20 hover:bg-white/30 text-white py-3 px-4 rounded-lg font-medium transition-colors"
                      title="Importar gastos desde CSV"
                    >
                      📥 CSV
                    </button>
                  </div>
                )}
              </div>
            )}

            {/* Purchases List */}
            <div className="bg-white rounded-xl shadow-lg p-6">
              <h3 className="text-lg font-bold text-gray-800 mb-4">Compras del Período</h3>
              
              {filteredPurchases.length === 0 ? (
                <div className="text-center py-8 text-gray-400">
                  <p>No hay compras en este período</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {filteredPurchases.map((purchase) => (
                    <div
                      key={purchase.id}
                      className={`border rounded-lg p-4 cursor-pointer transition-all ${
                        selectedPurchaseId === purchase.id
                          ? 'border-finly-primary bg-finly-primary/5 ring-2 ring-finly-primary/50'
                          : 'border-gray-200 hover:border-finly-primary/50 hover:bg-gray-50'
                      }`}
                      onClick={() => handleSelectPurchase(purchase)}
                    >
                      <div className="flex justify-between items-start gap-3">
                        <div className="flex-1">
                          <p className="font-semibold text-gray-800">{purchase.description}</p>
                          <p className="text-sm text-gray-500 mt-1">
                            {formatDate(purchase.purchase_date)} • {purchase.installments} cuotas
                          </p>
                        </div>
                        <div className="text-right">
                          <p className="font-bold text-gray-800">
                            {purchase.currency === 'USD' ? `USD ${purchase.total_amount.toLocaleString('es-AR', { minimumFractionDigits: 2 })}` : formatCurrency(purchase.total_amount)}
                          </p>
                          {purchase.currency === 'USD' && purchase.amount_in_pesos && (
                            <p className="text-xs text-blue-600">≈ {formatCurrency(purchase.amount_in_pesos)}</p>
                          )}
                          {purchase.installment_plan && (
                            <p className="text-sm text-gray-500 mt-1">
                              {purchase.installment_plan.paid_installments || 0}/{purchase.installments} pagadas
                            </p>
                          )}
                        </div>
                        {canEdit && (
                          <div className="flex gap-1">
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                handleEditPurchase(purchase);
                              }}
                              className="p-2 hover:bg-gray-200 rounded-lg transition-colors text-gray-600 hover:text-finly-primary"
                              title="Editar compra"
                            >
                              ✏️
                            </button>
                            <button
                              onClick={(e) => {
                                e.stopPropagation();
                                handleDeletePurchaseClick(purchase);
                              }}
                              className="p-2 hover:bg-red-100 rounded-lg transition-colors text-gray-600 hover:text-red-600"
                              title="Eliminar compra"
                            >
                              🗑️
                            </button>
                          </div>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* RIGHT COLUMN: Installment Schedule */}
          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex justify-between items-center mb-4">
              <div className="flex items-center gap-4">
                <h3 className="text-lg font-bold text-gray-800">Cronograma de Cuotas</h3>
                {selectedPurchaseId && installmentSchedule.length > 0 && (
                  <span className="text-sm font-semibold text-indigo-700 bg-indigo-50 px-3 py-1 rounded-lg">
                    Total: {formatCurrency(installmentSchedule.reduce((sum, i) => sum + i.total_installment_amount, 0))}
                  </span>
                )}
              </div>
              {selectedPurchaseId && (() => {
                const purchase = cardPurchases.find(p => p.id === selectedPurchaseId);
                return purchase?.debt_id ? (
                  <button
                    onClick={() => setCurrentView && setCurrentView('debts')}
                    className="text-sm text-indigo-600 hover:text-indigo-800 font-medium flex items-center gap-1"
                    title="Ver item en Presupuesto"
                  >
                    📋 Ver en Presupuesto
                  </button>
                ) : null;
              })()}
            </div>
            
            {!selectedPurchaseId ? (
              <div className="text-center py-12 text-gray-400">
                <div className="text-5xl mb-3">📅</div>
                <p>Selecciona una compra para ver el cronograma</p>
              </div>
            ) : installmentSchedule.length === 0 ? (
              <div className="text-center py-12 text-gray-400">
                <p>Cargando cronograma...</p>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="border-b border-gray-200">
                      <th className="text-left py-3 px-2 text-sm font-semibold text-gray-600">Fecha</th>
                      <th className="text-left py-3 px-2 text-sm font-semibold text-gray-600">Descripción</th>
                      <th className="text-right py-3 px-2 text-sm font-semibold text-gray-600">Monto</th>
                      <th className="text-center py-3 px-2 text-sm font-semibold text-gray-600">Cuota</th>
                      <th className="text-center py-3 px-2 text-sm font-semibold text-gray-600">Estado</th>
                      {canEdit && <th className="text-center py-3 px-2 text-sm font-semibold text-gray-600">Acción</th>}
                    </tr>
                  </thead>
                  <tbody>
                    {installmentSchedule.map((installment) => {
                      const selectedPurchase = cardPurchases.find(p => p.id === selectedPurchaseId);
                      return (
                        <tr
                          key={installment.id}
                          className="border-b border-gray-100 hover:bg-gray-50"
                        >
                          <td className="py-3 px-2 text-sm text-gray-700">
                            {formatDate(installment.due_date)}
                          </td>
                          <td className="py-3 px-2 text-sm text-gray-700">
                            {selectedPurchase?.description || '-'}
                          </td>
                          <td className="py-3 px-2 text-sm text-right font-semibold text-gray-800">
                            {selectedPurchase?.currency === 'USD'
                              ? <>
                                  USD {installment.total_installment_amount.toLocaleString('es-AR', { minimumFractionDigits: 2 })}
                                  {selectedPurchase.exchange_rate && (
                                    <p className="text-xs text-blue-600 font-normal">≈ {formatCurrency(installment.total_installment_amount * selectedPurchase.exchange_rate)}</p>
                                  )}
                                </>
                              : formatCurrency(installment.total_installment_amount)
                            }
                          </td>
                          <td className="py-3 px-2 text-center">
                            <span className="bg-indigo-100 text-indigo-800 px-2 py-1 rounded text-sm font-medium">
                              {installment.installment_number}/{selectedPurchase?.installments || 0}
                            </span>
                          </td>
                          <td className="py-3 px-2 text-center">
                            {getStatusBadge(installment.status)}
                          </td>
                          {canEdit && (
                            <td className="py-3 px-2 text-center">
                              {installment.status === 'PENDING' && (
                                <button
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    handlePayInstallment(installment);
                                  }}
                                  className="bg-green-500 hover:bg-green-600 text-white text-sm px-3 py-1 rounded transition-colors"
                                >
                                  Pagar
                                </button>
                              )}
                              {installment.status === 'PAID' && (
                                <button
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    handleUnpayInstallment(installment);
                                  }}
                                  className="bg-orange-500 hover:bg-orange-600 text-white text-sm px-3 py-1 rounded transition-colors"
                                  title="Revertir pago"
                                >
                                  Revertir
                                </button>
                              )}
                            </td>
                          )}
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
        </>
      )}

      {/* SUMMARY VIEW */}
      {viewMode === 'detail' && selectedCard && summaryView && (
        <div className="space-y-6">
          {purchasesSummary ? (
            <>
              {/* Summary Cards */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="bg-white rounded-xl shadow-lg p-6">
                  <p className="text-sm text-gray-500 mb-1">Total Compras</p>
                  <p className="text-2xl font-bold text-gray-800">{purchasesSummary.purchase_count}</p>
                </div>
                <div className="bg-white rounded-xl shadow-lg p-6">
                  <p className="text-sm text-gray-500 mb-1">Monto Original</p>
                  <p className="text-2xl font-bold text-gray-800">{formatCurrency(purchasesSummary.total_original)}</p>
                </div>
                <div className="bg-white rounded-xl shadow-lg p-6">
                  <p className="text-sm text-gray-500 mb-1">Total con Intereses</p>
                  <p className="text-2xl font-bold text-indigo-700">{formatCurrency(purchasesSummary.total_with_interest)}</p>
                </div>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Pie Chart */}
                <div className="bg-white rounded-xl shadow-lg p-6">
                  <h3 className="text-lg font-bold text-gray-800 mb-4">Distribución por Descripción</h3>
                  {purchasesSummary.by_description.length > 0 ? (
                    <div className="flex flex-col items-center">
                      <svg viewBox="0 0 200 200" className="w-64 h-64 mb-4">
                        {(() => {
                          const total = purchasesSummary.by_description.reduce((s, d) => s + d.total_with_interest, 0);
                          const colors = ['#4F46E5', '#7C3AED', '#EC4899', '#F59E0B', '#10B981', '#3B82F6', '#EF4444', '#8B5CF6', '#14B8A6', '#F97316'];
                          let cumAngle = 0;
                          return purchasesSummary.by_description
                            .sort((a, b) => b.total_with_interest - a.total_with_interest)
                            .map((item, i) => {
                              const fraction = total > 0 ? item.total_with_interest / total : 0;
                              const angle = fraction * 360;
                              const startAngle = cumAngle;
                              cumAngle += angle;

                              if (fraction === 0) return null;
                              if (fraction >= 0.9999) {
                                return <circle key={i} cx="100" cy="100" r="80" fill={colors[i % colors.length]} />;
                              }

                              const startRad = (startAngle - 90) * Math.PI / 180;
                              const endRad = (startAngle + angle - 90) * Math.PI / 180;
                              const x1 = 100 + 80 * Math.cos(startRad);
                              const y1 = 100 + 80 * Math.sin(startRad);
                              const x2 = 100 + 80 * Math.cos(endRad);
                              const y2 = 100 + 80 * Math.sin(endRad);
                              const largeArc = angle > 180 ? 1 : 0;

                              return (
                                <path
                                  key={i}
                                  d={`M100,100 L${x1},${y1} A80,80 0 ${largeArc},1 ${x2},${y2} Z`}
                                  fill={colors[i % colors.length]}
                                />
                              );
                            });
                        })()}
                      </svg>
                      {/* Legend */}
                      <div className="w-full space-y-2">
                        {(() => {
                          const colors = ['#4F46E5', '#7C3AED', '#EC4899', '#F59E0B', '#10B981', '#3B82F6', '#EF4444', '#8B5CF6', '#14B8A6', '#F97316'];
                          const total = purchasesSummary.by_description.reduce((s, d) => s + d.total_with_interest, 0);
                          return purchasesSummary.by_description
                            .sort((a, b) => b.total_with_interest - a.total_with_interest)
                            .map((item, i) => (
                              <div key={i} className="flex items-center justify-between text-sm">
                                <div className="flex items-center gap-2">
                                  <div className="w-3 h-3 rounded-full" style={{ backgroundColor: colors[i % colors.length] }} />
                                  <span className="text-gray-700 truncate max-w-[200px]">{item.description}</span>
                                </div>
                                <span className="font-semibold text-gray-800">
                                  {formatCurrency(item.total_with_interest)} ({total > 0 ? ((item.total_with_interest / total) * 100).toFixed(1) : 0}%)
                                </span>
                              </div>
                            ));
                        })()}
                      </div>
                    </div>
                  ) : (
                    <p className="text-gray-400 text-center py-8">No hay datos</p>
                  )}
                </div>

                {/* Table */}
                <div className="bg-white rounded-xl shadow-lg p-6">
                  <h3 className="text-lg font-bold text-gray-800 mb-4">Detalle por Descripción</h3>
                  <div className="overflow-x-auto">
                    <table className="w-full">
                      <thead>
                        <tr className="border-b border-gray-200">
                          <th className="text-left py-3 px-2 text-sm font-semibold text-gray-600">Descripción</th>
                          <th className="text-center py-3 px-2 text-sm font-semibold text-gray-600">Cant.</th>
                          <th className="text-right py-3 px-2 text-sm font-semibold text-gray-600">Original</th>
                          <th className="text-right py-3 px-2 text-sm font-semibold text-gray-600">Con Interés</th>
                        </tr>
                      </thead>
                      <tbody>
                        {purchasesSummary.by_description
                          .sort((a, b) => b.total_with_interest - a.total_with_interest)
                          .map((item, i) => (
                            <tr key={i} className="border-b border-gray-100 hover:bg-gray-50">
                              <td className="py-3 px-2 text-sm text-gray-700">{item.description}</td>
                              <td className="py-3 px-2 text-sm text-center text-gray-700">{item.count}</td>
                              <td className="py-3 px-2 text-sm text-right font-semibold text-gray-800">{formatCurrency(item.total_original)}</td>
                              <td className="py-3 px-2 text-sm text-right font-semibold text-indigo-700">{formatCurrency(item.total_with_interest)}</td>
                            </tr>
                          ))}
                      </tbody>
                      <tfoot>
                        <tr className="border-t-2 border-gray-300">
                          <td className="py-3 px-2 text-sm font-bold text-gray-800">Total</td>
                          <td className="py-3 px-2 text-sm text-center font-bold text-gray-800">{purchasesSummary.purchase_count}</td>
                          <td className="py-3 px-2 text-sm text-right font-bold text-gray-800">{formatCurrency(purchasesSummary.total_original)}</td>
                          <td className="py-3 px-2 text-sm text-right font-bold text-indigo-700">{formatCurrency(purchasesSummary.total_with_interest)}</td>
                        </tr>
                      </tfoot>
                    </table>
                  </div>
                </div>
              </div>
            </>
          ) : (
            <div className="bg-white rounded-xl shadow-lg p-12 text-center text-gray-400">
              <p>Cargando resumen...</p>
            </div>
          )}
        </div>
      )}

      {/* Modals */}
      <NewCreditCardModal
        isOpen={newModalOpen}
        onClose={() => setNewModalOpen(false)}
        onSuccess={loadCards}
      />

      <EditCreditCardModal
        isOpen={editModalOpen}
        card={cardToEdit}
        onClose={() => {
          setEditModalOpen(false);
          setCardToEdit(null);
        }}
        onSave={handleSaveEdit}
      />

      <PurchaseModal
        isOpen={purchaseModalOpen}
        card={cardForPurchase}
        purchase={purchaseToEdit}
        onClose={() => {
          setPurchaseModalOpen(false);
          setCardForPurchase(null);
          setPurchaseToEdit(null);
        }}
        onSuccess={handlePurchaseSuccess}
      />

      <InstallmentScheduleModal
        isOpen={scheduleModalOpen}
        plan={selectedPlan}
        onClose={() => {
          setScheduleModalOpen(false);
          setSelectedPlan(null);
        }}
        onPaymentSuccess={() => {
          if (selectedCard) {
            loadCardSummary(selectedCard.id);
          }
        }}
        canEdit={canEdit}
      />

      {csvImportOpen && selectedCard && (
        <CreditCardCSVImport
          cardId={selectedCard.id}
          cardName={`${selectedCard.bank_name} - ${selectedCard.card_name}`}
          onImportSuccess={() => {
            loadCardPurchases(selectedCard.id);
            loadCardSummary(selectedCard.id);
          }}
          onClose={() => setCsvImportOpen(false)}
        />
      )}

      <ConfirmDialog
        isOpen={deleteDialog.isOpen}
        title="Eliminar Tarjeta"
        message={`¿Estás seguro de que quieres eliminar la tarjeta "${deleteDialog.cardName}"? Esta acción no se puede deshacer.`}
        confirmText="Eliminar"
        cancelText="Cancelar"
        onConfirm={handleDeleteConfirm}
        onCancel={() => setDeleteDialog({ isOpen: false, cardId: null, cardName: '' })}
        isDangerous={true}
      />

      <ConfirmDialog
        isOpen={deletePurchaseDialog.isOpen}
        title="Eliminar Gasto"
        message={`¿Estás seguro de que quieres eliminar "${deletePurchaseDialog.purchaseName}"? Se eliminarán también el plan de cuotas y el item de presupuesto asociado.`}
        confirmText="Eliminar"
        cancelText="Cancelar"
        onConfirm={handleDeletePurchaseConfirm}
        onCancel={() => setDeletePurchaseDialog({ isOpen: false, purchaseId: null, purchaseName: '' })}
        isDangerous={true}
      />
    </div>
  );
}
