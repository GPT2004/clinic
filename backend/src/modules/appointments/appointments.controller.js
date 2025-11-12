const appointmentService = require('./appointments.service');
const { successResponse } = require('../../utils/response');

class AppointmentController {
  async createAppointment(req, res, next) {
    try {
      const appointment = await appointmentService.createAppointment(req.validatedBody, req.user);
      return successResponse(res, appointment, 'Appointment created successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  async getAppointments(req, res, next) {
    try {
      const { status, date, doctor_id, patient_id, page = 1, limit = 10 } = req.query;
      const result = await appointmentService.getAppointments({
        status,
        date,
        doctor_id,
        patient_id,
        page: parseInt(page),
        limit: parseInt(limit),
      }, req.user);
      return successResponse(res, result, 'Appointments retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getAppointmentById(req, res, next) {
    try {
      const appointment = await appointmentService.getAppointmentById(req.params.id, req.user);
      return successResponse(res, appointment, 'Appointment retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async updateAppointment(req, res, next) {
    try {
      const appointment = await appointmentService.updateAppointment(
        req.params.id,
        req.validatedBody,
        req.user
      );
      return successResponse(res, appointment, 'Appointment updated successfully');
    } catch (error) {
      next(error);
    }
  }

  async cancelAppointment(req, res, next) {
    try {
      const { reason } = req.body;
      const appointment = await appointmentService.cancelAppointment(req.params.id, reason, req.user);
      return successResponse(res, appointment, 'Appointment cancelled successfully');
    } catch (error) {
      next(error);
    }
  }

  async confirmAppointment(req, res, next) {
    try {
      const appointment = await appointmentService.confirmAppointment(req.params.id);
      return successResponse(res, appointment, 'Appointment confirmed successfully');
    } catch (error) {
      next(error);
    }
  }

  async checkInAppointment(req, res, next) {
    try {
      const appointment = await appointmentService.checkInAppointment(req.params.id);
      return successResponse(res, appointment, 'Patient checked in successfully');
    } catch (error) {
      next(error);
    }
  }

  async startAppointment(req, res, next) {
    try {
      const appointment = await appointmentService.startAppointment(req.params.id);
      return successResponse(res, appointment, 'Appointment started successfully');
    } catch (error) {
      next(error);
    }
  }

  async completeAppointment(req, res, next) {
    try {
      const appointment = await appointmentService.completeAppointment(req.params.id);
      return successResponse(res, appointment, 'Appointment completed successfully');
    } catch (error) {
      next(error);
    }
  }

  async markNoShow(req, res, next) {
    try {
      const appointment = await appointmentService.markNoShow(req.params.id);
      return successResponse(res, appointment, 'Appointment marked as no-show');
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new AppointmentController();