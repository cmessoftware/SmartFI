export default function MonthStatusBadge({ status }) {
  const config = {
    OPEN: { label: 'Abierto', className: 'bg-green-100 text-green-700 border-green-300' },
    CLOSED: { label: 'Cerrado', className: 'bg-red-100 text-red-700 border-red-300' },
    REOPENED: { label: 'Reabierto', className: 'bg-yellow-100 text-yellow-700 border-yellow-300' },
  };
  const { label, className } = config[status] || config.OPEN;
  return (
    <span className={`px-2 py-0.5 text-xs font-medium rounded border ${className}`}>
      {label}
    </span>
  );
}
