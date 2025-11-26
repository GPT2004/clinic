-- seed_specialties_pediatric.sql
-- Update specialties table to pediatric specialties for pediatric hospital
BEGIN;

-- Update existing specialties to pediatric versions
UPDATE specialties SET name = 'Nhi khoa tổng quát', slug = 'nhi-khoa-tong-quat' WHERE name = 'Nội tổng quát';
UPDATE specialties SET name = 'Nhi hô hấp', slug = 'nhi-ho-hap' WHERE name = 'Hô hấp';
UPDATE specialties SET name = 'Nhi tiêu hóa', slug = 'nhi-tieu-hoa' WHERE name = 'Tiêu hóa';
UPDATE specialties SET name = 'Nhi tim mạch', slug = 'nhi-tim-mach' WHERE name = 'Tim mạch';
UPDATE specialties SET name = 'Nhi thần kinh', slug = 'nhi-than-kinh' WHERE name = 'Neurology';
UPDATE specialties SET name = 'Nhi dinh dưỡng', slug = 'nhi-dinh-duong' WHERE name = 'Nutrition';
UPDATE specialties SET name = 'Nhi nội tiết', slug = 'nhi-noi-tiet' WHERE name = 'Nội tiết';
UPDATE specialties SET name = 'Nhi da liễu', slug = 'nhi-da-lieu' WHERE name = 'Da liễu';

-- Insert any missing pediatric specialties
INSERT INTO specialties (name, slug) VALUES
('Nhi khoa tổng quát', 'nhi-khoa-tong-quat'),
('Nhi hô hấp', 'nhi-ho-hap'),
('Nhi tiêu hóa', 'nhi-tieu-hoa'),
('Nhi tim mạch', 'nhi-tim-mach'),
('Nhi thần kinh', 'nhi-than-kinh'),
('Nhi dinh dưỡng', 'nhi-dinh-duong'),
('Nhi nội tiết', 'nhi-noi-tiet'),
('Nhi da liễu', 'nhi-da-lieu')
ON CONFLICT (name) DO NOTHING;

-- Update doctors' specialties arrays to pediatric versions
UPDATE doctors d
SET specialties = ARRAY['Nhi khoa tổng quát','Nhi tim mạch']
FROM users u
WHERE d.user_id = u.id AND u.email = 'general.med@example.com';

UPDATE doctors d
SET specialties = ARRAY['Nhi tim mạch']
FROM users u
WHERE d.user_id = u.id AND u.email = 'cardio@example.com';

UPDATE doctors d
SET specialties = ARRAY['Nhi tiêu hóa']
FROM users u
WHERE d.user_id = u.id AND u.email = 'gastro@example.com';

UPDATE doctors d
SET specialties = ARRAY['Nhi nội tiết']
FROM users u
WHERE d.user_id = u.id AND u.email = 'endo@example.com';

UPDATE doctors d
SET specialties = ARRAY['Nhi da liễu']
FROM users u
WHERE d.user_id = u.id AND u.email = 'derma@example.com';

UPDATE doctors d
SET specialties = ARRAY['Tai Mũi Họng nhi']
FROM users u
WHERE d.user_id = u.id AND u.email = 'ent@example.com';

UPDATE doctors d
SET specialties = ARRAY['Nhi hô hấp']
FROM users u
WHERE d.user_id = u.id AND u.email = 'pulmo@example.com';

-- Update doctor@example.com (John Smith) multi-specialty
UPDATE doctors d
SET specialties = ARRAY['Nhi tim mạch','Nhi khoa tổng quát']
FROM users u
WHERE d.user_id = u.id AND u.email = 'doctor@example.com';

COMMIT;

-- Run with: npx prisma db execute --file seed_specialties_pediatric.sql