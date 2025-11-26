-- clean_old_specialties.sql
-- Remove old non-pediatric specialties, keeping only pediatric ones
BEGIN;

-- Delete old specialties that are not pediatric
DELETE FROM specialties WHERE name IN (
    'General',
    'Pediatrics',
    'Orthopedics',
    'General Medicine',
    'Gastroenterology',
    'Endocrinology',
    'Dermatology',
    'ENT',
    'Pulmonology',
    'Cardiology',
    '123' -- This seems to be a test entry
);

-- Keep only pediatric specialties
-- The pediatric specialties are already inserted with IDs 27-34

COMMIT;

-- Run with: npx prisma db execute --file clean_old_specialties.sql