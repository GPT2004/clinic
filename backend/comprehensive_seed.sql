-- Comprehensive seed data for all tables
BEGIN;

-- ===== ROLES ===== (Already have basic roles)
-- Admin, Doctor, Receptionist, Patient, Pharmacist already exist

-- ===== USERS ===== (Add more users if needed)
-- Basic users already exist from previous seed

-- ===== DOCTORS ===== (Add more doctor details)
UPDATE doctors SET
  specialties = ARRAY['Cardiology', 'Internal Medicine'],
  bio = 'Experienced cardiologist with 10+ years in patient care',
  gender = 'MALE',
  address = '123 Nguyen Trai, District 1, HCMC'
WHERE user_id = (SELECT id FROM users WHERE email = 'dr1@example.test');

UPDATE doctors SET
  specialties = ARRAY['Dermatology', 'Cosmetic Surgery'],
  bio = 'Dermatologist specializing in skin conditions and cosmetic procedures',
  gender = 'FEMALE',
  address = '456 Le Loi, District 3, HCMC'
WHERE user_id = (SELECT id FROM users WHERE email = 'dr2@example.test');

UPDATE doctors SET
  specialties = ARRAY['General Medicine', 'Family Medicine'],
  bio = 'General practitioner providing comprehensive healthcare',
  gender = 'MALE',
  address = '789 Tran Hung Dao, District 5, HCMC'
WHERE user_id = (SELECT id FROM users WHERE email = 'dr3@example.test');

UPDATE doctors SET
  specialties = ARRAY['Pediatrics', 'Child Health'],
  bio = 'Pediatrician dedicated to children''s health and development',
  gender = 'FEMALE',
  address = '321 Vo Van Kiet, District 6, HCMC'
WHERE user_id = (SELECT id FROM users WHERE email = 'dr4@example.test');

-- ===== SPECIALTIES ===== (Already have basic specialties)
-- General, Cardiology, Dermatology, Pediatrics already exist

-- ===== DOCTOR-SPECIALTIES ===== (Already linked)

-- ===== PATIENTS ===== (Update with more details)
UPDATE patients SET
  address = '123 Nguyen Van A, District 1, HCMC',
  gender = 'MALE',
  blood_type = 'O+',
  allergies = 'None',
  emergency_contact = '{"name": "Jane Doe", "phone": "0901234567", "relationship": "Sister"}'::jsonb
WHERE user_id = (SELECT id FROM users WHERE email = 'patient1@example.test');

UPDATE patients SET
  address = '456 Tran Phu, District 7, HCMC',
  gender = 'FEMALE',
  blood_type = 'A+',
  allergies = 'Penicillin',
  emergency_contact = '{"name": "John Smith", "phone": "0902234567", "relationship": "Husband"}'::jsonb
WHERE user_id = (SELECT id FROM users WHERE email = 'patient2@example.test');

UPDATE patients SET
  address = '789 Le Van Sy, District 3, HCMC',
  gender = 'MALE',
  blood_type = 'B+',
  allergies = 'None',
  emergency_contact = '{"name": "Mary Johnson", "phone": "0903234567", "relationship": "Wife"}'::jsonb
WHERE user_id = (SELECT id FROM users WHERE email = 'patient3@example.test');

UPDATE patients SET
  address = '321 Nguyen Thi Minh Khai, District 1, HCMC',
  gender = 'FEMALE',
  blood_type = 'AB+',
  allergies = 'Shellfish',
  emergency_contact = '{"name": "Bob Wilson", "phone": "0904234567", "relationship": "Father"}'::jsonb
WHERE user_id = (SELECT id FROM users WHERE email = 'patient4@example.test');

-- ===== ROOMS =====
INSERT INTO rooms (name, type, capacity, is_active) VALUES
('Room 101', 'Consultation', 1, true),
('Room 102', 'Consultation', 1, true),
('Room 201', 'Examination', 1, true),
('Room 202', 'Examination', 1, true),
('Lab Room', 'Laboratory', 5, true),
('Pharmacy', 'Pharmacy', 2, true)
ON CONFLICT (name) DO NOTHING;

