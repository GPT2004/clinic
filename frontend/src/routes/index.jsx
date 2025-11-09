// frontend/src/routes/index.jsx
import { lazy } from 'react';
import { ROLES } from '../utils/constants';

// Lazy load pages
const LoginPage = lazy(() => import('../pages/auth/LoginPage'));
const RegisterPage = lazy(() => import('../pages/auth/RegisterPage'));
const ForgotPasswordPage = lazy(() => import('../pages/auth/ForgotPasswordPage'));

// Patient Pages
const PatientDashboard = lazy(() => import('../pages/patient/PatientDashboard'));
const AppointmentsPage = lazy(() => import('../pages/patient/AppointmentsPage'));
const BookAppointmentPage = lazy(() => import('../pages/patient/BookAppointmentPage'));
const MedicalRecordsPage = lazy(() => import('../pages/patient/MedicalRecordsPage'));
const PrescriptionsPage = lazy(() => import('../pages/patient/PrescriptionsPage'));
const LabResultsPage = lazy(() => import('../pages/patient/LabResultsPage'));
const InvoicesPage = lazy(() => import('../pages/patient/InvoicesPage'));
const AISymptomCheckerPage = lazy(() => import('../pages/patient/AISymptomCheckerPage'));
const ProfilePage = lazy(() => import('../pages/patient/ProfilePage'));

// Doctor Pages
const DoctorDashboard = lazy(() => import('../pages/doctor/DoctorDashboard'));
const SchedulePage = lazy(() => import('../pages/doctor/SchedulePage'));
const TodayAppointmentsPage = lazy(() => import('../pages/doctor/TodayAppointmentsPage'));
const ExaminationPage = lazy(() => import('../pages/doctor/ExaminationPage'));
const PatientDetailPage = lazy(() => import('../pages/doctor/PatientDetailPage'));
const PrescriptionPage = lazy(() => import('../pages/doctor/PrescriptionPage'));
const LabOrderPage = lazy(() => import('../pages/doctor/LabOrderPage'));
const AIToolsPage = lazy(() => import('../pages/doctor/AIToolsPage'));
const DoctorProfilePage = lazy(() => import('../pages/doctor/DoctorProfilePage'));

// Receptionist Pages
const ReceptionistDashboard = lazy(() => import('../pages/receptionist/ReceptionistDashboard'));
const AppointmentManagementPage = lazy(() => import('../pages/receptionist/AppointmentManagementPage'));
const PatientRegistrationPage = lazy(() => import('../pages/receptionist/PatientRegistrationPage'));
const CheckInPage = lazy(() => import('../pages/receptionist/CheckInPage'));
const InvoicePage = lazy(() => import('../pages/receptionist/InvoicePage'));
const TimeslotManagementPage = lazy(() => import('../pages/receptionist/TimeslotManagementPage'));
const DailyReportPage = lazy(() => import('../pages/receptionist/DailyReportPage'));

// Admin Pages
const AdminDashboard = lazy(() => import('../pages/admin/AdminDashboard'));
const UsersPage = lazy(() => import('../pages/admin/UsersPage'));
const DoctorsPage = lazy(() => import('../pages/admin/DoctorsPage'));
const PatientsPage = lazy(() => import('../pages/admin/PatientsPage'));
const MedicinesPage = lazy(() => import('../pages/admin/MedicinesPage'));
const RoomsPage = lazy(() => import('../pages/admin/RoomsPage'));
const SchedulesPage = lazy(() => import('../pages/admin/SchedulesPage'));
const SuppliersPage = lazy(() => import('../pages/admin/SuppliersPage'));
const ReportsPage = lazy(() => import('../pages/admin/ReportsPage'));
const AuditLogsPage = lazy(() => import('../pages/admin/AuditLogsPage'));
const NotificationsPage = lazy(() => import('../pages/admin/NotificationsPage'));
const SettingsPage = lazy(() => import('../pages/admin/SettingsPage'));

