const express = require('express');
const router = express.Router();
const doctorsController = require('./doctors.controller');
const { validate } = require('../../middlewares/validate.middleware');
const { authenticate } = require('../../middlewares/auth.middleware');
const { authorize } = require('../../middlewares/role.middleware');

const { createDoctorSchema, updateDoctorSchema, updateProfileSchema } = require('./doctors.validator');

// Public routes
router.get('/public', doctorsController.getAllDoctorsPublic);
router.get('/public/:id', doctorsController.getDoctorByIdPublic);
router.get('/public/specialties/list', doctorsController.getSpecialties);

// Protected routes
router.use(authenticate);

router.get('/', authorize(['Admin', 'Receptionist', 'Doctor']), doctorsController.getAllDoctors);
router.get('/:id', authorize(['Admin', 'Receptionist', 'Doctor']), doctorsController.getDoctorById);
router.get('/:id/appointments', authorize(['Admin', 'Receptionist', 'Doctor']), doctorsController.getDoctorAppointments);
router.get('/:id/schedules', authorize(['Admin', 'Receptionist', 'Doctor']), doctorsController.getDoctorSchedules);
router.get('/:id/patients', authorize(['Admin', 'Doctor']), doctorsController.getDoctorPatients);
router.get('/:id/stats', authorize(['Admin', 'Doctor']), doctorsController.getDoctorStats);

router.post('/', authorize(['Admin']), validate(createDoctorSchema), doctorsController.createDoctor);
router.put('/:id', authorize(['Admin']), validate(updateDoctorSchema), doctorsController.updateDoctor);
router.put('/me/profile', authorize(['Doctor']), validate(updateProfileSchema), doctorsController.updateOwnProfile);
router.delete('/:id', authorize(['Admin']), doctorsController.deleteDoctor);
router.patch('/:id/toggle-status', authorize(['Admin']), doctorsController.toggleDoctorStatus);

module.exports = router;