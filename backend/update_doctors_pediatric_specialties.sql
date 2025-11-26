-- update_doctors_pediatric_specialties.sql
-- Update doctors' specialties to pediatric versions for pediatric hospital
BEGIN;

-- Update doctors' specialties arrays to pediatric versions
UPDATE doctors d
SET specialties = ARRAY['Nhi khoa tổng quát']
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

-- Update doctor@example.com (John Smith) - multi-specialty pediatric doctor
UPDATE doctors d
SET specialties = ARRAY['Nhi tim mạch', 'Nhi khoa tổng quát']
FROM users u
WHERE d.user_id = u.id AND u.email = 'doctor@example.com';

-- Add some additional pediatric specialties for variety
-- Create a few more doctors with multiple specialties

-- Update bio to reflect pediatric specialization
UPDATE doctors d
SET bio = 'Bác sĩ nhi khoa chuyên ' ||
  CASE
    WHEN d.specialties && ARRAY['Nhi khoa tổng quát'] THEN 'khám và điều trị tổng quát cho trẻ em'
    WHEN d.specialties && ARRAY['Nhi tim mạch'] THEN 'chuyên khoa tim mạch nhi với hơn 10 năm kinh nghiệm'
    WHEN d.specialties && ARRAY['Nhi tiêu hóa'] THEN 'chuyên gia tiêu hóa nhi khoa'
    WHEN d.specialties && ARRAY['Nhi nội tiết'] THEN 'bác sĩ nội tiết nhi khoa'
    WHEN d.specialties && ARRAY['Nhi da liễu'] THEN 'chuyên khoa da liễu nhi'
    WHEN d.specialties && ARRAY['Tai Mũi Họng nhi'] THEN 'bác sĩ tai mũi họng nhi khoa'
    WHEN d.specialties && ARRAY['Nhi hô hấp'] THEN 'chuyên gia hô hấp nhi khoa'
    ELSE 'bác sĩ nhi khoa giàu kinh nghiệm'
  END
FROM users u
WHERE d.user_id = u.id AND u.email IN (
  'general.med@example.com', 'cardio@example.com', 'gastro@example.com',
  'endo@example.com', 'derma@example.com', 'ent@example.com', 'pulmo@example.com', 'doctor@example.com'
);

COMMIT;

-- Verify the updates
SELECT 'Updated doctors specialties to pediatric:' as info;
SELECT u.email, u.full_name, d.specialties, d.bio
FROM doctors d
JOIN users u ON d.user_id = u.id
WHERE u.email IN (
  'general.med@example.com', 'cardio@example.com', 'gastro@example.com',
  'endo@example.com', 'derma@example.com', 'ent@example.com', 'pulmo@example.com', 'doctor@example.com'
)
ORDER BY u.email;

-- Run with: npx prisma db execute --file update_doctors_pediatric_specialties.sql