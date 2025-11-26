-- Seed basic test data
BEGIN;

-- Roles
INSERT INTO roles (name, description) VALUES 
('Admin', 'Administrator'),
('Doctor', 'Doctor role'),
('Receptionist', 'Reception staff'),
('Patient', 'Patient role')
ON CONFLICT (name) DO NOTHING;

-- Users & Patients
WITH user_insert AS (
  INSERT INTO users (email, full_name, role_id, password) 
  VALUES 
    ('patient1@example.test', 'Patient One', (SELECT id FROM roles WHERE name = 'Patient'), '$2a$10$dummyhash1'),
    ('patient2@example.test', 'Patient Two', (SELECT id FROM roles WHERE name = 'Patient'), '$2a$10$dummyhash2'),
    ('patient3@example.test', 'Patient Three', (SELECT id FROM roles WHERE name = 'Patient'), '$2a$10$dummyhash3')
  ON CONFLICT (email) DO NOTHING
  RETURNING id, email
)
INSERT INTO patients (user_id, full_name, phone, email, dob, address, gender, blood_type, allergies)
SELECT u.id, 
  CASE WHEN u.email = 'patient1@example.test' THEN 'Patient One'
       WHEN u.email = 'patient2@example.test' THEN 'Patient Two'
       ELSE 'Patient Three' END,
  CASE WHEN u.email = 'patient1@example.test' THEN '0901234567'
       WHEN u.email = 'patient2@example.test' THEN '0902234567'
       ELSE '0903234567' END,
  u.email,
  CASE WHEN u.email = 'patient1@example.test' THEN '1990-01-15'::DATE
       WHEN u.email = 'patient2@example.test' THEN '1992-05-20'::DATE
       ELSE '1988-03-10'::DATE END,
  '123 Nguyen Van A, District 1, HCMC',
  'M',
  'O+',
  'None'
FROM user_insert u
ON CONFLICT (user_id) DO NOTHING;

-- Doctors
WITH doc_users AS (
  INSERT INTO users (email, full_name, role_id, password) 
  VALUES 
    ('dr1@example.test', 'Dr. Nguyen Van A', (SELECT id FROM roles WHERE name = 'Doctor'), '$2a$10$dummyhash4'),
    ('dr2@example.test', 'Dr. Tran Thi B', (SELECT id FROM roles WHERE name = 'Doctor'), '$2a$10$dummyhash5'),
    ('dr3@example.test', 'Dr. Le Van C', (SELECT id FROM roles WHERE name = 'Doctor'), '$2a$10$dummyhash6')
  ON CONFLICT (email) DO NOTHING
  RETURNING id, email
)
INSERT INTO doctors (user_id, license_number, consultation_fee, rating)
SELECT u.id, 'LIC-' || u.id, 200000, 4.5
FROM doc_users u
ON CONFLICT (user_id) DO NOTHING;

-- Specialties
INSERT INTO specialties (name, slug) VALUES 
('General', 'general'),
('Cardiology', 'cardiology'),
('Dermatology', 'dermatology'),
('Pediatrics', 'pediatrics')
ON CONFLICT (slug) DO NOTHING;

-- Doctor-Specialties
WITH docs AS (
  SELECT d.id, d.user_id FROM doctors d LIMIT 3
),
specs AS (
  SELECT id, ROW_NUMBER() OVER (ORDER BY id) as rn FROM specialties LIMIT 3
)
INSERT INTO doctor_specialties (doctor_id, specialty_id)
SELECT d.id, s.id
FROM docs d 
JOIN specs s ON TRUE
LIMIT 3
ON CONFLICT (doctor_id, specialty_id) DO NOTHING;

-- Medicines
INSERT INTO medicines (name, code, price) VALUES 
('Paracetamol', 'PAR001', 10000),
('Ibuprofen', 'IBU001', 15000),
('Amoxicillin', 'AMX001', 20000)
ON CONFLICT (code) DO NOTHING;

-- Timeslots for tomorrow
WITH tomorrow AS (
  SELECT CURRENT_DATE + INTERVAL '1 day' as next_day
),
doctors_list AS (
  SELECT id FROM doctors LIMIT 3
),
hours AS (
  SELECT h FROM GENERATE_SERIES(8, 16) AS t(h)
)
INSERT INTO timeslots (doctor_id, date, start_time, end_time, max_patients, is_active)
SELECT d.id, tm.next_day, 
  MAKE_TIME(h.h, 0, 0),
  MAKE_TIME(h.h + 1, 0, 0),
  1, TRUE
FROM doctors_list d, hours h, tomorrow tm
ON CONFLICT DO NOTHING;

-- Appointments
WITH patients_list AS (
  SELECT id FROM patients LIMIT 2
),
timeslots_list AS (
  SELECT id, doctor_id, date, start_time FROM timeslots LIMIT 2
),
doctors_list AS (
  SELECT id FROM doctors LIMIT 1
)
INSERT INTO appointments (patient_id, doctor_id, timeslot_id, appointment_date, appointment_time, status, reason)
SELECT p.id, t.doctor_id, t.id, t.date, t.start_time, 'PENDING', 'Regular checkup'
FROM patients_list p, timeslots_list t, doctors_list d;

COMMIT;