-- ===== SCHEDULES =====
INSERT INTO schedules (doctor_id, room_id, date, start_time, end_time, is_active)
SELECT
  d.id,
  r.id,
  CURRENT_DATE + INTERVAL '1 day',
  '08:00:00'::time,
  '17:00:00'::time,
  true
FROM doctors d
CROSS JOIN rooms r
WHERE r.type = 'Consultation'
LIMIT 4
ON CONFLICT DO NOTHING;

-- ===== TIMESLOTS ===== (Already have timeslots for tomorrow)

-- ===== APPOINTMENTS ===== (Already have appointments)

-- ===== MEDICAL_RECORDS ===== (Add some sample medical records)
INSERT INTO medical_records (appointment_id, patient_id, doctor_id, diagnosis, notes, exam_results, attachments, created_at, updated_at)
SELECT
  a.id,
  a.patient_id,
  a.doctor_id,
  CASE
    WHEN a.patient_id = 31 THEN 'Hypertension - Stage 1'
    WHEN a.patient_id = 32 THEN 'Acute Upper Respiratory Infection'
    ELSE 'Regular Health Checkup'
  END,
  CASE
    WHEN a.patient_id = 31 THEN 'Patient reports occasional headaches. BP readings elevated. Prescribed medication and lifestyle changes.'
    WHEN a.patient_id = 32 THEN 'Patient presents with cough, sore throat, and mild fever. Prescribed antibiotics and rest.'
    ELSE 'Routine examination shows patient in good health. Recommended annual checkup.'
  END,
  CASE
    WHEN a.patient_id = 31 THEN 'Blood Pressure: 145/92 mmHg, Heart Rate: 78 bpm, Weight: 75.5 kg, Height: 170 cm'
    WHEN a.patient_id = 32 THEN 'Temperature: 38.2°C, Blood Pressure: 120/80 mmHg, Oxygen Saturation: 98%'
    ELSE 'Blood Pressure: 118/76 mmHg, Heart Rate: 72 bpm, Temperature: 36.8°C'
  END,
  '[]'::jsonb,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
FROM appointments a
WHERE a.status = 'CHECKED_IN'
ON CONFLICT DO NOTHING;

-- ===== MEDICINES ===== (Already have basic medicines)
-- Paracetamol, Ibuprofen, Amoxicillin already exist

-- ===== STOCKS ===== (Add stock for medicines)
INSERT INTO stocks (medicine_id, batch_number, quantity, expiry_date, purchase_price, selling_price, supplier_id, created_at)
SELECT
  m.id,
  'BATCH-' || m.id || '-001',
  CASE m.name
    WHEN 'Paracetamol' THEN 500
    WHEN 'Ibuprofen' THEN 300
    WHEN 'Amoxicillin' THEN 200
    ELSE 100
  END,
  CURRENT_DATE + INTERVAL '1 year',
  CASE m.name
    WHEN 'Paracetamol' THEN 5000
    WHEN 'Ibuprofen' THEN 7500
    WHEN 'Amoxicillin' THEN 10000
    ELSE 5000
  END,
  m.price,
  NULL,
  CURRENT_TIMESTAMP
FROM medicines m
ON CONFLICT (medicine_id, batch_number) DO NOTHING;

