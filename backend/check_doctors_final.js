const { Client } = require('pg');

async function checkDoctors() {
  const client = new Client({
    connectionString: process.env.DATABASE_URL,
  });

  try {
    await client.connect();

    console.log('=== DANH SÁCH BÁC SĨ VÀ CHUYÊN KHOA NHI KHOA ===');

    const doctorsQuery = `
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
      ORDER BY u.email
    `;

    const doctorsResult = await client.query(doctorsQuery);
    doctorsResult.rows.forEach(doctor => {
      console.log(`ID: ${doctor.doctor_id}`);
      console.log(`Tên: ${doctor.full_name}`);
      console.log(`Email: ${doctor.email}`);
      console.log(`Chuyên khoa: ${JSON.stringify(doctor.specialties)}`);
      console.log(`Bio: ${doctor.bio}`);
      console.log(`License: ${doctor.license_number}`);
      console.log(`Phí khám: ${doctor.consultation_fee}`);
      console.log(`Rating: ${doctor.rating}`);
      console.log('---');
    });

    console.log('\n=== THỐNG KÊ BÁC SĨ THEO CHUYÊN KHOA ===');

    const statsQuery = `
      SELECT
        unnest(specialties) as specialty,
        COUNT(*) as doctor_count
      FROM doctors d
      JOIN users u ON d.user_id = u.id
      WHERE u.role_id = (SELECT id FROM roles WHERE name = 'Doctor')
      GROUP BY unnest(specialties)
      ORDER BY doctor_count DESC, specialty
    `;

    const statsResult = await client.query(statsQuery);
    statsResult.rows.forEach(stat => {
      console.log(`${stat.specialty}: ${stat.doctor_count} bác sĩ`);
    });

  } catch (error) {
    console.error('Error:', error);
  } finally {
    await client.end();
  }
}

checkDoctors();