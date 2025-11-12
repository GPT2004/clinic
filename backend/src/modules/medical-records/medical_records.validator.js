const Joi = require('joi');

const createMedicalRecordSchema = Joi.object({
  appointment_id: Joi.number().integer().optional(),
  patient_id: Joi.number().integer().required(),
  doctor_id: Joi.number().integer().optional(), // Optional for doctors
  diagnosis: Joi.string().required(),
  notes: Joi.string().optional(),
  attachments: Joi.array().items(
    Joi.object({
      filename: Joi.string().required(),
      path: Joi.string().required(),
      mimetype: Joi.string().optional(),
      size: Joi.number().optional(),
    })
  ).optional(),
});

const updateMedicalRecordSchema = Joi.object({
  diagnosis: Joi.string().optional(),
  notes: Joi.string().optional(),
  attachments: Joi.array().items(
    Joi.object({
      filename: Joi.string().required(),
      path: Joi.string().required(),
      mimetype: Joi.string().optional(),
      size: Joi.number().optional(),
    })
  ).optional(),
});

module.exports = {
  createMedicalRecordSchema,
  updateMedicalRecordSchema,
};