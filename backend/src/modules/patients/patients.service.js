/* eslint-disable no-console */
const prisma = require('../../config/database');
const { hashPassword } = require('../../utils/bcrypt');
const { ROLES } = require('../../config/constants');

class PatientsService {
  async getAllPatients(filters = {}, pagination = { page: 1, limit: 10 }) {
    try {
      const { page, limit } = pagination;
      const skip = (page - 1) * limit;

      const where = {};

      if (filters.gender) {
        where.gender = filters.gender;
      }

      if (filters.blood_type) {
        where.blood_type = filters.blood_type;
      }

      if (filters.search) {
        where.user = {  // ← Fixed: users → user
          OR: [
            {
              full_name: {
                contains: filters.search,
                mode: 'insensitive'
              }
            },
            {
              phone: {
                contains: filters.search,
                mode: 'insensitive'
              }
            },
            {
              email: {
                contains: filters.search,
                mode: 'insensitive'
              }
            }
          ]
        };
      }

      const [total, patients] = await Promise.all([
        prisma.patients.count({ where }),
        prisma.patients.findMany({
          where,
          skip,
          take: limit,
          include: {
            user: {  // ← Fixed: users → user
              select: {
                id: true,
                full_name: true,
                email: true,
                phone: true,
                dob: true,
                avatar_url: true,
                is_active: true,
                created_at: true
              }
            },
            _count: {
              select: {
                appointments: true,
                medical_records: true
              }
            }
          },
          orderBy: {
            created_at: 'desc'
          }
        })
      ]);

      return {
        patients,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      console.error('Error in getAllPatients:', error);
      throw error;
    }
  }

  async getPatientById(id) {
    try {
      const patient = await prisma.patients.findUnique({
        where: { id },
        include: {
          user: {  // ← Fixed: users → user
            select: {
              id: true,
              full_name: true,
              email: true,
              phone: true,
              dob: true,
              avatar_url: true,
              is_active: true,
              created_at: true
            }
          },
          _count: {
            select: {
              appointments: true,
              medical_records: true,
              prescriptions: true,
              invoices: true
            }
          }
        }
      });

      return patient;
    } catch (error) {
      console.error('Error in getPatientById:', error);
      throw error;
    }
  }

  async getPatientByUserId(userId) {
    try {
      const patient = await prisma.patients.findFirst({
        where: { user_id: userId },
        include: {
          user: {  // ← Fixed: users → user
            select: {
              id: true,
              full_name: true,
              email: true,
              phone: true,
              dob: true,
              avatar_url: true
            }
          },
          _count: {
            select: {
              appointments: true,
              medical_records: true
            }
          }
        }
      });

      return patient;
    } catch (error) {
      console.error('Error in getPatientByUserId:', error);
      throw error;
    }
  }

  async getPatientMedicalRecords(patientId, pagination = { page: 1, limit: 20 }) {
    try {
      const { page, limit } = pagination;
      const skip = (page - 1) * limit;

      const where = { patient_id: patientId };

      const [total, records] = await Promise.all([
        prisma.medical_records.count({ where }),
        prisma.medical_records.findMany({
          where,
          skip,
          take: limit,
          include: {
            doctor: {  // ← Fixed: doctors → doctor
              include: {
                user: {  // ← Fixed: users → user
                  select: {
                    full_name: true
                  }
                }
              }
            },
            appointment: {  // ← Fixed: appointments → appointment
              select: {
                appointment_date: true,
                appointment_time: true
              }
            }
          },
          orderBy: {
            created_at: 'desc'
          }
        })
      ]);

      return {
        records,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      console.error('Error in getPatientMedicalRecords:', error);
      throw error;
    }
  }

  async getPatientAppointments(patientId, filters = {}, pagination = { page: 1, limit: 20 }) {
    try {
      const { page, limit } = pagination;
      const skip = (page - 1) * limit;

      const where = { patient_id: patientId };

      if (filters.status) {
        where.status = filters.status;
      }

      if (filters.startDate || filters.endDate) {
        where.appointment_date = {};
        if (filters.startDate) where.appointment_date.gte = new Date(filters.startDate);
        if (filters.endDate) where.appointment_date.lte = new Date(filters.endDate);
      }

      const [total, appointments] = await Promise.all([
        prisma.appointments.count({ where }),
        prisma.appointments.findMany({
          where,
          skip,
          take: limit,
          include: {
            doctor: {  // ← Fixed: doctors → doctor
              include: {
                user: {  // ← Fixed: users → user
                  select: {
                    full_name: true,
                    phone: true
                  }
                }
              }
            },
            timeslot: true  // ← Fixed: timeslots → timeslot
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
      console.error('Error in getPatientAppointments:', error);
      throw error;
    }
  }

  async getPatientPrescriptions(patientId, pagination = { page: 1, limit: 20 }) {
    try {
      const { page, limit } = pagination;
      const skip = (page - 1) * limit;

      const where = { patient_id: patientId };

      const [total, prescriptions] = await Promise.all([
        prisma.prescriptions.count({ where }),
        prisma.prescriptions.findMany({
          where,
          skip,
          take: limit,
          include: {
            doctor: {  // ← Fixed: doctors → doctor
              include: {
                user: {  // ← Fixed: users → user
                  select: {
                    full_name: true
                  }
                }
              }
            },
            appointment: {  // ← Fixed: appointments → appointment
              select: {
                appointment_date: true
              }
            }
          },
          orderBy: {
            created_at: 'desc'
          }
        })
      ]);

      return {
        prescriptions,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      console.error('Error in getPatientPrescriptions:', error);
      throw error;
    }
  }

  async getPatientInvoices(patientId, filters = {}, pagination = { page: 1, limit: 20 }) {
    try {
      const { page, limit } = pagination;
      const skip = (page - 1) * limit;

      const where = { patient_id: patientId };

      if (filters.status) {
        where.status = filters.status;
      }

      const [total, invoices] = await Promise.all([
        prisma.invoices.count({ where }),
        prisma.invoices.findMany({
          where,
          skip,
          take: limit,
          include: {
            appointment: {  // ← Fixed: appointments → appointment
              include: {
                doctor: {  // ← Fixed: doctors → doctor
                  include: {
                    user: {  // ← Fixed: users → user
                      select: {
                        full_name: true
                      }
                    }
                  }
                }
              }
            }
          },
          orderBy: {
            created_at: 'desc'
          }
        })
      ]);

      return {
        invoices,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit)
      };
    } catch (error) {
      console.error('Error in getPatientInvoices:', error);
      throw error;
    }
  }

  async createPatient(patientData) {
    try {
      const {
        email,
        password,
        full_name,
        phone,
        dob,
        gender,
        blood_type,
        allergies,
        emergency_contact
      } = patientData;

      const existingUser = await prisma.users.findUnique({
        where: { email }
      });

      if (existingUser) {
        throw new Error('Email already registered');
      }

      const patientRole = await prisma.roles.findUnique({
        where: { name: ROLES.PATIENT }
      });

      if (!patientRole) {
        throw new Error('Patient role not found');
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
            role_id: patientRole.id,
            is_active: true
          }
        });

        const patient = await tx.patients.create({
          data: {
            user_id: user.id,
            gender,
            blood_type,
            allergies,
            emergency_contact: emergency_contact || {}
          },
          include: {
            user: {  // ← Fixed: users → user
              select: {
                id: true,
                full_name: true,
                email: true,
                phone: true
              }
            }
          }
        });

        return patient;
      });

      return result;
    } catch (error) {
      console.error('Error in createPatient:', error);
      throw error;
    }
  }

  async updatePatient(id, updateData) {
    try {
      const patient = await prisma.patients.findUnique({
        where: { id },
        include: { user: true }  // ← Fixed: users → user
      });

      if (!patient) {
        return null;
      }

      const result = await prisma.$transaction(async (tx) => {
        // Update user info
        const userUpdateData = {};
        if (updateData.full_name) userUpdateData.full_name = updateData.full_name;
        if (updateData.phone) userUpdateData.phone = updateData.phone;
        if (updateData.email) userUpdateData.email = updateData.email;
        if (updateData.dob) userUpdateData.dob = new Date(updateData.dob);

        if (Object.keys(userUpdateData).length > 0) {
          await tx.users.update({
            where: { id: patient.user_id },
            data: userUpdateData
          });
        }

        // Update patient info
        const patientUpdateData = {};
        if (updateData.gender) patientUpdateData.gender = updateData.gender;
        if (updateData.blood_type) patientUpdateData.blood_type = updateData.blood_type;
        if (updateData.allergies !== undefined) patientUpdateData.allergies = updateData.allergies;
        if (updateData.emergency_contact) patientUpdateData.emergency_contact = updateData.emergency_contact;

        const updatedPatient = await tx.patients.update({
          where: { id },
          data: patientUpdateData,
          include: {
            user: {  // ← Fixed: users → user
              select: {
                id: true,
                full_name: true,
                email: true,
                phone: true,
                dob: true
              }
            }
          }
        });

        return updatedPatient;
      });

      return result;
    } catch (error) {
      console.error('Error in updatePatient:', error);
      throw error;
    }
  }

  async updatePatientProfile(userId, updateData) {
    try {
      const patient = await prisma.patients.findFirst({
        where: { user_id: userId }
      });

      if (!patient) {
        return null;
      }

      const result = await prisma.$transaction(async (tx) => {
        // Update user info
        const userUpdateData = {};
        if (updateData.full_name) userUpdateData.full_name = updateData.full_name;
        if (updateData.phone) userUpdateData.phone = updateData.phone;
        if (updateData.avatar_url !== undefined) userUpdateData.avatar_url = updateData.avatar_url;

        if (Object.keys(userUpdateData).length > 0) {
          await tx.users.update({
            where: { id: userId },
            data: userUpdateData
          });
        }

        // Update patient info
        const patientUpdateData = {};
        if (updateData.emergency_contact) patientUpdateData.emergency_contact = updateData.emergency_contact;

        const updatedPatient = await tx.patients.update({
          where: { id: patient.id },
          data: patientUpdateData,
          include: {
            user: {  // ← Fixed: users → user
              select: {
                id: true,
                full_name: true,
                email: true,
                phone: true,
                avatar_url: true,
                dob: true
              }
            }
          }
        });

        return updatedPatient;
      });

      return result;
    } catch (error) {
      console.error('Error in updatePatientProfile:', error);
      throw error;
    }
  }

  async deletePatient(id) {
    try {
      const patient = await prisma.patients.findUnique({
        where: { id }
      });

      if (!patient) {
        throw new Error('Patient not found');
      }

      const activeAppointments = await prisma.appointments.count({
        where: {
          patient_id: id,
          appointment_date: { gte: new Date() },
          status: { in: ['PENDING', 'CONFIRMED', 'CHECKED_IN'] }
        }
      });

      if (activeAppointments > 0) {
        throw new Error('Cannot delete patient with active appointments');
      }

      await prisma.users.delete({
        where: { id: patient.user_id }
      });
    } catch (error) {
      console.error('Error in deletePatient:', error);
      throw error;
    }
  }
}

module.exports = new PatientsService();