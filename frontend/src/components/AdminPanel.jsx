import { useState, useEffect } from 'react';
import { useToast } from './ToastContainer';
import { adminAPI, transactionsAPI } from '../services/api';
import ConfirmDialog from './ConfirmDialog';

function AdminPanel() {
  const [activeTab, setActiveTab] = useState('users');
  const [users, setUsers] = useState([
    { username: 'admin', full_name: 'Administrador', role: 'admin' },
    { username: 'writer', full_name: 'Editor', role: 'writer' },
    { username: 'reader', full_name: 'Lector', role: 'reader' }
  ]);
  const [categories, setCategories] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [modalType, setModalType] = useState('user');
  const [editingItem, setEditingItem] = useState(null);
  const [formData, setFormData] = useState({ username: '', full_name: '', role: 'reader', password: '' });
  const [newCategory, setNewCategory] = useState('');
  const [exchangeRate, setExchangeRate] = useState('');
  const [exchangeRateLoading, setExchangeRateLoading] = useState(false);
  const [confirmDialog, setConfirmDialog] = useState({ isOpen: false, onConfirm: null, title: '', message: '' });
  const toast = useToast();

  const roles = ['admin', 'writer', 'reader'];

  useEffect(() => {
    if (activeTab === 'settings') {
      loadExchangeRate();
    }
    if (activeTab === 'categories') {
      loadCategories();
    }
  }, [activeTab]);

  const loadCategories = async () => {
    try {
      const response = await transactionsAPI.getCategories();
      setCategories(response.data || []);
    } catch (error) {
      console.error('Error loading categories:', error);
    }
  };

  const loadExchangeRate = async () => {
    try {
      const response = await adminAPI.getSetting('dollar_exchange_rate');
      setExchangeRate(response.data.value || '');
    } catch (error) {
      console.error('Error loading exchange rate:', error);
    }
  };

  const handleSaveExchangeRate = async (e) => {
    e.preventDefault();
    const rate = parseFloat(exchangeRate);
    if (!rate || rate <= 0) {
      toast.warning('Ingrese una cotización válida');
      return;
    }
    setExchangeRateLoading(true);
    try {
      await adminAPI.updateSetting('dollar_exchange_rate', rate);
      toast.success('Cotización del dólar actualizada');
    } catch (error) {
      toast.error('Error al actualizar la cotización');
      console.error('Error saving exchange rate:', error);
    } finally {
      setExchangeRateLoading(false);
    }
  };

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
      toast.warning('No se puede eliminar el usuario administrador');
      return;
    }
    setConfirmDialog({
      isOpen: true,
      title: 'Eliminar Usuario',
      message: `¿Estás seguro de eliminar al usuario ${username}?`,
      onConfirm: () => {
        setUsers(users.filter(u => u.username !== username));
        toast.success('Usuario eliminado correctamente');
      }
    });
  };

  const handleSaveUser = (e) => {
    e.preventDefault();
    if (editingItem) {
      setUsers(users.map(u => u.username === editingItem.username ? { ...formData, password: undefined } : u));
      toast.success('Usuario actualizado correctamente');
    } else {
      if (users.find(u => u.username === formData.username)) {
        toast.error('El nombre de usuario ya existe');
        return;
      }
      setUsers([...users, { ...formData, password: undefined }]);
      toast.success('Usuario creado correctamente');
    }
    setShowModal(false);
  };

  const handleAddCategory = (e) => {
    e.preventDefault();
    const catName = newCategory.trim();
    if (catName && !categories.some(c => (c.name || c) === catName)) {
      setCategories([...categories, { id: Date.now(), name: catName }].sort((a, b) => (a.name || a).localeCompare(b.name || b)));
      setNewCategory('');
    }
  };

  const handleDeleteCategory = (category) => {
    const catName = category.name || category;
    if (confirm(`¿Estás seguro de eliminar la categoría "${catName}"?`)) {
      setCategories(categories.filter(c => (c.name || c) !== catName));
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
            <button
              onClick={() => setActiveTab('settings')}
              className={`py-4 px-2 border-b-2 font-semibold transition ${
                activeTab === 'settings'
                  ? 'border-finly-primary text-finly-primary'
                  : 'border-transparent text-finly-textSecondary hover:text-finly-text'
              }`}
            >
              💲 Cotización
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
                    key={category.id || category}
                    className="flex items-center justify-between bg-gray-50 rounded-lg p-3 border border-gray-200"
                  >
                    <span className="text-sm font-medium text-finly-text">{category.name || category}</span>
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

          {activeTab === 'settings' && (
            <div>
              <h2 className="text-2xl font-bold text-finly-text mb-6">
                Cotización del Dólar
              </h2>
              <form onSubmit={handleSaveExchangeRate} className="max-w-md">
                <div className="mb-4">
                  <label className="block text-sm font-medium text-finly-text mb-2">
                    Cotización USD → ARS
                  </label>
                  <div className="flex items-center space-x-3">
                    <span className="text-lg font-semibold text-gray-500">1 USD =</span>
                    <input
                      type="number"
                      value={exchangeRate}
                      onChange={(e) => setExchangeRate(e.target.value)}
                      step="0.01"
                      min="0.01"
                      className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary text-lg"
                      placeholder="1200.00"
                      required
                    />
                    <span className="text-lg font-semibold text-gray-500">ARS</span>
                  </div>
                  <p className="text-xs text-gray-500 mt-2">
                    Esta cotización se usa para convertir compras en dólares a pesos argentinos.
                  </p>
                </div>
                <button
                  type="submit"
                  disabled={exchangeRateLoading}
                  className="bg-finly-primary text-white px-6 py-2 rounded-lg font-semibold hover:bg-indigo-700 transition disabled:opacity-50"
                >
                  {exchangeRateLoading ? 'Guardando...' : 'Guardar Cotización'}
                </button>
              </form>
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

      <ConfirmDialog
        isOpen={confirmDialog.isOpen}
        onClose={() => setConfirmDialog({ ...confirmDialog, isOpen: false })}
        onConfirm={confirmDialog.onConfirm}
        title={confirmDialog.title}
        message={confirmDialog.message}
        type="danger"
      />
    </div>
  );
}

export default AdminPanel;
