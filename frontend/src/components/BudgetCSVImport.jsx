import { useState } from 'react';
import Papa from 'papaparse';
import { decodeCsvFile } from '../utils/csvEncoding';

function BudgetCSVImport({ onImportSuccess }) {
  const [csvHeaders, setCsvHeaders] = useState([]);
  const [rawRows, setRawRows] = useState([]);
  const [mapping, setMapping] = useState({ 
    detalle: '', 
    monto_total: '', 
    tipo: '', 
    categoria: '', 
    fecha_vencimiento: '' 
  });
  const [previewData, setPreviewData] = useState([]);
  const [message, setMessage] = useState(null);
  const [isImporting, setIsImporting] = useState(false);

  const requiredFields = ['detalle', 'monto_total', 'fecha_vencimiento'];
  const optionalFields = ['tipo', 'categoria'];

  const downloadTemplate = () => {
    const headers = ['detalle', 'monto_total', 'tipo', 'categoria', 'fecha_vencimiento'];
    const exampleRows = [
      ['Alquiler', '50000', 'Vivienda', 'Alquiler', '2024-04-05'],
      ['Tarjeta Visa', '120000', 'Tarjeta', 'Crédito', '2024-04-10'],
      ['Internet', '4000', 'Servicio', 'Servicios', '2024-04-15'],
      ['Salario', '250000', 'Ingreso', 'Trabajo', '2024-04-30']
    ];
    
    const csvContent = [
      headers.join(','),
      ...exampleRows.map(row => row.join(','))
    ].join('\n');

    // Create blob with UTF-8 BOM for Excel compatibility
    const BOM = '\uFEFF';
    const blob =new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    
    link.setAttribute('href', url);
    link.setAttribute('download', 'plantilla_presupuestos.csv');
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handleFile = async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    setMessage(null);
    try {
      const { text, encoding } = await decodeCsvFile(file);

      Papa.parse(text, {
      header: true,
      skipEmptyLines: true,
      complete: (results) => {
        if (results.data.length === 0) {
          setMessage({ type: 'error', text: 'El archivo CSV está vacío' });
          return;
        }
        setCsvHeaders(Object.keys(results.data[0]));
        setRawRows(results.data);
        setMessage({ 
          type: 'success', 
          text: `Archivo cargado: ${results.data.length} filas detectadas (${encoding.toUpperCase()})` 
        });
      },
      error: (error) => {
        setMessage({ type: 'error', text: `Error al leer el archivo: ${error.message}` });
      }
      });
    } catch (error) {
      setMessage({ type: 'error', text: `Error al leer el archivo: ${error.message}` });
    }
  };

  const processImport = () => {
    setMessage(null);

    // Validate required mappings
    if (!mapping.detalle || !mapping.monto_total || !mapping.fecha_vencimiento) {
      setMessage({ 
        type: 'error', 
        text: 'Debes seleccionar las columnas: Detalle, Monto Total y Fecha Vencimiento' 
      });
      return;
    }

    try {
      const formatted = rawRows.map((row, index) => {
        // Parse amount
        const montoStr = row[mapping.monto_total]?.toString().trim() || '0';
        let monto;
        
        // Detect format (Argentine vs US)
        const lastCommaIndex = montoStr.lastIndexOf(',');
        const lastDotIndex = montoStr.lastIndexOf('.');
        
        if (lastCommaIndex > lastDotIndex) {
          // Argentine format: 12.981,50
          monto = parseFloat(montoStr.replace(/\./g, '').replace(',', '.'));
        } else if (lastDotIndex > lastCommaIndex) {
          // US format: 12,981.50
          monto = parseFloat(montoStr.replace(/,/g, ''));
        } else {
          monto = parseFloat(montoStr);
        }
        
        // Validate
        monto = isNaN(monto) ? 0 : monto;
        
        if (monto === 0 && montoStr !== '0') {
          throw new Error(`Monto inválido en la fila ${index + 1}`);
        }

        return {
          fecha: new Date().toLocaleDateString('es-AR', { 
            day: '2-digit', 
            month: '2-digit', 
            year: 'numeric' 
          }),
          tipo: mapping.tipo ? row[mapping.tipo] : 'Préstamo',
          categoria: mapping.categoria ? row[mapping.categoria] : '',
          monto_total: monto,
          monto_pagado: 0.0,
          detalle: row[mapping.detalle] || '',
          fecha_vencimiento: row[mapping.fecha_vencimiento] || '',
          status: 'PENDIENTE'
        };
      });

      const preview = formatted.slice(0, 5);
      setPreviewData(preview);
      setMessage({ 
        type: 'info', 
        text: `Vista previa de ${preview.length} de ${formatted.length} items. Revisa y confirma la importación.` 
      });

      // Store for confirmation
      window.formattedBudgets = formatted;
    } catch (error) {
      setMessage({ type: 'error', text: error.message });
    }
  };

  const confirmImport = async () => {
    if (!window.formattedBudgets || window.formattedBudgets.length === 0) {
      setMessage({ type: 'error', text: 'No hay datos para importar' });
      return;
    }

    setIsImporting(true);
    try {
      const response = await fetch('http://localhost:8000/api/budget-items/import-csv', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${localStorage.getItem('token')}`
        },
        body: JSON.stringify(window.formattedBudgets)
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.detail || 'Error al importar presupuestos');
      }

      const result = await response.json();
      
      setMessage({ 
        type: 'success', 
        text: `✅ ${result.added} presupuestos importados exitosamente` 
      });
      
      // Reset
      setCsvHeaders([]);
      setRawRows([]);
      setMapping({ detalle: '', monto_total: '', tipo: '', categoria: '', fecha_vencimiento: '' });
      setPreviewData([]);
      window.formattedBudgets = null;

      // Callback to parent
      if (onImportSuccess) {
        setTimeout(() => onImportSuccess(), 1500);
      }
    } catch (error) {
      setMessage({ 
        type: 'error', 
        text: `❌ Error: ${error.message}` 
      });
    } finally {
      setIsImporting(false);
    }
  };

  const resetImport = () => {
    setCsvHeaders([]);
    setRawRows([]);
    setMapping({ detalle: '', monto_total: '', tipo: '', categoria: '', fecha_vencimiento: '' });
    setPreviewData([]);
    setMessage(null);
    window.formattedBudgets = null;
  };

  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <div className="bg-white rounded-xl shadow-md p-8">
        <h2 className="text-2xl font-bold text-finly-text mb-6">
          Importar Presupuestos desde CSV
        </h2>

        {message && (
          <div className={`mb-6 p-4 rounded-lg ${
            message.type === 'success' ? 'bg-green-50 text-green-700 border border-green-200' :
            message.type === 'error' ? 'bg-red-50 text-red-700 border border-red-200' :
            'bg-blue-50 text-blue-700 border border-blue-200'
          }`}>
            {message.text}
          </div>
        )}

        {!csvHeaders.length ? (
          <div>
            <div className="border-2 border-dashed border-finly-dropzoneBorder bg-finly-dropzone rounded-xl p-12 text-center">
              <div className="text-6xl mb-4">📁</div>
              <h3 className="text-lg font-semibold text-finly-text mb-2">
                Arrastra tu archivo CSV aquí
              </h3>
              <p className="text-finly-textSecondary mb-4">
                o haz clic para seleccionar un archivo
              </p>
              <input
                type="file"
                accept=".csv"
                onChange={handleFile}
                className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-finly-primary file:text-white hover:file:bg-indigo-700 file:cursor-pointer cursor-pointer"
              />
            </div>

            <div className="mt-6 bg-gray-50 rounded-lg p-4">
              <h4 className="font-semibold text-finly-text mb-2">📌 Formato del CSV:</h4>
              <ul className="text-sm text-finly-textSecondary space-y-1">
                <li>• Primera fila debe contener los encabezados</li>
                <li>• Columnas requeridas: Detalle, Monto Total, Fecha Vencimiento</li>
                <li>• Columnas opcionales: Tipo, Categoría</li>
                <li>• Formato de fecha: YYYY-MM-DD o DD/MM/YYYY</li>
                <li>• Ejemplo de monto: 50000 o 50.000 o 50,000.00</li>
              </ul>
              <button
                onClick={downloadTemplate}
                className="mt-4 w-full bg-finly-primary text-white py-2 px-4 rounded-lg font-semibold hover:bg-indigo-700 transition flex items-center justify-center space-x-2"
              >
                <span>📥</span>
                <span>Descargar Plantilla CSV</span>
              </button>
            </div>
          </div>
        ) : (
          <div className="space-y-6">
            <div className="bg-gray-50 rounded-lg p-4">
              <h3 className="font-bold text-finly-text mb-4">
                📋 Mapear Columnas del CSV
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {[...requiredFields, ...optionalFields].map((field) => (
                  <div key={field}>
                    <label className="block text-sm font-medium text-finly-text mb-2 capitalize">
                      {field === 'detalle' && 'Detalle'}
                      {field === 'monto_total' && 'Monto Total'}
                      {field === 'tipo' && 'Tipo'}
                      {field === 'categoria' && 'Categoría'}
                      {field === 'fecha_vencimiento' && 'Fecha Vencimiento'}
                      {requiredFields.includes(field) && <span className="text-red-500">*</span>}
                    </label>
                    <select
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                      value={mapping[field]}
                      onChange={(e) => setMapping({ ...mapping, [field]: e.target.value })}
                    >
                      <option value="">-- Seleccionar columna --</option>
                      {csvHeaders.map(h => (
                        <option key={h} value={h}>{h}</option>
                      ))}
                    </select>
                  </div>
                ))}
              </div>
            </div>

            <div className="flex space-x-4">
              <button
                onClick={processImport}
                disabled={!mapping.detalle || !mapping.monto_total || !mapping.fecha_vencimiento}
                className="flex-1 bg-finly-primary text-white py-3 rounded-lg font-semibold hover:bg-indigo-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Vista Previa ({rawRows.length} filas)
              </button>
              <button
                onClick={resetImport}
                className="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg font-semibold hover:bg-gray-300 transition"
              >
                Cancelar
              </button>
            </div>

            {previewData.length > 0 && (
              <div className="bg-gray-50 rounded-lg p-4">
                <h3 className="font-bold text-finly-text mb-4">
                  👁️ Vista Previa
                </h3>
                <div className="overflow-x-auto">
                  <table className="w-full text-sm">
                    <thead className="bg-gray-200">
                      <tr>
                        <th className="px-4 py-2 text-left">Detalle</th>
                        <th className="px-4 py-2 text-left">Tipo</th>
                        <th className="px-4 py-2 text-left">Categoría</th>
                        <th className="px-4 py-2 text-right">Monto Total</th>
                        <th className="px-4 py-2 text-left">Vencimiento</th>
                      </tr>
                    </thead>
                    <tbody>
                      {previewData.map((item, idx) => (
                        <tr key={idx} className="border-b">
                          <td className="px-4 py-2">{item.detalle}</td>
                          <td className="px-4 py-2">{item.tipo}</td>
                          <td className="px-4 py-2">{item.categoria}</td>
                          <td className="px-4 py-2 text-right">
                            ${item.monto_total.toLocaleString('es-AR', { minimumFractionDigits: 2 })}
                          </td>
                          <td className="px-4 py-2">{item.fecha_vencimiento}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                <div className="mt-4 flex space-x-4">
                  <button
                    onClick={confirmImport}
                    disabled={isImporting}
                    className="flex-1 bg-green-600 text-white py-3 rounded-lg font-semibold hover:bg-green-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isImporting ? 'Importando...' : `✅ Confirmar Importación (${window.formattedBudgets?.length || 0} items)`}
                  </button>
                  <button
                    onClick={() => setPreviewData([])}
                    disabled={isImporting}
                    className="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg font-semibold hover:bg-gray-300 transition disabled:opacity-50"
                  >
                    Volver
                  </button>
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

export default BudgetCSVImport;
