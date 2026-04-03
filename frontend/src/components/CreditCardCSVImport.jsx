import { useState } from 'react';
import Papa from 'papaparse';
import { creditCardAPI } from '../services/api';

function CreditCardCSVImport({ cardId, cardName, onImportSuccess, onClose }) {
  const [csvHeaders, setCsvHeaders] = useState([]);
  const [rawRows, setRawRows] = useState([]);
  const [mapping, setMapping] = useState({
    fecha: '',
    descripcion: '',
    detalle: '',
    importe: ''
  });
  const [previewData, setPreviewData] = useState([]);
  const [formattedPurchases, setFormattedPurchases] = useState([]);
  const [message, setMessage] = useState(null);
  const [isImporting, setIsImporting] = useState(false);
  const [importResult, setImportResult] = useState(null);

  const requiredFields = ['fecha', 'descripcion', 'importe'];
  const optionalFields = ['detalle'];

  const fieldLabels = {
    fecha: 'Fecha',
    descripcion: 'Descripción',
    detalle: 'Detalle (cuotas)',
    importe: 'Importe'
  };

  const downloadTemplate = () => {
    const headers = ['fecha', 'Codigo', 'Descripcion', 'Detalle', 'Importe'];
    const exampleRows = [
      ['09/02/2026', '834023', 'VISA PLAN V', '2-12 (TNA 84,00)', '43946.21'],
      ['14/02/2026', '2723', 'MERPAGO BELLEZAPERFECTA', 'Cuota', '2381.66'],
      ['19/02/2026', '077', 'LIBRERIA LA MILAGROSA', '', '10000.00'],
      ['20/02/2026', '1', 'AUTOPISTA DEL OESTE', '', '1677.86']
    ];

    const csvContent = [
      headers.join(','),
      ...exampleRows.map(row => row.join(','))
    ].join('\n');

    const BOM = '\uFEFF';
    const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.setAttribute('href', url);
    link.setAttribute('download', 'plantilla_gastos_tarjeta.csv');
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const parseAmount = (raw) => {
    if (!raw) return 0;
    let str = raw.toString().trim();
    // Handle / as decimal separator (e.g. 3200/00 → 3200.00)
    str = str.replace(/\//g, '.');
    // Detect Argentine format: last comma is decimal (e.g. 12.981,50)
    const lastComma = str.lastIndexOf(',');
    const lastDot = str.lastIndexOf('.');
    if (lastComma > lastDot) {
      return parseFloat(str.replace(/\./g, '').replace(',', '.'));
    }
    if (lastDot > lastComma) {
      return parseFloat(str.replace(/,/g, ''));
    }
    return parseFloat(str);
  };

  const parseDate = (raw) => {
    if (!raw) return null;
    const str = raw.toString().trim();
    // Already ISO format
    if (/^\d{4}-\d{2}-\d{2}$/.test(str)) return str;
    // Handle DD/MM/YYYY, DD.MM.YYYY, DD-MM-YYYY (also 2-digit year)
    const match = str.match(/^(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})$/);
    if (match) {
      const day = match[1].padStart(2, '0');
      const month = match[2].padStart(2, '0');
      let year = match[3];
      if (year.length === 2) {
        year = `20${year}`;
      }
      return `${year}-${month}-${day}`;
    }
    return null;
  };

  const parseInstallmentInfo = (detalle) => {
    if (!detalle) return null;
    // Pattern: "2-12 (TNA 84,00)" → installment 2 of 12, interest 84%
    const match = detalle.match(/^(\d+)-(\d+)\s*\(TNA\s+([\d,.]+)\)/i);
    if (match) {
      const current = parseInt(match[1]);
      const total = parseInt(match[2]);
      const tna = parseAmount(match[3]);
      // Convert TNA (annual) to monthly rate
      const monthlyRate = tna / 12;
      return { current, total, tna, monthlyRate, isInstallment: true };
    }
    // Pattern: "Cuota" → single installment payment (no plan creation)
    if (/^cuota$/i.test(detalle.trim())) {
      return { isInstallment: false, isCuota: true };
    }
    return null;
  };

  const handleFile = async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    setMessage(null);
    setPreviewData([]);
    setFormattedPurchases([]);
    setImportResult(null);

    try {
      const text = await file.text();
      Papa.parse(text, {
        header: true,
        skipEmptyLines: true,
        complete: (results) => {
          if (results.data.length === 0) {
            setMessage({ type: 'error', text: 'El archivo CSV está vacío' });
            return;
          }
          const headers = Object.keys(results.data[0]);
          setCsvHeaders(headers);
          setRawRows(results.data);

          // Auto-map columns by matching common names
          const autoMapping = { fecha: '', descripcion: '', detalle: '', importe: '' };
          for (const h of headers) {
            const lower = h.toLowerCase().trim();
            if (lower === 'fecha' || lower === 'date') autoMapping.fecha = h;
            else if (lower === 'descripcion' || lower === 'description') autoMapping.descripcion = h;
            else if (lower === 'detalle' || lower === 'detail') autoMapping.detalle = h;
            else if (lower === 'importe' || lower === 'monto' || lower === 'amount') autoMapping.importe = h;
          }
          setMapping(autoMapping);

          setMessage({
            type: 'success',
            text: `Archivo cargado: ${results.data.length} filas detectadas`
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
    if (!mapping.fecha || !mapping.descripcion || !mapping.importe) {
      setMessage({ type: 'error', text: 'Debes seleccionar las columnas: Fecha, Descripción e Importe' });
      return;
    }

    try {
      const purchases = [];
      const errors = [];

      rawRows.forEach((row, index) => {
        try {
          const rawImporte = row[mapping.importe];
          const importe = parseAmount(rawImporte);
          if (!importe || isNaN(importe) || importe <= 0) {
            errors.push(`Fila ${index + 1}: Importe inválido "${rawImporte}"`);
            return;
          }

          const rawFecha = row[mapping.fecha];
          const fecha = parseDate(rawFecha);
          if (!fecha) {
            errors.push(`Fila ${index + 1}: Fecha inválida "${rawFecha}"`);
            return;
          }

          const descripcion = row[mapping.descripcion]?.trim() || '';
          if (!descripcion) {
            errors.push(`Fila ${index + 1}: Descripción vacía`);
            return;
          }

          const detalleRaw = mapping.detalle ? row[mapping.detalle]?.trim() : '';
          const installmentInfo = parseInstallmentInfo(detalleRaw);

          purchases.push({
            card_id: cardId,
            description: descripcion,
            amount: importe,
            purchase_date: fecha,
            installments: 1, // Default: single payment
            interest_rate: 0,
            detalle_raw: detalleRaw,
            installment_info: installmentInfo,
            _row: index + 1
          });
        } catch (err) {
          errors.push(`Fila ${index + 1}: ${err.message}`);
        }
      });

      if (purchases.length === 0) {
        setMessage({
          type: 'error',
          text: `No se pudieron procesar filas válidas. ${errors.length > 0 ? errors.join('; ') : ''}`
        });
        return;
      }

      setFormattedPurchases(purchases);
      setPreviewData(purchases.slice(0, 10));
      setMessage({
        type: 'info',
        text: `${purchases.length} gastos listos para importar${errors.length > 0 ? ` (${errors.length} filas con errores)` : ''}. Revisa y confirma.`
      });
    } catch (error) {
      setMessage({ type: 'error', text: error.message });
    }
  };

  const confirmImport = async () => {
    if (formattedPurchases.length === 0) {
      setMessage({ type: 'error', text: 'No hay datos para importar' });
      return;
    }

    setIsImporting(true);
    try {
      // Send bulk import request
      const payload = formattedPurchases.map(p => ({
        card_id: p.card_id,
        description: p.description,
        amount: p.amount,
        purchase_date: p.purchase_date,
        installments: p.installments,
        interest_rate: p.interest_rate,
        detalle: p.detalle_raw || ''
      }));

      const response = await creditCardAPI.bulkImportPurchases(cardId, payload);
      const result = response.data;

      setImportResult(result);
      setMessage({
        type: 'success',
        text: `✅ ${result.added} gastos importados exitosamente${result.errors?.length ? ` (${result.errors.length} errores)` : ''}`
      });

      if (result.added > 0 && onImportSuccess) {
        setTimeout(() => onImportSuccess(), 1500);
      }
    } catch (error) {
      const detail = error.response?.data?.detail || error.message;
      setMessage({ type: 'error', text: `❌ Error: ${detail}` });
    } finally {
      setIsImporting(false);
    }
  };

  const resetImport = () => {
    setCsvHeaders([]);
    setRawRows([]);
    setMapping({ fecha: '', descripcion: '', detalle: '', importe: '' });
    setPreviewData([]);
    setFormattedPurchases([]);
    setMessage(null);
    setImportResult(null);
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          {/* Header */}
          <div className="flex justify-between items-center mb-6">
            <div>
              <h2 className="text-2xl font-bold text-finly-text">
                📥 Importar Gastos desde CSV
              </h2>
              <p className="text-gray-500 mt-1">
                Tarjeta: <span className="font-medium text-gray-700">{cardName}</span>
              </p>
            </div>
            <button
              onClick={onClose}
              className="text-gray-400 hover:text-gray-600 text-2xl"
            >
              ✕
            </button>
          </div>

          {/* Messages */}
          {message && (
            <div className={`mb-6 p-4 rounded-lg ${
              message.type === 'success' ? 'bg-green-50 text-green-700 border border-green-200' :
              message.type === 'error' ? 'bg-red-50 text-red-700 border border-red-200' :
              'bg-blue-50 text-blue-700 border border-blue-200'
            }`}>
              {message.text}
            </div>
          )}

          {/* Import Result Details */}
          {importResult?.errors?.length > 0 && (
            <div className="mb-4 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
              <p className="font-medium text-yellow-800 mb-2">⚠️ Errores en importación:</p>
              <ul className="text-sm text-yellow-700 space-y-1 max-h-32 overflow-y-auto">
                {importResult.errors.map((err, i) => (
                  <li key={i}>• {err}</li>
                ))}
              </ul>
            </div>
          )}

          {/* Step 1: File Upload */}
          {!csvHeaders.length && !importResult ? (
            <div>
              <div className="border-2 border-dashed border-finly-dropzoneBorder bg-finly-dropzone rounded-xl p-12 text-center">
                <div className="text-6xl mb-4">💳</div>
                <h3 className="text-lg font-semibold text-finly-text mb-2">
                  Arrastra tu resumen de tarjeta CSV
                </h3>
                <p className="text-finly-textSecondary mb-4">
                  o haz clic para seleccionar un archivo
                </p>
                <input
                  type="file"
                  accept=".csv,.txt"
                  onChange={handleFile}
                  className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-finly-primary file:text-white hover:file:bg-indigo-700 file:cursor-pointer cursor-pointer"
                />
              </div>

              <div className="mt-6 bg-gray-50 rounded-lg p-4">
                <h4 className="font-semibold text-finly-text mb-2">📌 Formato esperado:</h4>
                <ul className="text-sm text-finly-textSecondary space-y-1">
                  <li>• Columnas requeridas: <strong>Fecha, Descripción, Importe</strong></li>
                  <li>• Columna opcional: <strong>Detalle</strong> (info de cuotas, ej: "2-12 (TNA 84,00)")</li>
                  <li>• Fecha: DD/MM/YYYY, DD.MM.YY, DD.MM.YYYY, DD-MM-YYYY o YYYY-MM-DD</li>
                  <li>• Importe: 10000.00, 10.000,00, o 10000/00</li>
                  <li>• Las columnas se mapean manualmente después de cargar</li>
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
          ) : importResult ? (
            /* Step 4: Import Complete */
            <div className="text-center py-8">
              <div className="text-6xl mb-4">✅</div>
              <h3 className="text-xl font-bold text-gray-800 mb-2">Importación Completada</h3>
              <p className="text-gray-600 mb-6">
                Se importaron {importResult.added} de {importResult.total} gastos
              </p>
              <div className="flex gap-4 justify-center">
                <button
                  onClick={() => { resetImport(); }}
                  className="px-6 py-3 bg-finly-primary text-white rounded-lg font-medium hover:bg-indigo-700 transition"
                >
                  Importar Más
                </button>
                <button
                  onClick={onClose}
                  className="px-6 py-3 bg-gray-200 text-gray-700 rounded-lg font-medium hover:bg-gray-300 transition"
                >
                  Cerrar
                </button>
              </div>
            </div>
          ) : (
            /* Step 2: Column Mapping + Step 3: Preview */
            <div className="space-y-6">
              {/* Column Mapping */}
              <div className="bg-gray-50 rounded-lg p-4">
                <h3 className="font-bold text-finly-text mb-4">📋 Mapear Columnas del CSV</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {[...requiredFields, ...optionalFields].map((field) => (
                    <div key={field}>
                      <label className="block text-sm font-medium text-finly-text mb-2">
                        {fieldLabels[field]}
                        {requiredFields.includes(field) && <span className="text-red-500 ml-1">*</span>}
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

              {/* Process Button */}
              <div className="flex space-x-4">
                <button
                  onClick={processImport}
                  disabled={!mapping.fecha || !mapping.descripcion || !mapping.importe}
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

              {/* Preview Table */}
              {previewData.length > 0 && (
                <div className="bg-gray-50 rounded-lg p-4">
                  <h3 className="font-bold text-finly-text mb-4">
                    👁️ Vista Previa ({previewData.length} de {formattedPurchases.length})
                  </h3>
                  <div className="overflow-x-auto">
                    <table className="w-full text-sm">
                      <thead className="bg-gray-200">
                        <tr>
                          <th className="px-3 py-2 text-left">Fecha</th>
                          <th className="px-3 py-2 text-left">Descripción</th>
                          <th className="px-3 py-2 text-left">Detalle</th>
                          <th className="px-3 py-2 text-right">Importe</th>
                        </tr>
                      </thead>
                      <tbody>
                        {previewData.map((item, idx) => (
                          <tr key={idx} className="border-b">
                            <td className="px-3 py-2 whitespace-nowrap">{item.purchase_date}</td>
                            <td className="px-3 py-2">{item.description}</td>
                            <td className="px-3 py-2 text-gray-500 text-xs">
                              {item.detalle_raw || '-'}
                            </td>
                            <td className="px-3 py-2 text-right font-mono">
                              ${item.amount.toLocaleString('es-AR', { minimumFractionDigits: 2 })}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                      <tfoot className="bg-gray-100 font-bold">
                        <tr>
                          <td className="px-3 py-2" colSpan={3}>Total ({formattedPurchases.length} gastos)</td>
                          <td className="px-3 py-2 text-right font-mono">
                            ${formattedPurchases.reduce((s, p) => s + p.amount, 0).toLocaleString('es-AR', { minimumFractionDigits: 2 })}
                          </td>
                        </tr>
                      </tfoot>
                    </table>
                  </div>

                  <div className="mt-4 flex space-x-4">
                    <button
                      onClick={confirmImport}
                      disabled={isImporting}
                      className="flex-1 bg-green-600 text-white py-3 rounded-lg font-semibold hover:bg-green-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {isImporting
                        ? 'Importando...'
                        : `✅ Confirmar Importación (${formattedPurchases.length} gastos)`}
                    </button>
                    <button
                      onClick={() => { setPreviewData([]); setFormattedPurchases([]); }}
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
    </div>
  );
}

export default CreditCardCSVImport;
