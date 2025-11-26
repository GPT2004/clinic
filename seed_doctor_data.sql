-- ================================================================
-- Seed data for doctor@example.com with appointments and schedules
-- ================================================================

-- 1. Create user doctor@example.com if not exists
INSERT INTO users (email, password, full_name, phone, role_id, is_active)
SELECT 
  'doctor@example.com',
  '$2b$12$7DJh87RcG3x/wHJMP6Baqes54G6xteskbF/JvuKotfH/J.3sTgJiW', -- doctor123
  'Dr. John Smith',
  '+1234567890',
  r.id,
  true
FROM roles r
WHERE r.name = 'Doctor'
  AND NOT EXISTS (SELECT 1 FROM users WHERE email = 'doctor@example.com')
ON CONFLICT (email) DO NOTHING;

-- 2. Create doctor profile if not exists
INSERT INTO doctors (user_id, license_number, specialties, bio, consultation_fee, rating)
SELECT 
  u.id,
  'LIC-2024-001',
  ARRAY['Cardiology', 'Internal Medicine'],
  'Experienced cardiologist with 10+ years of practice',
  500000,
  4.8
FROM users u
WHERE u.email = 'doctor@example.com'
  AND NOT EXISTS (SELECT 1 FROM doctors WHERE user_id = u.id);

-- 3. Create work schedules for this week
INSERT INTO schedules (doctor_id, room_id, date, start_time, end_time, created_at)
SELECT 
  d.id,
  (SELECT id FROM rooms LIMIT 1), -- Use first available room
  current_date + (i || ' days')::interval,
  '08:00:00'::time,
  '17:00:00'::time,
  now()
FROM doctors d
JOIN users u ON d.user_id = u.id
CROSS JOIN generate_series(0, 4) AS t(i)
WHERE u.email = 'doctor@example.com'
  AND NOT EXISTS (
    SELECT 1 FROM schedules 
    WHERE doctor_id = d.id 
      AND date >= current_date
  );

-- 4. Create timeslots for today and tomorrow (20-min slots)
WITH doc AS (
  SELECT d.id as doctor_id
  FROM doctors d
  JOIN users u ON d.user_id = u.id
  WHERE u.email = 'doctor@example.com'
)
INSERT INTO timeslots (doctor_id, date, start_time, end_time, max_patients, booked_count, is_active)
SELECT 
  doctor_id,
  current_date + (day_offset || ' days')::interval,
  (start_hour || ':' || start_min || ':00')::time,
  (end_hour || ':' || end_min || ':00')::time,
  1,
  0,
  true
FROM doc
CROSS JOIN generate_series(0, 1) AS t1(day_offset)
CROSS JOIN generate_series(8, 16) AS t2(start_hour)
CROSS JOIN generate_series(0, 40, 20) AS t3(start_min)
CROSS JOIN LATERAL (
  SELECT 
    start_hour + (start_min + 20) / 60 AS end_hour,
    (start_min + 20) % 60 AS end_min
) AS calc
WHERE start_min < 60
  AND NOT EXISTS (
    SELECT 1 FROM timeslots
    WHERE doctor_id = doc.doctor_id
      AND date = current_date + (day_offset || ' days')::interval
  );

-- 5. Create patient if not exists for testing
INSERT INTO users (email, password, full_name, phone, role_id, is_active)
SELECT 
  'patient@example.com',
  '$2b$12$RI6fCs/UQm4MiweuUlBpOelXmiY0CPR2miKS2WEADFYdsv9naoRTa', -- patient123
  'Jane Doe',
  '+0987654321',
  r.id,
  true
FROM roles r
WHERE r.name = 'Patient'
  AND NOT EXISTS (SELECT 1 FROM users WHERE email = 'patient@example.com')
ON CONFLICT (email) DO NOTHING;

-- 6. Create patient profile if not exists
INSERT INTO patients (user_id, gender, blood_type, allergies)
SELECT 
  u.id,
  'Female',
  'A+',
  'Penicillin, Sulfonamides'
FROM users u
WHERE u.email = 'patient@example.com'
  AND NOT EXISTS (SELECT 1 FROM patients WHERE user_id = u.id);

