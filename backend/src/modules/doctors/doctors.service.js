/* eslint-disable no-console */
const prisma = require('../../config/database');
const { hashPassword } = require('../../utils/bcrypt');
const { ROLES } = require('../../config/constants');

class DoctorsService {
  async getAllDoctors(filters = {}, pagination = { page: 1, limit: 10 }) {
    try {
      const { page, limit } = pagination;
      const skip = (page - 1) * limit;

      const where = {};

      if (filters.specialty) {
        where.specialties = {
          has: filters.specialty // Dùng 'has' cho String[]
        };
      }

      if (filters.is_active !== undefined) {
        where.user = {
          is_active: filters.is_active
        };
      }

      if (filters.search) {
        where.user = {
          ...where.user,
          full_name: {
            contains: filters.search,
            mode: 'insensitive'
          }
        };
      }

      const [total, doctors] = await Promise.all([
        prisma.doctors.count({ where }),
        prisma.doctors.findMany({
          where,
          skip,
          take: limit,
          include: {
            user: {
              select: {
                id: true,
                full_name: true,
                email: true,
                phone: true,
                avatar_url: true,
                is_active: true
              }
            },
            _count: {
              select: {
                appointments: true
              }
            }
          },
          orderBy: {
            user: {
              full_name: 'asc'
            }
          }
        })
      ]);

      return {
        doctors,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      console.error('Error in getAllDoctors:', error);
      throw error;
    }
  }

  async getDoctorById(id, publicView = false) {
    try {
      const doctor = await prisma.doctors.findUnique({
        where: { id },
        include: {
          user: {
            select: {
              id: true,
              full_name: true,
              email: publicView ? false : true,
              phone: true,
              avatar_url: true,
              is_active: true,
              dob: publicView ? false : true
            }
          },
          _count: {
            select: {
              appointments: true,
              schedules: true
            }
          }
        }
      });

      return doctor;
    } catch (error) {
      console.error('Error in getDoctorById:', error);
      throw error;
    }
  }

  async getSpecialties() {
    try {
      const doctors = await prisma.doctors.findMany({
        where: {
          specialties: { not: null }
        },
        select: {
          specialties: true
        }
      });

      const specialtiesSet = new Set();

      doctors.forEach(doctor => {
        if (Array.isArray(doctor.specialties)) {
          doctor.specialties.forEach(spec => specialtiesSet.add(spec));
        }
      });

      return Array.from(specialtiesSet).sort();
    } catch (error) {
      console.error('Error in getSpecialties:', error);
      throw error;
    }
  }

  async getDoctorAppointments(doctorId, filters = {}, pagination = { page: 1, limit: 20 }) {
    try {
      const { page, limit } = pagination;
      const skip = (page - 1) * limit;

      const where = { doctor_id: doctorId };

      if (filters.startDate || filters.endDate) {
        where.appointment_date = {};
        if (filters.startDate) where.appointment_date.gte = new Date(filters.startDate);
        if (filters.endDate) where.appointment_date.lte = new Date(filters.endDate);
      }

      if (filters.status) {
        where.status = filters.status;
      }

      const [total, appointments] = await Promise.all([
        prisma.appointments.count({ where }),
        prisma.appointments.findMany({
          where,
          skip,
          take: limit,
          include: {
            patients: {
              include: {
                user: {
                  select: {
                    full_name: true,
                    phone: true
                  }
                }
              }
            },
            timeslots: true
          },
          orderBy: [
            { appointment_date: 'desc' },
            { appointment_time: 'desc' }
          ]
        })
      ]);

      return {
        appointments,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      console.error('Error in getDoctorAppointments:', error);
      throw error;
    }
  }

  async getDoctorSchedules(doctorId, startDate, endDate) {
    try {
      const where = { doctor_id: doctorId };

      if (startDate) {
        where.date = { ...where.date, gte: new Date(startDate) };
      }

      if (endDate) {
        where.date = { ...where.date, lte: new Date(endDate) };
      }

      const schedules = await prisma.schedules.findMany({
        where,
        include: {
          rooms: true
        },
        orderBy: [
          { date: 'asc' },
          { start_time: 'asc' }
        ]
      });

      return schedules;
    } catch (error) {
      console.error('Error in getDoctorSchedules:', error);
      throw error;
    }
  }

  async getDoctorPatients(doctorId) {
    try {
      const appointments = await prisma.appointments.findMany({
        where: {
          doctor_id: doctorId,
          status: 'COMPLETED'
        },
        select: {
          patient_id: true
        },
        distinct: ['patient_id']
      });

      const patientIds = appointments.map(a => a.patient_id);

      const patients = await prisma.patients.findMany({
        where: {
          id: { in: patientIds }
        },
        include: {
          user: {
            select: {
              full_name: true,
              phone: true,
              email: true,
              dob: true
            }
          },
          _count: {
            select: {
              appointments: {
                where: {
                  doctor_id: doctorId
                }
              }
            }
          }
        }
      });

      return patients;
    } catch (error) {
      console.error('Error in getDoctorPatients:', error);
      throw error;
    }
  }

  async getDoctorStats(doctorId) {
    try {
      const [
        totalAppointments,
        completedAppointments,
        upcomingAppointments,
        totalPatients,
        totalRevenue
      ] = await Promise.all([
        prisma.appointments.count({
          where: { doctor_id: doctorId }
        }),
        prisma.appointments.count({
          where: {
            doctor_id: doctorId,
            status: 'COMPLETED'
          }
        }),
        prisma.appointments.count({
          where: {
            doctor_id: doctorId,
            appointment_date: { gte: new Date() },
            status: { in: ['PENDING', 'CONFIRMED', 'CHECKED_IN'] }
          }
        }),
        prisma.appointments.findMany({
          where: {
            doctor_id: doctorId,
            status: 'COMPLETED'
          },
          select: { patient_id: true },
          distinct: ['patient_id']
        }),
        prisma.invoices.aggregate({
          where: {
            appointments: {
              doctor_id: doctorId
            },
            status: 'PAID'
          },
          _sum: {
            total: true
          }
        })
      ]);

      return {
        total_appointments: totalAppointments,
        completed_appointments: completedAppointments,
        upcoming_appointments: upcomingAppointments,
        total_patients: totalPatients.length,
        total_revenue: totalRevenue._sum.total || 0
      };
    } catch (error) {
      console.error('Error in getDoctorStats:', error);
      throw error;
    }
  }

  async createDoctor(doctorData) {
  try {
    const {
      email, password, full_name, phone, dob,
      license_number, specialties, bio, consultation_fee
    } = doctorData;

    // XỬ LÝ SPECIALTIES
    let specialtiesArray = [];
    if (typeof specialties === 'string') {
      specialtiesArray = specialties.split(',').map(s => s.trim()).filter(Boolean);
    } else if (Array.isArray(specialties)) {
      specialtiesArray = specialties;
    }

    // KIỂM TRA EMAIL TRÙNG
    const existingUser = await prisma.users.findUnique({ where: { email } });
    if (existingUser) {
      throw new Error('Email already registered');
    }

    // KIỂM TRA ROLE DOCTOR
    if (!prisma?.roles?.findUnique) {
      throw new Error('Prisma client not initialized');
    }

    const doctorRole = await prisma.roles.findUnique({
      where: { name: ROLES.DOCTOR }
    });

    if (!doctorRole) {
      throw new Error('Doctor role not found in database');
    }

    const hashedPassword = await hashPassword(password);

    const result = await prisma.$transaction(async (tx) => {
      const user = await tx.users.create({
        data: {
          email,
          password: hashedPassword,
          full_name,
          phone,
          dob: dob ? new Date(dob) : null,
          role_id: doctorRole.id,
          is_active: true
        }
      });

      const doctor = await tx.doctors.create({
        data: {
          user_id: user.id,
          license_number,
          specialties: specialtiesArray,
          bio,
          consultation_fee: consultation_fee || 0,
          rating: 0
        },
        include: {
          user: {  // ← ĐÃ SỬA TỪ `users` → `user`
            select: {
              id: true,
              full_name: true,
              email: true,
              phone: true
            }
          }
        }
      });

      return doctor;
    });

    return result;
  } catch (error) {
    console.error('Error in createDoctor:', error);
    throw error;
  }
}

  async updateDoctor(id, updateData) {
    try {
      const doctor = await prisma.doctors.findUnique({
        where: { id },
        include: { user: true }
      });

      if (!doctor) {
        return null;
      }

      // Xử lý specialties nếu có
      let specialtiesArray = doctor.specialties;
      if (updateData.specialties) {
        if (typeof updateData.specialties === 'string') {
          specialtiesArray = updateData.specialties
            .split(',')
            .map(s => s.trim())
            .filter(Boolean);
        } else if (Array.isArray(updateData.specialties)) {
          specialtiesArray = updateData.specialties;
        }
      }

      const result = await prisma.$transaction(async (tx) => {
        // Update user info
        const userUpdateData = {};
        if (updateData.full_name) userUpdateData.full_name = updateData.full_name;
        if (updateData.phone) userUpdateData.phone = updateData.phone;
        if (updateData.email) userUpdateData.email = updateData.email;
        if (updateData.dob) userUpdateData.dob = new Date(updateData.dob);

        if (Object.keys(userUpdateData).length > 0) {
          await tx.user.update({
            where: { id: doctor.user_id },
            data: userUpdateData
          });
        }

        // Update doctor info
        const doctorUpdateData = {};
        if (updateData.license_number) doctorUpdateData.license_number = updateData.license_number;
        if (updateData.specialties) doctorUpdateData.specialties = specialtiesArray;
        if (updateData.bio !== undefined) doctorUpdateData.bio = updateData.bio;
        if (updateData.consultation_fee !== undefined) doctorUpdateData.consultation_fee = updateData.consultation_fee;

        const updatedDoctor = await tx.doctors.update({
          where: { id },
          data: doctorUpdateData,
          include: {
            user: {
              select: {
                id: true,
                full_name: true,
                email: true,
                phone: true,
                is_active: true
              }
            }
          }
        });

        return updatedDoctor;
      });

      return result;
    } catch (error) {
      console.error('Error in updateDoctor:', error);
      throw error;
    }
  }

  async updateDoctorProfile(userId, updateData) {
    try {
      const doctor = await prisma.doctors.findFirst({
        where: { user_id: userId }
      });

      if (!doctor) {
        return null;
      }

      let specialtiesArray = doctor.specialties;
      if (updateData.specialties) {
        if (typeof updateData.specialties === 'string') {
          specialtiesArray = updateData.specialties
            .split(',')
            .map(s => s.trim())
            .filter(Boolean);
        } else if (Array.isArray(updateData.specialties)) {
          specialtiesArray = updateData.specialties;
        }
      }

      const result = await prisma.$transaction(async (tx) => {
        // Update user info
        const userUpdateData = {};
        if (updateData.full_name) userUpdateData.full_name = updateData.full_name;
        if (updateData.phone) userUpdateData.phone = updateData.phone;
        if (updateData.avatar_url !== undefined) userUpdateData.avatar_url = updateData.avatar_url;

        if (Object.keys(userUpdateData).length > 0) {
          await tx.user.update({
            where: { id: userId },
            data: userUpdateData
          });
        }

        // Update doctor info
        const doctorUpdateData = {};
        if (updateData.bio !== undefined) doctorUpdateData.bio = updateData.bio;
        if (updateData.specialties) doctorUpdateData.specialties = specialtiesArray;

        const updatedDoctor = await tx.doctors.update({
          where: { id: doctor.id },
          data: doctorUpdateData,
          include: {
            user: {
              select: {
                full_name: true,
                email: true,
                phone: true,
                avatar_url: true
              }
            }
          }
        });

        return updatedDoctor;
      });

      return result;
    } catch (error) {
      console.error('Error in updateDoctorProfile:', error);
      throw error;
    }
  }

  async deleteDoctor(id) {
    try {
      const doctor = await prisma.doctors.findUnique({
        where: { id }
      });

      if (!doctor) {
        throw new Error('Doctor not found');
      }

      const activeAppointments = await prisma.appointments.count({
        where: {
          doctor_id: id,
          appointment_date: { gte: new Date() },
          status: { in: ['PENDING', 'CONFIRMED', 'CHECKED_IN'] }
        }
      });

      if (activeAppointments > 0) {
        throw new Error('Cannot delete doctor with active appointments');
      }

      await prisma.user.delete({
        where: { id: doctor.user_id }
      });
    } catch (error) {
      console.error('Error in deleteDoctor:', error);
      throw error;
    }
  }

  async toggleDoctorStatus(id) {
    try {
      const doctor = await prisma.doctors.findUnique({
        where: { id },
        include: { user: true }
      });

      if (!doctor) {
        throw new Error('Doctor not found');
      }

      await prisma.user.update({
        where: { id: doctor.user_id },
        data: {
          is_active: !doctor.user.is_active
        }
      });

      const updatedDoctor = await prisma.doctors.findUnique({
        where: { id },
        include: {
          user: {
            select: {
              id: true,
              full_name: true,
              email: true,
              is_active: true
            }
          }
        }
      });

      return updatedDoctor;
    } catch (error) {
      console.error('Error in toggleDoctorStatus:', error);
      throw error;
    }
  }
}

module.exports = new DoctorsService();