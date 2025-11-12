import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './context/AuthContext';

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

// Protected Route
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

  // ✅ FIX LỖI ĐOẠN NÀY
  const userRole = user?.role?.name || user?.role || "";
  const redirectPath = "/" + String(userRole).toLowerCase();

  return (
    <Router>
      <Routes>

        {/* Public */}
        <Route
          path="/login"
          element={!user ? <LoginPage /> : <Navigate to={redirectPath} replace />}
        />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/forgot-password" element={<ForgotPasswordPage />} />

        {/* Patient */}
        <Route path="/patient" element={<ProtectedRoute role="patient"><PatientDashboard /></ProtectedRoute>} />
        <Route path="/patient/appointments" element={<ProtectedRoute role="patient"><AppointmentsPage /></ProtectedRoute>} />
        <Route path="/patient/medical-records" element={<ProtectedRoute role="patient"><MedicalRecordsPage /></ProtectedRoute>} />
        <Route path="/patient/prescriptions" element={<ProtectedRoute role="patient"><PrescriptionsPage /></ProtectedRoute>} />
        <Route path="/patient/symptom-checker" element={<ProtectedRoute role="patient"><AISymptomCheckerPage /></ProtectedRoute>} />
        <Route path="/patient/profile" element={<ProtectedRoute role="patient"><ProfilePage /></ProtectedRoute>} />

        {/* Doctor */}
        <Route path="/doctor" element={<ProtectedRoute role="doctor"><DoctorDashboard /></ProtectedRoute>} />
        <Route path="/doctor/schedule" element={<ProtectedRoute role="doctor"><SchedulePage /></ProtectedRoute>} />
        <Route path="/doctor/appointments" element={<ProtectedRoute role="doctor"><TodayAppointmentsPage /></ProtectedRoute>} />
        <Route path="/doctor/examination/:id" element={<ProtectedRoute role="doctor"><ExaminationPage /></ProtectedRoute>} />
        <Route path="/doctor/ai-tools" element={<ProtectedRoute role="doctor"><AIToolsPage /></ProtectedRoute>} />

        {/* Receptionist */}
        <Route path="/receptionist" element={<ProtectedRoute role="receptionist"><ReceptionistDashboard /></ProtectedRoute>} />
        <Route path="/receptionist/appointments" element={<ProtectedRoute role="receptionist"><AppointmentManagementPage /></ProtectedRoute>} />
        <Route path="/receptionist/register-patient" element={<ProtectedRoute role="receptionist"><PatientRegistrationPage /></ProtectedRoute>} />
        <Route path="/receptionist/check-in" element={<ProtectedRoute role="receptionist"><CheckInPage /></ProtectedRoute>} />

        {/* Admin */}
        <Route path="/admin" element={<ProtectedRoute role="admin"><AdminDashboard /></ProtectedRoute>} />
        <Route path="/admin/users" element={<ProtectedRoute role="admin"><UsersPage /></ProtectedRoute>} />
        <Route path="/admin/doctors" element={<ProtectedRoute role="admin"><DoctorsPage /></ProtectedRoute>} />
        <Route path="/admin/medicines" element={<ProtectedRoute role="admin"><MedicinesPage /></ProtectedRoute>} />
        <Route path="/admin/reports" element={<ProtectedRoute role="admin"><ReportsPage /></ProtectedRoute>} />

        {/* Default redirect */}
        <Route path="/" element={<Navigate to={user ? redirectPath : "/login"} replace />} />

        {/* Errors */}
        <Route path="/unauthorized" element={<UnauthorizedPage />} />
        <Route path="*" element={<NotFoundPage />} />

      </Routes>
    </Router>
  );
}

export default App;
