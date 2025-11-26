-- check_doctors_specialties.sql
-- Check all doctors and their pediatric specialties

SELECT '=== DANH SÁCH BÁC SĨ VÀ CHUYÊN KHOA NHI KHOA ===' as info;

SELECT
  d.id as doctor_id,
  u.full_name,
  u.email,
  d.specialties,
  d.bio,
  d.license_number,
  d.consultation_fee,
  d.rating
FROM doctors d
JOIN users u ON d.user_id = u.id
WHERE u.role_id = (SELECT id FROM roles WHERE name = 'Doctor')
ORDER BY u.email;

-- Count doctors by specialty
SELECT '=== THỐNG KÊ BÁC SĨ THEO CHUYÊN KHOA ===' as info;

SELECT
  unnest(specialties) as specialty,
  COUNT(*) as doctor_count
FROM doctors d
JOIN users u ON d.user_id = u.id
WHERE u.role_id = (SELECT id FROM roles WHERE name = 'Doctor')
GROUP BY unnest(specialties)
ORDER BY doctor_count DESC, specialty;

-- Run with: npx prisma db execute --file check_doctors_specialties.sql