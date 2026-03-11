function Sidebar({ user, currentView, setCurrentView, onLogout }) {
  const menuItems = [
    { id: 'dashboard', label: 'Panel Principal', icon: '📊', roles: ['admin', 'writer', 'reader'] },
    { id: 'add', label: 'Cargar Gasto/Ingreso', icon: '➕', roles: ['admin', 'writer'] },
    { id: 'import', label: 'Importar CSV', icon: '📁', roles: ['admin', 'writer'] },
    { id: 'reports', label: 'Reportes', icon: '📈', roles: ['admin', 'writer', 'reader'] },
    { id: 'admin', label: 'Administración', icon: '⚙️', roles: ['admin'] },
  ];

  const visibleItems = menuItems.filter(item => item.roles.includes(user.role));

  return (
    <aside className="w-64 bg-white shadow-lg flex flex-col">
      <div className="p-6 border-b border-gray-200">
        <div className="flex items-center space-x-3">
          <img src="/logo.png" alt="Finly" className="w-12 h-12" />
          <div>
            <h1 className="text-xl font-bold text-finly-text">Finly</h1>
            <p className="text-xs text-finly-textSecondary">v1.0.0.1bd44</p>
          </div>
        </div>
      </div>

      <div className="p-4 border-b border-gray-200">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 bg-finly-primary rounded-full flex items-center justify-center text-white font-bold">
            {user.username.charAt(0).toUpperCase()}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-finly-text truncate">
              {user.full_name || user.username}
            </p>
            <p className="text-xs text-finly-textSecondary capitalize">
              {user.role}
            </p>
          </div>
        </div>
      </div>

      <nav className="flex-1 overflow-y-auto p-4">
        <ul className="space-y-2">
          {visibleItems.map(item => (
            <li key={item.id}>
              <button
                onClick={() => setCurrentView(item.id)}
                className={`w-full flex items-center space-x-3 px-4 py-3 rounded-lg transition ${
                  currentView === item.id
                    ? 'bg-finly-primary text-white font-semibold'
                    : 'text-finly-text hover:bg-finly-secondary'
                }`}
              >
                <span className="text-xl">{item.icon}</span>
                <span>{item.label}</span>
              </button>
            </li>
          ))}
        </ul>
      </nav>

      <div className="p-4 border-t border-gray-200">
        <button
          onClick={onLogout}
          className="w-full flex items-center justify-center space-x-2 px-4 py-3 bg-red-500 text-white rounded-lg hover:bg-red-600 transition font-semibold"
        >
          <span>🚪</span>
          <span>Cerrar Sesión</span>
        </button>
      </div>
    </aside>
  );
}

export default Sidebar;
