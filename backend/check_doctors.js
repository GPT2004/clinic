const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function checkDoctors() {
  try {
    const doctors = await prisma.doctor.findMany({
      include: {
        user: true
      }
    });

    console.log('=== DANH SÁCH BÁC SĨ ===');
    doctors.forEach(doctor => {
      console.log(`ID: ${doctor.id}, Name: ${doctor.user.first_name} ${doctor.user.last_name}, Email: ${doctor.user.email}`);
      console.log(`Specialties: ${JSON.stringify(doctor.specialties)}`);
      console.log('---');
    });

  } catch (error) {
    console.error('Error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

checkDoctors();