-- ===== PRESCRIPTIONS ===== (Add prescriptions linked to medical records)
INSERT INTO prescriptions (appointment_id, medical_record_id, doctor_id, patient_id, items, total_amount, status, created_at, updated_at)
SELECT
  mr.appointment_id,
  mr.id,
  mr.doctor_id,
  mr.patient_id,
  CASE
    WHEN mr.diagnosis LIKE '%Hypertension%' THEN
      '[{"medicine_id": 1, "medicine_name": "Paracetamol", "quantity": 20, "unit_price": 10000, "instructions": "Take 2 tablets every 6 hours as needed for pain", "dosage": "500mg"}, {"medicine_id": 2, "medicine_name": "Ibuprofen", "quantity": 15, "unit_price": 15000, "instructions": "Take 1 tablet every 8 hours for inflammation", "dosage": "400mg"}]'
    WHEN mr.diagnosis LIKE '%Respiratory%' THEN
      '[{"medicine_id": 3, "medicine_name": "Amoxicillin", "quantity": 14, "unit_price": 20000, "instructions": "Take 1 capsule every 8 hours for 7 days", "dosage": "500mg"}]'
    ELSE
      '[{"medicine_id": 1, "medicine_name": "Paracetamol", "quantity": 10, "unit_price": 10000, "instructions": "Take 1-2 tablets every 4-6 hours as needed", "dosage": "500mg"}]'
  END::jsonb,
  CASE
    WHEN mr.diagnosis LIKE '%Hypertension%' THEN 550000
    WHEN mr.diagnosis LIKE '%Respiratory%' THEN 280000
    ELSE 100000
  END,
  'PENDING',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
FROM medical_records mr
ON CONFLICT DO NOTHING;

-- ===== SUPPLIERS =====
INSERT INTO suppliers (name, contact_info, created_at)
VALUES
('MedPharm Corp', '{"person": "Mr. Nguyen", "phone": "028-12345678", "email": "contact@medpharm.vn", "address": "123 Industrial Zone, HCMC"}'::jsonb, CURRENT_TIMESTAMP),
('HealthCare Supplies', '{"person": "Ms. Tran", "phone": "028-87654321", "email": "sales@healthcare.vn", "address": "456 Business District, HCMC"}'::jsonb, CURRENT_TIMESTAMP)
ON CONFLICT (name) DO NOTHING;

-- ===== INVOICES ===== (Add invoices for prescriptions)
INSERT INTO invoices (appointment_id, patient_id, prescription_id, items, total, status, paid_at, created_at)
SELECT
  p.appointment_id,
  p.patient_id,
  p.id,
  p.items,
  p.total_amount,
  CASE WHEN p.status = 'DISPENSED' THEN 'PAID'::invoice_status ELSE 'UNPAID'::invoice_status END,
  CASE WHEN p.status = 'DISPENSED' THEN CURRENT_TIMESTAMP ELSE NULL END,
  CURRENT_TIMESTAMP
FROM prescriptions p
ON CONFLICT DO NOTHING;

-- ===== LAB_ORDERS ===== (Add lab orders for some appointments)
INSERT INTO lab_orders (appointment_id, medical_record_id, patient_id, doctor_id, tests, status, priority, notes, created_at, updated_at)
SELECT
  mr.appointment_id,
  mr.id,
  mr.patient_id,
  mr.doctor_id,
  CASE
    WHEN mr.diagnosis LIKE '%Hypertension%' THEN
      '[{"test_code": "CBC", "name": "Complete Blood Count", "price": 150000}, {"test_code": "LIPID", "name": "Lipid Profile", "price": 200000}, {"test_code": "ECG", "name": "Electrocardiogram", "price": 100000}]'
    WHEN mr.diagnosis LIKE '%Respiratory%' THEN
      '[{"test_code": "CBC", "name": "Complete Blood Count", "price": 150000}, {"test_code": "CHEST_XRAY", "name": "Chest X-Ray", "price": 180000}]'
    ELSE
      '[{"test_code": "CBC", "name": "Complete Blood Count", "price": 150000}]'
  END::jsonb,
  'PENDING',
  'NORMAL',
  CASE
    WHEN mr.diagnosis LIKE '%Hypertension%' THEN 'Monitor cardiovascular health'
    WHEN mr.diagnosis LIKE '%Respiratory%' THEN 'Confirm infection and monitor progress'
    ELSE 'Routine health screening'
  END,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
FROM medical_records mr
WHERE mr.id IN (SELECT id FROM medical_records LIMIT 2)
ON CONFLICT DO NOTHING;

