import { Chart as ChartJS, ArcElement, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend } from 'chart.js';
import { Pie, Bar } from 'react-chartjs-2';
import { useMemo } from 'react';

ChartJS.register(ArcElement, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend);

function TransactionReport({ transactions }) {
  const chartColors = ['#6366F1', '#8B5CF6', '#EC4899', '#F59E0B', '#22C55E', '#3B82F6', '#EF4444'];

  const categoryData = useMemo(() => {
    const gastos = transactions.filter(t => t.tipo === 'Gasto');
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
  }, [transactions]);

  const dateData = useMemo(() => {
    const grouped = transactions.reduce((acc, t) => {
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
  }, [transactions]);

  const stats = useMemo(() => {
    const ingresos = transactions
      .filter(t => t.tipo === 'Ingreso')
      .reduce((sum, t) => sum + (parseFloat(t.monto) || 0), 0);
    const gastos = transactions
      .filter(t => t.tipo === 'Gasto')
      .reduce((sum, t) => sum + (parseFloat(t.monto) || 0), 0);
    const balance = ingresos - gastos;

    return { ingresos, gastos, balance };
  }, [transactions]);

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
          <h3 className="text-lg font-bold text-finly-text mb-4">
            Últimas Transacciones
          </h3>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Fecha</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Tipo</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Categoría</th>
                  <th className="text-right py-3 px-4 text-sm font-semibold text-finly-text">Monto</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Detalle</th>
                </tr>
              </thead>
              <tbody>
                {transactions.slice().reverse().map((t, idx) => (
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
