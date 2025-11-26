const prisma = require('./src/config/database');

(async () => {
  try {
    const res = await prisma.prescriptions.findMany({
      where: { notified_at: { not: null } },
      orderBy: { created_at: 'desc' },
      take: 50,
      select: { id: true, status: true, notified_at: true, notified_by: true, patient_id: true, created_at: true }
    });
    console.log(JSON.stringify(res, null, 2));
  } catch (err) {
    console.error('Error querying prescriptions:', err && err.message ? err.message : err);
  } finally {
    await prisma.$disconnect();
  }
})();
