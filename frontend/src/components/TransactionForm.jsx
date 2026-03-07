import { useState, useEffect } from 'react';
import { transactionsAPI } from '../services/api';

function TransactionForm({ addTransaction }) {
  const [formData, setFormData] = useState({
    fecha: new Date().toISOString().split('T')[0],
    tipo: 'Gasto',
    categoria: 'Comida',
    monto: '',
    necesidad: 'Necesario',
    detalle: ''
  });

  const [categories, setCategories] = useState([]);
  const [transactionTypes, setTransactionTypes] = useState([]);
  const [necessityTypes, setNecessityTypes] = useState([]);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState(null);

  useEffect(() => {
    loadOptions();
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

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);

    try {
      const transaction = {
        ...formData,
        marca_temporal: new Date().toISOString(),
        partida: formData.categoria,
        monto: parseFloat(formData.monto),
        id: Date.now()
      };

      await addTransaction(transaction);
      
      setMessage({ type: 'success', text: '✅ Transacción guardada en Google Sheets' });
      
      // Reset form
      setFormData({
        fecha: new Date().toISOString().split('T')[0],
        tipo: 'Gasto',
        categoria: 'Comida',
        monto: '',
        necesidad: 'Necesario',
        detalle: ''
      });
    } catch (error) {
      setMessage({ type: 'error', text: '❌ Error al conectar con Google Sheets. Verifica tu conexión.' });
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
