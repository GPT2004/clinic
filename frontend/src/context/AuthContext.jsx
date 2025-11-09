// frontend/src/context/AuthContext.jsx
/**
 * Auth Context - Quản lý toàn bộ authentication state
 * COMPLETE IMPLEMENTATION
 */

import React, { createContext, useState, useEffect, useContext, useCallback } from 'react';
import { authService } from '../services/authService';
import { 
  getAuthToken, 
  setAuthToken, 
  setRefreshToken,
  setUserData,
  clearAuthData,
  getUserData 
} from '../utils/storage';

// Create Context
export const AuthContext = createContext(null);

// Provider Component
export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  // Initialize auth state from storage
  useEffect(() => {
    const initAuth = async () => {
      try {
        const token = getAuthToken();
        const savedUser = getUserData();

        if (token && savedUser) {
          // Verify token is still valid by fetching profile
          try {
            const response = await authService.getProfile();
            const freshUser = response.data;
            
            setUser(freshUser);
            setUserData(freshUser);
            setIsAuthenticated(true);
          } catch (err) {
            // Token invalid, clear everything
            clearAuthData();
            setUser(null);
            setIsAuthenticated(false);
          }
        }
      } catch (err) {
        console.error('Auth initialization error:', err);
        clearAuthData();
      } finally {
        setLoading(false);
      }
    };

    initAuth();
  }, []);

  // Login
  const login = useCallback(async (email, password) => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await authService.login(email, password);
      const { user: userData, token, refreshToken } = response.data;

      // Save to storage
      setAuthToken(token);
      setRefreshToken(refreshToken);
      setUserData(userData);

      // Update state
      setUser(userData);
      setIsAuthenticated(true);

      return { success: true, user: userData };
    } catch (err) {
      const errorMsg = err.response?.data?.message || 'Đăng nhập thất bại';
      setError(errorMsg);
      return { success: false, error: errorMsg };
    } finally {
      setLoading(false);
    }
  }, []);

  // Register
  const register = useCallback(async (userData) => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await authService.register(userData);
      const { user: newUser, token, refreshToken } = response.data;

      // Save to storage
      setAuthToken(token);
      setRefreshToken(refreshToken);
      setUserData(newUser);

      // Update state
      setUser(newUser);
      setIsAuthenticated(true);

      return { success: true, user: newUser };
    } catch (err) {
      const errorMsg = err.response?.data?.message || 'Đăng ký thất bại';
      setError(errorMsg);
      return { success: false, error: errorMsg };
    } finally {
      setLoading(false);
    }
  }, []);

  // Logout
  const logout = useCallback(async () => {
    try {
      await authService.logout();
    } catch (err) {
      console.error('Logout error:', err);
    } finally {
      // Clear everything regardless of API call result
      clearAuthData();
      setUser(null);
      setIsAuthenticated(false);
      setError(null);
    }
  }, []);

  // Update profile
  const updateProfile = useCallback(async (data) => {
    try {
      const response = await authService.getProfile();
      const updatedUser = response.data;
      
      setUserData(updatedUser);
      setUser(updatedUser);
      
      return { success: true, user: updatedUser };
    } catch (err) {
      return { success: false, error: err.message };
    }
  }, []);

  // Refresh user data (after external updates)
  const refreshUser = useCallback(async () => {
    try {
      const response = await authService.getProfile();
      const freshUser = response.data;
      
      setUserData(freshUser);
      setUser(freshUser);
      
      return freshUser;
    } catch (err) {
      console.error('Refresh user error:', err);
      return null;
    }
  }, []);

  // Change password
  const changePassword = useCallback(async (currentPassword, newPassword) => {
    try {
      await authService.changePassword(currentPassword, newPassword);
      return { success: true };
    } catch (err) {
      const errorMsg = err.response?.data?.message || 'Đổi mật khẩu thất bại';
      return { success: false, error: errorMsg };
    }
  }, []);

  // Check if user has specific role
  const hasRole = useCallback((role) => {
    if (!user || !user.role) return false;
    return user.role.name === role;
  }, [user]);

  // Check if user has any of the specified roles
  const hasAnyRole = useCallback((roles) => {
    if (!user || !user.role) return false;
    return roles.includes(user.role.name);
  }, [user]);

  // Check if user can perform action
  const can = useCallback((permission) => {
    // Simple permission check based on role
    // Can be extended with more granular permissions
    if (!user || !user.role) return false;
    
    const rolePermissions = {
      Admin: ['*'], // Admin can do everything
      Doctor: ['view:patients', 'create:medical-records', 'create:prescriptions', 'view:appointments'],
      Receptionist: ['create:appointments', 'view:patients', 'manage:invoices'],
      Patient: ['view:own-data', 'book:appointments'],
      Pharmacist: ['dispense:medicines', 'manage:stock'],
      LabTech: ['manage:lab-orders', 'update:lab-results'],
    };

    const userPermissions = rolePermissions[user.role.name] || [];
    
    // Admin has all permissions
    if (userPermissions.includes('*')) return true;
    
    return userPermissions.includes(permission);
  }, [user]);

  // Get user's full name
  const getUserName = useCallback(() => {
    return user?.full_name || 'User';
  }, [user]);

  // Get user's role
  const getUserRole = useCallback(() => {
    return user?.role?.name || null;
  }, [user]);

  // Get user's avatar URL
  const getUserAvatar = useCallback(() => {
    return user?.avatar_url || null;
  }, [user]);

  // Context value
  const value = {
    // State
    user,
    loading,
    error,
    isAuthenticated,

    // Actions
    login,
    register,
    logout,
    updateProfile,
    refreshUser,
    changePassword,

    // Helpers
    hasRole,
    hasAnyRole,
    can,
    getUserName,
    getUserRole,
    getUserAvatar,

    // Setters (for internal use)
    setUser,
    setError,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

// Custom hook
export const useAuth = () => {
  const context = useContext(AuthContext);
  
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  
  return context;
};

export default AuthContext;