-- 7. Create appointments for today and tomorrow
WITH doc AS (
  SELECT d.id as doctor_id
  FROM doctors d
  JOIN users u ON d.user_id = u.id
  WHERE u.email = 'doctor@example.com'
),
pat AS (
  SELECT p.id as patient_id
  FROM patients p
  JOIN users u ON p.user_id = u.id
  WHERE u.email = 'patient@example.com'
),
slots AS (
  SELECT t.id as timeslot_id, t.date, t.start_time, t.doctor_id
  FROM timeslots t
  WHERE t.doctor_id = (SELECT doctor_id FROM doc)
    AND t.date IN (current_date, current_date + '1 day'::interval)
  LIMIT 6
)
INSERT INTO appointments (patient_id, doctor_id, timeslot_id, appointment_date, appointment_time, status, reason, source, created_by)
SELECT 
  pat.patient_id,
  slots.doctor_id,
  slots.timeslot_id,
  slots.date,
  slots.start_time,
  CASE 
    WHEN slots.date = current_date AND slots.start_time < current_time THEN 'COMPLETED'::appointment_status
    WHEN slots.date = current_date THEN 'CONFIRMED'::appointment_status
    ELSE 'PENDING'::appointment_status
  END,
  'General checkup and consultation',
  'web',
  (SELECT id FROM users WHERE email = 'doctor@example.com' LIMIT 1)
FROM pat, slots, doc
WHERE NOT EXISTS (
  SELECT 1 FROM appointments 
  WHERE timeslot_id = slots.timeslot_id
);

-- 8. Update timeslots booked_count
UPDATE timeslots t
SET booked_count = COALESCE(sub.cnt, 0)
FROM (
  SELECT timeslot_id, COUNT(*) AS cnt
  FROM appointments
  WHERE timeslot_id IS NOT NULL
  GROUP BY timeslot_id
) sub
WHERE t.id = sub.timeslot_id;

-- 9. Create invoices for completed appointments (for revenue calculation)
INSERT INTO invoices (appointment_id, patient_id, items, subtotal, tax, discount, total, status, paid_at)
SELECT 
  a.id,
  a.patient_id,
  '[{"service": "Consultation", "amount": 500000}]'::jsonb,
  500000,
  50000,
  0,
  550000,
  'PAID',
  now()
FROM appointments a
WHERE a.status = 'COMPLETED'
  AND a.doctor_id = (SELECT d.id FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.email = 'doctor@example.com')
  AND NOT EXISTS (SELECT 1 FROM invoices WHERE appointment_id = a.id);

-- Done
SELECT 'Sample data seeded successfully for doctor@example.com' AS message;
SELECT COUNT(*) as total_appointments FROM appointments 
WHERE doctor_id = (SELECT d.id FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.email = 'doctor@example.com');
SELECT COUNT(*) as total_schedules FROM schedules 
WHERE doctor_id = (SELECT d.id FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.email = 'doctor@example.com');
SELECT COUNT(*) as total_timeslots FROM timeslots 
WHERE doctor_id = (SELECT d.id FROM doctors d JOIN users u ON d.user_id = u.id WHERE u.email = 'doctor@example.com');

-- ================================================================
-- Add seven specialties and create one doctor for each specialty
-- General Medicine, Cardiology, Gastroenterology, Endocrinology,
-- Dermatology, ENT, Pulmonology
-- ================================================================

DO $$
DECLARE
  spec_record RECORD;
  role_doctor_id INT;
