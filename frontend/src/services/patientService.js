// src/services/patientService.js
import api from './api';

export const patientService = {
  // Get all patients (Admin/Receptionist/Doctor)
  getAllPatients: async (params = {}) => {
    return await api.get('/patients', { params });
  },

  // Get patient by ID
  getPatientById: async (id) => {
    return await api.get(`/patients/${id}`);
  },

  // Get my profile (Patient)
  getMyProfile: async () => {
    return await api.get('/patients/me/profile');
  },

  // Update my profile (Patient)
  updateMyProfile: async (data) => {
    return await api.put('/patients/me/profile', data);
  },

  // Get patient medical records
  getPatientMedicalRecords: async (patientId, params = {}) => {
    return await api.get(`/patients/${patientId}/medical-records`, { params });
  },

  // Get patient appointments
  getPatientAppointments: async (patientId, params = {}) => {
    return await api.get(`/patients/${patientId}/appointments`, { params });
  },

  // Get patient prescriptions
  getPatientPrescriptions: async (patientId, params = {}) => {
    return await api.get(`/patients/${patientId}/prescriptions`, { params });
  },

  // Get patient invoices
  getPatientInvoices: async (patientId, params = {}) => {
    return await api.get(`/patients/${patientId}/invoices`, { params });
  },

  // Create patient (Receptionist/Admin)
  createPatient: async (data) => {
    return await api.post('/patients', data);
  },

  // Update patient (Receptionist/Admin)
  updatePatient: async (id, data) => {
    return await api.put(`/patients/${id}`, data);
  },

  // Delete patient (Admin)
  deletePatient: async (id) => {
    return await api.delete(`/patients/${id}`);
  },
};