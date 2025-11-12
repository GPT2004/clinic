const doctorsService = require('./doctors.service');
const { successResponse } = require('../../utils/response');

class DoctorsController {
  async getAllDoctorsPublic(req, res, next) {
    try {
      const { specialty, page = 1, limit = 10, search } = req.query;
      
      const filters = { is_active: true };
      if (specialty) filters.specialty = specialty;
      if (search) filters.search = search;

      const result = await doctorsService.getAllDoctors(filters, {
        page: parseInt(page),
        limit: parseInt(limit)
      });

      return successResponse(res, result, 'Doctors retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getDoctorByIdPublic(req, res, next) {
    try {
      const { id } = req.params;
      const doctor = await doctorsService.getDoctorById(parseInt(id), true);

      if (!doctor) {
        throw new Error('Doctor not found');
      }

      return successResponse(res, doctor, 'Doctor retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getSpecialties(req, res, next) {
    try {
      const specialties = await doctorsService.getSpecialties();
      return successResponse(res, specialties, 'Specialties retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getAllDoctors(req, res, next) {
    try {
      const { specialty, is_active, page = 1, limit = 10, search } = req.query;
      
      const filters = {};
      if (specialty) filters.specialty = specialty;
      if (is_active !== undefined) filters.is_active = is_active === 'true';
      if (search) filters.search = search;

      const result = await doctorsService.getAllDoctors(filters, {
        page: parseInt(page),
        limit: parseInt(limit)
      });

      return successResponse(res, result, 'Doctors retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getDoctorById(req, res, next) {
    try {
      const { id } = req.params;
      const doctor = await doctorsService.getDoctorById(parseInt(id));

      if (!doctor) {
        throw new Error('Doctor not found');
      }

      return successResponse(res, doctor, 'Doctor retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getDoctorAppointments(req, res, next) {
    try {
      const { id } = req.params;
      const { startDate, endDate, status, page = 1, limit = 20 } = req.query;

      const filters = {};
      if (startDate) filters.startDate = startDate;
      if (endDate) filters.endDate = endDate;
      if (status) filters.status = status;

      const result = await doctorsService.getDoctorAppointments(
        parseInt(id),
        filters,
        { page: parseInt(page), limit: parseInt(limit) }
      );

      return successResponse(res, result, 'Doctor appointments retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getDoctorSchedules(req, res, next) {
    try {
      const { id } = req.params;
      const { startDate, endDate } = req.query;

      const schedules = await doctorsService.getDoctorSchedules(
        parseInt(id),
        startDate,
        endDate
      );

      return successResponse(res, schedules, 'Doctor schedules retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getDoctorPatients(req, res, next) {
    try {
      const { id } = req.params;
      const patients = await doctorsService.getDoctorPatients(parseInt(id));

      return successResponse(res, patients, 'Doctor patients retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getDoctorStats(req, res, next) {
    try {
      const { id } = req.params;
      const stats = await doctorsService.getDoctorStats(parseInt(id));

      return successResponse(res, stats, 'Doctor statistics retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async createDoctor(req, res, next) {
    try {
      const doctorData = req.validatedBody;
      const newDoctor = await doctorsService.createDoctor(doctorData);

      return successResponse(res, newDoctor, 'Doctor created successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  async updateDoctor(req, res, next) {
    try {
      const { id } = req.params;
      const updateData = req.validatedBody;

      const updatedDoctor = await doctorsService.updateDoctor(
        parseInt(id),
        updateData
      );

      if (!updatedDoctor) {
        throw new Error('Doctor not found');
      }

      return successResponse(res, updatedDoctor, 'Doctor updated successfully');
    } catch (error) {
      next(error);
    }
  }

  async updateOwnProfile(req, res, next) {
    try {
      const userId = req.user.id;
      const updateData = req.validatedBody;

      const updatedDoctor = await doctorsService.updateDoctorProfile(
        userId,
        updateData
      );

      if (!updatedDoctor) {
        throw new Error('Doctor profile not found');
      }

      return successResponse(res, updatedDoctor, 'Profile updated successfully');
    } catch (error) {
      next(error);
    }
  }

  async deleteDoctor(req, res, next) {
    try {
      const { id } = req.params;
      await doctorsService.deleteDoctor(parseInt(id));

      return successResponse(res, null, 'Doctor deleted successfully');
    } catch (error) {
      next(error);
    }
  }

  async toggleDoctorStatus(req, res, next) {
    try {
      const { id } = req.params;
      const updatedDoctor = await doctorsService.toggleDoctorStatus(parseInt(id));

      return successResponse(res, updatedDoctor, 'Doctor status updated successfully');
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new DoctorsController();