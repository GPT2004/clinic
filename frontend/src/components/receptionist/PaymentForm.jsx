// src/components/receptionist/PaymentForm.jsx
import React, { useState } from 'react';
import { CreditCard, Wallet, QrCode, CheckCircle } from 'lucide-react';

const PaymentForm = ({ amount, onPay }) => {
  const [method, setMethod] = useState('CASH');
  const [paidAmount, setPaidAmount] = useState(amount);

  const methods = [
    { id: 'CASH', label: 'Tiền mặt', icon: Wallet },
    { id: 'CARD', label: 'Thẻ', icon: CreditCard },
    { id: 'QR', label: 'QR Code', icon: QrCode },
  ];

  return (
    <div className="bg-white rounded-lg shadow-lg p-6">
      <h3 className="text-xl font-bold text-gray-900 mb-4">Thanh toán</h3>
      <div className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Số tiền cần thanh toán</label>
          <p className="text-2xl font-bold text-green-600">{amount.toLocaleString('vi-VN')} ₫</p>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Phương thức</label>
          <div className="grid grid-cols-3 gap-3">
            {methods.map(m => (
              <button
                key={m.id}
                onClick={() => setMethod(m.id)}
                className={`p-4 border rounded-lg flex flex-col items-center gap-2 transition ${
                  method === m.id ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-gray-400'
                }`}
              >
                <m.icon className="w-6 h-6" />
                <span className="text-sm font-medium">{m.label}</span>
              </button>
            ))}
          </div>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Số tiền nhận</label>
          <input
            type="number"
            className="w-full px-3 py-2 border rounded-lg"
            value={paidAmount}
            onChange={(e) => setPaidAmount(+e.target.value)}
          />
          <p className="text-sm text-gray-600 mt-1">
            Tiền thừa: <span className="font-medium text-green-600">
              {(paidAmount - amount).toLocaleString('vi-VN')} ₫
            </span>
          </p>
        </div>
        <button
          onClick={() => onPay({ method, paidAmount, change: paidAmount - amount })}
          className="w-full py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 flex items-center justify-center gap-2"
        >
          <CheckCircle className="w-5 h-5" />
          Xác nhận thanh toán
        </button>
      </div>
    </div>
  );
};

export default PaymentForm;