// src/services/appointmentService.js
import api from './api';

export const appointmentService = {
  // Get all appointments
  getAppointments: async (params = {}) => {
    return await api.get('/appointments', { params });
  },

  // Get appointment by ID
  getAppointmentById: async (id) => {
    return await api.get(`/appointments/${id}`);
  },

  // Create appointment
  createAppointment: async (data) => {
    return await api.post('/appointments', data);
  },

  // Update appointment
  updateAppointment: async (id, data) => {
    return await api.put(`/appointments/${id}`, data);
  },

  // Confirm appointment (Receptionist/Admin)
  confirmAppointment: async (id) => {
    return await api.patch(`/appointments/${id}/confirm`);
  },

  // Check-in appointment (Receptionist/Admin)
  checkInAppointment: async (id) => {
    return await api.patch(`/appointments/${id}/check-in`);
  },

  // Start appointment (Doctor)
  startAppointment: async (id) => {
    return await api.patch(`/appointments/${id}/start`);
  },

  // Complete appointment (Doctor)
  completeAppointment: async (id) => {
    return await api.patch(`/appointments/${id}/complete`);
  },

  // Mark as no-show (Receptionist/Admin)
  markNoShow: async (id) => {
    return await api.patch(`/appointments/${id}/no-show`);
  },

  // Cancel appointment
  cancelAppointment: async (id, reason) => {
    return await api.patch(`/appointments/${id}/cancel`, { reason });
  },
};