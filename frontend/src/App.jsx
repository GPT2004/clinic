import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './hooks/useAuth';

// Auth Pages
import LoginPage from './pages/auth/LoginPage';
import RegisterPage from './pages/auth/RegisterPage';
import ForgotPasswordPage from './pages/auth/ForgotPasswordPage';

// Patient Pages
import PatientDashboard from './pages/patient/PatientDashboard';
import AppointmentsPage from './pages/patient/AppointmentsPage';
import MedicalRecordsPage from './pages/patient/MedicalRecordsPage';
import PrescriptionsPage from './pages/patient/PrescriptionsPage';
import AISymptomCheckerPage from './pages/patient/AISymptomCheckerPage';
import ProfilePage from './pages/patient/ProfilePage';

// Doctor Pages
import DoctorDashboard from './pages/doctor/DoctorDashboard';
import SchedulePage from './pages/doctor/SchedulePage';
import TodayAppointmentsPage from './pages/doctor/TodayAppointmentsPage';
import ExaminationPage from './pages/doctor/ExaminationPage';
import AIToolsPage from './pages/doctor/AIToolsPage';

// Receptionist Pages
import ReceptionistDashboard from './pages/receptionist/ReceptionistDashboard';
import AppointmentManagementPage from './pages/receptionist/AppointmentManagementPage';
import PatientRegistrationPage from './pages/receptionist/PatientRegistrationPage';
import CheckInPage from './pages/receptionist/CheckInPage';

// Admin Pages
import AdminDashboard from './pages/admin/AdminDashboard';
import UsersPage from './pages/admin/UsersPage';
import DoctorsPage from './pages/admin/DoctorsPage';
import MedicinesPage from './pages/admin/MedicinesPage';
import ReportsPage from './pages/admin/ReportsPage';

// Error Pages
import NotFoundPage from './pages/NotFoundPage';
import UnauthorizedPage from './pages/UnauthorizedPage';

// Protected Route Component
import ProtectedRoute from './components/auth/ProtectedRoute';

function App() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <Router>
      <Routes>
        {/* Public Routes */}
        <Route path="/login" element={!user ? <LoginPage /> : <Navigate to={`/${user.role.toLowerCase()}`} />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/forgot-password" element={<ForgotPasswordPage />} />

        {/* Patient Routes */}
        <Route path="/patient" element={<ProtectedRoute role="PATIENT"><PatientDashboard /></ProtectedRoute>} />
        <Route path="/patient/appointments" element={<ProtectedRoute role="PATIENT"><AppointmentsPage /></ProtectedRoute>} />
        <Route path="/patient/medical-records" element={<ProtectedRoute role="PATIENT"><MedicalRecordsPage /></ProtectedRoute>} />
        <Route path="/patient/prescriptions" element={<ProtectedRoute role="PATIENT"><PrescriptionsPage /></ProtectedRoute>} />
        <Route path="/patient/symptom-checker" element={<ProtectedRoute role="PATIENT"><AISymptomCheckerPage /></ProtectedRoute>} />
        <Route path="/patient/profile" element={<ProtectedRoute role="PATIENT"><ProfilePage /></ProtectedRoute>} />

        {/* Doctor Routes */}
        <Route path="/doctor" element={<ProtectedRoute role="DOCTOR"><DoctorDashboard /></ProtectedRoute>} />
        <Route path="/doctor/schedule" element={<ProtectedRoute role="DOCTOR"><SchedulePage /></ProtectedRoute>} />
        <Route path="/doctor/appointments" element={<ProtectedRoute role="DOCTOR"><TodayAppointmentsPage /></ProtectedRoute>} />
        <Route path="/doctor/examination/:id" element={<ProtectedRoute role="DOCTOR"><ExaminationPage /></ProtectedRoute>} />
        <Route path="/doctor/ai-tools" element={<ProtectedRoute role="DOCTOR"><AIToolsPage /></ProtectedRoute>} />

        {/* Receptionist Routes */}
        <Route path="/receptionist" element={<ProtectedRoute role="RECEPTIONIST"><ReceptionistDashboard /></ProtectedRoute>} />
        <Route path="/receptionist/appointments" element={<ProtectedRoute role="RECEPTIONIST"><AppointmentManagementPage /></ProtectedRoute>} />
        <Route path="/receptionist/register-patient" element={<ProtectedRoute role="RECEPTIONIST"><PatientRegistrationPage /></ProtectedRoute>} />
        <Route path="/receptionist/check-in" element={<ProtectedRoute role="RECEPTIONIST"><CheckInPage /></ProtectedRoute>} />

        {/* Admin Routes */}
        <Route path="/admin" element={<ProtectedRoute role="ADMIN"><AdminDashboard /></ProtectedRoute>} />
        <Route path="/admin/users" element={<ProtectedRoute role="ADMIN"><UsersPage /></ProtectedRoute>} />
        <Route path="/admin/doctors" element={<ProtectedRoute role="ADMIN"><DoctorsPage /></ProtectedRoute>} />
        <Route path="/admin/medicines" element={<ProtectedRoute role="ADMIN"><MedicinesPage /></ProtectedRoute>} />
        <Route path="/admin/reports" element={<ProtectedRoute role="ADMIN"><ReportsPage /></ProtectedRoute>} />

        {/* Default & Error Routes */}
        <Route path="/" element={<Navigate to={user ? `/${user.role.toLowerCase()}` : "/login"} />} />
        <Route path="/unauthorized" element={<UnauthorizedPage />} />
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </Router>
  );
}

export default App;