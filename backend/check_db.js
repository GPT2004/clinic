const { PrismaClient } = require('@prisma/client');
const p = new PrismaClient();

async function check() {
  try {
    const users = await p.users.count();
    const appointments = await p.appointments.count();
    const rooms = await p.rooms.count();
    const specialties = await p.specialties.count();
    console.log('Users:', users);
    console.log('Appointments:', appointments);
    console.log('Rooms:', rooms);
    console.log('Specialties:', specialties);
  } catch (e) {
    console.error(e);
  } finally {
    await p.$disconnect();
  }
}

check();