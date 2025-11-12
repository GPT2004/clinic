const prisma = require('../../config/database');
const { APPOINTMENT_STATUS, ROLES } = require('../../config/constants');

class AppointmentService {
  async createAppointment(data, user) {
    // Verify timeslot exists and is available
    const timeslot = await prisma.timeslots.findUnique({
      where: { id: parseInt(data.timeslot_id) },
    });

    if (!timeslot || !timeslot.is_active) {
      throw new Error('Timeslot not available');
    }

    if (timeslot.booked_count >= timeslot.max_patients) {
      throw new Error('Timeslot is fully booked');
    }

    // Get patient_id based on user role
    let patient_id = data.patient_id;
    if (user.role.name === ROLES.PATIENT) {
      const patient = await prisma.patients.findFirst({
        where: { user_id: user.id },
      });
      if (!patient) {
        throw new Error('Patient profile not found');
      }
      patient_id = patient.id;
    }

    // Get doctor_id from timeslot
    const doctor_id = timeslot.doctor_id;

    // Determine appointment status based on user role
    let status = APPOINTMENT_STATUS.PENDING;
    let source = 'web';
    
    if (user.role.name === ROLES.RECEPTIONIST) {
      status = APPOINTMENT_STATUS.CONFIRMED;
      source = 'walk-in';
    } else if (user.role.name === ROLES.PATIENT) {
      source = 'online';
    }

    // Create appointment (trigger will auto-increment booked_count)
    const appointment = await prisma.appointments.create({
      data: {
        patient_id: parseInt(patient_id),
        doctor_id: parseInt(doctor_id),
        timeslot_id: parseInt(data.timeslot_id),
        appointment_date: new Date(data.appointment_date || timeslot.date),
        appointment_time: timeslot.start_time,
        status,
        reason: data.reason,
        source,
        created_by: user.id,
      },
      include: {
        patient: {
          include: {
            user: {
              select: {
                id: true,
                full_name: true,
                phone: true,
                email: true,
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
        timeslot: true,
      },
    });

    return appointment;
  }

  async getAppointments(filters, user) {
    const { status, date, doctor_id, patient_id, page, limit } = filters;
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
    if (status) where.status = status;
    if (doctor_id) where.doctor_id = parseInt(doctor_id);
    if (patient_id) where.patient_id = parseInt(patient_id);
    
    if (date) {
      where.appointment_date = new Date(date);
    }

    const [appointments, total] = await Promise.all([
      prisma.appointments.findMany({
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
                  phone: true,
                  email: true,
                },
              },
            },
          },
          doctor: {
            select: {
    id: true,
    license_number: true,
    specialties: true,  // ← ĐÚNG: lấy từ doctors
    user: {
      select: {
        id: true,
        full_name: true,
        phone: true,
        email: true
      }
    }
  },
          },
          timeslot: true,
        },
        orderBy: [
          { appointment_date: 'desc' },
          { appointment_time: 'desc' },
        ],
      }),
      prisma.appointments.count({ where }),
    ]);

    return {
      appointments,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getAppointmentById(id, user) {
    const appointment = await prisma.appointments.findUnique({
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
        timeslot: true,
        medical_records: {
          orderBy: {
            created_at: 'desc',
          },
        },
      },
    });

    if (!appointment) {
      throw new Error('Appointment not found');
    }

    // Authorization check
    if (user.role.name === ROLES.PATIENT) {
      const patient = await prisma.patients.findFirst({
        where: { user_id: user.id },
      });
      if (!patient || appointment.patient_id !== patient.id) {
        throw new Error('Unauthorized access');
      }
    } else if (user.role.name === ROLES.DOCTOR) {
      const doctor = await prisma.doctors.findFirst({
        where: { user_id: user.id },
      });
      if (!doctor || appointment.doctor_id !== doctor.id) {
        throw new Error('Unauthorized access');
      }
    }

    return appointment;
  }

