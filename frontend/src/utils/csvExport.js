const escapeCsvValue = (value) => {
  if (value === null || value === undefined) return '';

  const stringValue = String(value);
  const needsQuotes = /[",\n\r]/.test(stringValue);
  const escaped = stringValue.replace(/"/g, '""');

  return needsQuotes ? `"${escaped}"` : escaped;
};

export const exportToCsv = ({ filename, headers, rows }) => {
  if (!headers || headers.length === 0) return false;
  if (!rows || rows.length === 0) return false;

  const headerRow = headers.map(escapeCsvValue).join(',');
  const dataRows = rows.map((row) =>
    headers.map((header) => escapeCsvValue(row[header])).join(',')
  );

  const csvContent = [headerRow, ...dataRows].join('\n');
  const BOM = '\uFEFF';
  const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);

  const link = document.createElement('a');
  link.href = url;
  link.setAttribute('download', filename);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);

  URL.revokeObjectURL(url);
  return true;
};
