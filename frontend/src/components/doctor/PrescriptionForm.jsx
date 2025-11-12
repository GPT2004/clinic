// src/components/doctor/PrescriptionForm.jsx
import React, { useState } from 'react';
import { Pill, Plus, X } from 'lucide-react';

const PrescriptionForm = ({ patient, onSave, onCancel }) => {
  const [medicines, setMedicines] = useState([
    { id: 1, name: '', dosage: '', quantity: '', duration: '', instructions: '' }
  ]);
  const [notes, setNotes] = useState('');

  const addMedicine = () => {
    setMedicines([...medicines, {
      id: Date.now(),
      name: '', dosage: '', quantity: '', duration: '', instructions: ''
    }]);
  };

  const removeMedicine = (id) => {
    setMedicines(medicines.filter(m => m.id !== id));
  };

  const updateMedicine = (id, field, value) => {
    setMedicines(medicines.map(m => m.id === id ? { ...m, [field]: value } : m));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onSave({ medicines, notes });
  };

  return (
    <div className="bg-white rounded-lg shadow-lg">
      <div className="p-6 border-b">
        <h3 className="text-xl font-bold text-gray-900">Kê Đơn Thuốc</h3>
        <p className="text-sm text-gray-600 mt-1">Bệnh nhân: {patient?.name}</p>
      </div>
      <form onSubmit={handleSubmit} className="p-6 space-y-6">
        <div className="space-y-4">
          {medicines.map((medicine, index) => (
            <div key={medicine.id} className="border border-gray-200 rounded-lg p-4 bg-gray-50">
              <div className="flex justify-between items-center mb-3">
                <h4 className="font-medium text-gray-900">Thuốc {index + 1}</h4>
                {medicines.length > 1 && (
                  <button type="button" onClick={() => removeMedicine(medicine.id)} className="text-red-600 hover:text-red-700">
                    <X className="w-5 h-5" />
                  </button>
                )}
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Tên thuốc *</label>
                  <input
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                    placeholder="VD: Amoxicillin 500mg"
                    value={medicine.name}
                    onChange={(e) => updateMedicine(medicine.id, 'name', e.target.value)}
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Liều lượng *</label>
                  <input
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                    placeholder="VD: 1 viên/lần"
                    value={medicine.dosage}
                    onChange={(e) => updateMedicine(medicine.id, 'dosage', e.target.value)}
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Số lượng *</label>
                  <input
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                    placeholder="VD: 2 hộp (20 viên)"
                    value={medicine.quantity}
                    onChange={(e) => updateMedicine(medicine.id, 'quantity', e.target.value)}
                    required
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Thời gian dùng</label>
                  <input
                    type="text"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                    placeholder="VD: 7 ngày"
                    value={medicine.duration}
                    onChange={(e) => updateMedicine(medicine.id, 'duration', e.target.value)}
                  />
                </div>
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-700 mb-1">Hướng dẫn sử dụng</label>
                  <textarea
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg"
                    rows="2"
                    placeholder="VD: Uống sau bữa ăn, ngày 3 lần"
                    value={medicine.instructions}
                    onChange={(e) => updateMedicine(medicine.id, 'instructions', e.target.value)}
                  />
                </div>
              </div>
            </div>
          ))}
        </div>
        <button
          type="button"
          onClick={addMedicine}
          className="w-full px-4 py-2 border-2 border-dashed border-gray-300 text-gray-600 rounded-lg hover:border-blue-500 hover:text-blue-600 flex items-center justify-center gap-2"
        >
          <Plus className="w-4 h-4" />
          Thêm thuốc
        </button>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Ghi chú</label>
          <textarea
            className="w-full px-3 py-2 border border-gray-300 rounded-lg"
            rows="3"
            placeholder="Lời dặn thêm..."
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
          />
        </div>
        <div className="flex justify-end gap-3 pt-4 border-t">
          <button type="button" onClick={onCancel} className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50">
            Hủy
          </button>
          <button type="submit" className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 flex items-center gap-2">
            <Pill className="w-4 h-4" />
            Lưu đơn thuốc
          </button>
        </div>
      </form>
    </div>
  );
};

export default PrescriptionForm;