// Error Pages
const NotFoundPage = lazy(() => import('../pages/NotFoundPage'));
const UnauthorizedPage = lazy(() => import('../pages/UnauthorizedPage'));

// Route configurations
export const publicRoutes = [
  {
    path: '/login',
    element: LoginPage,
    title: 'Đăng nhập',
  },
  {
    path: '/register',
    element: RegisterPage,
    title: 'Đăng ký',
  },
  {
    path: '/forgot-password',
    element: ForgotPasswordPage,
    title: 'Quên mật khẩu',
  },
];

export const patientRoutes = [
  {
    path: '/patient',
    element: PatientDashboard,
    title: 'Trang chủ',
    role: ROLES.PATIENT,
  },
  {
    path: '/patient/appointments',
    element: AppointmentsPage,
    title: 'Lịch hẹn',
    role: ROLES.PATIENT,
  },
  {
    path: '/patient/appointments/book',
    element: BookAppointmentPage,
    title: 'Đặt lịch hẹn',
    role: ROLES.PATIENT,
  },
  {
    path: '/patient/medical-records',
    element: MedicalRecordsPage,
    title: 'Hồ sơ bệnh án',
    role: ROLES.PATIENT,
  },
  {
    path: '/patient/prescriptions',
    element: PrescriptionsPage,
    title: 'Đơn thuốc',
    role: ROLES.PATIENT,
  },
  {
    path: '/patient/lab-results',
    element: LabResultsPage,
    title: 'Kết quả xét nghiệm',
    role: ROLES.PATIENT,
  },
  {
    path: '/patient/invoices',
    element: InvoicesPage,
    title: 'Hóa đơn',
    role: ROLES.PATIENT,
  },
  {
    path: '/patient/symptom-checker',
    element: AISymptomCheckerPage,
    title: 'Kiểm tra triệu chứng AI',
    role: ROLES.PATIENT,
  },
  {
    path: '/patient/profile',
    element: ProfilePage,
    title: 'Thông tin cá nhân',
    role: ROLES.PATIENT,
  },
];

export const doctorRoutes = [
  {
    path: '/doctor',
    element: DoctorDashboard,
    title: 'Trang chủ',
    role: ROLES.DOCTOR,
  },
  {
    path: '/doctor/schedule',
    element: SchedulePage,
    title: 'Lịch làm việc',
    role: ROLES.DOCTOR,
  },
  {
    path: '/doctor/appointments',
    element: TodayAppointmentsPage,
    title: 'Lịch hẹn hôm nay',
    role: ROLES.DOCTOR,
  },
  {
    path: '/doctor/examination/:id',
    element: ExaminationPage,
    title: 'Khám bệnh',
    role: ROLES.DOCTOR,
  },
  {
    path: '/doctor/patients/:id',
    element: PatientDetailPage,
    title: 'Chi tiết bệnh nhân',
    role: ROLES.DOCTOR,
  },
  {
    path: '/doctor/prescriptions',
    element: PrescriptionPage,
    title: 'Kê đơn thuốc',
    role: ROLES.DOCTOR,
  },
  {
    path: '/doctor/lab-orders',
    element: LabOrderPage,
    title: 'Chỉ định xét nghiệm',
    role: ROLES.DOCTOR,
  },
  {
    path: '/doctor/ai-tools',
    element: AIToolsPage,
    title: 'Công cụ AI',
    role: ROLES.DOCTOR,
  },
  {
    path: '/doctor/profile',
    element: DoctorProfilePage,
    title: 'Thông tin cá nhân',
    role: ROLES.DOCTOR,
  },
];