-- ===== NOTIFICATIONS ===== (Add some notifications)
INSERT INTO notifications (user_id, type, payload, is_read, created_at)
SELECT
  u.id,
  'INFO',
  CASE
    WHEN u.email LIKE '%dr%' THEN '{"title": "New Appointment Scheduled", "message": "You have a new appointment scheduled for tomorrow"}'::jsonb
    WHEN u.email LIKE '%patient%' THEN '{"title": "Appointment Reminder", "message": "Your appointment is confirmed for tomorrow at 9:00 AM"}'::jsonb
    ELSE '{"title": "System Notification", "message": "Welcome to the clinic management system"}'::jsonb
  END,
  false,
  CURRENT_TIMESTAMP
FROM users u
WHERE u.email LIKE '%@example.%'
ON CONFLICT DO NOTHING;

-- ===== AUDIT_LOGS ===== (Add some audit logs)
INSERT INTO audit_logs (user_id, action, meta, created_at)
SELECT
  u.id,
  CASE
    WHEN u.email LIKE '%dr%' THEN 'LOGIN'
    WHEN u.email LIKE '%patient%' THEN 'VIEW_APPOINTMENT'
    ELSE 'CREATE_PRESCRIPTION'
  END,
  CASE
    WHEN u.email LIKE '%dr%' THEN '{"ip": "192.168.1.100", "user_agent": "Chrome/91.0"}'
    WHEN u.email LIKE '%patient%' THEN '{"appointment_id": 1}'
    ELSE '{"prescription_id": 1}'
  END::jsonb,
  CURRENT_TIMESTAMP
FROM users u
WHERE u.email LIKE '%@example.%'
LIMIT 5
ON CONFLICT DO NOTHING;

-- ===== DOCTOR_REVIEWS ===== (Add some reviews)
INSERT INTO doctor_reviews (doctor_id, patient_id, rating, comment, created_at, updated_at)
SELECT
  d.id,
  p.id,
  CASE
    WHEN p.user_id % 5 = 0 THEN 5
    WHEN p.user_id % 5 = 1 THEN 4
    WHEN p.user_id % 5 = 2 THEN 5
    WHEN p.user_id % 5 = 3 THEN 3
    ELSE 4
  END,
  CASE
    WHEN p.user_id % 5 = 0 THEN 'Excellent doctor, very professional and caring'
    WHEN p.user_id % 5 = 1 THEN 'Good experience, doctor was knowledgeable'
    WHEN p.user_id % 5 = 2 THEN 'Highly recommend, great bedside manner'
    WHEN p.user_id % 5 = 3 THEN 'Satisfactory service'
    ELSE 'Very helpful and attentive'
  END,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
FROM doctors d
CROSS JOIN patients p
LIMIT 8
ON CONFLICT DO NOTHING;

COMMIT;

-- Summary of added data
SELECT
  'Roles' as table_name, COUNT(*) as count FROM roles
UNION ALL
SELECT 'Users', COUNT(*) FROM users
UNION ALL
SELECT 'Doctors', COUNT(*) FROM doctors
UNION ALL
SELECT 'Patients', COUNT(*) FROM patients
UNION ALL
SELECT 'Rooms', COUNT(*) FROM rooms
UNION ALL
SELECT 'Schedules', COUNT(*) FROM schedules
UNION ALL
SELECT 'Timeslots', COUNT(*) FROM timeslots
UNION ALL
SELECT 'Appointments', COUNT(*) FROM appointments
UNION ALL
SELECT 'Medical Records', COUNT(*) FROM medical_records
UNION ALL
SELECT 'Medicines', COUNT(*) FROM medicines
UNION ALL
SELECT 'Stocks', COUNT(*) FROM stocks
UNION ALL
SELECT 'Prescriptions', COUNT(*) FROM prescriptions
UNION ALL
SELECT 'Suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'Invoices', COUNT(*) FROM invoices
UNION ALL
SELECT 'Lab Orders', COUNT(*) FROM lab_orders
UNION ALL
SELECT 'Notifications', COUNT(*) FROM notifications
UNION ALL
SELECT 'Audit Logs', COUNT(*) FROM audit_logs
UNION ALL
SELECT 'Doctor Reviews', COUNT(*) FROM doctor_reviews;