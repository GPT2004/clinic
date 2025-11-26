-- seed_specialties_full.sql
-- Add full specialty metadata and update doctors with realistic bios, education, experience
BEGIN;

-- Upsert specialties
INSERT INTO specialties (name, slug, description, image_url, created_at, updated_at)
VALUES
  ('General Medicine', 'general-medicine', 'Khám và điều trị các bệnh nội khoa phổ thông cho mọi lứa tuổi; chẩn đoán ban đầu và chuyển tuyến khi cần.', NULL, now(), now()),
  ('Cardiology', 'cardiology', 'Chuyên khám và điều trị các bệnh tim mạch: tăng huyết áp, suy tim, rối loạn nhịp và bệnh mạch vành.', NULL, now(), now()),
  ('Gastroenterology', 'gastroenterology', 'Chẩn đoán và điều trị các bệnh tiêu hóa, gan mật, viêm dạ dày, loét, rối loạn tiêu hóa mãn tính.', NULL, now(), now()),
  ('Endocrinology', 'endocrinology', 'Điều trị các rối loạn nội tiết: đái tháo đường, rối loạn tuyến giáp, rối loạn chuyển hóa.', NULL, now(), now()),
  ('Dermatology', 'dermatology', 'Chuyên về da liễu: mụn, viêm da, bệnh da mãn tính, tư vấn chăm sóc da và các thủ thuật da liễu cơ bản.', NULL, now(), now()),
  ('ENT', 'ent', 'Tai - mũi - họng: khám, điều trị viêm tai, viêm xoang, rối loạn giọng nói và phẫu thuật nhỏ vùng tai mũi họng.', NULL, now(), now()),
  ('Pulmonology', 'pulmonology', 'Chuyên khám và điều trị các bệnh hô hấp: hen, COPD, nhiễm trùng đường hô hấp và các rối loạn phổi mãn tính.', NULL, now(), now())
ON CONFLICT (name) DO UPDATE SET description = EXCLUDED.description, updated_at = now();

-- Update doctors bios, education, experience, license numbers and fees
-- We use users.email to find related doctor records (doctors.user_id -> users.id)

-- Dr. Nguyen Van A (general.med@example.com)
UPDATE doctors d
SET license_number = 'MD-VN-001',
    bio = 'Bác sĩ nội tổng quát với 10+ năm kinh nghiệm khám bệnh, điều trị bệnh lý nội khoa phổ biến và quản lý bệnh mạn tính. Thích hợp khám tổng quát và tư vấn chăm sóc lâu dài cho gia đình.',
    consultation_fee = 200000,
    rating = 4.8,
    specialties = ARRAY['General Medicine','Cardiology']
FROM users u
WHERE d.user_id = u.id AND u.email = 'general.med@example.com';

-- Dr. Tran Thi B (cardio@example.com)
UPDATE doctors d
SET license_number = 'MD-CR-014',
    bio = 'Bác sĩ tim mạch, chuyên đánh giá và quản lý bệnh nhân bệnh mạch vành, tăng huyết áp và rối loạn nhịp. Có kinh nghiệm can thiệp cơ bản và phối hợp với phòng xét nghiệm tim mạch.',
    consultation_fee = 350000,
    rating = 4.7,
    specialties = ARRAY['Cardiology']
FROM users u
WHERE d.user_id = u.id AND u.email = 'cardio@example.com';

-- Dr. Le Van C (gastro@example.com)
UPDATE doctors d
SET license_number = 'MD-GI-022',
    bio = 'Bác sĩ tiêu hóa với 8 năm kinh nghiệm xử lý các rối loạn tiêu hóa, viêm dạ dày và hội chứng ruột kích thích. Thực hiện hướng dẫn dinh dưỡng và theo dõi bệnh lý mạn tính.',
    consultation_fee = 250000,
    rating = 4.6,
    specialties = ARRAY['Gastroenterology']
FROM users u
WHERE d.user_id = u.id AND u.email = 'gastro@example.com';

