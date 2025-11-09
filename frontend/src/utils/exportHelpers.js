import * as XLSX from 'xlsx';
import { saveAs } from 'file-saver';
import { formatDate, formatCurrency } from './helpers';

/**
 * Export data to Excel
 */
export const exportToExcel = (data, filename = 'export.xlsx', sheetName = 'Sheet1') => {
  try {
    const worksheet = XLSX.utils.json_to_sheet(data);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, sheetName);
    
    const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' });
    const blob = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
    
    saveAs(blob, filename);
    return true;
  } catch (error) {
    console.error('Error exporting to Excel:', error);
    return false;
  }
};

/**
 * Export data to CSV
 */
export const exportToCSV = (data, filename = 'export.csv') => {
  try {
    const worksheet = XLSX.utils.json_to_sheet(data);
    const csv = XLSX.utils.sheet_to_csv(worksheet);
    
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    saveAs(blob, filename);
    return true;
  } catch (error) {
    console.error('Error exporting to CSV:', error);
    return false;
  }
};

/**
 * Export table to Excel
 */
export const exportTableToExcel = (tableId, filename = 'table.xlsx') => {
  try {
    const table = document.getElementById(tableId);
    if (!table) {
      console.error('Table not found');
      return false;
    }
    
    const worksheet = XLSX.utils.table_to_sheet(table);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, 'Sheet1');
    
    const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' });
    const blob = new Blob([excelBuffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
    
    saveAs(blob, filename);
    return true;
  } catch (error) {
    console.error('Error exporting table to Excel:', error);
    return false;
  }
};

/**
 * Format appointments data for export
 */
export const formatAppointmentsForExport = (appointments) => {
  return appointments.map(app => ({
    'Mã lịch hẹn': app.id,
    'Bệnh nhân': app.patient?.user?.full_name || '',
    'Bác sĩ': app.doctor?.user?.full_name || '',
    'Ngày khám': formatDate(app.appointment_date),
    'Giờ khám': app.appointment_time,
    'Lý do': app.reason || '',
    'Trạng thái': app.status,
    'Nguồn': app.source,
  }));
};

/**
 * Format patients data for export
 */
export const formatPatientsForExport = (patients) => {
  return patients.map(patient => ({
    'Mã BN': patient.id,
    'Họ tên': patient.user?.full_name || '',
    'Giới tính': patient.gender || '',
    'Ngày sinh': formatDate(patient.user?.dob),
    'Điện thoại': patient.user?.phone || '',
    'Email': patient.user?.email || '',
    'Nhóm máu': patient.blood_type || '',
    'Dị ứng': patient.allergies || '',
  }));
};

/**
 * Format invoices data for export
 */
export const formatInvoicesForExport = (invoices) => {
  return invoices.map(invoice => ({
    'Mã HĐ': invoice.id,
    'Bệnh nhân': invoice.patient?.user?.full_name || '',
    'Ngày tạo': formatDate(invoice.created_at),
    'Tổng phụ': formatCurrency(invoice.subtotal),
    'Thuế': formatCurrency(invoice.tax),
    'Giảm giá': formatCurrency(invoice.discount),
    'Tổng cộng': formatCurrency(invoice.total),
    'Trạng thái': invoice.status,
    'Ngày thanh toán': invoice.paid_at ? formatDate(invoice.paid_at) : '',
  }));
};

/**
 * Format prescriptions data for export
 */
export const formatPrescriptionsForExport = (prescriptions) => {
  return prescriptions.map(prescription => ({
    'Mã đơn': prescription.id,
    'Bệnh nhân': prescription.patient?.user?.full_name || '',
    'Bác sĩ': prescription.doctor?.user?.full_name || '',
    'Ngày kê': formatDate(prescription.created_at),
    'Tổng tiền': formatCurrency(prescription.total_amount),
    'Trạng thái': prescription.status,
  }));
};

/**
 * Format medical records data for export
 */
export const formatMedicalRecordsForExport = (records) => {
  return records.map(record => ({
    'Mã BA': record.id,
    'Bệnh nhân': record.patient?.user?.full_name || '',
    'Bác sĩ': record.doctor?.user?.full_name || '',
    'Ngày khám': formatDate(record.created_at),
    'Chẩn đoán': record.diagnosis || '',
    'Ghi chú': record.notes || '',
  }));
};

/**
 * Format medicines data for export
 */
export const formatMedicinesForExport = (medicines) => {
  return medicines.map(medicine => ({
    'Mã thuốc': medicine.code || '',
    'Tên thuốc': medicine.name,
    'Đơn vị': medicine.unit,
    'Giá': formatCurrency(medicine.price),
    'Tồn kho': medicine.total_stock || 0,
  }));
};