import { useState, useEffect } from 'react';
import { transactionsAPI, debtsAPI } from '../services/api';

function TransactionForm({ addTransaction }) {
  const [formData, setFormData] = useState({
    fecha: new Date().toISOString().split('T')[0],
    tipo: 'Gasto',
    categoria: 'Comida',
    monto: '',
    necesidad: 'Necesario',
    forma_pago: 'Débito',
    detalle: '',
    debt_id: null
  });

  const [categories, setCategories] = useState([]);
  const [transactionTypes, setTransactionTypes] = useState([]);
  const [necessityTypes, setNecessityTypes] = useState([]);
  const [debts, setDebts] = useState([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState(null);

  useEffect(() => {
    loadOptions();
    loadDebts();
  }, []);

  const loadOptions = async () => {
    try {
      const [catRes, typeRes, needRes] = await Promise.all([
        transactionsAPI.getCategories(),
        transactionsAPI.getTransactionTypes(),
        transactionsAPI.getNecessityTypes()
      ]);
      setCategories(catRes.data);
      setTransactionTypes(typeRes.data);
      setNecessityTypes(needRes.data);
    } catch (error) {
      console.error('Error loading options:', error);
    }
  };

  const loadDebts = async () => {
    try {
      const response = await debtsAPI.getDebts();
      // Mostrar todos los items de presupuesto (tanto gastos como ingresos)
      const allDebts = (response.data || [])
        .sort((a, b) => {
          const labelA = (a.detalle || `Presupuesto ${a.tipo || ''}`).trim().toLowerCase();
          const labelB = (b.detalle || `Presupuesto ${b.tipo || ''}`).trim().toLowerCase();
          return labelA.localeCompare(labelB, 'es');
        });
      setDebts(allDebts);
    } catch (error) {
      console.error('Error loading debts:', error);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);

    try {
      const transaction = {
        ...formData,
        marca_temporal: new Date().toISOString(),
        monto: parseFloat(formData.monto),
        id: Date.now(),
        debt_id: formData.debt_id ? parseInt(formData.debt_id) : null
      };

      await addTransaction(transaction);
      
      setMessage({ type: 'success', text: '✅ Transacción guardada correctamente' });
      
      // Reset form
      setFormData({
        fecha: new Date().toISOString().split('T')[0],
        tipo: 'Gasto',
        categoria: 'Comida',
        monto: '',
        necesidad: 'Necesario',
        forma_pago: 'Débito',
        detalle: '',
        debt_id: null
      });
    } catch (error) {
      setMessage({ type: 'error', text: '❌ Error al guardar la transacción' });
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  return (
    <div className="max-w-2xl mx-auto">
      <div className="bg-white rounded-xl shadow-md p-8">
        <h2 className="text-2xl font-bold text-finly-text mb-6">
          Cargar Gasto/Ingreso
        </h2>

        {message && (
          <div className={`mb-6 p-4 rounded-lg ${
            message.type === 'success' 
              ? 'bg-green-50 text-green-700 border border-green-200' 
              : 'bg-red-50 text-red-700 border border-red-200'
          }`}>
            {message.text}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Fecha *
              </label>
              <input
                type="date"
                name="fecha"
                value={formData.fecha}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Tipo *
              </label>
              <select
                name="tipo"
                value={formData.tipo}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              >
                {transactionTypes.map(type => (
                  <option key={type} value={type}>{type}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Categoría *
              </label>
              <select
                name="categoria"
                value={formData.categoria}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              >
                {categories.map(cat => (
                  <option key={cat} value={cat}>{cat}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Monto (ARS) *
              </label>
              <input
                type="number"
                name="monto"
                value={formData.monto}
                onChange={handleChange}
                step="0.01"
                min="0"
                placeholder="0.00"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Necesidad *
              </label>
              <select
                name="necesidad"
                value={formData.necesidad}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              >
                {necessityTypes.map(need => (
                  <option key={need} value={need}>{need}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Forma de Pago *
              </label>
              <select
                name="forma_pago"
                value={formData.forma_pago}
                onChange={handleChange}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                required
              >
                <option value="Débito">Débito</option>
                <option value="Crédito">Crédito</option>
              </select>
            </div>

            {/* Selector de presupuesto para gastos e ingresos */}
            {debts.length > 0 && (
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-finly-text mb-2">
                  Asociar a Item de Presupuesto (Opcional)
                  {formData.categoria && (
                    <span className="ml-2 text-xs font-normal text-blue-600">
                      💡 Sugerencia: Busque {formData.tipo === 'Gasto' ? 'gastos' : 'ingresos'} en categoría "{formData.categoria}"
                    </span>
                  )}
                </label>
                <select
                  name="debt_id"
                  value={formData.debt_id || ''}
                  onChange={handleChange}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                >
                  <option value="">-- Sin asignar (se asignará automáticamente) --</option>
                  <optgroup label="🎯 Sugeridos por categoría y tipo de flujo">
                    {debts
                      .filter(debt => 
                        debt.categoria === formData.categoria && 
                        debt.tipo_flujo === formData.tipo
                      )
                      .map(debt => {
                        const montoEjecutado = debt.monto_ejecutado ?? debt.monto_pagado ?? 0;
                        const remaining = debt.monto_total - montoEjecutado;
                        const tipoPresupuesto = debt.tipo_presupuesto || 'OBLIGATION';
                        const tipoBadge = tipoPresupuesto === 'OBLIGATION' ? '🔴' : '🔵';
                        const flujoIcon = debt.tipo_flujo === 'Gasto' ? '💸' : '💰';
                        return (
                          <option key={debt.id} value={debt.id}>
                            {tipoBadge} {flujoIcon} {debt.detalle || `${debt.tipo} - ${debt.categoria}`} - Resta: ${remaining.toFixed(2)}
                          </option>
                        );
                      })}
                  </optgroup>
                  <optgroup label="📋 Otros items de presupuesto">
                    {debts
                      .filter(debt => 
                        !(debt.categoria === formData.categoria && debt.tipo_flujo === formData.tipo)
                      )
                      .map(debt => {
                        const montoEjecutado = debt.monto_ejecutado ?? debt.monto_pagado ?? 0;
                        const remaining = debt.monto_total - montoEjecutado;
                        const tipoPresupuesto = debt.tipo_presupuesto || 'OBLIGATION';
                        const tipoBadge = tipoPresupuesto === 'OBLIGATION' ? '🔴' : '🔵';
                        const flujoIcon = debt.tipo_flujo === 'Gasto' ? '💸' : '💰';
                        return (
                          <option key={debt.id} value={debt.id}>
                            {tipoBadge} {flujoIcon} {debt.detalle || `${debt.tipo} - ${debt.categoria}`} - Resta: ${remaining.toFixed(2)}
                          </option>
                        );
                      })}
                  </optgroup>
                </select>
                <p className="text-xs text-finly-textSecondary mt-1">
                  🔴 Obligación (Deuda/Compromiso) | 🔵 Variable (Flexible) | Si no selecciona, se asignará automáticamente
                </p>
              </div>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-finly-text mb-2">
              Detalle
            </label>
            <input
              type="text"
              name="detalle"
              value={formData.detalle}
              onChange={handleChange}
              maxLength={50}
              placeholder="Descripción de la transacción (máx. 50 caracteres)"
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
            />
            <p className="text-xs text-finly-textSecondary mt-1">
              {formData.detalle.length}/50 caracteres
            </p>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-finly-primary text-white py-3 rounded-lg font-semibold hover:bg-indigo-700 transition disabled:opacity-50"
          >
            {loading ? 'Guardando...' : 'Guardar Transacción'}
          </button>
        </form>
      </div>
    </div>
  );
}

export default TransactionForm;