-- Dr. Pham Thi D (endo@example.com)
UPDATE doctors d
SET license_number = 'MD-END-009',
    bio = 'Chuyên gia nội tiết, đặc biệt trong quản lý đái tháo đường và rối loạn tuyến giáp. Hỗ trợ bệnh nhân với kế hoạch điều trị dài hạn và giáo dục liên quan.',
    consultation_fee = 280000,
    rating = 4.5,
    specialties = ARRAY['Endocrinology']
FROM users u
WHERE d.user_id = u.id AND u.email = 'endo@example.com';

-- Dr. Hoang Van E (derma@example.com)
UPDATE doctors d
SET license_number = 'MD-DER-033',
    bio = 'Bác sĩ da liễu có kinh nghiệm trong điều trị mụn, viêm da cơ địa và các thủ thuật da liễu thẩm mỹ cơ bản. Tư vấn chăm sóc da và điều trị lâu dài.',
    consultation_fee = 220000,
    rating = 4.6,
    specialties = ARRAY['Dermatology']
FROM users u
WHERE d.user_id = u.id AND u.email = 'derma@example.com';

-- Dr. Bui Thi F (ent@example.com)
UPDATE doctors d
SET license_number = 'MD-ENT-017',
    bio = 'Bác sĩ chuyên khoa Tai - Mũi - Họng, xử lý các tình trạng viêm mũi xoang, viêm họng và rối loạn giọng nói. Kinh nghiệm phẫu thuật nhỏ vùng tai mũi họng.',
    consultation_fee = 230000,
    rating = 4.4,
    specialties = ARRAY['ENT']
FROM users u
WHERE d.user_id = u.id AND u.email = 'ent@example.com';

-- Dr. Dao Van G (pulmo@example.com)
UPDATE doctors d
SET license_number = 'MD-PUL-027',
    bio = 'Bác sĩ hô hấp, chuyên chẩn đoán và điều trị các bệnh phổi mãn tính như hen và COPD, cũng như các nhiễm trùng hô hấp nặng.',
    consultation_fee = 260000,
    rating = 4.5,
    specialties = ARRAY['Pulmonology']
FROM users u
WHERE d.user_id = u.id AND u.email = 'pulmo@example.com';

-- Dr. John Smith (doctor@example.com) - multi-specialty example
UPDATE doctors d
SET license_number = 'MD-INT-050',
    bio = 'Bác sĩ khóa học tại nước ngoài, có kinh nghiệm lâm sàng trong tim mạch và nội tổng quát. Hợp tác đa khoa, chịu trách nhiệm tư vấn cho bệnh nhân phức tạp.',
    consultation_fee = 400000,
    rating = 4.9,
    specialties = ARRAY['Cardiology','General Medicine']
FROM users u
WHERE d.user_id = u.id AND u.email = 'doctor@example.com';

-- Ensure doctor_specialties mapping exists for each doctor -> specialty
-- This inserts mapping if not present
INSERT INTO doctor_specialties (doctor_id, specialty_id, created_at)
SELECT d.id, s.id, now()
FROM doctors d
JOIN users u ON u.id = d.user_id
JOIN specialties s ON (
  (s.name = 'General Medicine' AND u.email IN ('general.med@example.com','doctor@example.com')) OR
  (s.name = 'Cardiology' AND u.email IN ('cardio@example.com','general.med@example.com','doctor@example.com')) OR
  (s.name = 'Gastroenterology' AND u.email = 'gastro@example.com') OR
  (s.name = 'Endocrinology' AND u.email = 'endo@example.com') OR
  (s.name = 'Dermatology' AND u.email = 'derma@example.com') OR
  (s.name = 'ENT' AND u.email = 'ent@example.com') OR
  (s.name = 'Pulmonology' AND u.email = 'pulmo@example.com')
)
ON CONFLICT DO NOTHING;

COMMIT;

-- Done. Run: npx prisma db execute --file seed_specialties_full.sql
