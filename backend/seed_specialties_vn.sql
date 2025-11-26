-- seed_specialties_vn.sql
-- Translate specialty names to Vietnamese and update doctor specialties arrays
BEGIN;

-- Update specialties table: English -> Vietnamese
UPDATE specialties SET name = 'Nội tổng quát', slug = 'noi-tong-quat' WHERE name = 'General Medicine';
UPDATE specialties SET name = 'Tim mạch', slug = 'tim-mach' WHERE name = 'Cardiology';
UPDATE specialties SET name = 'Tiêu hóa', slug = 'tieu-hoa' WHERE name = 'Gastroenterology';
UPDATE specialties SET name = 'Nội tiết', slug = 'noi-tiet' WHERE name = 'Endocrinology';
UPDATE specialties SET name = 'Da liễu', slug = 'da-lieu' WHERE name = 'Dermatology';
UPDATE specialties SET name = 'Tai Mũi Họng', slug = 'tai-mui-hong' WHERE name = 'ENT';
UPDATE specialties SET name = 'Hô hấp', slug = 'ho-hap' WHERE name = 'Pulmonology';

-- Normalize any remaining slug empty
UPDATE specialties SET slug = lower(regexp_replace(name, '\\s+', '-', 'g')) WHERE slug IS NULL OR slug = '';

-- Update doctors.specialties arrays to Vietnamese equivalents based on user emails
UPDATE doctors d
SET specialties = ARRAY['Nội tổng quát','Tim mạch']
FROM users u
WHERE d.user_id = u.id AND u.email = 'general.med@example.com';

UPDATE doctors d
SET specialties = ARRAY['Tim mạch']
FROM users u
WHERE d.user_id = u.id AND u.email = 'cardio@example.com';

UPDATE doctors d
SET specialties = ARRAY['Tiêu hóa']
FROM users u
WHERE d.user_id = u.id AND u.email = 'gastro@example.com';

UPDATE doctors d
SET specialties = ARRAY['Nội tiết']
FROM users u
WHERE d.user_id = u.id AND u.email = 'endo@example.com';

UPDATE doctors d
SET specialties = ARRAY['Da liễu']
FROM users u
WHERE d.user_id = u.id AND u.email = 'derma@example.com';

UPDATE doctors d
SET specialties = ARRAY['Tai Mũi Họng']
FROM users u
WHERE d.user_id = u.id AND u.email = 'ent@example.com';

UPDATE doctors d
SET specialties = ARRAY['Hô hấp']
FROM users u
WHERE d.user_id = u.id AND u.email = 'pulmo@example.com';

-- Update doctor@example.com (John Smith) multi-specialty
UPDATE doctors d
SET specialties = ARRAY['Tim mạch','Nội tổng quát']
FROM users u
WHERE d.user_id = u.id AND u.email = 'doctor@example.com';

COMMIT;

-- Run with: npx prisma db execute --file seed_specialties_vn.sql
