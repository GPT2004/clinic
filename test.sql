-- ================================================================
-- Clinic Management DB Schema + Triggers + Seed (FINAL, corrected)
-- Paste into pgAdmin4 -> Query Tool -> Execute
-- ================================================================

-- 0. Ensure uuid extension (optional)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Create enum-like types (if not exists)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'appointment_status') THEN
    CREATE TYPE appointment_status AS ENUM (
      'PENDING', 'CONFIRMED', 'CHECKED_IN', 'IN_PROGRESS',
      'COMPLETED', 'CANCELLED', 'NO_SHOW'
    );
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'invoice_status') THEN
    CREATE TYPE invoice_status AS ENUM ('UNPAID','PAID','REFUNDED');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'prescription_status') THEN
    CREATE TYPE prescription_status AS ENUM ('DRAFT','APPROVED','DISPENSED');
  END IF;
END$$;


-- 2. Roles & Users ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS roles (
  id              SERIAL PRIMARY KEY,
  name            VARCHAR(50) NOT NULL UNIQUE,
  description     TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS users (
  id              SERIAL PRIMARY KEY,
  email           VARCHAR(255) UNIQUE,
  password        VARCHAR(255), -- bcrypt hashed (for dev)
  full_name       VARCHAR(255) NOT NULL,
  phone           VARCHAR(50),
  dob             DATE,
  avatar_url      TEXT,
  is_active       BOOLEAN DEFAULT TRUE,
  role_id         INT NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- 3. Doctors & Patients ----------------------------------------------------
CREATE TABLE IF NOT EXISTS doctors (
  id              SERIAL PRIMARY KEY,
  user_id         INT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  license_number  VARCHAR(100),
  specialties     TEXT, -- comma-separated or JSON
  bio             TEXT,
  consultation_fee INTEGER,
  rating          NUMERIC(3,2) DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS patients (
  id              SERIAL PRIMARY KEY,
  user_id         INT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  gender          VARCHAR(20),
  blood_type      VARCHAR(10),
  allergies       TEXT,
  emergency_contact JSONB,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- 4. Rooms & Schedules -----------------------------------------------------
CREATE TABLE IF NOT EXISTS rooms (
  id              SERIAL PRIMARY KEY,
  name            VARCHAR(150) NOT NULL,
  type            VARCHAR(100),
  description     TEXT,
  capacity        INT DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS schedules (
  id              SERIAL PRIMARY KEY,
  doctor_id       INT NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
  room_id         INT REFERENCES rooms(id) ON DELETE SET NULL,
  date            DATE NOT NULL,
  start_time      TIME NOT NULL,
  end_time        TIME NOT NULL,
  recurrent_rule  VARCHAR(255),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- 5. TimeSlots --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS timeslots (
  id              SERIAL PRIMARY KEY,
  doctor_id       INT NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
  date            DATE NOT NULL,
  start_time      TIME NOT NULL,
  end_time        TIME NOT NULL,
  max_patients    INT DEFAULT 1,
  booked_count    INT DEFAULT 0,
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT timeslot_unique UNIQUE (doctor_id, date, start_time, end_time)
);


-- 6. Appointments ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS appointments (
  id              SERIAL PRIMARY KEY,
  patient_id      INT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  doctor_id       INT NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
  timeslot_id     INT REFERENCES timeslots(id) ON DELETE SET NULL,
  appointment_date DATE NOT NULL,
  appointment_time TIME,
  status          appointment_status NOT NULL DEFAULT 'PENDING',
  reason          TEXT,
  source          VARCHAR(50) DEFAULT 'web',
  created_by      INT REFERENCES users(id) ON DELETE SET NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- 7. Medical Records -------------------------------------------------------
CREATE TABLE IF NOT EXISTS medical_records (
  id              SERIAL PRIMARY KEY,
  appointment_id  INT REFERENCES appointments(id) ON DELETE SET NULL,
  patient_id      INT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  doctor_id       INT NOT NULL REFERENCES doctors(id) ON DELETE SET NULL,
  diagnosis       TEXT,
  notes           TEXT,
  attachments     JSONB,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- 8. Medicines & Stock -----------------------------------------------------
CREATE TABLE IF NOT EXISTS medicines (
  id              SERIAL PRIMARY KEY,
  name            VARCHAR(255) NOT NULL,
  code            VARCHAR(100) UNIQUE,
  description     TEXT,
  unit            VARCHAR(50),
  price           INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS stocks (
  id              SERIAL PRIMARY KEY,
  medicine_id     INT NOT NULL REFERENCES medicines(id) ON DELETE CASCADE,
  batch_number    VARCHAR(100),
  expiry_date     DATE,
  quantity        INT NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- 9. Prescriptions ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS prescriptions (
  id              SERIAL PRIMARY KEY,
  appointment_id  INT REFERENCES appointments(id) ON DELETE SET NULL,
  doctor_id       INT NOT NULL REFERENCES doctors(id) ON DELETE SET NULL,
  patient_id      INT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  items           JSONB NOT NULL, -- [{medicine_id, qty, instructions, unit_price}, ...]
  total_amount    INTEGER DEFAULT 0,
  status          prescription_status NOT NULL DEFAULT 'DRAFT',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- 10. Suppliers -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS suppliers (
  id              SERIAL PRIMARY KEY,
  name            VARCHAR(255) NOT NULL,
  contact_info    JSONB,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- 11. Invoices --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS invoices (
  id              SERIAL PRIMARY KEY,
  appointment_id  INT REFERENCES appointments(id) ON DELETE SET NULL,
  patient_id      INT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  items           JSONB NOT NULL,
  subtotal        INTEGER DEFAULT 0,
  tax             INTEGER DEFAULT 0,
  discount        INTEGER DEFAULT 0,
  total           INTEGER DEFAULT 0,
  status          invoice_status NOT NULL DEFAULT 'UNPAID',
  paid_at         TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- 12. Lab orders & results -------------------------------------------------
CREATE TABLE IF NOT EXISTS lab_orders (
  id              SERIAL PRIMARY KEY,
  appointment_id  INT REFERENCES appointments(id) ON DELETE SET NULL,
  patient_id      INT NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
  doctor_id       INT NOT NULL REFERENCES doctors(id) ON DELETE SET NULL,
  tests           JSONB NOT NULL,
  status          VARCHAR(50) DEFAULT 'PENDING',
  results         JSONB,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- 13. Notifications & Audit logs -------------------------------------------
CREATE TABLE IF NOT EXISTS notifications (
  id              SERIAL PRIMARY KEY,
  user_id         INT REFERENCES users(id) ON DELETE CASCADE,
  type            VARCHAR(100),
  payload         JSONB,
  is_read         BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id              SERIAL PRIMARY KEY,
  user_id         INT,
  action          VARCHAR(255) NOT NULL,
  meta            JSONB,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- 14. Indexes for performance ----------------------------------------------
CREATE INDEX IF NOT EXISTS idx_appointments_doctor_date ON appointments (doctor_id, appointment_date);
CREATE INDEX IF NOT EXISTS idx_timeslots_doctor_date ON timeslots (doctor_id, date);
CREATE INDEX IF NOT EXISTS idx_medicalrecords_patient ON medical_records (patient_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_patient ON prescriptions (patient_id);
CREATE INDEX IF NOT EXISTS idx_invoices_patient ON invoices (patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments (status);


-- ================================================================
-- 15. Seed basic roles and users (passwords bcrypt-hashed for dev)
-- ================================================================
INSERT INTO roles (name, description) VALUES
  ('Admin', 'System administrator'),
  ('Doctor', 'Medical doctor'),
  ('Receptionist', 'Front desk / receptionist'),
  ('Pharmacist', 'Pharmacy staff'),
  ('LabTech', 'Lab technician'),
  ('Patient', 'Patient / Customer')
ON CONFLICT (name) DO NOTHING;

-- BCRYPT HASHES (DEV)
-- admin123 -> $2b$12$j9k23rgrapQZ0h3pnCinjenT9qR8yxR/2Ea9v855WkJUDfuAqIhqC
-- doctor123 -> $2b$12$7DJh87RcG3x/wHJMP6Baqes54G6xteskbF/JvuKotfH/J.3sTgJiW
-- patient123 -> $2b$12$RI6fCs/UQm4MiweuUlBpOelXmiY0CPR2miKS2WEADFYdsv9naoRTa

INSERT INTO users (email, password, full_name, phone, role_id)
SELECT 'admin@clinic.test', '$2b$12$j9k23rgrapQZ0h3pnCinjenT9qR8yxR/2Ea9v855WkJUDfuAqIhqC', 'System Admin', '+84000000001', r.id
FROM roles r WHERE r.name = 'Admin'
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (email, password, full_name, phone, role_id)
SELECT 'doctor1@clinic.test', '$2b$12$7DJh87RcG3x/wHJMP6Baqes54G6xteskbF/JvuKotfH/J.3sTgJiW', 'Dr. Nguyen Van A', '+84000000002', r.id
FROM roles r WHERE r.name = 'Doctor'
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (email, password, full_name, phone, role_id)
SELECT 'patient1@clinic.test', '$2b$12$RI6fCs/UQm4MiweuUlBpOelXmiY0CPR2miKS2WEADFYdsv9naoRTa', 'Nguyen Thi B', '+84000000003', r.id
FROM roles r WHERE r.name = 'Patient'
ON CONFLICT (email) DO NOTHING;


-- Link doctor & patient profiles (insert only if user exists and profile not exist)
INSERT INTO doctors (user_id, license_number, specialties, bio, consultation_fee)
SELECT u.id, 'LIC-001', 'General Medicine,Cardiology', 'Experienced GP', 200000
FROM users u
WHERE u.email = 'doctor1@clinic.test'
  AND NOT EXISTS (SELECT 1 FROM doctors d WHERE d.user_id = u.id);

INSERT INTO patients (user_id, gender, blood_type, allergies)
SELECT u.id, 'Female','O+','Penicillin'
FROM users u
WHERE u.email = 'patient1@clinic.test'
  AND NOT EXISTS (SELECT 1 FROM patients p WHERE p.user_id = u.id);


-- 16. Example timeslot + appointment for testing (fixed casting)
WITH doc AS (
  SELECT d.id AS doctor_id
  FROM doctors d
  JOIN users u ON d.user_id = u.id
  WHERE u.email='doctor1@clinic.test'
)
INSERT INTO timeslots (doctor_id, date, start_time, end_time, max_patients)
SELECT doctor_id, (current_date + 1), '09:00'::time, '09:20'::time, 1 FROM doc
ON CONFLICT DO NOTHING;

WITH p AS (
  SELECT pa.id AS patient_id
  FROM patients pa
  JOIN users u ON pa.user_id = u.id
  WHERE u.email = 'patient1@clinic.test'
), d AS (
  SELECT d.id AS doctor_id
  FROM doctors d
  JOIN users u ON d.user_id = u.id
  WHERE u.email = 'doctor1@clinic.test'
), ts AS (
  SELECT t.id AS timeslot_id, t.date, t.start_time, t.end_time
  FROM timeslots t
  JOIN d ON t.doctor_id = d.doctor_id
  LIMIT 1
)
INSERT INTO appointments (patient_id, doctor_id, timeslot_id, appointment_date, appointment_time, status, reason, created_by)
SELECT p.patient_id, d.doctor_id, ts.timeslot_id, ts.date, ts.start_time, 'PENDING', 'General checkup', (SELECT id FROM users WHERE email='patient1@clinic.test')
FROM p, d, ts
ON CONFLICT DO NOTHING;


-- Ensure timeslots.booked_count reflects inserted appointments (safe update)
UPDATE timeslots t
SET booked_count = sub.cnt
FROM (
  SELECT timeslot_id, COUNT(*) AS cnt
  FROM appointments
  WHERE timeslot_id IS NOT NULL
  GROUP BY timeslot_id
) sub
WHERE t.id = sub.timeslot_id;


-- ================================================================
-- 17. Functions & Triggers to maintain timeslots.booked_count safely
-- ================================================================

-- 17.1. Function to increment booked_count with check
CREATE OR REPLACE FUNCTION fn_increment_timeslot_booked_count(ts_id INT) RETURNS VOID AS $$
DECLARE
  current_count INT;
  max_pat INT;
BEGIN
  IF ts_id IS NULL THEN
    RETURN;
  END IF;
  SELECT booked_count, max_patients INTO current_count, max_pat FROM timeslots WHERE id = ts_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Timeslot % not found', ts_id;
  END IF;
  IF current_count + 1 > max_pat THEN
    RAISE EXCEPTION 'Timeslot % is full (max %)', ts_id, max_pat;
  END IF;
  UPDATE timeslots SET booked_count = booked_count + 1, updated_at = now() WHERE id = ts_id;
END;
$$ LANGUAGE plpgsql;

-- 17.2. Function to decrement booked_count (safe)
CREATE OR REPLACE FUNCTION fn_decrement_timeslot_booked_count(ts_id INT) RETURNS VOID AS $$
DECLARE
  current_count INT;
BEGIN
  IF ts_id IS NULL THEN
    RETURN;
  END IF;
  SELECT booked_count INTO current_count FROM timeslots WHERE id = ts_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Timeslot % not found', ts_id;
  END IF;
  IF current_count > 0 THEN
    UPDATE timeslots SET booked_count = booked_count - 1, updated_at = now() WHERE id = ts_id;
  ELSE
    UPDATE timeslots SET booked_count = 0, updated_at = now() WHERE id = ts_id;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- 17.3. Trigger function BEFORE INSERT on appointments
CREATE OR REPLACE FUNCTION trg_appointments_before_insert() RETURNS TRIGGER AS $$
BEGIN
  PERFORM fn_increment_timeslot_booked_count(NEW.timeslot_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 17.4. Trigger function BEFORE DELETE on appointments
CREATE OR REPLACE FUNCTION trg_appointments_before_delete() RETURNS TRIGGER AS $$
BEGIN
  PERFORM fn_decrement_timeslot_booked_count(OLD.timeslot_id);
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- 17.5. Trigger function BEFORE UPDATE on appointments
CREATE OR REPLACE FUNCTION trg_appointments_before_update() RETURNS TRIGGER AS $$
BEGIN
  IF (OLD.timeslot_id IS NOT NULL AND NEW.timeslot_id IS NULL) THEN
    PERFORM fn_decrement_timeslot_booked_count(OLD.timeslot_id);
  ELSIF (OLD.timeslot_id IS NULL AND NEW.timeslot_id IS NOT NULL) THEN
    PERFORM fn_increment_timeslot_booked_count(NEW.timeslot_id);
  ELSIF (OLD.timeslot_id IS NOT NULL AND NEW.timeslot_id IS NOT NULL AND OLD.timeslot_id <> NEW.timeslot_id) THEN
    PERFORM fn_decrement_timeslot_booked_count(OLD.timeslot_id);
    PERFORM fn_increment_timeslot_booked_count(NEW.timeslot_id);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach triggers to appointments
DROP TRIGGER IF EXISTS appointments_before_insert ON appointments;
CREATE TRIGGER appointments_before_insert
BEFORE INSERT ON appointments
FOR EACH ROW EXECUTE FUNCTION trg_appointments_before_insert();

DROP TRIGGER IF EXISTS appointments_before_delete ON appointments;
CREATE TRIGGER appointments_before_delete
BEFORE DELETE ON appointments
FOR EACH ROW EXECUTE FUNCTION trg_appointments_before_delete();

DROP TRIGGER IF EXISTS appointments_before_update ON appointments;
CREATE TRIGGER appointments_before_update
BEFORE UPDATE ON appointments
FOR EACH ROW EXECUTE FUNCTION trg_appointments_before_update();


-- ================================================================
-- 18. Prevent duplicate booking (same patient, same timeslot) - add constraint if not exists
-- ================================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'uq_appointments_patient_timeslot'
  ) THEN
    ALTER TABLE appointments
      ADD CONSTRAINT uq_appointments_patient_timeslot UNIQUE (patient_id, timeslot_id);
  END IF;
END$$;


-- ================================================================
-- 19. Optional: materialized view suggestion (commented)
-- CREATE MATERIALIZED VIEW mv_daily_visits AS
-- SELECT appointment_date, status, count(*) as cnt
-- FROM appointments
-- GROUP BY appointment_date, status;
-- REFRESH MATERIALIZED VIEW mv_daily_visits;
-- ================================================================


-- ================================================================
-- End of script
-- ================================================================
