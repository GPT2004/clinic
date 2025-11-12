const prisma = require('../../config/database');
const { ROLES, PRESCRIPTION_STATUS } = require('../../config/constants');

class PrescriptionService {
  async createPrescription(data, user) {
    // Verify doctor
    let doctor_id = data.doctor_id;
    if (user.role.name === ROLES.DOCTOR) {
      const doctor = await prisma.doctors.findFirst({
        where: { user_id: user.id },
      });
      if (!doctor) {
        throw new Error('Doctor profile not found');
      }
      doctor_id = doctor.id;
    }

    // Verify patient
    const patient = await prisma.patients.findUnique({
      where: { id: parseInt(data.patient_id) },
    });

    if (!patient) {
      throw new Error('Patient not found');
    }

    // Verify appointment if provided
    if (data.appointment_id) {
      const appointment = await prisma.appointments.findUnique({
        where: { id: parseInt(data.appointment_id) },
      });

      if (!appointment) {
        throw new Error('Appointment not found');
      }
    }

    // Verify medicines and calculate total
    let total_amount = 0;
    const items = [];

    for (const item of data.items) {
      const medicine = await prisma.medicines.findUnique({
        where: { id: parseInt(item.medicine_id) },
      });

      if (!medicine) {
        throw new Error(`Medicine with ID ${item.medicine_id} not found`);
      }

      const unit_price = item.unit_price || medicine.price;
      const itemTotal = unit_price * item.quantity;
      
      items.push({
        medicine_id: medicine.id,
        medicine_name: medicine.name,
        quantity: item.quantity,
        unit_price: unit_price,
        instructions: item.instructions || '',
        dosage: item.dosage || '',
      });

      total_amount += itemTotal;
    }

    // Create prescription
    const prescription = await prisma.prescriptions.create({
      data: {
        appointment_id: data.appointment_id ? parseInt(data.appointment_id) : null,
        doctor_id: parseInt(doctor_id),
        patient_id: parseInt(data.patient_id),
        items: items,
        total_amount: total_amount,
        status: PRESCRIPTION_STATUS.DRAFT,
      },
      include: {
        doctor: {
          include: {
            user: {
              select: {
                full_name: true,
              },
            },
          },
        },
        patient: {
          include: {
            user: {
              select: {
                full_name: true,
              },
            },
          },
        },
      },
    });

    return prescription;
  }

