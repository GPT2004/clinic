const express = require('express');
const router = express.Router();
const prescriptionController = require('./prescriptions.controller');
const { validate } = require('../../middlewares/validate.middleware');
const { authenticate } = require('../../middlewares/auth.middleware');
const { authorize } = require('../../middlewares/role.middleware');

const {
  createPrescriptionSchema,
  updatePrescriptionSchema,
} = require('./prescriptions.validator');
const { ROLES } = require('../../config/constants');

// Get all prescriptions
router.get(
  '/',
  authenticate,
  prescriptionController.getPrescriptions
);

// Get prescription by ID
router.get(
  '/:id',
  authenticate,
  prescriptionController.getPrescriptionById
);

// Create prescription (Doctor only)
router.post(
  '/',
  authenticate,
  authorize([ROLES.DOCTOR, ROLES.ADMIN]),
  validate(createPrescriptionSchema),
  prescriptionController.createPrescription
);

// Update prescription (Doctor only, DRAFT status)
router.put(
  '/:id',
  authenticate,
  authorize([ROLES.DOCTOR, ROLES.ADMIN]),
  validate(updatePrescriptionSchema),
  prescriptionController.updatePrescription
);

// Approve prescription (Doctor only)
router.patch(
  '/:id/approve',
  authenticate,
  authorize([ROLES.DOCTOR, ROLES.ADMIN]),
  prescriptionController.approvePrescription
);

// Dispense prescription (Pharmacist only)
router.patch(
  '/:id/dispense',
  authenticate,
  authorize([ROLES.PHARMACIST, ROLES.ADMIN]),
  prescriptionController.dispensePrescription
);

// Delete prescription (Doctor/Admin, DRAFT only)
router.delete(
  '/:id',
  authenticate,
  authorize([ROLES.DOCTOR, ROLES.ADMIN]),
  prescriptionController.deletePrescription
);

module.exports = router;
