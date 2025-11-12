// frontend/src/components/patient/BookAppointmentForm.jsx
import React, { useState, useEffect } from 'react';
import { Calendar, Clock, User, FileText, Search } from 'lucide-react';
import Input from '../common/Input';
import Button from '../common/Button';
import Alert from '../common/Alert';

export default function BookAppointmentForm({ 
  onSubmit, 
  loading = false,
  doctors = [],
  onLoadDoctors 
}) {
  const [formData, setFormData] = useState({
    doctor_id: '',
    appointment_date: '',
    appointment_time: '',
    reason: '',
    notes: '',
  });
  const [errors, setErrors] = useState({});
  const [selectedDoctor, setSelectedDoctor] = useState(null);
  const [availableSlots, setAvailableSlots] = useState([]);
  const [specialtyFilter, setSpecialtyFilter] = useState('');
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    if (onLoadDoctors) {
      onLoadDoctors();
    }
  }, [onLoadDoctors]);

  // Generate time slots
  const generateTimeSlots = () => {
    const slots = [];
    const startHour = 7;
    const endHour = 20;
    
    for (let hour = startHour; hour < endHour; hour++) {
      for (let minute = 0; minute < 60; minute += 20) {
        const timeStr = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
        slots.push(timeStr);
      }
    }
    
    return slots;
  };

  useEffect(() => {
    setAvailableSlots(generateTimeSlots());
  }, []);

  const filteredDoctors = doctors.filter(doctor => {
    const matchesSearch = doctor.user?.full_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         doctor.specialty?.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesSpecialty = !specialtyFilter || doctor.specialty === specialtyFilter;
    return matchesSearch && matchesSpecialty;
  });

  const specialties = [...new Set(doctors.map(d => d.specialty).filter(Boolean))];

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

  const handleDoctorSelect = (doctor) => {
    setSelectedDoctor(doctor);
    handleChange('doctor_id', doctor.id);
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.doctor_id) {
      newErrors.doctor_id = 'Vui lòng chọn bác sĩ';
    }
    if (!formData.appointment_date) {
      newErrors.appointment_date = 'Vui lòng chọn ngày khám';
    }
    if (!formData.appointment_time) {
      newErrors.appointment_time = 'Vui lòng chọn giờ khám';
    }
    if (!formData.reason || formData.reason.trim().length < 10) {
      newErrors.reason = 'Vui lòng nhập lý do khám (tối thiểu 10 ký tự)';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    if (onSubmit) {
      await onSubmit(formData);
    }
  };

  const minDate = new Date().toISOString().split('T')[0];
  const maxDate = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Step 1: Select Doctor */}
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
          <User className="w-5 h-5 text-blue-600" />
          Bước 1: Chọn Bác sĩ
        </h3>

        {/* Search and Filter */}
        <div className="grid grid-cols-2 gap-4 mb-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              placeholder="Tìm kiếm bác sĩ, chuyên khoa..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          <select
            value={specialtyFilter}
            onChange={(e) => setSpecialtyFilter(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
          >
            <option value="">Tất cả chuyên khoa</option>
            {specialties.map(specialty => (
              <option key={specialty} value={specialty}>{specialty}</option>
            ))}
          </select>
        </div>

        {/* Doctor List */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 max-h-96 overflow-y-auto">
          {filteredDoctors.map(doctor => (
            <div
              key={doctor.id}
              onClick={() => handleDoctorSelect(doctor)}
              className={`p-4 border-2 rounded-lg cursor-pointer transition-all ${
                selectedDoctor?.id === doctor.id
                  ? 'border-blue-500 bg-blue-50'
                  : 'border-gray-200 hover:border-blue-300'
              }`}
            >
              <div className="flex items-start gap-3">
                <img
                  src={doctor.user?.avatar_url || '/avatar-placeholder.png'}
                  alt={doctor.user?.full_name}
                  className="w-12 h-12 rounded-full object-cover"
                />
                <div className="flex-1">
                  <h4 className="font-semibold text-gray-900">
                    BS. {doctor.user?.full_name}
                  </h4>
                  <p className="text-sm text-gray-600">{doctor.specialty}</p>
                  {doctor.years_of_experience && (
                    <p className="text-xs text-gray-500 mt-1">
                      {doctor.years_of_experience} năm kinh nghiệm
                    </p>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
        {errors.doctor_id && (
          <p className="text-red-500 text-sm mt-2">{errors.doctor_id}</p>
        )}
      </div>

      {/* Step 2: Select Date & Time */}
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
          <Calendar className="w-5 h-5 text-blue-600" />
          Bước 2: Chọn Ngày & Giờ
        </h3>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Ngày khám <span className="text-red-500">*</span>
            </label>
            <input
              type="date"
              value={formData.appointment_date}
              onChange={(e) => handleChange('appointment_date', e.target.value)}
              min={minDate}
              max={maxDate}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            {errors.appointment_date && (
              <p className="text-red-500 text-sm mt-1">{errors.appointment_date}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Giờ khám <span className="text-red-500">*</span>
            </label>
            <select
              value={formData.appointment_time}
              onChange={(e) => handleChange('appointment_time', e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="">Chọn giờ khám</option>
              {availableSlots.map(slot => (
                <option key={slot} value={slot}>{slot}</option>
              ))}
            </select>
            {errors.appointment_time && (
              <p className="text-red-500 text-sm mt-1">{errors.appointment_time}</p>
            )}
          </div>
        </div>
      </div>

      {/* Step 3: Reason & Notes */}
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
          <FileText className="w-5 h-5 text-blue-600" />
          Bước 3: Thông tin khám
        </h3>

        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Lý do khám <span className="text-red-500">*</span>
            </label>
            <textarea
              value={formData.reason}
              onChange={(e) => handleChange('reason', e.target.value)}
              rows={4}
              placeholder="Mô tả triệu chứng, lý do khám..."
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
            {errors.reason && (
              <p className="text-red-500 text-sm mt-1">{errors.reason}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Ghi chú (tùy chọn)
            </label>
            <textarea
              value={formData.notes}
              onChange={(e) => handleChange('notes', e.target.value)}
              rows={3}
              placeholder="Thông tin bổ sung..."
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
        </div>
      </div>

      {/* Info Alert */}
      <Alert
        type="info"
        message="Lưu ý: Lịch hẹn sẽ được xác nhận trong vòng 24h. Bạn sẽ nhận được thông báo qua email và SMS."
      />

      {/* Submit Button */}
      <div className="flex justify-end gap-3">
        <Button
          type="submit"
          disabled={loading}
          className="px-6"
        >
          {loading ? 'Đang xử lý...' : 'Đặt lịch khám'}
        </Button>
      </div>
    </form>
  );
}