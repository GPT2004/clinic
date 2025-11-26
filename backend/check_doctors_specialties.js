const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function checkDoctorsSpecialties() {
  try {
    const doctors = await prisma.doctor.findMany({
      include: {
        user: true
      }
    });

    console.log('=== DANH SÁCH BÁC SĨ VÀ CHUYÊN KHOA NHI KHOA ===');
    doctors.forEach(doctor => {
      console.log(`ID: ${doctor.id}`);
      console.log(`Tên: ${doctor.user.first_name} ${doctor.user.last_name}`);
      console.log(`Email: ${doctor.user.email}`);
      console.log(`Chuyên khoa: ${JSON.stringify(doctor.specialties)}`);
      console.log(`Bio: ${doctor.bio}`);
      console.log('---');
    });

  } catch (error) {
    console.error('Error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

checkDoctorsSpecialties();