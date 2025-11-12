# Clinic Management System - Backend API

Backend API cho hệ thống quản lý phòng khám đa khoa tư nhân.

## Tính năng

- ✅ Quản lý bệnh nhân, bác sĩ, lịch hẹn
- ✅ Quản lý bệnh án, đơn thuốc, xét nghiệm
- ✅ Tích hợp AI (Symptom Checker, Risk Prediction)
- ✅ Phân quyền đa cấp (Admin, Doctor, Receptionist, Patient...)
- ✅ Thông báo real-time
- ✅ Báo cáo thống kê

## Cài đặt

1. Clone repository
2. Cài đặt dependencies: npm install
3. Copy .env.example thành .env và cấu hình
4. Chạy database: docker-compose up -d postgres
5. Import schema: psql -U postgres -d clinic_db -f test.sql
6. Generate Prisma Client: npm run prisma:generate
7. Chạy server: npm run dev

## API Documentation

Server chạy tại: http://localhost:3000
API docs: http://localhost:3000/api-docs

## License

MIT