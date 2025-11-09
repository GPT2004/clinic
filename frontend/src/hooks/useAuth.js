// frontend/src/hooks/useAuth.js
import { useState, useEffect, useContext, createContext } from 'react';
import { authService } from '../services/authService';
import { 
  getAuthToken, 
  setAuthToken, 
  setRefreshToken,
  setUserData,
  clearAuthData,
  getUserData 
} from '../utils/storage';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Load user from storage on mount
  useEffect(() => {
    const initAuth = async () => {
      const token = getAuthToken();
      const savedUser = getUserData();

      if (token && savedUser) {
        setUser(savedUser);
      }
      setLoading(false);
    };

    initAuth();
  }, []);

  // Login
  const login = async (email, password) => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await authService.login(email, password);
      const { user, token, refreshToken } = response.data;

      setAuthToken(token);
      setRefreshToken(refreshToken);
      setUserData(user);
      setUser(user);

      return { success: true, user };
    } catch (err) {
      const errorMsg = err.response?.data?.message || 'Đăng nhập thất bại';
      setError(errorMsg);
      return { success: false, error: errorMsg };
    } finally {
      setLoading(false);
    }
  };

  // Register
  const register = async (userData) => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await authService.register(userData);
      const { user, token, refreshToken } = response.data;

      setAuthToken(token);
      setRefreshToken(refreshToken);
      setUserData(user);
      setUser(user);

      return { success: true, user };
    } catch (err) {
      const errorMsg = err.response?.data?.message || 'Đăng ký thất bại';
      setError(errorMsg);
      return { success: false, error: errorMsg };
    } finally {
      setLoading(false);
    }
  };

  // Logout
  const logout = async () => {
    try {
      await authService.logout();
    } catch (err) {
      console.error('Logout error:', err);
    } finally {
      clearAuthData();
      setUser(null);
    }
  };

  // Update profile
  const updateProfile = async (data) => {
    try {
      const response = await authService.getProfile();
      const updatedUser = response.data;
      
      setUserData(updatedUser);
      setUser(updatedUser);
      
      return { success: true, user: updatedUser };
    } catch (err) {
      return { success: false, error: err.message };
    }
  };

  // Refresh user data
  const refreshUser = async () => {
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
  };

  // Check if user has role
  const hasRole = (role) => {
    return user?.role?.name === role;
  };

  // Check if user has any of roles
  const hasAnyRole = (roles) => {
    return roles.includes(user?.role?.name);
  };

  const value = {
    user,
    loading,
    error,
    isAuthenticated: !!user,
    login,
    register,
    logout,
    updateProfile,
    refreshUser,
    hasRole,
    hasAnyRole,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};