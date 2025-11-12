const prisma = require('../../config/database');
const { ROLES } = require('../../config/constants');

class MedicalRecordService {
  async createMedicalRecord(data, user) {
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

    // Verify patient exists
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

      if (appointment.patient_id !== parseInt(data.patient_id)) {
        throw new Error('Appointment does not belong to this patient');
      }
    }

    // Create medical record
    const record = await prisma.medical_records.create({
      data: {
        appointment_id: data.appointment_id ? parseInt(data.appointment_id) : null,
        patient_id: parseInt(data.patient_id),
        doctor_id: parseInt(doctor_id),
        diagnosis: data.diagnosis,
        notes: data.notes,
        attachments: data.attachments || null,
      },
      include: {
        patient: {
          include: {
            user: {
              select: {
                id: true,
                full_name: true,
                dob: true,
              },
            },
          },
        },
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
        appointment: {
          select: {
            appointment_date: true,
            appointment_time: true,
          },
        },
      },
    });

    return record;
  }

  async getMedicalRecords(filters, user) {
    const { patient_id, doctor_id, page, limit } = filters;
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
    }

    // Additional filters
    if (patient_id) where.patient_id = parseInt(patient_id);
    if (doctor_id) where.doctor_id = parseInt(doctor_id);

    const [records, total] = await Promise.all([
      prisma.medical_records.findMany({
        where,
        skip,
        take: limit,
        include: {
          patient: {
            include: {
              user: {
                select: {
                  id: true,
                  full_name: true,
                  dob: true,
                },
              },
            },
          },
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
          appointment: {
            select: {
              appointment_date: true,
              appointment_time: true,
            },
          },
        },
        orderBy: {
          created_at: 'desc',
        },
      }),
      prisma.medical_records.count({ where }),
    ]);

    return {
      records,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getMedicalRecordById(id, user) {
    const record = await prisma.medical_records.findUnique({
      where: { id: parseInt(id) },
      include: {
        patient: {
          include: {
            user: {
              select: {
                id: true,
                full_name: true,
                phone: true,
                email: true,
                dob: true,
              },
            },
          },
        },
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
        appointment: {
          select: {
            id: true,
            appointment_date: true,
            appointment_time: true,
            reason: true,
          },
        },
      },
    });

    if (!record) {
      throw new Error('Medical record not found');
    }

    // Authorization check
    if (user.role.name === ROLES.PATIENT) {
      const patient = await prisma.patients.findFirst({
        where: { user_id: user.id },
      });
      if (!patient || record.patient_id !== patient.id) {
        throw new Error('Unauthorized access');
      }
    } else if (user.role.name === ROLES.DOCTOR) {
      const doctor = await prisma.doctors.findFirst({
        where: { user_id: user.id },
      });
      if (!doctor || record.doctor_id !== doctor.id) {
        throw new Error('Unauthorized access');
      }
    }

    return record;
  }

  async updateMedicalRecord(id, data, user) {
    const record = await prisma.medical_records.findUnique({
      where: { id: parseInt(id) },
    });

    if (!record) {
      throw new Error('Medical record not found');
    }

    // Authorization check - only the doctor who created it can update
    if (user.role.name === ROLES.DOCTOR) {
      const doctor = await prisma.doctors.findFirst({
        where: { user_id: user.id },
      });
      if (!doctor || record.doctor_id !== doctor.id) {
        throw new Error('Unauthorized access');
      }
    }

    const updateData = {};
    if (data.diagnosis) updateData.diagnosis = data.diagnosis;
    if (data.notes) updateData.notes = data.notes;
    if (data.attachments) updateData.attachments = data.attachments;
    updateData.updated_at = new Date();

    const updated = await prisma.medical_records.update({
      where: { id: parseInt(id) },
      data: updateData,
      include: {
        patient: {
          include: {
            user: {
              select: {
                full_name: true,
              },
            },
          },
        },
        doctor: {
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

  async deleteMedicalRecord(id, user) {
    const record = await prisma.medical_records.findUnique({
      where: { id: parseInt(id) },
    });

    if (!record) {
      throw new Error('Medical record not found');
    }

    // Only admin can delete medical records
    if (user.role.name !== ROLES.ADMIN) {
      throw new Error('Only administrators can delete medical records');
    }

    await prisma.medical_records.delete({
      where: { id: parseInt(id) },
    });

    return { message: 'Medical record deleted successfully' };
  }

  async getPatientMedicalHistory(patient_id, user) {
    // Authorization check
    if (user.role.name === ROLES.PATIENT) {
      const patient = await prisma.patients.findFirst({
        where: { user_id: user.id },
      });
      if (!patient || patient.id !== parseInt(patient_id)) {
        throw new Error('Unauthorized access');
      }
    }

    const records = await prisma.medical_records.findMany({
      where: {
        patient_id: parseInt(patient_id),
      },
      include: {
        doctor: {
          include: {
            user: {
              select: {
                full_name: true,
                specialties: true,
              },
            },
          },
        },
        appointment: {
          select: {
            appointment_date: true,
            appointment_time: true,
            reason: true,
          },
        },
      },
      orderBy: {
        created_at: 'desc',
      },
    });

    // Get patient info
    const patient = await prisma.patients.findUnique({
      where: { id: parseInt(patient_id) },
      include: {
        user: {
          select: {
            full_name: true,
            dob: true,
            phone: true,
            email: true,
          },
        },
      },
    });

    return {
      patient,
      records,
      total_visits: records.length,
    };
  }

  async addAttachment(id, file, user) {
    const record = await prisma.medical_records.findUnique({
      where: { id: parseInt(id) },
    });

    if (!record) {
      throw new Error('Medical record not found');
    }

    // Authorization check
    if (user.role.name === ROLES.DOCTOR) {
      const doctor = await prisma.doctors.findFirst({
        where: { user_id: user.id },
      });
      if (!doctor || record.doctor_id !== doctor.id) {
        throw new Error('Unauthorized access');
      }
    }

    // Get existing attachments
    let attachments = record.attachments || [];
    if (typeof attachments === 'string') {
      attachments = JSON.parse(attachments);
    }

    // Add new attachment
    const newAttachment = {
      filename: file.originalname,
      path: file.path,
      mimetype: file.mimetype,
      size: file.size,
      uploaded_at: new Date(),
    };

    attachments.push(newAttachment);

    // Update record
    const updated = await prisma.medical_records.update({
      where: { id: parseInt(id) },
      data: {
        attachments: attachments,
        updated_at: new Date(),
      },
    });

    return updated;
  }
}

module.exports = new MedicalRecordService();