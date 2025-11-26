const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function checkData() {
  try {
    const specialties = await prisma.specialties.findMany();
    console.log('Specialties count:', specialties.length);
    console.log('Specialties:', specialties);

    const rooms = await prisma.rooms.findMany();
    console.log('Rooms count:', rooms.length);
    console.log('Rooms:', rooms);
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

checkData();