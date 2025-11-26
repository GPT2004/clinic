-- Clean and reseed specialties with 7 Vietnamese specialties
-- Drop old specialties and recreate
BEGIN;

-- Delete old specialties (cascade will handle doctor relationships)
DELETE FROM specialties WHERE true;

-- Reset ID sequence
ALTER SEQUENCE specialties_id_seq RESTART WITH 1;

-- Insert 7 new specialties in Vietnamese
INSERT INTO specialties (name, slug, description, icon, is_active, created_at, updated_at) VALUES
('Nội tổng quát', 'noi-tong-quat', 'Khoa Nội tổng quát - Chữa các bệnh về hệ thống nội tạng', '🏥', true, NOW(), NOW()),
('Tim mạch', 'tim-mach', 'Khoa Tim mạch - Chẩn đoán và điều trị các bệnh về tim và mạch máu', '❤️', true, NOW(), NOW()),
('Tiêu hóa', 'tieu-hoa', 'Khoa Tiêu hóa - Chuyên môn về bệnh đường tiêu hóa', '🍽️', true, NOW(), NOW()),
('Nội tiết', 'noi-tiet', 'Khoa Nội tiết - Điều trị các rối loạn về nội tiết tố', '⚡', true, NOW(), NOW()),
('Da liễu', 'da-lieu', 'Khoa Da liễu - Chữa các bệnh về da và liễu', '🧴', true, NOW(), NOW()),
('Tai Mũi Họng', 'tai-mui-hong', 'Khoa Tai Mũi Họng - Khám chữa bệnh tai, mũi, họng', '👂', true, NOW(), NOW()),
('Hô hấp', 'ho-hap', 'Khoa Hô hấp - Điều trị các bệnh về hệ hô hấp', '💨', true, NOW(), NOW());

-- Assign doctors to specialties
-- Update existing doctors or create new ones
-- Assuming doctors already exist, we update their specialties

UPDATE doctors
SET specialties = ARRAY['Nội tổng quát', 'Tim mạch']
WHERE user_id IN (SELECT id FROM users WHERE email = 'doctor@example.com' LIMIT 1);

UPDATE doctors
SET specialties = ARRAY['Tiêu hóa']
WHERE user_id IN (SELECT id FROM users WHERE email LIKE '%gastro%' LIMIT 1);

UPDATE doctors
SET specialties = ARRAY['Da liễu']
WHERE user_id IN (SELECT id FROM users WHERE email LIKE '%derma%' LIMIT 1);

UPDATE doctors
SET specialties = ARRAY['Tai Mũi Họng']
WHERE user_id IN (SELECT id FROM users WHERE email LIKE '%ent%' LIMIT 1);

UPDATE doctors
SET specialties = ARRAY['Hô hấp']
WHERE user_id IN (SELECT id FROM users WHERE email LIKE '%pulmo%' LIMIT 1);

UPDATE doctors
SET specialties = ARRAY['Tim mạch']
WHERE user_id IN (SELECT id FROM users WHERE email LIKE '%cardio%' LIMIT 1);

UPDATE doctors
SET specialties = ARRAY['Nội tiết']
WHERE user_id IN (SELECT id FROM users WHERE email LIKE '%endo%' LIMIT 1);

COMMIT;

-- Verify: SELECT * FROM specialties;
-- Verify: SELECT id, full_name, specialties FROM doctors;
