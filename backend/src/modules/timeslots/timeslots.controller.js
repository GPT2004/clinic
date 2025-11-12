const timeslotsService = require('./timeslots.service');
const { successResponse } = require('../../utils/response');

class TimeslotsController {
  async getAllTimeslots(req, res, next) {
    try {
      const { 
        page = 1, 
        limit = 50, 
        doctor_id, 
        date, 
        available 
      } = req.query;

      const filters = {};
      if (doctor_id) filters.doctor_id = parseInt(doctor_id);
      if (date) filters.date = date;
      if (available === 'true') filters.available = true;

      const result = await timeslotsService.getAllTimeslots(filters, {
        page: parseInt(page),
        limit: parseInt(limit)
      });

      return successResponse(res, result, 'Timeslots retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getTimeslotById(req, res, next) {
    try {
      const { id } = req.params;
      const timeslot = await timeslotsService.getTimeslotById(parseInt(id));

      if (!timeslot) {
        throw new Error('Timeslot not found');
      }

      return successResponse(res, timeslot, 'Timeslot retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getAvailableTimeslots(req, res, next) {
    try {
      const { doctor_id, date } = req.query;

      if (!doctor_id || !date) {
        throw new Error('doctor_id and date are required');
      }

      const timeslots = await timeslotsService.getAvailableTimeslots(
        parseInt(doctor_id),
        date
      );

      return successResponse(res, timeslots, 'Available timeslots retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async getDoctorTimeslots(req, res, next) {
    try {
      const { doctorId } = req.params;
      const { startDate, endDate } = req.query;

      if (!startDate || !endDate) {
        throw new Error('startDate and endDate are required');
      }

      const timeslots = await timeslotsService.getDoctorTimeslots(
        parseInt(doctorId),
        { startDate, endDate }
      );

      return successResponse(res, timeslots, 'Doctor timeslots retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async createTimeslot(req, res, next) {
    try {
      const timeslotData = req.validatedBody;
      const newTimeslot = await timeslotsService.createTimeslot(timeslotData);

      return successResponse(res, newTimeslot, 'Timeslot created successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  async createMultipleTimeslots(req, res, next) {
    try {
      const { doctor_id, date, start_time, end_time, duration = 20, max_patients = 1 } = req.validatedBody;

      const timeslots = await timeslotsService.createMultipleTimeslots({
        doctor_id,
        date,
        start_time,
        end_time,
        duration,
        max_patients
      });

      return successResponse(res, timeslots, 'Timeslots created successfully', 201);
    } catch (error) {
      next(error);
    }
  }

  async updateTimeslot(req, res, next) {
    try {
      const { id } = req.params;
      const updateData = req.validatedBody;

      const updatedTimeslot = await timeslotsService.updateTimeslot(
        parseInt(id),
        updateData
      );

      if (!updatedTimeslot) {
        throw new Error('Timeslot not found');
      }

      return successResponse(res, updatedTimeslot, 'Timeslot updated successfully');
    } catch (error) {
      next(error);
    }
  }

  async deleteTimeslot(req, res, next) {
    try {
      const { id } = req.params;
      await timeslotsService.deleteTimeslot(parseInt(id));

      return successResponse(res, null, 'Timeslot deleted successfully');
    } catch (error) {
      next(error);
    }
  }

  async toggleTimeslotStatus(req, res, next) {
    try {
      const { id } = req.params;
      const { is_active } = req.validatedBody;

      const updatedTimeslot = await timeslotsService.toggleTimeslotStatus(
        parseInt(id),
        is_active
      );

      if (!updatedTimeslot) {
        throw new Error('Timeslot not found');
      }

      return successResponse(res, updatedTimeslot, 'Timeslot status updated successfully');
    } catch (error) {
      next(error);
    }
  }

  async getTimeslotAppointments(req, res, next) {
    try {
      const { id } = req.params;
      const appointments = await timeslotsService.getTimeslotAppointments(parseInt(id));

      return successResponse(res, appointments, 'Timeslot appointments retrieved successfully');
    } catch (error) {
      next(error);
    }
  }

  async bulkUpdateTimeslots(req, res, next) {
    try {
      const { doctor_id, date, is_active } = req.validatedBody;

      const result = await timeslotsService.bulkUpdateTimeslots({
        doctor_id,
        date,
        is_active
      });

      return successResponse(res, result, 'Timeslots updated successfully');
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new TimeslotsController();