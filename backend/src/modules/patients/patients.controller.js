const patientsService = require('./patients.service');
const { successResponse } = require('../../utils/response');

class PatientsController {
  async getAllPatients(req, res, next) {
    try {
      const { page = 1, limit = 10, search, gender, blood_type } = req.query;

      const filters = {};
      if (search) filters.search = search;
      if (gender) filters.gender = gender;
      if (blood_type) filters.blood_type = blood_type;

      const result = await patientsService.getAllPatients(filters, {
        page: parseInt(page),
        limit: parseInt(limit)
      });

      return successResponse(res, result, 'Patients retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getPatientById(req, res, next) {
    try {
      const { id } = req.params;
      const userId = req.user.id;
      const userRole = req.user.role.name;

      // If patient, check if they can only view their own profile
      if (userRole === 'Patient') {
        const patient = await patientsService.getPatientByUserId(userId);
        if (patient.id !== parseInt(id)) {
          throw new Error('You can only view your own profile');
        }
      }

      const patient = await patientsService.getPatientById(parseInt(id));

      if (!patient) {
        throw new Error('Patient not found');
      }

      return successResponse(res, patient, 'Patient retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getPatientMedicalRecords(req, res, next) {
    try {
      const { id } = req.params;
      const { page = 1, limit = 20 } = req.query;

      const result = await patientsService.getPatientMedicalRecords(
        parseInt(id),
        { page: parseInt(page), limit: parseInt(limit) }
      );

      return successResponse(res, result, 'Medical records retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getPatientAppointments(req, res, next) {
    try {
      const { id } = req.params;
      const { status, startDate, endDate, page = 1, limit = 20 } = req.query;

      const filters = {};
      if (status) filters.status = status;
      if (startDate) filters.startDate = startDate;
      if (endDate) filters.endDate = endDate;

      const result = await patientsService.getPatientAppointments(
        parseInt(id),
        filters,
        { page: parseInt(page), limit: parseInt(limit) }
      );

      return successResponse(res, result, 'Appointments retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getPatientPrescriptions(req, res, next) {
    try {
      const { id } = req.params;
      const { page = 1, limit = 20 } = req.query;

      const result = await patientsService.getPatientPrescriptions(
        parseInt(id),
        { page: parseInt(page), limit: parseInt(limit) }
      );

      return successResponse(res, result, 'Prescriptions retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getPatientInvoices(req, res, next) {
    try {
      const { id } = req.params;
      const { status, page = 1, limit = 20 } = req.query;

      const filters = {};
      if (status) filters.status = status;

      const result = await patientsService.getPatientInvoices(
        parseInt(id),
        filters,
        { page: parseInt(page), limit: parseInt(limit) }
      );

      return successResponse(res, result, 'Invoices retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getMyProfile(req, res, next) {
    try {
      const userId = req.user.id;
      const patient = await patientsService.getPatientByUserId(userId);

      if (!patient) {
        throw new Error('Patient profile not found');
      }

      return successResponse(res, patient, 'Profile retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async updateMyProfile(req, res, next) {
    try {
      const userId = req.user.id;
      const updateData = req.validatedBody;

      const updatedPatient = await patientsService.updatePatientProfile(
        userId,
        updateData
      );

      if (!updatedPatient) {
        throw new Error('Patient profile not found');
      }

      return successResponse(res, updatedPatient, 'Profile updated successfully');
    } catch (error) {
      next(error);
    }
  }

  async createPatient(req, res, next) {
    try {
      const patientData = req.validatedBody;
      const newPatient = await patientsService.createPatient(patientData);

      return successResponse(res, newPatient, 'Patient created successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  async updatePatient(req, res, next) {
    try {
      const { id } = req.params;
      const updateData = req.validatedBody;

      const updatedPatient = await patientsService.updatePatient(
        parseInt(id),
        updateData
      );

      if (!updatedPatient) {
        throw new Error('Patient not found');
      }

      return successResponse(res, updatedPatient, 'Patient updated successfully');
    } catch (error) {
      next(error);
    }
  }

  async deletePatient(req, res, next) {
    try {
      const { id } = req.params;
      await patientsService.deletePatient(parseInt(id));

      return successResponse(res, null, 'Patient deleted successfully');
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new PatientsController();