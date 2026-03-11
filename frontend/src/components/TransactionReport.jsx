import { Chart as ChartJS, ArcElement, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend } from 'chart.js';
import { Pie, Bar } from 'react-chartjs-2';
import { useMemo, useState } from 'react';

ChartJS.register(ArcElement, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

function TransactionReport({ transactions, onEdit, onDelete, canEdit = false }) {
  const chartColors = ['#6366F1', '#8B5CF6', '#EC4899', '#F59E0B', '#22C55E', '#3B82F6', '#EF4444'];
  
  // Filtros y ordenamiento
  const [filterType, setFilterType] = useState('all');
  const [filterCategory, setFilterCategory] = useState('all');
  const [sortBy, setSortBy] = useState('fecha');
  const [sortOrder, setSortOrder] = useState('desc');

  // Obtener categorías únicas
  const categories = useMemo(() => {
    const uniqueCategories = [...new Set(transactions.map(t => t.categoria))];
    return uniqueCategories.sort();
  }, [transactions]);

  // Aplicar filtros y ordenamiento
  const filteredAndSortedTransactions = useMemo(() => {
    let filtered = [...transactions];

    // Aplicar filtros
    if (filterType !== 'all') {
      filtered = filtered.filter(t => t.tipo === filterType);
    }
    if (filterCategory !== 'all') {
      filtered = filtered.filter(t => t.categoria === filterCategory);
    }

    // Aplicar ordenamiento
    filtered.sort((a, b) => {
      let compareValue = 0;
      
      switch (sortBy) {
        case 'fecha':
          compareValue = new Date(a.fecha) - new Date(b.fecha);
          break;
        case 'tipo':
          compareValue = a.tipo.localeCompare(b.tipo);
          break;
        case 'categoria':
          compareValue = a.categoria.localeCompare(b.categoria);
          break;
        case 'monto':
          compareValue = (parseFloat(a.monto) || 0) - (parseFloat(b.monto) || 0);
          break;
        default:
          compareValue = 0;
      }

      return sortOrder === 'asc' ? compareValue : -compareValue;
    });

    return filtered;
  }, [transactions, filterType, filterCategory, sortBy, sortOrder]);

  const handleEdit = (transaction) => {
    if (onEdit) {
      onEdit(transaction);
    }
  };

  const handleDelete = (transaction) => {
    if (onDelete && window.confirm(`¿Estás seguro de eliminar esta transacción?\n\nFecha: ${transaction.fecha}\nMonto: $${transaction.monto}\nDetalle: ${transaction.detalle || 'Sin detalle'}`)) {
      onDelete(transaction);
    }
  };

  const categoryData = useMemo(() => {
    const gastos = filteredAndSortedTransactions.filter(t => t.tipo === 'Gasto');
    const grouped = gastos.reduce((acc, t) => {
      acc[t.categoria] = (acc[t.categoria] || 0) + (parseFloat(t.monto) || 0);
      return acc;
    }, {});

    return {
      labels: Object.keys(grouped),
      datasets: [{
        label: 'Gastos por Categoría',
        data: Object.values(grouped),
        backgroundColor: chartColors,
        borderWidth: 2,
        borderColor: '#fff'
      }]
    };
  }, [filteredAndSortedTransactions]);

  const dateData = useMemo(() => {
    const grouped = filteredAndSortedTransactions.reduce((acc, t) => {
      const monto = parseFloat(t.monto) || 0;
      acc[t.fecha] = (acc[t.fecha] || 0) + (t.tipo === 'Gasto' ? -monto : monto);
      return acc;
    }, {});

    const sortedDates = Object.keys(grouped).sort();

    return {
      labels: sortedDates,
      datasets: [{
        label: 'Balance por Fecha',
        data: sortedDates.map(date => grouped[date]),
        backgroundColor: sortedDates.map(date => 
          grouped[date] >= 0 ? '#22C55E' : '#EF4444'
        ),
      }]
    };
  }, [filteredAndSortedTransactions]);

  const stats = useMemo(() => {
    const ingresos = filteredAndSortedTransactions
      .filter(t => t.tipo === 'Ingreso')
      .reduce((sum, t) => sum + (parseFloat(t.monto) || 0), 0);
    const gastos = filteredAndSortedTransactions
      .filter(t => t.tipo === 'Gasto')
      .reduce((sum, t) => sum + (parseFloat(t.monto) || 0), 0);
    const balance = ingresos - gastos;

    return { ingresos, gastos, balance };
  }, [filteredAndSortedTransactions]);

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-finly-text">Reportes</h2>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-white rounded-xl shadow-md p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-finly-textSecondary">Ingresos</p>
              <p className="text-3xl font-bold text-finly-income mt-2">
                ${stats.ingresos.toLocaleString('es-AR', { minimumFractionDigits: 2 })}
              </p>
            </div>
            <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center text-2xl">
              📈
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-md p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-finly-textSecondary">Gastos</p>
              <p className="text-3xl font-bold text-finly-expense mt-2">
                ${stats.gastos.toLocaleString('es-AR', { minimumFractionDigits: 2 })}
              </p>
            </div>
            <div className="w-12 h-12 bg-red-100 rounded-full flex items-center justify-center text-2xl">
              📉
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-md p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm text-finly-textSecondary">Balance</p>
              <p className={`text-3xl font-bold mt-2 ${
                stats.balance >= 0 ? 'text-finly-income' : 'text-finly-expense'
              }`}>
                ${stats.balance.toLocaleString('es-AR', { minimumFractionDigits: 2 })}
              </p>
            </div>
            <div className={`w-12 h-12 rounded-full flex items-center justify-center text-2xl ${
              stats.balance >= 0 ? 'bg-blue-100' : 'bg-orange-100'
            }`}>
              💰
            </div>
          </div>
        </div>
      </div>

      {/* Charts */}
      {transactions.length > 0 ? (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white rounded-xl shadow-md p-6">
            <h3 className="text-lg font-bold text-finly-text mb-4">
              Gastos por Categoría
            </h3>
            <div className="h-80 flex items-center justify-center">
              <Pie 
                data={categoryData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: {
                      position: 'bottom',
                    }
                  }
                }}
              />
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-md p-6">
            <h3 className="text-lg font-bold text-finly-text mb-4">
              Balance por Fecha
            </h3>
            <div className="h-80">
              <Bar 
                data={dateData}
                options={{
                  responsive: true,
                  maintainAspectRatio: false,
                  plugins: {
                    legend: {
                      display: false,
                    }
                  },
                  scales: {
                    y: {
                      beginAtZero: true,
                      ticks: {
                        callback: function(value) {
                          return '$' + value.toLocaleString('es-AR');
                        }
                      }
                    }
                  }
                }}
              />
            </div>
          </div>
        </div>
      ) : (
        <div className="bg-white rounded-xl shadow-md p-12 text-center">
          <p className="text-finly-textSecondary text-lg">
            No hay transacciones para mostrar. Agrega algunas transacciones para ver los reportes.
          </p>
        </div>
      )}

      {/* Transaction List */}
      {transactions.length > 0 && (
        <div className="bg-white rounded-xl shadow-md p-6">
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-lg font-bold text-finly-text">
              Transacciones ({filteredAndSortedTransactions.length})
            </h3>
            <button
              onClick={() => {
                setFilterType('all');
                setFilterCategory('all');
                setSortBy('fecha');
                setSortOrder('desc');
              }}
              className="text-sm text-finly-primary hover:text-finly-secondary font-semibold transition"
            >
              Limpiar Filtros
            </button>
          </div>

          {/* Filtros y Ordenamiento */}
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6 p-4 bg-gray-50 rounded-lg">
            {/* Filtro por Tipo */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Filtrar por Tipo
              </label>
              <select
                value={filterType}
                onChange={(e) => setFilterType(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary text-sm"
              >
                <option value="all">Todos</option>
                <option value="Ingreso">Ingresos</option>
                <option value="Gasto">Gastos</option>
              </select>
            </div>

            {/* Filtro por Categoría */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Filtrar por Categoría
              </label>
              <select
                value={filterCategory}
                onChange={(e) => setFilterCategory(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary text-sm"
              >
                <option value="all">Todas</option>
                {categories.map(cat => (
                  <option key={cat} value={cat}>{cat}</option>
                ))}
              </select>
            </div>

            {/* Ordenar por */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Ordenar por
              </label>
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary text-sm"
              >
                <option value="fecha">Fecha</option>
                <option value="tipo">Tipo</option>
                <option value="categoria">Categoría</option>
                <option value="monto">Monto</option>
              </select>
            </div>

            {/* Orden */}
            <div>
              <label className="block text-sm font-medium text-finly-text mb-2">
                Orden
              </label>
              <select
                value={sortOrder}
                onChange={(e) => setSortOrder(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary text-sm"
              >
                <option value="desc">
                  {sortBy === 'fecha' ? 'Más reciente primero' : 
                   sortBy === 'monto' ? 'Mayor a menor' : 
                   'Z a A'}
                </option>
                <option value="asc">
                  {sortBy === 'fecha' ? 'Más antiguo primero' : 
                   sortBy === 'monto' ? 'Menor a mayor' : 
                   'A a Z'}
                </option>
              </select>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Fecha</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Tipo</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Categoría</th>
                  <th className="text-right py-3 px-4 text-sm font-semibold text-finly-text">Monto</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Detalle</th>
                  {canEdit && <th className="text-center py-3 px-4 text-sm font-semibold text-finly-text">Acciones</th>}
                </tr>
              </thead>
              <tbody>
                {filteredAndSortedTransactions.map((t, idx) => (
                  <tr key={t.id || idx} className="border-b border-gray-100 hover:bg-gray-50">
                    <td className="py-3 px-4 text-sm text-finly-text">{t.fecha}</td>
                    <td className="py-3 px-4">
                      <span className={`inline-block px-2 py-1 rounded text-xs font-semibold ${
                        t.tipo === 'Ingreso' 
                          ? 'bg-green-100 text-green-700' 
                          : 'bg-red-100 text-red-700'
                      }`}>
                        {t.tipo}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-sm text-finly-text">{t.categoria}</td>
                    <td className={`py-3 px-4 text-sm text-right font-semibold ${
                      t.tipo === 'Ingreso' ? 'text-finly-income' : 'text-finly-expense'
                    }`}>
                      ${(parseFloat(t.monto) || 0).toLocaleString('es-AR', { minimumFractionDigits: 2 })}
                    </td>
                    <td className="py-3 px-4 text-sm text-finly-textSecondary">{t.detalle || '-'}</td>
                    {canEdit && (
                      <td className="py-3 px-4 text-center">
                        <div className="flex justify-center gap-2">
                          <button
                            onClick={() => handleEdit(t)}
                            className="text-finly-primary hover:text-finly-secondary p-1.5 rounded hover:bg-finly-primary/10 transition-colors"
                            title="Editar transacción"
                          >
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                              <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
                            </svg>
                          </button>
                          <button
                            onClick={() => handleDelete(t)}
                            className="text-red-600 hover:text-red-700 p-1.5 rounded hover:bg-red-50 transition-colors"
                            title="Eliminar transacción"
                          >
                            <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4" viewBox="0 0 20 20" fill="currentColor">
                              <path fillRule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clipRule="evenodd" />
                            </svg>
                          </button>
                        </div>
                      </td>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}

export default TransactionReport;
