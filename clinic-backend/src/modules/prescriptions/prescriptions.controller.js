const prescriptionService = require('./prescriptions.service');
const { successResponse } = require('../../utils/response');

class PrescriptionController {
  async createPrescription(req, res, next) {
    try {
      const prescription = await prescriptionService.createPrescription(req.validatedBody, req.user);
      return successResponse(res, prescription, 'Prescription created successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  async getPrescriptions(req, res, next) {
    try {
      const { patient_id, doctor_id, status, page = 1, limit = 10 } = req.query;
      const result = await prescriptionService.getPrescriptions({
        patient_id,
        doctor_id,
        status,
        page: parseInt(page),
        limit: parseInt(limit),
      }, req.user);
      return successResponse(res, result, 'Prescriptions retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getPrescriptionById(req, res, next) {
    try {
      const prescription = await prescriptionService.getPrescriptionById(req.params.id, req.user);
      return successResponse(res, prescription, 'Prescription retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async updatePrescription(req, res, next) {
    try {
      const prescription = await prescriptionService.updatePrescription(
        req.params.id,
        req.validatedBody,
        req.user
      );
      return successResponse(res, prescription, 'Prescription updated successfully');
    } catch (error) {
      next(error);
    }
  }

  async approvePrescription(req, res, next) {
    try {
      const prescription = await prescriptionService.approvePrescription(req.params.id, req.user);
      return successResponse(res, prescription, 'Prescription approved successfully');
    } catch (error) {
      next(error);
    }
  }

  async dispensePrescription(req, res, next) {
    try {
      const prescription = await prescriptionService.dispensePrescription(req.params.id, req.user);
      return successResponse(res, prescription, 'Prescription dispensed successfully');
    } catch (error) {
      next(error);
    }
  }

  async deletePrescription(req, res, next) {
    try {
      await prescriptionService.deletePrescription(req.params.id, req.user);
      return successResponse(res, null, 'Prescription deleted successfully');
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new PrescriptionController();