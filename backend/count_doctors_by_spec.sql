SELECT unnest(specialties) AS specialty, COUNT(*) AS doctor_count
FROM doctors
GROUP BY unnest(specialties)
ORDER BY doctor_count DESC, specialty;