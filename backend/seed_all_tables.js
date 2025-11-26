const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function seedAllTables() {
  try {
    console.log('Starting comprehensive database seeding...');

    // ===== Update existing doctors with more details =====
    console.log('Updating doctor details...');
    await prisma.doctors.update({
      where: { user_id: (await prisma.users.findFirst({ where: { email: 'dr1@example.test' } })).id },
      data: {
        specialties: ['Cardiology', 'Internal Medicine'],
        bio: 'Experienced cardiologist with 10+ years in patient care',
        gender: 'MALE',
        address: '123 Nguyen Trai, District 1, HCMC'
      }
    });

    await prisma.doctors.update({
      where: { user_id: (await prisma.users.findFirst({ where: { email: 'dr2@example.test' } })).id },
      data: {
        specialties: ['Dermatology', 'Cosmetic Surgery'],
        bio: 'Dermatologist specializing in skin conditions and cosmetic procedures',
        gender: 'FEMALE',
        address: '456 Le Loi, District 3, HCMC'
      }
    });

    await prisma.doctors.update({
      where: { user_id: (await prisma.users.findFirst({ where: { email: 'dr3@example.test' } })).id },
      data: {
        specialties: ['General Medicine', 'Family Medicine'],
        bio: 'General practitioner providing comprehensive healthcare',
        gender: 'MALE',
        address: '789 Tran Hung Dao, District 5, HCMC'
      }
    });

    await prisma.doctors.update({
      where: { user_id: (await prisma.users.findFirst({ where: { email: 'dr4@example.test' } })).id },
      data: {
        specialties: ['Pediatrics', 'Child Health'],
        bio: 'Pediatrician dedicated to children\'s health and development',
        gender: 'FEMALE',
        address: '321 Vo Van Kiet, District 6, HCMC'
      }
    });

    // ===== Update patients with more details =====
    console.log('Updating patient details...');
    await prisma.patients.update({
      where: { user_id: (await prisma.users.findFirst({ where: { email: 'patient1@example.test' } })).id },
      data: {
        address: '123 Nguyen Van A, District 1, HCMC',
        gender: 'MALE',
        blood_type: 'O+',
        allergies: 'None',
        emergency_contact: { name: 'Jane Doe', phone: '0901234567', relationship: 'Sister' }
      }
    });

    await prisma.patients.update({
      where: { user_id: (await prisma.users.findFirst({ where: { email: 'patient2@example.test' } })).id },
      data: {
        address: '456 Tran Phu, District 7, HCMC',
        gender: 'FEMALE',
        blood_type: 'A+',
        allergies: 'Penicillin',
        emergency_contact: { name: 'John Smith', phone: '0902234567', relationship: 'Husband' }
      }
    });

    await prisma.patients.update({
      where: { user_id: (await prisma.users.findFirst({ where: { email: 'patient3@example.test' } })).id },
      data: {
        address: '789 Le Van Sy, District 3, HCMC',
        gender: 'MALE',
        blood_type: 'B+',
        allergies: 'None',
        emergency_contact: { name: 'Mary Johnson', phone: '0903234567', relationship: 'Wife' }
      }
    });

    await prisma.patients.update({
      where: { user_id: (await prisma.users.findFirst({ where: { email: 'patient4@example.test' } })).id },
      data: {
        address: '321 Nguyen Thi Minh Khai, District 1, HCMC',
        gender: 'FEMALE',
        blood_type: 'AB+',
        allergies: 'Shellfish',
        emergency_contact: { name: 'Bob Wilson', phone: '0904234567', relationship: 'Father' }
      }
    });

    // ===== Add rooms =====
    console.log('Adding rooms...');
    await prisma.rooms.createMany({
      data: [
        { name: 'Room 101', type: 'Consultation', capacity: 1 },
        { name: 'Room 102', type: 'Consultation', capacity: 1 },
        { name: 'Room 201', type: 'Examination', capacity: 1 },
        { name: 'Room 202', type: 'Examination', capacity: 1 },
        { name: 'Lab Room', type: 'Laboratory', capacity: 5 },
        { name: 'Pharmacy', type: 'Pharmacy', capacity: 2 }
      ],
      skipDuplicates: true
    });

    // ===== Add schedules =====
    console.log('Adding schedules...');
    const doctors = await prisma.doctors.findMany();
    const rooms = await prisma.rooms.findMany({ where: { type: 'Consultation' } });

    const schedules = [];
    doctors.slice(0, 4).forEach((doctor, index) => {
      if (rooms[index]) {
        schedules.push({
          doctor_id: doctor.id,
          room_id: rooms[index].id,
          date: new Date(Date.now() + 24 * 60 * 60 * 1000), // Tomorrow
          start_time: new Date('1970-01-01T08:00:00.000Z'),
          end_time: new Date('1970-01-01T17:00:00.000Z')
        });
      }
    });

    await prisma.schedules.createMany({
      data: schedules,
      skipDuplicates: true
    });

    // ===== Add medical records =====
    console.log('Adding medical records...');
    const appointments = await prisma.appointments.findMany({
      where: { status: 'CHECKED_IN' }
    });

    for (const appointment of appointments) {
      let diagnosis, notes, examResults;

      if (appointment.patient_id === 31) {
        diagnosis = 'Hypertension - Stage 1';
        notes = 'Patient reports occasional headaches. BP readings elevated. Prescribed medication and lifestyle changes.';
        examResults = 'Blood Pressure: 145/92 mmHg, Heart Rate: 78 bpm, Weight: 75.5 kg, Height: 170 cm';
      } else if (appointment.patient_id === 32) {
        diagnosis = 'Acute Upper Respiratory Infection';
        notes = 'Patient presents with cough, sore throat, and mild fever. Prescribed antibiotics and rest.';
        examResults = 'Temperature: 38.2°C, Blood Pressure: 120/80 mmHg, Oxygen Saturation: 98%';
      } else {
        diagnosis = 'Regular Health Checkup';
        notes = 'Routine examination shows patient in good health. Recommended annual checkup.';
        examResults = 'Blood Pressure: 118/76 mmHg, Heart Rate: 72 bpm, Temperature: 36.8°C';
      }

      await prisma.medical_records.upsert({
        where: { id: appointment.id }, // This might not work, but let's try
        update: {},
        create: {
          appointment_id: appointment.id,
          patient_id: appointment.patient_id,
          doctor_id: appointment.doctor_id,
          diagnosis,
          notes,
          exam_results: examResults,
          attachments: []
        }
      });
    }

    // ===== Add stocks =====
    console.log('Adding stocks...');
    const medicines = await prisma.medicines.findMany();

    for (const medicine of medicines) {
      let quantity;

      switch (medicine.name) {
        case 'Paracetamol':
          quantity = 500;
          break;
        case 'Ibuprofen':
          quantity = 300;
          break;
        case 'Amoxicillin':
          quantity = 200;
          break;
        default:
          quantity = 100;
      }

      await prisma.stocks.upsert({
        where: {
          medicine_id_batch_number: {
            medicine_id: medicine.id,
            batch_number: `BATCH-${medicine.id}-001`
          }
        },
        update: {},
        create: {
          medicine_id: medicine.id,
          batch_number: `BATCH-${medicine.id}-001`,
          quantity,
          expiry_date: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000) // 1 year from now
        }
      });
    }

    // ===== Add prescriptions =====
    console.log('Adding prescriptions...');
    const medicalRecords = await prisma.medical_records.findMany();

    for (const record of medicalRecords) {
      let items, totalAmount;

      if (record.diagnosis?.includes('Hypertension')) {
        items = [
          {
            medicine_id: 1,
            medicine_name: 'Paracetamol',
            quantity: 20,
            unit_price: 10000,
            instructions: 'Take 2 tablets every 6 hours as needed for pain',
            dosage: '500mg'
          },
          {
            medicine_id: 2,
            medicine_name: 'Ibuprofen',
            quantity: 15,
            unit_price: 15000,
            instructions: 'Take 1 tablet every 8 hours for inflammation',
            dosage: '400mg'
          }
        ];
        totalAmount = 550000;
      } else if (record.diagnosis?.includes('Respiratory')) {
        items = [
          {
            medicine_id: 3,
            medicine_name: 'Amoxicillin',
            quantity: 14,
            unit_price: 20000,
            instructions: 'Take 1 capsule every 8 hours for 7 days',
            dosage: '500mg'
          }
        ];
        totalAmount = 280000;
      } else {
        items = [
          {
            medicine_id: 1,
            medicine_name: 'Paracetamol',
            quantity: 10,
            unit_price: 10000,
            instructions: 'Take 1-2 tablets every 4-6 hours as needed',
            dosage: '500mg'
          }
        ];
        totalAmount = 100000;
      }

      await prisma.prescriptions.create({
        data: {
          appointment_id: record.appointment_id,
          medical_record_id: record.id,
          doctor_id: record.doctor_id,
          patient_id: record.patient_id,
          items,
          total_amount: totalAmount,
          status: 'APPROVED'
        }
      });
    }

    // ===== Add suppliers =====
    console.log('Adding suppliers...');
    await prisma.suppliers.createMany({
      data: [
        {
          name: 'MedPharm Corp',
          contact_info: {
            person: 'Mr. Nguyen',
            phone: '028-12345678',
            email: 'contact@medpharm.vn',
            address: '123 Industrial Zone, HCMC'
          }
        },
        {
          name: 'HealthCare Supplies',
          contact_info: {
            person: 'Ms. Tran',
            phone: '028-87654321',
            email: 'sales@healthcare.vn',
            address: '456 Business District, HCMC'
          }
        }
      ],
      skipDuplicates: true
    });

    // ===== Add invoices =====
    console.log('Adding invoices...');
    const prescriptions = await prisma.prescriptions.findMany();

    for (const prescription of prescriptions) {
      await prisma.invoices.create({
        data: {
          appointment_id: prescription.appointment_id,
          patient_id: prescription.patient_id,
          prescription_id: prescription.id,
          items: prescription.items,
          total: prescription.total_amount,
          status: prescription.status === 'DISPENSED' ? 'PAID' : 'UNPAID'
        }
      });
    }

    // ===== Add lab orders =====
    console.log('Adding lab orders...');
    const sampleRecords = medicalRecords.slice(0, 2);

    for (const record of sampleRecords) {
      let tests;

      if (record.diagnosis?.includes('Hypertension')) {
        tests = [
          { test_code: 'CBC', name: 'Complete Blood Count', price: 150000 },
          { test_code: 'LIPID', name: 'Lipid Profile', price: 200000 },
          { test_code: 'ECG', name: 'Electrocardiogram', price: 100000 }
        ];
      } else if (record.diagnosis?.includes('Respiratory')) {
        tests = [
          { test_code: 'CBC', name: 'Complete Blood Count', price: 150000 },
          { test_code: 'CHEST_XRAY', name: 'Chest X-Ray', price: 180000 }
        ];
      } else {
        tests = [
          { test_code: 'CBC', name: 'Complete Blood Count', price: 150000 }
        ];
      }

      await prisma.lab_orders.create({
        data: {
          appointment_id: record.appointment_id,
          medical_record_id: record.id,
          patient_id: record.patient_id,
          doctor_id: record.doctor_id,
          tests,
          status: 'PENDING'
        }
      });
    }

    // ===== Add notifications =====
    console.log('Adding notifications...');
    const users = await prisma.users.findMany({
      where: { email: { contains: '@example.' } }
    });

    for (const user of users) {
      let payload;

      if (user.email.includes('dr')) {
        payload = {
          title: 'New Appointment Scheduled',
          message: 'You have a new appointment scheduled for tomorrow'
        };
      } else if (user.email.includes('patient')) {
        payload = {
          title: 'Appointment Reminder',
          message: 'Your appointment is confirmed for tomorrow at 9:00 AM'
        };
      } else {
        payload = {
          title: 'System Notification',
          message: 'Welcome to the clinic management system'
        };
      }

      await prisma.notifications.create({
        data: {
          user_id: user.id,
          type: 'INFO',
          payload,
          is_read: false
        }
      });
    }

    // ===== Add audit logs =====
    console.log('Adding audit logs...');
    const sampleUsers = users.slice(0, 5);

    for (const user of sampleUsers) {
      let action, meta;

      if (user.email.includes('dr')) {
        action = 'LOGIN';
        meta = { ip: '192.168.1.100', user_agent: 'Chrome/91.0' };
      } else if (user.email.includes('patient')) {
        action = 'VIEW_APPOINTMENT';
        meta = { appointment_id: 1 };
      } else {
        action = 'CREATE_PRESCRIPTION';
        meta = { prescription_id: 1 };
      }

      await prisma.audit_logs.create({
        data: {
          user_id: user.id,
          action,
          meta
        }
      });
    }

    // ===== Add doctor reviews =====
    console.log('Adding doctor reviews...');
    const allDoctors = await prisma.doctors.findMany();
    const allPatients = await prisma.patients.findMany();

    const reviews = [];
    allDoctors.forEach(doctor => {
      allPatients.slice(0, 2).forEach((patient, index) => {
        const rating = (doctor.id + patient.id + index) % 5 + 1;
        let comment;

        switch (rating) {
          case 5: comment = 'Excellent doctor, very professional and caring'; break;
          case 4: comment = 'Good experience, doctor was knowledgeable'; break;
          case 3: comment = 'Satisfactory service'; break;
          default: comment = 'Very helpful and attentive';
        }

        reviews.push({
          doctor_id: doctor.id,
          patient_id: patient.id,
          rating,
          comment
        });
      });
    });

    await prisma.doctor_reviews.createMany({
      data: reviews.slice(0, 8),
      skipDuplicates: true
    });

    console.log('Seeding completed successfully!');

    // ===== Print summary =====
    const summary = await Promise.all([
      prisma.roles.count(),
      prisma.users.count(),
      prisma.doctors.count(),
      prisma.patients.count(),
      prisma.rooms.count(),
      prisma.schedules.count(),
      prisma.timeslots.count(),
      prisma.appointments.count(),
      prisma.medical_records.count(),
      prisma.medicines.count(),
      prisma.stocks.count(),
      prisma.prescriptions.count(),
      prisma.suppliers.count(),
      prisma.invoices.count(),
      prisma.lab_orders.count(),
      prisma.notifications.count(),
      prisma.audit_logs.count(),
      prisma.doctor_reviews.count()
    ]);

    console.log('\n=== DATABASE SUMMARY ===');
    console.log(`Roles: ${summary[0]}`);
    console.log(`Users: ${summary[1]}`);
    console.log(`Doctors: ${summary[2]}`);
    console.log(`Patients: ${summary[3]}`);
    console.log(`Rooms: ${summary[4]}`);
    console.log(`Schedules: ${summary[5]}`);
    console.log(`Timeslots: ${summary[6]}`);
    console.log(`Appointments: ${summary[7]}`);
    console.log(`Medical Records: ${summary[8]}`);
    console.log(`Medicines: ${summary[9]}`);
    console.log(`Stocks: ${summary[10]}`);
    console.log(`Prescriptions: ${summary[11]}`);
    console.log(`Suppliers: ${summary[12]}`);
    console.log(`Invoices: ${summary[13]}`);
    console.log(`Lab Orders: ${summary[14]}`);
    console.log(`Notifications: ${summary[15]}`);
    console.log(`Audit Logs: ${summary[16]}`);
    console.log(`Doctor Reviews: ${summary[17]}`);

  } catch (error) {
    console.error('Seeding failed:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

seedAllTables();