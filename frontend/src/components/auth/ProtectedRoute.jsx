// frontend/src/components/auth/ProtectedRoute.jsx
/**
 * Protected Route Component
 * Bảo vệ routes theo role
 */

import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import Loader from '../common/Loader';

/**
 * ProtectedRoute Component
 * @param {string} role - Required role to access route (optional)
 * @param {string[]} roles - Array of allowed roles (optional)
 * @param {JSX.Element} children - Components to render if authorized
 * @param {string} redirectTo - Where to redirect if unauthorized
 */
const ProtectedRoute = ({ 
  role, 
  roles = [], 
  children,
  redirectTo = '/login'
}) => {
  const { user, loading, isAuthenticated } = useAuth();
  const location = useLocation();

  // Show loader while checking authentication
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader size="large" />
      </div>
    );
  }

  // Not authenticated - redirect to login
  if (!isAuthenticated || !user) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // No role requirement - allow access
  if (!role && roles.length === 0) {
    return children;
  }

  // Check single role
  if (role && user.role?.name !== role) {
    return <Navigate to="/unauthorized" state={{ from: location }} replace />;
  }

  // Check multiple roles
  if (roles.length > 0 && !roles.includes(user.role?.name)) {
    return <Navigate to="/unauthorized" state={{ from: location }} replace />;
  }

  // User is authorized
  return children;
};

/**
 * RoleBasedRedirect Component
 * Redirect user to their default dashboard based on role
 */
export const RoleBasedRedirect = () => {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader size="large" />
      </div>
    );
  }

  if (!user || !user.role) {
    return <Navigate to="/login" replace />;
  }

  // Redirect based on role
  const roleRedirects = {
    Admin: '/admin',
    Doctor: '/doctor',
    Patient: '/patient',
    Receptionist: '/receptionist',
    Pharmacist: '/pharmacist',
    LabTech: '/lab-tech',
  };

  const redirectPath = roleRedirects[user.role.name] || '/login';
  
  return <Navigate to={redirectPath} replace />;
};

/**
 * PublicRoute Component
 * Only allow access if NOT authenticated (for login, register pages)
 */
export const PublicRoute = ({ children, redirectTo }) => {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader size="large" />
      </div>
    );
  }

  // If authenticated, redirect to their dashboard
  if (user && user.role) {
    const roleRedirects = {
      Admin: '/admin',
      Doctor: '/doctor',
      Patient: '/patient',
      Receptionist: '/receptionist',
      Pharmacist: '/pharmacist',
      LabTech: '/lab-tech',
    };

    const redirectPath = redirectTo || roleRedirects[user.role.name] || '/';
    return <Navigate to={redirectPath} replace />;
  }

  return children;
};

/**
 * ConditionalRoute Component
 * Render different components based on conditions
 */
export const ConditionalRoute = ({ 
  condition, 
  whenTrue, 
  whenFalse,
  loading: customLoading 
}) => {
  const { loading: authLoading } = useAuth();
  
  const isLoading = customLoading !== undefined ? customLoading : authLoading;

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader size="large" />
      </div>
    );
  }

  return condition ? whenTrue : whenFalse;
};

/**
 * PermissionGate Component
 * Show/hide content based on permissions
 */
export const PermissionGate = ({ 
  permission, 
  children, 
  fallback = null 
}) => {
  const { can } = useAuth();

  if (!can(permission)) {
    return fallback;
  }

  return children;
};

/**
 * RoleGate Component
 * Show/hide content based on role
 */
export const RoleGate = ({ 
  role, 
  roles = [], 
  children, 
  fallback = null 
}) => {
  const { hasRole, hasAnyRole } = useAuth();

  // Check single role
  if (role && !hasRole(role)) {
    return fallback;
  }

  // Check multiple roles
  if (roles.length > 0 && !hasAnyRole(roles)) {
    return fallback;
  }

  return children;
};

export default ProtectedRoute;