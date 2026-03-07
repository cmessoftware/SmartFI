import { useState } from 'react';

function AdminPanel() {
  const [activeTab, setActiveTab] = useState('users');
  const [users, setUsers] = useState([
    { username: 'admin', full_name: 'Administrador', role: 'admin' },
    { username: 'writer', full_name: 'Editor', role: 'writer' },
    { username: 'reader', full_name: 'Lector', role: 'reader' }
  ]);
  const [categories, setCategories] = useState([
    'Ahorro', 'Comida', 'Cuidado Personal', 'Tarjeta VISA',
    'Educación', 'Alquiler', 'Hogar', 'Impuestos',
    'Ingresos', 'Ocio', 'Préstamos', 'Ropa',
    'Salud', 'Seguros', 'Servicios', 'Trámites', 'Transporte'
  ]);
  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState('user');
  const [editingItem, setEditingItem] = useState(null);
  const [formData, setFormData] = useState({ username: '', full_name: '', role: 'reader', password: '' });
  const [newCategory, setNewCategory] = useState('');

  const roles = ['admin', 'writer', 'reader'];

  const handleAddUser = () => {
    setModalType('user');
    setEditingItem(null);
    setFormData({ username: '', full_name: '', role: 'reader', password: '' });
    setShowModal(true);
  };

  const handleEditUser = (user) => {
    setModalType('user');
    setEditingItem(user);
    setFormData({ ...user, password: '' });
    setShowModal(true);
  };

  const handleDeleteUser = (username) => {
    if (username === 'admin') {
      alert('No se puede eliminar el usuario administrador');
      return;
    }
    if (confirm(`¿Estás seguro de eliminar al usuario ${username}?`)) {
      setUsers(users.filter(u => u.username !== username));
    }
  };

  const handleSaveUser = (e) => {
    e.preventDefault();
    if (editingItem) {
      setUsers(users.map(u => u.username === editingItem.username ? { ...formData, password: undefined } : u));
    } else {
      if (users.find(u => u.username === formData.username)) {
        alert('El nombre de usuario ya existe');
        return;
      }
      setUsers([...users, { ...formData, password: undefined }]);
    }
    setShowModal(false);
  };

  const handleAddCategory = (e) => {
    e.preventDefault();
    if (newCategory && !categories.includes(newCategory)) {
      setCategories([...categories, newCategory].sort());
      setNewCategory('');
    }
  };

  const handleDeleteCategory = (category) => {
    if (confirm(`¿Estás seguro de eliminar la categoría "${category}"?`)) {
      setCategories(categories.filter(c => c !== category));
    }
  };

  return (
    <div className="max-w-6xl mx-auto">
      <div className="bg-white rounded-xl shadow-md">
        {/* Tabs */}
        <div className="border-b border-gray-200">
          <div className="flex space-x-8 px-8">
            <button
              onClick={() => setActiveTab('users')}
              className={`py-4 px-2 border-b-2 font-semibold transition ${
                activeTab === 'users'
                  ? 'border-finly-primary text-finly-primary'
                  : 'border-transparent text-finly-textSecondary hover:text-finly-text'
              }`}
            >
              👥 Usuarios y Roles
            </button>
            <button
              onClick={() => setActiveTab('categories')}
              className={`py-4 px-2 border-b-2 font-semibold transition ${
                activeTab === 'categories'
                  ? 'border-finly-primary text-finly-primary'
                  : 'border-transparent text-finly-textSecondary hover:text-finly-text'
              }`}
            >
              📊 Categorías
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-8">
          {activeTab === 'users' && (
            <div>
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-2xl font-bold text-finly-text">
                  Gestión de Usuarios
                </h2>
                <button
                  onClick={handleAddUser}
                  className="bg-finly-primary text-white px-4 py-2 rounded-lg font-semibold hover:bg-indigo-700 transition"
                >
                  + Nuevo Usuario
                </button>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="border-b border-gray-200">
                      <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Usuario</th>
                      <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Nombre Completo</th>
                      <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Rol</th>
                      <th className="text-right py-3 px-4 text-sm font-semibold text-finly-text">Acciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    {users.map(user => (
                      <tr key={user.username} className="border-b border-gray-100 hover:bg-gray-50">
                        <td className="py-3 px-4 text-sm font-medium text-finly-text">{user.username}</td>
                        <td className="py-3 px-4 text-sm text-finly-text">{user.full_name}</td>
                        <td className="py-3 px-4">
                          <span className={`inline-block px-3 py-1 rounded-full text-xs font-semibold ${
                            user.role === 'admin' ? 'bg-purple-100 text-purple-700' :
                            user.role === 'writer' ? 'bg-blue-100 text-blue-700' :
                            'bg-gray-100 text-gray-700'
                          }`}>
                            {user.role}
                          </span>
                        </td>
                        <td className="py-3 px-4 text-right">
                          <button
                            onClick={() => handleEditUser(user)}
                            className="text-blue-600 hover:text-blue-800 mx-2"
                          >
                            ✏️
                          </button>
                          {user.username !== 'admin' && (
                            <button
                              onClick={() => handleDeleteUser(user.username)}
                              className="text-red-600 hover:text-red-800 mx-2"
                            >
                              🗑️
                            </button>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {activeTab === 'categories' && (
            <div>
              <h2 className="text-2xl font-bold text-finly-text mb-6">
                Gestión de Categorías
              </h2>

              <form onSubmit={handleAddCategory} className="mb-6">
                <div className="flex space-x-4">
                  <input
                    type="text"
                    value={newCategory}
                    onChange={(e) => setNewCategory(e.target.value)}
                    placeholder="Nueva categoría"
                    className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                  />
                  <button
                    type="submit"
                    className="bg-finly-primary text-white px-6 py-2 rounded-lg font-semibold hover:bg-indigo-700 transition"
                  >
                    + Agregar
                  </button>
                </div>
              </form>

              <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                {categories.map(category => (
                  <div
                    key={category}
                    className="flex items-center justify-between bg-gray-50 rounded-lg p-3 border border-gray-200"
                  >
                    <span className="text-sm font-medium text-finly-text">{category}</span>
                    <button
                      onClick={() => handleDeleteCategory(category)}
                      className="text-red-600 hover:text-red-800"
                    >
                      ✕
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-xl shadow-2xl p-8 max-w-md w-full">
            <h3 className="text-xl font-bold text-finly-text mb-6">
              {editingItem ? 'Editar Usuario' : 'Nuevo Usuario'}
            </h3>
            <form onSubmit={handleSaveUser} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-finly-text mb-2">
                  Usuario *
                </label>
                <input
                  type="text"
                  value={formData.username}
                  onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                  disabled={!!editingItem}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary disabled:bg-gray-100"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-finly-text mb-2">
                  Nombre Completo *
                </label>
                <input
                  type="text"
                  value={formData.full_name}
                  onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-finly-text mb-2">
                  Rol *
                </label>
                <select
                  value={formData.role}
                  onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                  required
                >
                  {roles.map(role => (
                    <option key={role} value={role}>{role}</option>
                  ))}
                </select>
              </div>
              {!editingItem && (
                <div>
                  <label className="block text-sm font-medium text-finly-text mb-2">
                    Contraseña *
                  </label>
                  <input
                    type="password"
                    value={formData.password}
                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                    required={!editingItem}
                  />
                </div>
              )}
              <div className="flex space-x-4 pt-4">
                <button
                  type="submit"
                  className="flex-1 bg-finly-primary text-white py-2 rounded-lg font-semibold hover:bg-indigo-700 transition"
                >
                  Guardar
                </button>
                <button
                  type="button"
                  onClick={() => setShowModal(false)}
                  className="flex-1 bg-gray-200 text-gray-700 py-2 rounded-lg font-semibold hover:bg-gray-300 transition"
                >
                  Cancelar
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

export default AdminPanel;