  async updateAppointment(id, data, user) {
    const appointment = await prisma.appointments.findUnique({
      where: { id: parseInt(id) },
    });

    if (!appointment) {
      throw new Error('Appointment not found');
    }

    // Cannot update completed or cancelled appointments
    if ([APPOINTMENT_STATUS.COMPLETED, APPOINTMENT_STATUS.CANCELLED, APPOINTMENT_STATUS.NO_SHOW].includes(appointment.status)) {
      throw new Error('Cannot update completed, cancelled or no-show appointment');
    }

    const updateData = {};
    
    if (data.appointment_date) {
      updateData.appointment_date = new Date(data.appointment_date);
    }
    if (data.appointment_time) {
      updateData.appointment_time = data.appointment_time;
    }
    if (data.reason) {
      updateData.reason = data.reason;
    }
    if (data.status && [ROLES.ADMIN, ROLES.RECEPTIONIST, ROLES.DOCTOR].includes(user.role.name)) {
      updateData.status = data.status;
    }

    updateData.updated_at = new Date();

    const updated = await prisma.appointments.update({
      where: { id: parseInt(id) },
      data: updateData,
      include: {
        patient: {
          include: {
            user: {
              select: {
                full_name: true,
                phone: true,
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
        timeslot: true,
      },
    });

    return updated;
  }

  async confirmAppointment(id) {
    const appointment = await prisma.appointments.findUnique({
      where: { id: parseInt(id) },
    });

    if (!appointment) {
      throw new Error('Appointment not found');
    }

    if (appointment.status !== APPOINTMENT_STATUS.PENDING) {
      throw new Error('Only pending appointments can be confirmed');
    }

    const updated = await prisma.appointments.update({
      where: { id: parseInt(id) },
      data: {
        status: APPOINTMENT_STATUS.CONFIRMED,
        updated_at: new Date(),
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
      },
    });

    return updated;
  }

  async cancelAppointment(id, reason, user) {
    const appointment = await prisma.appointments.findUnique({
      where: { id: parseInt(id) },
    });

    if (!appointment) {
      throw new Error('Appointment not found');
    }

    if (appointment.status === APPOINTMENT_STATUS.COMPLETED) {
      throw new Error('Cannot cancel completed appointment');
    }

    // Check cancellation time (24 hours before for patients)
    if (user.role.name === ROLES.PATIENT) {
      const appointmentDateTime = new Date(appointment.appointment_date);
      const now = new Date();
      const hoursBeforeAppointment = (appointmentDateTime - now) / (1000 * 60 * 60);
      
      if (hoursBeforeAppointment < 24) {
        throw new Error('Cannot cancel appointment less than 24 hours before scheduled time. Please contact reception.');
      }
    }

    // Update appointment status (trigger will auto-decrement booked_count)
    const updated = await prisma.appointments.update({
      where: { id: parseInt(id) },
      data: {
        status: APPOINTMENT_STATUS.CANCELLED,
        reason: reason ? `${appointment.reason || ''}\nCancellation reason: ${reason}` : appointment.reason,
        updated_at: new Date(),
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
      },
    });

    return updated;
  }

  async checkInAppointment(id) {
    const appointment = await prisma.appointments.findUnique({
      where: { id: parseInt(id) },
    });

    if (!appointment) {
      throw new Error('Appointment not found');
    }

    if (appointment.status !== APPOINTMENT_STATUS.CONFIRMED) {
      throw new Error('Only confirmed appointments can be checked in');
    }

    const updated = await prisma.appointments.update({
      where: { id: parseInt(id) },
      data: {
        status: APPOINTMENT_STATUS.CHECKED_IN,
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

  async startAppointment(id) {
    const appointment = await prisma.appointments.findUnique({
      where: { id: parseInt(id) },
    });

    if (!appointment) {
      throw new Error('Appointment not found');
    }

    if (appointment.status !== APPOINTMENT_STATUS.CHECKED_IN) {
      throw new Error('Patient must be checked in first');
    }

    const updated = await prisma.appointments.update({
      where: { id: parseInt(id) },
      data: {
        status: APPOINTMENT_STATUS.IN_PROGRESS,
        updated_at: new Date(),
      },
    });

    return updated;
  }

  async completeAppointment(id) {
    const appointment = await prisma.appointments.findUnique({
      where: { id: parseInt(id) },
    });

    if (!appointment) {
      throw new Error('Appointment not found');
    }

    if (appointment.status !== APPOINTMENT_STATUS.IN_PROGRESS) {
      throw new Error('Only in-progress appointments can be completed');
    }

    const updated = await prisma.appointments.update({
      where: { id: parseInt(id) },
      data: {
        status: APPOINTMENT_STATUS.COMPLETED,
        updated_at: new Date(),
      },
    });

    return updated;
  }

  async markNoShow(id) {
    const appointment = await prisma.appointments.findUnique({
      where: { id: parseInt(id) },
    });

    if (!appointment) {
      throw new Error('Appointment not found');
    }

    if (![APPOINTMENT_STATUS.CONFIRMED, APPOINTMENT_STATUS.CHECKED_IN].includes(appointment.status)) {
      throw new Error('Only confirmed or checked-in appointments can be marked as no-show');
    }

    const updated = await prisma.appointments.update({
      where: { id: parseInt(id) },
      data: {
        status: APPOINTMENT_STATUS.NO_SHOW,
        updated_at: new Date(),
      },
    });

    return updated;
  }
}

module.exports = new AppointmentService();