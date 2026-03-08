import { useState } from 'react';
import Papa from 'papaparse';

function CSVImport({ addMultipleTransactions }) {
  const [csvHeaders, setCsvHeaders] = useState([]);
  const [rawRows, setRawRows] = useState([]);
  const [mapping, setMapping] = useState({ fecha: '', concepto: '', monto: '', tipo: '', categoria: '', forma_pago: '' });
  const [previewData, setPreviewData] = useState([]);
  const [message, setMessage] = useState(null);

  const requiredFields = ['fecha', 'monto'];
  const optionalFields = ['concepto', 'tipo', 'categoria', 'forma_pago'];

  const downloadTemplate = () => {
    // Create CSV content with headers and example row
    const headers = ['fecha', 'tipo', 'categoria', 'monto', 'forma_pago', 'detalle'];
    const exampleRow = ['2024-03-06', 'Gasto', 'Comida', '15000', 'Débito', 'Almuerzo en restaurante'];
    
    const csvContent = [
      headers.join(','),
      exampleRow.join(',')
    ].join('\n');

    // Create blob and download
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    
    link.setAttribute('href', url);
    link.setAttribute('download', 'plantilla_transacciones.csv');
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handleFile = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    setMessage(null);
    Papa.parse(file, {
      header: true,
      skipEmptyLines: true,
      complete: (results) => {
        if (results.data.length === 0) {
          setMessage({ type: 'error', text: 'El archivo CSV está vacío' });
          return;
        }
        setCsvHeaders(Object.keys(results.data[0]));
        setRawRows(results.data);
        setMessage({ type: 'success', text: `Archivo cargado: ${results.data.length} filas detectadas` });
      },
      error: (error) => {
        setMessage({ type: 'error', text: `Error al leer el archivo: ${error.message}` });
      }
    });
  };

  const processImport = () => {
    setMessage(null);

    // Validate required mappings
    if (!mapping.fecha || !mapping.monto) {
      setMessage({ type: 'error', text: 'Debes seleccionar al menos las columnas de Fecha y Monto' });
      return;
    }

    try {
      const formatted = rawRows.map((row, index) => {
        // Parse amount - handle Argentine format (12.981,50) and US format (12,981.50)
        const montoStr = row[mapping.monto]?.toString().trim() || '0';
        let monto;
        
        // Detect format by checking if comma is the last separator (Argentine format)
        const lastCommaIndex = montoStr.lastIndexOf(',');
        const lastDotIndex = montoStr.lastIndexOf('.');
        
        if (lastCommaIndex > lastDotIndex) {
          // Argentine format: 12.981,50 → remove dots (thousands), replace comma with dot (decimal)
          monto = parseFloat(montoStr.replace(/\./g, '').replace(',', '.'));
        } else if (lastDotIndex > lastCommaIndex) {
          // US format: 12,981.50 → remove commas (thousands), keep dot (decimal)
          monto = parseFloat(montoStr.replace(/,/g, ''));
        } else {
          // No separators or single separator - parse as is
          monto = parseFloat(montoStr);
        }
        
        // Validate the result
        monto = isNaN(monto) ? 0 : monto;
        
        if (monto === 0 && montoStr !== '0') {
          throw new Error(`Monto inválido en la fila ${index + 1}`);
        }

        return {
          id: Date.now() + index,
          marca_temporal: new Date().toISOString(),
          fecha: row[mapping.fecha],
          tipo: mapping.tipo ? row[mapping.tipo] : 'Gasto',
          categoria: mapping.categoria ? row[mapping.categoria] : 'Comida',
          monto: monto,
          necesidad: 'Necesario',
          forma_pago: mapping.forma_pago ? row[mapping.forma_pago] : 'Débito',
          partida: mapping.categoria ? row[mapping.categoria] : 'Comida',
          detalle: mapping.concepto ? row[mapping.concepto] : ''
        };
      });

      const preview = formatted.slice(0, 5);
      setPreviewData(preview);
      setMessage({ 
        type: 'info', 
        text: `Vista previa de ${preview.length} de ${formatted.length} transacciones. Revisa y confirma la importación.` 
      });

      // Store formatted data for confirmation
      window.formattedTransactions = formatted;
    } catch (error) {
      setMessage({ type: 'error', text: error.message });
    }
  };

  const confirmImport = async () => {
    if (window.formattedTransactions && window.formattedTransactions.length > 0) {
      try {
        await addMultipleTransactions(window.formattedTransactions);
        setMessage({ 
          type: 'success', 
          text: `✅ ${window.formattedTransactions.length} transacciones guardadas en Google Sheets` 
        });
        
        // Reset
        setCsvHeaders([]);
        setRawRows([]);
        setMapping({ fecha: '', concepto: '', monto: '', tipo: '', categoria: '', forma_pago: '' });
        setPreviewData([]);
        window.formattedTransactions = null;
      } catch (error) {
        setMessage({ 
          type: 'error', 
          text: '❌ Error al conectar con Google Sheets. Verifica tu conexión.' 
        });
      }
    }
  };

  const resetImport = () => {
    setCsvHeaders([]);
    setRawRows([]);
    setMapping({ fecha: '', concepto: '', monto: '', tipo: '', categoria: '', forma_pago: '' });
    setPreviewData([]);
    setMessage(null);
    window.formattedTransactions = null;
  };

  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <div className="bg-white rounded-xl shadow-md p-8">
        <h2 className="text-2xl font-bold text-finly-text mb-6">
          Importar Transacciones desde CSV
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
                <li>• Columnas requeridas: Fecha y Monto</li>
                <li>• Columnas opcionales: Tipo, Categoría, Concepto/Detalle</li>
                <li>• Ejemplo de formato de monto: 1234.56 o $1,234.56</li>
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
                      {field} {requiredFields.includes(field) && <span className="text-red-500">*</span>}
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
                disabled={!mapping.fecha || !mapping.monto}
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
          </div>
        )}
      </div>

      {/* Preview Table */}
      {previewData.length > 0 && (
        <div className="bg-white rounded-xl shadow-md p-8">
          <h3 className="text-xl font-bold text-finly-text mb-4">
            Vista Previa de Importación
          </h3>
          <div className="overflow-x-auto mb-6">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Fecha</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Tipo</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Categoría</th>
                  <th className="text-right py-3 px-4 text-sm font-semibold text-finly-text">Monto</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Forma de Pago</th>
                  <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Detalle</th>
                </tr>
              </thead>
              <tbody>
                {previewData.map((t, idx) => (
                  <tr key={idx} className="border-b border-gray-100">
                    <td className="py-3 px-4 text-sm text-finly-text">{t.fecha}</td>
                    <td className="py-3 px-4">
                      <span className={`inline-block px-2 py-1 rounded text-xs font-semibold ${
                        t.tipo === 'Ingreso' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'
                      }`}>
                        {t.tipo}
                      </span>
                    </td>
                    <td className="py-3 px-4 text-sm text-finly-text">{t.categoria}</td>
                    <td className="py-3 px-4 text-sm text-right font-semibold text-finly-text">
                      ${t.monto.toLocaleString('es-AR', { minimumFractionDigits: 2 })}
                    </td>
                    <td className="py-3 px-4 text-sm text-finly-text">{t.forma_pago || 'Débito'}</td>
                    <td className="py-3 px-4 text-sm text-finly-textSecondary">{t.detalle || '-'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <button
            onClick={confirmImport}
            className="w-full bg-green-600 text-white py-3 rounded-lg font-semibold hover:bg-green-700 transition"
          >
            ✓ Confirmar e Importar Todas las Transacciones
          </button>
        </div>
      )}
    </div>
  );
}

export default CSVImport;
