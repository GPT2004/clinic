// src/services/reportService.js
import api from './api';

export const reportService = {
  // Get dashboard stats
  getDashboardStats: async () => {
    return await api.get('/reports/dashboard');
  },

  // Get revenue report
  getRevenueReport: async (startDate, endDate, groupBy = 'day') => {
    return await api.get('/reports/revenue', {
      params: { startDate, endDate, groupBy },
    });
  },

  // Get appointment report
  getAppointmentReport: async (startDate, endDate, status) => {
    return await api.get('/reports/appointments', {
      params: { startDate, endDate, status },
    });
  },

  // Get doctor performance
  getDoctorPerformance: async (startDate, endDate, doctorId) => {
    return await api.get('/reports/doctors/performance', {
      params: { startDate, endDate, doctorId },
    });
  },

  // Get common diseases
  getCommonDiseases: async (startDate, endDate, limit = 10) => {
    return await api.get('/reports/diseases/common', {
      params: { startDate, endDate, limit },
    });
  },

  // Get stock report
  getStockReport: async () => {
    return await api.get('/reports/stock');
  },

  // Get patient report
  getPatientReport: async (startDate, endDate) => {
    return await api.get('/reports/patients', {
      params: { startDate, endDate },
    });
  },

  // Export report
  exportReport: async (type, format = 'csv', params = {}) => {
    return await api.get('/reports/export', {
      params: { type, format, ...params },
      responseType: 'blob',
    });
  },
};