export const receptionistRoutes = [
  {
    path: '/receptionist',
    element: ReceptionistDashboard,
    title: 'Trang chủ',
    role: ROLES.RECEPTIONIST,
  },
  {
    path: '/receptionist/appointments',
    element: AppointmentManagementPage,
    title: 'Quản lý lịch hẹn',
    role: ROLES.RECEPTIONIST,
  },
  {
    path: '/receptionist/register-patient',
    element: PatientRegistrationPage,
    title: 'Đăng ký bệnh nhân',
    role: ROLES.RECEPTIONIST,
  },
  {
    path: '/receptionist/check-in',
    element: CheckInPage,
    title: 'Check-in bệnh nhân',
    role: ROLES.RECEPTIONIST,
  },
  {
    path: '/receptionist/invoices',
    element: InvoicePage,
    title: 'Quản lý hóa đơn',
    role: ROLES.RECEPTIONIST,
  },
  {
    path: '/receptionist/timeslots',
    element: TimeslotManagementPage,
    title: 'Quản lý khung giờ',
    role: ROLES.RECEPTIONIST,
  },
  {
    path: '/receptionist/daily-report',
    element: DailyReportPage,
    title: 'Báo cáo hàng ngày',
    role: ROLES.RECEPTIONIST,
  },
];

export const adminRoutes = [
  {
    path: '/admin',
    element: AdminDashboard,
    title: 'Trang quản trị',
    role: ROLES.ADMIN,
  },
  {
    path: '/admin/users',
    element: UsersPage,
    title: 'Quản lý người dùng',
    role: ROLES.ADMIN,
  },
  {
    path: '/admin/doctors',
    element: DoctorsPage,
    title: 'Quản lý bác sĩ',
    role: ROLES.ADMIN,
  },
  {
    path: '/admin/patients',
    element: PatientsPage,
    title: 'Quản lý bệnh nhân',
    role: ROLES.ADMIN,
  },
  {
    path: '/admin/medicines',
    element: MedicinesPage,
    title: 'Quản lý thuốc',
    role: ROLES.ADMIN,
  },
  {
    path: '/admin/rooms',
    element: RoomsPage,
    title: 'Quản lý phòng khám',
    role: ROLES.ADMIN,
  },
  {
    path: '/admin/schedules',
    element: SchedulesPage,
    title: 'Quản lý lịch làm việc',
    role: ROLES.ADMIN,
  },
  {
    path: '/admin/suppliers',
    element: SuppliersPage,
    title: 'Quản lý nhà cung cấp',
    role: ROLES.ADMIN,
  },
  {
    path: '/admin/reports',
    element: ReportsPage,
    title: 'Báo cáo & Thống kê',
    role: ROLES.ADMIN,
  },
  {
    path: '/admin/audit-logs',
    element: AuditLogsPage,
    title: 'Nhật ký hệ thống',
    role: ROLES.ADMIN,
  },
  {
    path: '/admin/notifications',
    element: NotificationsPage,
    title: 'Quản lý thông báo',
    role: ROLES.ADMIN,
  },
  {
    path: '/admin/settings',
    element: SettingsPage,
    title: 'Cài đặt hệ thống',
    role: ROLES.ADMIN,
  },
];

export const errorRoutes = [
  {
    path: '/unauthorized',
    element: UnauthorizedPage,
    title: 'Không có quyền truy cập',
  },
  {
    path: '*',
    element: NotFoundPage,
    title: 'Không tìm thấy trang',
  },
];

// All protected routes
export const protectedRoutes = [
  ...patientRoutes,
  ...doctorRoutes,
  ...receptionistRoutes,
  ...adminRoutes,
];

// Get routes by role
export const getRoutesByRole = (role) => {
  switch (role) {
    case ROLES.PATIENT:
      return patientRoutes;
    case ROLES.DOCTOR:
      return doctorRoutes;
    case ROLES.RECEPTIONIST:
      return receptionistRoutes;
    case ROLES.ADMIN:
      return adminRoutes;
    default:
      return [];
  }
};

// Get default path by role
export const getDefaultPathByRole = (role) => {
  switch (role) {
    case ROLES.PATIENT:
      return '/patient';
    case ROLES.DOCTOR:
      return '/doctor';
    case ROLES.RECEPTIONIST:
      return '/receptionist';
    case ROLES.ADMIN:
      return '/admin';
    default:
      return '/login';
  }
};