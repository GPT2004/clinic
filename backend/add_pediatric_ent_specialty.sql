-- add_pediatric_ent_specialty.sql
-- Add pediatric ENT specialty to the specialties table
BEGIN;

-- Insert pediatric ENT specialty if not exists
INSERT INTO specialties (name, slug, description)
VALUES (
  'Tai Mũi Họng nhi',
  'tai-mui-hong-nhi',
  'Chuyên khoa tai mũi họng nhi khoa: khám và điều trị các bệnh về tai, mũi, họng ở trẻ em'
)
ON CONFLICT (name) DO NOTHING;

COMMIT;

-- Verify
SELECT 'Added pediatric ENT specialty:' as info;
SELECT id, name, slug, description FROM specialties WHERE name = 'Tai Mũi Họng nhi';

-- Run with: npx prisma db execute --file add_pediatric_ent_specialty.sql