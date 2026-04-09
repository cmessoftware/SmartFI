import { useState, useEffect } from 'react';
import { useToast } from './ToastContainer';
import { adminAPI, transactionsAPI } from '../services/api';
import ConfirmDialog from './ConfirmDialog';

function AdminPanel() {
  const [activeTab, setActiveTab] = useState('users');
  const [users, setUsers] = useState([]);
  const [roles, setRoles] = useState([]);
  const [categories, setCategories] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editingItem, setEditingItem] = useState(null);
  const [formData, setFormData] = useState({ username: '', email: '', first_name: '', last_name: '', password: '', role_ids: [] });
  const [showAdminPassword, setShowAdminPassword] = useState(false);
  const [newCategory, setNewCategory] = useState('');
  const [exchangeRate, setExchangeRate] = useState('');
  const [exchangeRateLoading, setExchangeRateLoading] = useState(false);
  const [confirmDialog, setConfirmDialog] = useState({ isOpen: false, onConfirm: null, title: '', message: '' });
  const toast = useToast();

  useEffect(() => {
    if (activeTab === 'users') {
      loadUsers();
      loadRoles();
    }
    if (activeTab === 'settings') {
      loadExchangeRate();
    }
    if (activeTab === 'categories') {
      loadCategories();
    }
  }, [activeTab]);

  const loadUsers = async () => {
    try {
      const response = await adminAPI.getUsers();
      setUsers(response.data || []);
    } catch (error) {
      console.error('Error loading users:', error);
      toast.error('Error al cargar usuarios');
    }
  };

  const loadRoles = async () => {
    try {
      const response = await adminAPI.getRoles();
      setRoles(response.data || []);
    } catch (error) {
      console.error('Error loading roles:', error);
    }
  };

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
    setEditingItem(null);
    setFormData({ username: '', email: '', first_name: '', last_name: '', password: '', role_ids: [] });
    setShowModal(true);
  };

  const handleEditUser = (user) => {
    setEditingItem(user);
    setFormData({
      username: user.username,
      email: user.email || '',
      first_name: user.first_name || '',
      last_name: user.last_name || '',
      password: '',
      role_ids: (user.roles || []).map(r => r.id),
    });
    setShowModal(true);
  };

  const handleDeleteUser = (user) => {
    if (user.username === 'admin') {
      toast.warning('No se puede desactivar el usuario administrador');
      return;
    }
    setConfirmDialog({
      isOpen: true,
      title: 'Desactivar Usuario',
      message: `¿Estás seguro de desactivar al usuario ${user.username}?`,
      onConfirm: async () => {
        try {
          await adminAPI.deactivateUser(user.id);
          toast.success('Usuario desactivado correctamente');
          loadUsers();
        } catch (error) {
          toast.error(error.response?.data?.detail || 'Error al desactivar usuario');
        }
      }
    });
  };

  const handleUnlockUser = async (user) => {
    try {
      await adminAPI.unlockUser(user.id);
      toast.success('Usuario desbloqueado correctamente');
      loadUsers();
    } catch (error) {
      toast.error(error.response?.data?.detail || 'Error al desbloquear usuario');
    }
  };

  const handleSaveUser = async (e) => {
    e.preventDefault();
    try {
      if (editingItem) {
        await adminAPI.updateUser(editingItem.id, {
          email: formData.email,
          first_name: formData.first_name,
          last_name: formData.last_name,
          role_ids: formData.role_ids,
        });
        toast.success('Usuario actualizado correctamente');
      } else {
        await adminAPI.createUser({
          username: formData.username,
          email: formData.email,
          password: formData.password,
          first_name: formData.first_name,
          last_name: formData.last_name,
          role_ids: formData.role_ids,
        });
        toast.success('Usuario creado correctamente');
      }
      setShowModal(false);
      loadUsers();
    } catch (error) {
      toast.error(error.response?.data?.detail || 'Error al guardar usuario');
    }
  };

  const handleAddCategory = async (e) => {
    e.preventDefault();
    const catName = newCategory.trim();
    if (!catName) return;
    if (categories.some(c => (c.name || c) === catName)) {
      toast.warning('La categoría ya existe');
      return;
    }
    try {
      const response = await transactionsAPI.createCategory(catName);
      setCategories([...categories, response.data].sort((a, b) => (a.name || a).localeCompare(b.name || b)));
      setNewCategory('');
      toast.success('Categoría creada correctamente');
    } catch (error) {
      const detail = error.response?.data?.detail || 'Error al crear la categoría';
      toast.error(detail);
    }
  };

  const handleDeleteCategory = async (category) => {
    const catName = category.name || category;
    setConfirmDialog({
      isOpen: true,
      title: 'Eliminar Categoría',
      message: `¿Estás seguro de eliminar la categoría "${catName}"?`,
      onConfirm: async () => {
        try {
          await transactionsAPI.deleteCategory(category.id);
          setCategories(categories.filter(c => (c.id || c) !== (category.id || category)));
          toast.success('Categoría eliminada correctamente');
        } catch (error) {
          const detail = error.response?.data?.detail || 'Error al eliminar la categoría';
          toast.error(detail);
        }
      }
    });
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
                      <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Email</th>
                      <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Nombre</th>
                      <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Roles</th>
                      <th className="text-left py-3 px-4 text-sm font-semibold text-finly-text">Estado</th>
                      <th className="text-right py-3 px-4 text-sm font-semibold text-finly-text">Acciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    {users.map(user => (
                      <tr key={user.id} className="border-b border-gray-100 hover:bg-gray-50">
                        <td className="py-3 px-4 text-sm font-medium text-finly-text">{user.username}</td>
                        <td className="py-3 px-4 text-sm text-finly-text">{user.email}</td>
                        <td className="py-3 px-4 text-sm text-finly-text">{[user.first_name, user.last_name].filter(Boolean).join(' ')}</td>
                        <td className="py-3 px-4">
                          <div className="flex flex-wrap gap-1">
                            {(user.roles || []).map(r => (
                              <span key={r.id} className={`inline-block px-2 py-0.5 rounded-full text-xs font-semibold ${
                                r.name === 'ADMIN' ? 'bg-purple-100 text-purple-700' :
                                r.name === 'WRITER' ? 'bg-blue-100 text-blue-700' :
                                'bg-gray-100 text-gray-700'
                              }`}>
                                {r.name}
                              </span>
                            ))}
                          </div>
                        </td>
                        <td className="py-3 px-4">
                          {user.is_locked ? (
                            <span className="inline-block px-2 py-0.5 rounded-full text-xs font-semibold bg-red-100 text-red-700">Bloqueado</span>
                          ) : user.is_active ? (
                            <span className="inline-block px-2 py-0.5 rounded-full text-xs font-semibold bg-green-100 text-green-700">Activo</span>
                          ) : (
                            <span className="inline-block px-2 py-0.5 rounded-full text-xs font-semibold bg-gray-100 text-gray-700">Inactivo</span>
                          )}
                        </td>
                        <td className="py-3 px-4 text-right">
                          <button
                            onClick={() => handleEditUser(user)}
                            className="text-blue-600 hover:text-blue-800 mx-1"
                            title="Editar"
                          >
                            ✏️
                          </button>
                          {user.is_locked && (
                            <button
                              onClick={() => handleUnlockUser(user)}
                              className="text-yellow-600 hover:text-yellow-800 mx-1"
                              title="Desbloquear"
                            >
                              🔓
                            </button>
                          )}
                          {user.username !== 'admin' && (
                            <button
                              onClick={() => handleDeleteUser(user)}
                              className="text-red-600 hover:text-red-800 mx-1"
                              title="Desactivar"
                            >
                              🚫
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
                  Email *
                </label>
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                  required
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-finly-text mb-2">Nombre</label>
                  <input
                    type="text"
                    value={formData.first_name}
                    onChange={(e) => setFormData({ ...formData, first_name: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-finly-text mb-2">Apellido</label>
                  <input
                    type="text"
                    value={formData.last_name}
                    onChange={(e) => setFormData({ ...formData, last_name: e.target.value })}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-finly-text mb-2">
                  Roles
                </label>
                <div className="space-y-2">
                  {roles.map(role => (
                    <label key={role.id} className="flex items-center space-x-2">
                      <input
                        type="checkbox"
                        checked={formData.role_ids.includes(role.id)}
                        onChange={(e) => {
                          const newIds = e.target.checked
                            ? [...formData.role_ids, role.id]
                            : formData.role_ids.filter(id => id !== role.id);
                          setFormData({ ...formData, role_ids: newIds });
                        }}
                        className="rounded border-gray-300 text-finly-primary focus:ring-finly-primary"
                      />
                      <span className="text-sm text-finly-text">{role.name} {role.description ? `— ${role.description}` : ''}</span>
                    </label>
                  ))}
                </div>
              </div>
              {!editingItem && (
                <div>
                  <label className="block text-sm font-medium text-finly-text mb-2">
                    Contraseña *
                  </label>
                  <div className="relative">
                    <input
                      type={showAdminPassword ? 'text' : 'password'}
                      value={formData.password}
                      onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                      className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-finly-primary pr-10"
                      required={!editingItem}
                      minLength={8}
                    />
                    <button
                      type="button"
                      onClick={() => setShowAdminPassword(!showAdminPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 focus:outline-none"
                      tabIndex={-1}
                    >
                      {showAdminPassword ? (
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                          <path fillRule="evenodd" d="M3.707 2.293a1 1 0 00-1.414 1.414l14 14a1 1 0 001.414-1.414l-1.473-1.473A10.014 10.014 0 0019.542 10C18.268 5.943 14.478 3 10 3a9.958 9.958 0 00-4.512 1.074l-1.78-1.781zm4.261 4.26l1.514 1.515a2.003 2.003 0 012.45 2.45l1.514 1.514a4 4 0 00-5.478-5.478z" clipRule="evenodd" />
                          <path d="M12.454 16.697L9.75 13.992a4 4 0 01-3.742-3.741L2.335 6.578A9.98 9.98 0 00.458 10c1.274 4.057 5.065 7 9.542 7 .847 0 1.669-.105 2.454-.303z" />
                        </svg>
                      ) : (
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                          <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
                          <path fillRule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clipRule="evenodd" />
                        </svg>
                      )}
                    </button>
                  </div>
                  <p className="text-xs text-gray-500 mt-1">Mínimo 8 caracteres, 1 mayúscula, 1 número, 1 especial</p>
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
