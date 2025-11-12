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

// Named exports & convenient wrappers
export const getAllAppointments = appointmentService.getAppointments;

// getAppointmentsByPatient: wrapper calling getAppointments with patientId param.
// If your backend supports a dedicated endpoint like /patients/{id}/appointments, you can replace this wrapper.
export const getAppointmentsByPatient = async (patientId, params = {}) => {
  const p = { ...(params || {}), patientId };
  return await appointmentService.getAppointments(p);
};

export const getAppointmentById = appointmentService.getAppointmentById;
export const createAppointment = appointmentService.createAppointment;
export const updateAppointment = appointmentService.updateAppointment;
export const confirmAppointment = appointmentService.confirmAppointment;
export const checkInAppointment = appointmentService.checkInAppointment;
export const startAppointment = appointmentService.startAppointment;
export const completeAppointment = appointmentService.completeAppointment;
export const markNoShow = appointmentService.markNoShow;
export const cancelAppointment = appointmentService.cancelAppointment;

export default appointmentService;
