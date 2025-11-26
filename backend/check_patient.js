const { PrismaClient } = require('@prisma/client');

const p = new PrismaClient();

async function main() {
  console.log('\n====== PATIENT ID 1 ======');
  const patient = await p.patients.findUnique({
    where: { id: 1 },
    include: {
      user: true,
      medical_records: true
    }
  });
  console.log(JSON.stringify(patient, null, 2));

  console.log('\n====== APPOINTMENT ID 30 ======');
  const appointment = await p.appointments.findUnique({
    where: { id: 30 },
    include: {
      patient: {
        include: {
          user: true,
          medical_records: true
        }
      },
      doctor: {
        include: {
          user: true,
          doctorSpecialties: {
            include: {
              specialty: true
            }
          }
        }
      },
      timeslot: true
    }
  });
  console.log(JSON.stringify(appointment, null, 2));

  await p.$disconnect();
}

main().catch(console.error);
