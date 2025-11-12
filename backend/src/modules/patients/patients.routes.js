const express = require('express');
const router = express.Router();
const patientsController = require('./patients.controller');
const { validate } = require('../../middlewares/validate.middleware');
const { authenticate } = require('../../middlewares/auth.middleware');
const { authorize } = require('../../middlewares/role.middleware');

const { createPatientSchema, updatePatientSchema, updateProfileSchema } = require('./patients.validator');

router.use(authenticate);

// Get all patients
router.get('/', authorize(['Admin', 'Receptionist', 'Doctor']), patientsController.getAllPatients);

// Get patient by ID
router.get('/:id', authorize(['Admin', 'Receptionist', 'Doctor', 'Patient']), patientsController.getPatientById);

// Get patient medical records
router.get('/:id/medical-records', authorize(['Admin', 'Doctor', 'Patient']), patientsController.getPatientMedicalRecords);

// Get patient appointments
router.get('/:id/appointments', authorize(['Admin', 'Receptionist', 'Doctor', 'Patient']), patientsController.getPatientAppointments);

// Get patient prescriptions
router.get('/:id/prescriptions', authorize(['Admin', 'Doctor', 'Patient']), patientsController.getPatientPrescriptions);

// Get patient invoices
router.get('/:id/invoices', authorize(['Admin', 'Receptionist', 'Patient']), patientsController.getPatientInvoices);

// Get my profile (Patient)
router.get('/me/profile', authorize(['Patient']), patientsController.getMyProfile);

// Update my profile (Patient)
router.put('/me/profile', authorize(['Patient']), validate(updateProfileSchema), patientsController.updateMyProfile);

// Create patient (Admin, Receptionist)
router.post('/', authorize(['Admin', 'Receptionist']), validate(createPatientSchema), patientsController.createPatient);

// Update patient (Admin, Receptionist)
router.put('/:id', authorize(['Admin', 'Receptionist']), validate(updatePatientSchema), patientsController.updatePatient);

// Delete patient (Admin only)
router.delete('/:id', authorize(['Admin']), patientsController.deletePatient);

module.exports = router;