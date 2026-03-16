import { useState, useEffect } from 'react';

function Toast({ message, type = 'success', onClose, duration = 5000 }) {
  const [isVisible, setIsVisible] = useState(true);
  const [isExiting, setIsExiting] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      handleClose();
    }, duration);

    return () => clearTimeout(timer);
  }, [duration]);

  const handleClose = () => {
    setIsExiting(true);
    setTimeout(() => {
      setIsVisible(false);
      onClose?.();
    }, 300); // Match animation duration
  };

  if (!isVisible) return null;

  const styles = {
    success: {
      bg: 'bg-green-50 border-green-400',
      text: 'text-green-800',
      icon: '✅',
      iconBg: 'bg-green-100'
    },
    error: {
      bg: 'bg-red-50 border-red-400',
      text: 'text-red-800',
      icon: '❌',
      iconBg: 'bg-red-100'
    },
    warning: {
      bg: 'bg-yellow-50 border-yellow-400',
      text: 'text-yellow-800',
      icon: '⚠️',
      iconBg: 'bg-yellow-100'
    },
    info: {
      bg: 'bg-blue-50 border-blue-400',
      text: 'text-blue-800',
      icon: 'ℹ️',
      iconBg: 'bg-blue-100'
    }
  };

  const style = styles[type] || styles.info;

  return (
    <div
      className={`flex items-start gap-3 max-w-md w-full p-4 rounded-lg border-l-4 shadow-lg ${style.bg} ${
        isExiting ? 'animate-slide-out' : 'animate-slide-in'
      }`}
      style={{
        animation: isExiting 
          ? 'slideOut 0.3s ease-in forwards' 
          : 'slideIn 0.3s ease-out'
      }}
    >
      <div className={`flex-shrink-0 w-8 h-8 rounded-full ${style.iconBg} flex items-center justify-center`}>
        <span className="text-lg">{style.icon}</span>
      </div>
      <div className="flex-1 min-w-0">
        <p className={`text-sm font-medium whitespace-pre-line ${style.text}`}>
          {message}
        </p>
      </div>
      <button
        onClick={handleClose}
        className={`flex-shrink-0 ml-2 ${style.text} hover:opacity-70 transition-opacity`}
        aria-label="Cerrar"
      >
        <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
          <path
            fillRule="evenodd"
            d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
            clipRule="evenodd"
          />
        </svg>
      </button>
    </div>
  );
}

export default Toast;
