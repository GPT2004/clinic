// src/services/authService.js
import api from './api';

export const authService = {
  // Register new patient
  register: async (userData) => {
    return await api.post('/auth/register', userData);
  },

  // Login
  login: async (email, password) => {
    return await api.post('/auth/login', { email, password });
  },

  // Logout
  logout: async () => {
    return await api.post('/auth/logout');
  },

  // Get current user profile
  getProfile: async () => {
    return await api.get('/auth/me');
  },

  // Change password
  changePassword: async (currentPassword, newPassword) => {
    return await api.put('/auth/change-password', {
      current_password: currentPassword,
      new_password: newPassword,
    });
  },

  // Refresh token
  refreshToken: async (refreshToken) => {
    return await api.post('/auth/refresh', { refreshToken });
  },
};