  async getPrescriptions(filters, user) {
    const { patient_id, doctor_id, status, page, limit } = filters;
    const skip = (page - 1) * limit;

    const where = {};

    // Role-based filtering
    if (user.role.name === ROLES.PATIENT) {
      const patient = await prisma.patients.findFirst({
        where: { user_id: user.id },
      });
      if (patient) {
        where.patient_id = patient.id;
      }
    } else if (user.role.name === ROLES.DOCTOR) {
      const doctor = await prisma.doctors.findFirst({
        where: { user_id: user.id },
      });
      if (doctor) {
        where.doctor_id = doctor.id;
      }
    } else if (user.role.name === ROLES.PHARMACIST) {
      // Pharmacist sees only approved prescriptions
      where.status = PRESCRIPTION_STATUS.APPROVED;
    }

    // Additional filters
    if (patient_id) where.patient_id = parseInt(patient_id);
    if (doctor_id) where.doctor_id = parseInt(doctor_id);
    if (status) where.status = status;

    const [prescriptions, total] = await Promise.all([
      prisma.prescriptions.findMany({
        where,
        skip,
        take: limit,
        include: {
          doctor: {
            include: {
              user: {
                select: {
                  id: true,
                  full_name: true,
                },
              },
            },
          },
          patient: {
            include: {
              user: {
                select: {
                  id: true,
                  full_name: true,
                  phone: true,
                },
              },
            },
          },
          appointment: {
            select: {
              appointment_date: true,
            },
          },
        },
        orderBy: {
          created_at: 'desc',
        },
      }),
      prisma.prescriptions.count({ where }),
    ]);

    return {
      prescriptions,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getPrescriptionById(id, user) {
    const prescription = await prisma.prescriptions.findUnique({
      where: { id: parseInt(id) },
      include: {
        doctor: {
          include: {
            user: {
              select: {
                id: true,
                full_name: true,
                phone: true,
              },
            },
          },
        },
        patient: {
          include: {
            user: {
              select: {
                id: true,
                full_name: true,
                phone: true,
                dob: true,
              },
            },
          },
        },
        appointment: {
          select: {
            id: true,
            appointment_date: true,
            reason: true,
          },
        },
      },
    });

    if (!prescription) {
      throw new Error('Prescription not found');
    }

    // Authorization check
    if (user.role.name === ROLES.PATIENT) {
      const patient = await prisma.patients.findFirst({
        where: { user_id: user.id },
      });
      if (!patient || prescription.patient_id !== patient.id) {
        throw new Error('Unauthorized access');
      }
    } else if (user.role.name === ROLES.DOCTOR) {
      const doctor = await prisma.doctors.findFirst({
        where: { user_id: user.id },
      });
      if (!doctor || prescription.doctor_id !== doctor.id) {
        throw new Error('Unauthorized access');
      }
    }

    return prescription;
  }

  async updatePrescription(id, data, user) {
    const prescription = await prisma.prescriptions.findUnique({
      where: { id: parseInt(id) },
    });

    if (!prescription) {
      throw new Error('Prescription not found');
    }

    // Can only update DRAFT prescriptions
    if (prescription.status !== PRESCRIPTION_STATUS.DRAFT) {
      throw new Error('Can only update draft prescriptions');
    }

    // Authorization check
    if (user.role.name === ROLES.DOCTOR) {
      const doctor = await prisma.doctors.findFirst({
        where: { user_id: user.id },
      });
      if (!doctor || prescription.doctor_id !== doctor.id) {
        throw new Error('Unauthorized access');
      }
    }

    const updateData = {};

    // Update items if provided
    if (data.items) {
      let total_amount = 0;
      const items = [];

      for (const item of data.items) {
        const medicine = await prisma.medicines.findUnique({
          where: { id: parseInt(item.medicine_id) },
        });

        if (!medicine) {
          throw new Error(`Medicine with ID ${item.medicine_id} not found`);
        }

        const unit_price = item.unit_price || medicine.price;
        const itemTotal = unit_price * item.quantity;

        items.push({
          medicine_id: medicine.id,
          medicine_name: medicine.name,
          quantity: item.quantity,
          unit_price: unit_price,
          instructions: item.instructions || '',
          dosage: item.dosage || '',
        });

        total_amount += itemTotal;
      }

      updateData.items = items;
      updateData.total_amount = total_amount;
    }

    updateData.updated_at = new Date();

    const updated = await prisma.prescriptions.update({
      where: { id: parseInt(id) },
      data: updateData,
      include: {
        doctor: {
          include: {
            user: {
              select: {
                full_name: true,
              },
            },
          },
        },
        patient: {
          include: {
            user: {
              select: {
                full_name: true,
              },
            },
          },
        },
      },
    });

    return updated;
  }

  async approvePrescription(id, user) {
    const prescription = await prisma.prescriptions.findUnique({
      where: { id: parseInt(id) },
    });

    if (!prescription) {
      throw new Error('Prescription not found');
    }

    if (prescription.status !== PRESCRIPTION_STATUS.DRAFT) {
      throw new Error('Only draft prescriptions can be approved');
    }

    // Authorization check - must be the doctor who created it
    if (user.role.name === ROLES.DOCTOR) {
      const doctor = await prisma.doctors.findFirst({
        where: { user_id: user.id },
      });
      if (!doctor || prescription.doctor_id !== doctor.id) {
        throw new Error('Unauthorized access');
      }
    }

    const updated = await prisma.prescriptions.update({
      where: { id: parseInt(id) },
      data: {
        status: PRESCRIPTION_STATUS.APPROVED,
        updated_at: new Date(),
      },
      include: {
        patient: {
          include: {
            user: true,
          },
        },
      },
    });

    return updated;
  }

  async dispensePrescription(id) {
    const prescription = await prisma.prescriptions.findUnique({
      where: { id: parseInt(id) },
    });

    if (!prescription) {
      throw new Error('Prescription not found');
    }

    if (prescription.status !== PRESCRIPTION_STATUS.APPROVED) {
      throw new Error('Only approved prescriptions can be dispensed');
    }

    // Check stock availability and update stock
    const items = typeof prescription.items === 'string' 
      ? JSON.parse(prescription.items) 
      : prescription.items;

    for (const item of items) {
      // Get available stock
      const stocks = await prisma.stocks.findMany({
        where: {
          medicine_id: item.medicine_id,
          expiry_date: { gt: new Date() },
          quantity: { gt: 0 },
        },
        orderBy: {
          expiry_date: 'asc', // Use oldest first
        },
      });

      let remainingQty = item.quantity;
      
      for (const stock of stocks) {
        if (remainingQty <= 0) break;

        const deductQty = Math.min(stock.quantity, remainingQty);
        
        await prisma.stocks.update({
          where: { id: stock.id },
          data: {
            quantity: stock.quantity - deductQty,
            updated_at: new Date(),
          },
        });

        remainingQty -= deductQty;
      }

      if (remainingQty > 0) {
        throw new Error(`Insufficient stock for medicine: ${item.medicine_name}`);
      }
    }

    // Update prescription status
    const updated = await prisma.prescriptions.update({
      where: { id: parseInt(id) },
      data: {
        status: PRESCRIPTION_STATUS.DISPENSED,
        updated_at: new Date(),
      },
    });

    return updated;
  }

  async deletePrescription(id, user) {
    const prescription = await prisma.prescriptions.findUnique({
      where: { id: parseInt(id) },
    });

    if (!prescription) {
      throw new Error('Prescription not found');
    }

    // Can only delete DRAFT prescriptions
    if (prescription.status !== PRESCRIPTION_STATUS.DRAFT) {
      throw new Error('Can only delete draft prescriptions');
    }

    // Authorization check
    if (user.role.name === ROLES.DOCTOR) {
      const doctor = await prisma.doctors.findFirst({
        where: { user_id: user.id },
      });
      if (!doctor || prescription.doctor_id !== doctor.id) {
        throw new Error('Unauthorized access');
      }
    }

    await prisma.prescriptions.delete({
      where: { id: parseInt(id) },
    });

    return { message: 'Prescription deleted successfully' };
  }
}

module.exports = new PrescriptionService();