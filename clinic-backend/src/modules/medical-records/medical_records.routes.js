const express = require('express');
const router = express.Router();
const medicalRecordController = require('./medical_records.controller');
const { validate } = require('../../middlewares/validate.middleware');
const { authenticate } = require('../../middlewares/auth.middleware');
const { authorize } = require('../../middlewares/role.middleware');

const {
  createMedicalRecordSchema,
  updateMedicalRecordSchema,
} = require('./medical_records.validator');
const { ROLES } = require('../../config/constants');

// Get all medical records (with filters)
router.get(
  '/',
  authenticate,
  authorize([ROLES.DOCTOR, ROLES.ADMIN, ROLES.PATIENT]),
  medicalRecordController.getMedicalRecords
);

// Get medical record by ID
router.get(
  '/:id',
  authenticate,
  medicalRecordController.getMedicalRecordById
);

// Get patient medical history
router.get(
  '/patient/:patient_id/history',
  authenticate,
  medicalRecordController.getPatientMedicalHistory
);

// Create medical record (Doctor only)
router.post(
  '/',
  authenticate,
  authorize([ROLES.DOCTOR, ROLES.ADMIN]),
  validate(createMedicalRecordSchema),
  medicalRecordController.createMedicalRecord
);

// Update medical record
router.put(
  '/:id',
  authenticate,
  authorize([ROLES.DOCTOR, ROLES.ADMIN]),
  validate(updateMedicalRecordSchema),
  medicalRecordController.updateMedicalRecord
);

// Delete medical record (Admin only)
router.delete(
  '/:id',
  authenticate,
  authorize([ROLES.ADMIN]),
  medicalRecordController.deleteMedicalRecord
);

// Upload attachment
router.post(
  '/:id/attachments',
  authenticate,
  authorize([ROLES.DOCTOR, ROLES.ADMIN]),
  // multer middleware should be added here
  medicalRecordController.uploadAttachment
);

module.exports = router;