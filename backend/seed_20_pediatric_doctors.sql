-- seed_20_pediatric_doctors.sql
-- Create 20 doctor user accounts and doctor profiles, distributed evenly across pediatric specialties
-- Emails: doctor1@email.com .. doctor20@email.com
-- Password: doctor123 (bcrypt-hashed value reused from existing seeds)

BEGIN;

-- get doctor role id
DO $$
DECLARE
  role_doctor_id INT;
  i INT := 1;
  total INT := 20;
  specs TEXT[] := ARRAY[
    'Nhi khoa tổng quát',
    'Nhi hô hấp',
    'Nhi tiêu hóa',
    'Nhi tim mạch',
    'Nhi thần kinh',
    'Nhi dinh dưỡng',
    'Nhi nội tiết',
    'Nhi da liễu',
    'Tai Mũi Họng nhi'
  ];
  spec_count INT := array_length(specs,1);
  chosen_spec TEXT;
  u_id INT;
  d_id INT;
  hashed_pw TEXT := '$2b$12$7DJh87RcG3x/wHJMP6Baqes54G6xteskbF/JvuKotfH/J.3sTgJiW';
BEGIN
  SELECT id INTO role_doctor_id FROM roles WHERE name = 'Doctor' LIMIT 1;
  IF role_doctor_id IS NULL THEN
    RAISE NOTICE 'Doctor role not found; aborting';
    RETURN;
  END IF;

  FOR i IN 1..total LOOP
    chosen_spec := specs[( (i - 1) % spec_count) + 1];

    -- create user if not exists
    INSERT INTO users (email, password, full_name, phone, role_id, is_active)
    SELECT
      ('doctor' || i || '@email.com'),
      hashed_pw,
      ('Dr. Generated ' || i::text),
      ('+84000000' || lpad(i::text,3,'0')),
      role_doctor_id,
      true
    WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = ('doctor' || i || '@email.com'));

    -- get user id
    SELECT id INTO u_id FROM users WHERE email = ('doctor' || i || '@email.com') LIMIT 1;

    -- create doctor profile if not exists
    INSERT INTO doctors (user_id, license_number, specialties, bio, consultation_fee, rating)
    SELECT
      u_id,
      ('DOC-' || lpad(i::text,3,'0')),
      ARRAY[chosen_spec],
      ('Bác sĩ nhi khoa chuyên ' || chosen_spec),
      500000,
      4.5
    WHERE NOT EXISTS (SELECT 1 FROM doctors WHERE user_id = u_id);

    -- get doctor id
    SELECT id INTO d_id FROM doctors WHERE user_id = u_id LIMIT 1;

    -- ensure specialty exists in specialties table (insert if missing)
    INSERT INTO specialties (name, slug, description)
    SELECT chosen_spec, lower(regexp_replace(chosen_spec, '\\s+', '-', 'g')), 'Pediatric specialty ' || chosen_spec
    WHERE NOT EXISTS (SELECT 1 FROM specialties WHERE name = chosen_spec);

    -- link doctor_specialties join table if not exists
    INSERT INTO doctor_specialties (doctor_id, specialty_id)
    SELECT d_id, s.id
    FROM specialties s
    WHERE s.name = chosen_spec
    AND NOT EXISTS (
      SELECT 1 FROM doctor_specialties ds WHERE ds.doctor_id = d_id AND ds.specialty_id = s.id
    );

  END LOOP;
END$$;

COMMIT;

-- Verification
SELECT 'Inserted/ensured 20 doctors (unique emails doctor1..doctor20) and linked to specialties' as info;
SELECT d.id, u.email, u.full_name, d.specialties, d.license_number
FROM doctors d
JOIN users u ON d.user_id = u.id
WHERE u.email LIKE 'doctor%@email.com'
ORDER BY u.email;

-- Run with: npx prisma db execute --file seed_20_pediatric_doctors.sql
