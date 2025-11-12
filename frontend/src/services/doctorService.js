// src/services/doctorService.js
import api from './api';

export const doctorService = {
  // Public: Get all doctors
  getAllDoctorsPublic: async (params = {}) => {
    return await api.get('/doctors/public', { params });
  },

  // Public: Get doctor by ID
  getDoctorByIdPublic: async (id) => {
    return await api.get(`/doctors/public/${id}`);
  },

  // Public: Get specialties
  getSpecialties: async () => {
    return await api.get('/doctors/public/specialties/list');
  },

  // Get all doctors (Admin/Receptionist/Doctor)
  getAllDoctors: async (params = {}) => {
    return await api.get('/doctors', { params });
  },

  // Get doctor by ID
  getDoctorById: async (id) => {
    return await api.get(`/doctors/${id}`);
  },

  // Get doctor appointments
  getDoctorAppointments: async (id, params = {}) => {
    return await api.get(`/doctors/${id}/appointments`, { params });
  },

  // Get doctor schedules
  getDoctorSchedules: async (id, params = {}) => {
    return await api.get(`/doctors/${id}/schedules`, { params });
  },

  // Get doctor patients
  getDoctorPatients: async (id) => {
    return await api.get(`/doctors/${id}/patients`);
  },

  // Get doctor stats
  getDoctorStats: async (id) => {
    return await api.get(`/doctors/${id}/stats`);
  },

  // Create doctor (Admin)
  createDoctor: async (data) => {
    return await api.post('/doctors', data);
  },

  // Update doctor (Admin)
  updateDoctor: async (id, data) => {
    return await api.put(`/doctors/${id}`, data);
  },

  // Update own profile (Doctor)
  updateOwnProfile: async (data) => {
    return await api.put('/doctors/me/profile', data);
  },

  // Delete doctor (Admin)
  deleteDoctor: async (id) => {
    return await api.delete(`/doctors/${id}`);
  },

  // Toggle doctor status (Admin)
  toggleDoctorStatus: async (id) => {
    return await api.patch(`/doctors/${id}/toggle-status`);
  },

  // Get today's appointments for the currently authenticated doctor (wrapper)
  getTodayAppointments: async (params = {}) => {
    // assumed backend endpoint; adjust if your backend uses a different path
    return await api.get('/doctors/me/appointments/today', { params });
  },
};

// Named exports (aliases)
export const getAllDoctorsPublic = doctorService.getAllDoctorsPublic;
export const getDoctorByIdPublic = doctorService.getDoctorByIdPublic;
export const getSpecialties = doctorService.getSpecialties;
export const getAllDoctors = doctorService.getAllDoctors;
export const getDoctorById = doctorService.getDoctorById;
export const getDoctorAppointments = doctorService.getDoctorAppointments;
export const getDoctorSchedules = doctorService.getDoctorSchedules;
export const getDoctorPatients = doctorService.getDoctorPatients;
export const getDoctorStats = doctorService.getDoctorStats;
export const createDoctor = doctorService.createDoctor;
export const updateDoctor = doctorService.updateDoctor;
export const updateOwnProfile = doctorService.updateOwnProfile;
export const deleteDoctor = doctorService.deleteDoctor;
export const toggleDoctorStatus = doctorService.toggleDoctorStatus;
export const getTodayAppointments = doctorService.getTodayAppointments;

export default doctorService;