BEGIN
  -- ensure Doctor role id
  SELECT id INTO role_doctor_id FROM roles WHERE lower(name) = 'doctor' LIMIT 1;
  IF role_doctor_id IS NULL THEN
    RAISE NOTICE 'Doctor role not found; skipping specialty seeding';
    RETURN;
  END IF;

  -- array of specialties and sample doctors
  FOR spec_record IN SELECT * FROM (VALUES
    ('General Medicine','general.med@example.com','Dr. Nguyen Van A','LIC-GEN-001'),
    ('Cardiology','cardio@example.com','Dr. Tran Thi B','LIC-CARD-002'),
    ('Gastroenterology','gastro@example.com','Dr. Le Van C','LIC-GAST-003'),
    ('Endocrinology','endo@example.com','Dr. Pham Thi D','LIC-ENDO-004'),
    ('Dermatology','derma@example.com','Dr. Hoang Van E','LIC-DERM-005'),
    ('ENT','ent@example.com','Dr. Bui Thi F','LIC-ENT-006'),
    ('Pulmonology','pulmo@example.com','Dr. Dao Van G','LIC-PULM-007')
  ) AS t(specialty, email, fullname, license)
  LOOP
    -- create user if not exists
    INSERT INTO users (email, password, full_name, phone, role_id, is_active)
    SELECT
      spec_record.email,
      '$2b$12$7DJh87RcG3x/wHJMP6Baqes54G6xteskbF/JvuKotfH/J.3sTgJiW', -- doctor123 (same hashed pw as sample)
      spec_record.fullname,
      '+84000000000',
      role_doctor_id,
      true
    WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = spec_record.email)
    ON CONFLICT (email) DO NOTHING;

    -- create doctor profile with specialty (string array)
    INSERT INTO doctors (user_id, license_number, specialties, bio, consultation_fee, rating)
    SELECT
      u.id,
      spec_record.license,
      ARRAY[spec_record.specialty],
      'Experienced specialist in ' || spec_record.specialty,
      CASE WHEN spec_record.specialty ILIKE '%cardio%' THEN 700000
           WHEN spec_record.specialty ILIKE '%pulm%' THEN 600000
           ELSE 500000 END,
      4.5
    FROM users u
    WHERE u.email = spec_record.email
      AND NOT EXISTS (SELECT 1 FROM doctors WHERE user_id = u.id);

    -- optional: create a couple of timeslots for the new doctor for today
    INSERT INTO schedules (doctor_id, room_id, date, start_time, end_time, created_at)
    SELECT d.id, (SELECT id FROM rooms LIMIT 1), current_date, '09:00:00'::time, '12:00:00'::time, now()
    FROM doctors d
    JOIN users u ON d.user_id = u.id
    WHERE u.email = spec_record.email
      AND NOT EXISTS (SELECT 1 FROM schedules s WHERE s.doctor_id = d.id AND s.date = current_date);

  END LOOP;
END$$;

-- Report the seeded specialties and doctors
SELECT 'Seeded specialties and doctors:' as info;
SELECT d.id, u.email, u.full_name, d.specialties
FROM doctors d
JOIN users u ON d.user_id = u.id
WHERE (
  lower(d.specialties) LIKE '%general medicine%' OR
  lower(d.specialties) LIKE '%cardiology%' OR
  lower(d.specialties) LIKE '%gastroenterology%' OR
  lower(d.specialties) LIKE '%endocrinology%' OR
  lower(d.specialties) LIKE '%dermatology%' OR
  lower(d.specialties) LIKE '%ent%' OR
  lower(d.specialties) LIKE '%pulmonology%'
);

-- ================================================================
-- If you migrated to a dedicated `specialties` table, insert specialties
-- and link existing doctors via the join table `doctor_specialties`.
-- This block is safe to run after applying Prisma migration that creates
-- `specialties` and `doctor_specialties` tables.
-- ================================================================

DO $$
DECLARE
  rec RECORD;
  sid INT;
  did INT;
BEGIN
  -- list of specialties to ensure exist
  FOR rec IN SELECT * FROM (VALUES
    ('General Medicine','nội tổng quát'),
    ('Cardiology','Tim mạch'),
    ('Gastroenterology','Tiêu hóa'),
    ('Endocrinology','Nội tiết'),
    ('Dermatology','Da liễu'),
    ('ENT','Tai Mũi Họng'),
    ('Pulmonology','Hô hấp')
  ) AS t(name, vn)
  LOOP
    -- insert specialty if not exists
    INSERT INTO specialties (name, slug, description)
    SELECT rec.name, lower(regexp_replace(rec.name, '\\s+', '-', 'g')), rec.vn
    WHERE NOT EXISTS (SELECT 1 FROM specialties WHERE name = rec.name);

    -- get id
    SELECT id INTO sid FROM specialties WHERE name = rec.name LIMIT 1;

    -- Example linking: find doctors who have this specialty in their existing specialties array
    -- doctors.specialties in `test.sql` is stored as TEXT (comma-separated),
    -- so match by substring (case-insensitive) rather than array operator.
    FOR did IN SELECT id FROM doctors WHERE specialties IS NOT NULL AND specialties ILIKE '%' || rec.name || '%'
    LOOP
      -- create link if not exists
      INSERT INTO doctor_specialties (doctor_id, specialty_id)
      SELECT did, sid
      WHERE NOT EXISTS (SELECT 1 FROM doctor_specialties WHERE doctor_id = did AND specialty_id = sid);
    END LOOP;
  END LOOP;
END$$;

SELECT 'Specialties inserted and linked (if doctors had matching specialties array).' as info2;
