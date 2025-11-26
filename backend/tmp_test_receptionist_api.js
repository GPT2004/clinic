const prisma = require('./src/config/database');
const { generateToken } = require('./src/utils/jwt');
const fetch = require('node-fetch');

(async () => {
  try {
    const receptionist = await prisma.users.findFirst({ where: { role: { name: 'Receptionist' } } });
    if (!receptionist) {
      console.log('No receptionist user found');
      process.exit(0);
    }
    console.log('Found receptionist:', { id: receptionist.id, email: receptionist.email });

    const token = generateToken({ userId: receptionist.id });
    console.log('Generated token (first 20 chars):', token.slice(0, 20) + '...');

    const res = await fetch('http://localhost:8080/api/prescriptions/for-invoicing?page=1&limit=50', {
      headers: { Authorization: 'Bearer ' + token, 'Content-Type': 'application/json' },
    });
    const body = await res.text();
    console.log('Status:', res.status);
    try {
      console.log('Body:', JSON.stringify(JSON.parse(body), null, 2));
    } catch (e) {
      console.log('Body (raw):', body);
    }
  } catch (err) {
    console.error('Error:', err && err.message ? err.message : err);
  } finally {
    await prisma.$disconnect();
  }
})();
