const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function main() {
  try {
    console.log('Checking appointments for 2025-11-22...\n');

    const appointments = await prisma.appointments.findMany({
      where: {
        appointment_date: new Date('2025-11-22'),
      },
      include: {
        patient: {
          include: {
            user: true,
          },
        },
        doctor: {
          include: {
            user: true,
          },
        },
        timeslot: true,
      },
      orderBy: {
        appointment_time: 'asc',
      },
    });

    console.log(`Total appointments for 2025-11-22: ${appointments.length}\n`);

    if (appointments.length === 0) {
      console.log('❌ No appointments found for 2025-11-22\n');
    } else {
      console.log('✅ Found appointments:\n');
      appointments.forEach((apt, idx) => {
        console.log(`${idx + 1}. ID: ${apt.id}`);
        console.log(`   Patient: ${apt.patient?.user?.full_name || apt.patient?.full_name}`);
        console.log(`   Doctor: ${apt.doctor?.user?.full_name}`);
        console.log(`   Time: ${apt.appointment_time}`);
        console.log(`   Status: ${apt.status}`);
        console.log(`   Created: ${apt.created_at}`);
        console.log('');
      });
    }

    // Check timeslots for 22/11
    console.log('\n\nChecking timeslots for 2025-11-22...\n');
    const timeslots = await prisma.timeslots.findMany({
      where: {
        date: new Date('2025-11-22'),
      },
      include: {
        doctor: {
          include: {
            user: true,
          },
        },
      },
      orderBy: {
        start_time: 'asc',
      },
    });

    console.log(`Total timeslots for 2025-11-22: ${timeslots.length}\n`);

    if (timeslots.length > 0) {
      console.log('Timeslots summary:');
      timeslots.forEach((ts) => {
        console.log(`- Doctor ${ts.doctor?.user?.full_name}: ${ts.start_time} - ${ts.end_time} (booked: ${ts.booked_count}/${ts.max_patients})`);
      });
    }

  } catch (error) {
    console.error('Error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
