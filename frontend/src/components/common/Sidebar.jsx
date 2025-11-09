// frontend/src/components/common/Sidebar.jsx
import React, { useState } from 'react';
import { Link, useLocation } from 'react-router-dom';
import {
  LayoutDashboard,
  Calendar,
  Users,
  FileText,
  ClipboardList,
  Package,
  DollarSign,
  BarChart3,
  Settings,
  ChevronDown,
  ChevronRight,
  X,
  Stethoscope,
  UserCog,
  Building2,
  Bell,
  FileSpreadsheet,
  Activity,
  Pill,
  FlaskConical,
} from 'lucide-react';
import { useAuth } from '../../context/AuthContext';

const Sidebar = ({ isOpen, onClose, collapsed = false }) => {
  const location = useLocation();
  const { user } = useAuth();
  const [expandedMenus, setExpandedMenus] = useState([]);

  const toggleMenu = (key) => {
    setExpandedMenus(prev =>
      prev.includes(key)
        ? prev.filter(item => item !== key)
        : [...prev, key]
    );
  };

  // Menu configuration by role
  const menuConfig = {
    Patient: [
      { key: 'dashboard', label: 'Trang chủ', icon: LayoutDashboard, path: '/patient' },
      { key: 'appointments', label: 'Lịch hẹn', icon: Calendar, path: '/patient/appointments' },
      { key: 'medical-records', label: 'Hồ sơ bệnh án', icon: FileText, path: '/patient/medical-records' },
      { key: 'prescriptions', label: 'Đơn thuốc', icon: ClipboardList, path: '/patient/prescriptions' },
      { key: 'lab-results', label: 'Kết quả XN', icon: FlaskConical, path: '/patient/lab-results' },
      { key: 'invoices', label: 'Hóa đơn', icon: DollarSign, path: '/patient/invoices' },
      { key: 'symptom-checker', label: 'Kiểm tra triệu chứng', icon: Activity, path: '/patient/symptom-checker' },
      { key: 'profile', label: 'Thông tin cá nhân', icon: UserCog, path: '/patient/profile' },
    ],
    Doctor: [
      { key: 'dashboard', label: 'Trang chủ', icon: LayoutDashboard, path: '/doctor' },
      { key: 'schedule', label: 'Lịch làm việc', icon: Calendar, path: '/doctor/schedule' },
      { key: 'appointments', label: 'Lịch hẹn hôm nay', icon: Stethoscope, path: '/doctor/appointments' },
      { 
        key: 'patients', 
        label: 'Bệnh nhân', 
        icon: Users,
        children: [
          { key: 'patient-list', label: 'Danh sách', path: '/doctor/patients' },
          { key: 'medical-records', label: 'Hồ sơ bệnh án', path: '/doctor/medical-records' },
        ]
      },
      { key: 'prescriptions', label: 'Đơn thuốc', icon: ClipboardList, path: '/doctor/prescriptions' },
      { key: 'lab-orders', label: 'Chỉ định XN', icon: FlaskConical, path: '/doctor/lab-orders' },
      { key: 'ai-tools', label: 'Công cụ AI', icon: Activity, path: '/doctor/ai-tools' },
      { key: 'profile', label: 'Thông tin cá nhân', icon: UserCog, path: '/doctor/profile' },
    ],
    Receptionist: [
      { key: 'dashboard', label: 'Trang chủ', icon: LayoutDashboard, path: '/receptionist' },
      { key: 'appointments', label: 'Quản lý lịch hẹn', icon: Calendar, path: '/receptionist/appointments' },
      { key: 'register', label: 'Đăng ký BN mới', icon: Users, path: '/receptionist/register-patient' },
      { key: 'check-in', label: 'Check-in', icon: Stethoscope, path: '/receptionist/check-in' },
      { key: 'invoices', label: 'Hóa đơn', icon: DollarSign, path: '/receptionist/invoices' },
      { key: 'timeslots', label: 'Quản lý khung giờ', icon: Calendar, path: '/receptionist/timeslots' },
      { key: 'daily-report', label: 'Báo cáo hàng ngày', icon: FileSpreadsheet, path: '/receptionist/daily-report' },
    ],
    Admin: [
      { key: 'dashboard', label: 'Trang quản trị', icon: LayoutDashboard, path: '/admin' },
      {
        key: 'users',
        label: 'Quản lý người dùng',
        icon: Users,
        children: [
          { key: 'all-users', label: 'Tất cả người dùng', path: '/admin/users' },
          { key: 'doctors', label: 'Bác sĩ', path: '/admin/doctors' },
          { key: 'patients', label: 'Bệnh nhân', path: '/admin/patients' },
        ]
      },
      { key: 'appointments', label: 'Lịch hẹn', icon: Calendar, path: '/admin/appointments' },
      {
        key: 'medicines',
        label: 'Quản lý thuốc',
        icon: Pill,
        children: [
          { key: 'medicine-list', label: 'Danh sách thuốc', path: '/admin/medicines' },
          { key: 'stock', label: 'Tồn kho', path: '/admin/medicines/stock' },
          { key: 'suppliers', label: 'Nhà cung cấp', path: '/admin/suppliers' },
        ]
      },
      { key: 'rooms', label: 'Phòng khám', icon: Building2, path: '/admin/rooms' },
      { key: 'schedules', label: 'Lịch làm việc', icon: Calendar, path: '/admin/schedules' },
      { key: 'reports', label: 'Báo cáo & Thống kê', icon: BarChart3, path: '/admin/reports' },
      { key: 'audit-logs', label: 'Nhật ký hệ thống', icon: FileText, path: '/admin/audit-logs' },
      { key: 'notifications', label: 'Thông báo', icon: Bell, path: '/admin/notifications' },
      { key: 'settings', label: 'Cài đặt', icon: Settings, path: '/admin/settings' },
    ],
  };

  const menus = menuConfig[user?.role?.name] || [];

  const isActive = (path) => {
    return location.pathname === path;
  };

  const isParentActive = (children) => {
    return children?.some(child => location.pathname === child.path);
  };

  const renderMenuItem = (item) => {
    const hasChildren = item.children && item.children.length > 0;
    const isExpanded = expandedMenus.includes(item.key);
    const active = isActive(item.path) || isParentActive(item.children);

    if (hasChildren) {
      return (
        <div key={item.key}>
          <button
            onClick={() => toggleMenu(item.key)}
            className={`
              w-full flex items-center justify-between px-4 py-2.5 text-sm font-medium rounded-lg transition-all
              ${active 
                ? 'bg-blue-50 text-blue-600' 
                : 'text-gray-700 hover:bg-gray-100'
              }
            `}
          >
            <div className="flex items-center gap-3">
              <item.icon size={20} />
              {!collapsed && <span>{item.label}</span>}
            </div>
            {!collapsed && (
              isExpanded ? <ChevronDown size={16} /> : <ChevronRight size={16} />
            )}
          </button>

          {!collapsed && isExpanded && (
            <div className="ml-4 mt-1 space-y-1">
              {item.children.map(child => (
                <Link
                  key={child.key}
                  to={child.path}
                  className={`
                    flex items-center gap-3 px-4 py-2 text-sm rounded-lg transition-all
                    ${isActive(child.path)
                      ? 'bg-blue-50 text-blue-600 font-medium'
                      : 'text-gray-600 hover:bg-gray-100'
                    }
                  `}
                >
                  <div className="w-5" />
                  <span>{child.label}</span>
                </Link>
              ))}
            </div>
          )}
        </div>
      );
    }

    return (
      <Link
        key={item.key}
        to={item.path}
        className={`
          flex items-center gap-3 px-4 py-2.5 text-sm font-medium rounded-lg transition-all
          ${active
            ? 'bg-blue-50 text-blue-600'
            : 'text-gray-700 hover:bg-gray-100'
          }
        `}
        title={collapsed ? item.label : ''}
      >
        <item.icon size={20} />
        {!collapsed && <span>{item.label}</span>}
      </Link>
    );
  };

  const sidebarContent = (
    <>
      {/* Logo */}
      <div className="flex items-center justify-between px-4 py-4 border-b border-gray-200">
        {!collapsed && (
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-sm">CMS</span>
            </div>
            <span className="text-lg font-semibold text-gray-900">
              Clinic MS
            </span>
          </div>
        )}
        <button
          onClick={onClose}
          className="lg:hidden p-1 text-gray-500 hover:text-gray-700"
        >
          <X size={20} />
        </button>
      </div>

      {/* User info */}
      {!collapsed && (
        <div className="px-4 py-4 border-b border-gray-200">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gradient-to-br from-blue-500 to-blue-600 rounded-full flex items-center justify-center text-white font-semibold">
              {user?.full_name?.charAt(0)}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-gray-900 truncate">
                {user?.full_name}
              </p>
              <p className="text-xs text-gray-500 truncate">
                {user?.role?.name}
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Navigation */}
      <nav className="flex-1 px-3 py-4 space-y-1 overflow-y-auto">
        {menus.map(item => renderMenuItem(item))}
      </nav>

      {/* Footer */}
      {!collapsed && (
        <div className="px-4 py-4 border-t border-gray-200">
          <p className="text-xs text-gray-500 text-center">
            © 2025 Clinic Management
          </p>
        </div>
      )}
    </>
  );

  return (
    <>
      {/* Mobile overlay */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`
          fixed lg:sticky top-0 left-0 z-50 h-screen
          bg-white border-r border-gray-200 flex flex-col
          transition-all duration-300 ease-in-out
          ${collapsed ? 'w-20' : 'w-64'}
          ${isOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
        `}
      >
        {sidebarContent}
      </aside>
    </>
  );
};

export default Sidebar;