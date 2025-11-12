import React, { useEffect, useState } from 'react';
import AdminLayout from '../../components/admin/AdminLayout';
import { getAllMedicines } from '../../services/medicineService';
import { ensureArray } from '../../utils/normalize';
import { Trash2, Edit2, Plus, Pill } from 'lucide-react';
import EditMedicineModal from '../../components/admin/EditMedicineModal';
import DeleteMedicineModal from '../../components/admin/DeleteMedicineModal';
import AddStockModal from '../../components/admin/AddStockModal';
import CreateMedicineModal from '../../components/admin/CreateMedicineModal';
import MedicineDetailModal from '../../components/admin/MedicineDetailModal';

export default function MedicinesPage() {
  const [meds, setMeds] = useState([]);
  const [name, setName] = useState(''); // search by name only
  const [formError, setFormError] = useState('');
  const [loading, setLoading] = useState(true);
  const [editingMedicine, setEditingMedicine] = useState(null);
  const [deletingMedicine, setDeletingMedicine] = useState(null);
  const [addingStockFor, setAddingStockFor] = useState(null);
  const [createModalOpen, setCreateModalOpen] = useState(false);
  const [detailMedicine, setDetailMedicine] = useState(null);

  useEffect(() => {
    loadMedicines();
  }, []);

  // loadMedicines accepts optional search params
  const loadMedicines = async (params = {}) => {
    try {
      setLoading(true);
      const r = await getAllMedicines(params);
      const arr = ensureArray(r);
      setMeds(arr);
    } catch (e) {
      // ignore
    } finally {
      setLoading(false);
    }
  };

  // search action - real-time search by name only
  const search = async (searchName) => {
    setFormError('');
    try {
      await loadMedicines({ search: searchName.trim() });
    } catch (e) {
      setFormError('Tìm thuốc thất bại');
    }
  };

  const handleNameChange = (e) => {
    const value = e.target.value;
    setName(value);
    // Real-time search as user types
    search(value);
  };

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <div className="flex items-center gap-2">
              <Pill className="text-orange-600" size={32} />
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Quản lý thuốc</h1>
                <p className="text-gray-600 mt-1">Quản lý kho thuốc và thông tin chi tiết</p>
              </div>
            </div>
          </div>
        </div>

        {/* Search Form - Tìm theo tên thuốc (real-time) */}
        <div className="bg-white rounded-lg border border-gray-200 p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Tìm thuốc theo tên</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-3 items-end">
            <input
              className="col-span-1 md:col-span-2 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-200 transition"
              value={name}
              onChange={handleNameChange}
              placeholder="Nhập tên thuốc (tìm kiếm tự động)..."
            />
            <div className="flex items-center gap-3 col-span-1 md:col-span-3">
              <button
                onClick={() => setCreateModalOpen(true)}
                className="flex-1 px-4 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-medium flex items-center gap-2 justify-center"
              >
                <Plus size={16} />
                Thêm thuốc
              </button>
            </div>
          </div>
          {formError && <div className="text-sm text-red-600 mt-2">{formError}</div>}
        </div>

        {/* Table */}
        <div className="bg-white rounded-lg border border-gray-200 overflow-hidden shadow-sm">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-gray-50 border-b border-gray-200">
                  <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700 w-12">#</th>
                  <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700">Tên thuốc</th>
                  <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700">Số lượng trong kho</th>
                  <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700">Trạng thái</th>
                  <th className="px-6 py-4 text-center text-sm font-semibold text-gray-700 w-24">Hành động</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan="5" className="px-6 py-12 text-center">
                      <div className="flex justify-center">
                        <div className="spinner"></div>
                      </div>
                    </td>
                  </tr>
                ) : meds.length === 0 ? (
                  <tr>
                    <td colSpan="5" className="px-6 py-12 text-center text-gray-500">
                      Chưa có thuốc nào trong hệ thống
                    </td>
                  </tr>
                ) : (
                  meds.map((m, i) => {
                    const stock = m.total_stock || 0;
                    const status = stock === 0 ? 'Hết hàng' : stock < 10 ? 'Sắp hết' : 'Có sẵn';
                    const statusColor = stock === 0 ? 'bg-red-100 text-red-800' : stock < 10 ? 'bg-yellow-100 text-yellow-800' : 'bg-green-100 text-green-800';

                    return (
                      <tr key={m.id || i} className="border-b border-gray-200 hover:bg-gray-50 transition cursor-pointer" onClick={() => setDetailMedicine(m)}>
                        <td className="px-6 py-4 text-sm text-gray-600">{i + 1}</td>
                        <td className="px-6 py-4 text-sm font-medium text-gray-900">{m.name}</td>
                        <td className="px-6 py-4 text-sm text-gray-600">
                          <span className="font-semibold">{stock}</span> {m.unit || 'cái'}
                        </td>
                        <td className="px-6 py-4">
                          <span className={`inline-block px-3 py-1 rounded-full text-xs font-semibold ${statusColor}`}>
                            {status}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-center" onClick={(e) => e.stopPropagation()}>
                          <div className="flex items-center justify-center gap-2">
                              <button
                                onClick={() => setEditingMedicine(m)}
                                className="p-2 text-blue-600 hover:bg-blue-100 rounded-lg transition"
                                title="Chỉnh sửa & nhập kho"
                              >
                              <Edit2 size={18} />
                            </button>
                              <button
                                onClick={() => setDeletingMedicine(m)}
                                className="p-2 text-red-600 hover:bg-red-100 rounded-lg transition"
                                title="Xóa"
                              >
                              <Trash2 size={18} />
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })
                )}
              </tbody>
            </table>
          </div>
        </div>

        {/* Footer Info */}
        {meds.length > 0 && (
          <div className="text-sm text-gray-600">
            Tổng số thuốc: <span className="font-semibold">{meds.length}</span> loại
          </div>
        )}
      </div>
      
        {/* Modals */}
        {editingMedicine && (
          <EditMedicineModal
            medicine={editingMedicine}
            onClose={() => setEditingMedicine(null)}
            onSuccess={() => { setEditingMedicine(null); loadMedicines(); }}
          />
        )}

        {deletingMedicine && (
          <DeleteMedicineModal
            medicine={deletingMedicine}
            onClose={() => setDeletingMedicine(null)}
            onSuccess={() => { setDeletingMedicine(null); loadMedicines(); }}
          />
        )}
        {addingStockFor && (
          <AddStockModal
            medicine={addingStockFor}
            onClose={() => setAddingStockFor(null)}
            onSuccess={() => { setAddingStockFor(null); loadMedicines(); }}
          />
        )}
        {createModalOpen && (
          <CreateMedicineModal
            onClose={() => setCreateModalOpen(false)}
            onSuccess={() => { setCreateModalOpen(false); loadMedicines(); }}
          />
        )}

        {detailMedicine && (
          <MedicineDetailModal
            medicine={detailMedicine}
            onClose={() => setDetailMedicine(null)}
          />
        )}
    </AdminLayout>
  );
}
