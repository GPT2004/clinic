const Joi = require('joi');

const createPatientSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  full_name: Joi.string().required(),
  phone: Joi.string().pattern(/^[0-9]{10,11}$/).required(),
  dob: Joi.date().max('now').optional(),
  gender: Joi.string().valid('Male', 'Female', 'Other').optional(),
  blood_type: Joi.string().valid('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-').optional(),
  allergies: Joi.string().max(500).optional().allow(''),
  emergency_contact: Joi.object({
    name: Joi.string().optional(),
    phone: Joi.string().optional(),
    relationship: Joi.string().optional()
  }).optional()
});

const updatePatientSchema = Joi.object({
  full_name: Joi.string().optional(),
  phone: Joi.string().pattern(/^[0-9]{10,11}$/).optional(),
  email: Joi.string().email().optional(),
  dob: Joi.date().max('now').optional(),
  gender: Joi.string().valid('Male', 'Female', 'Other').optional(),
  blood_type: Joi.string().valid('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-').optional(),
  allergies: Joi.string().max(500).optional().allow(''),
  emergency_contact: Joi.object({
    name: Joi.string().optional(),
    phone: Joi.string().optional(),
    relationship: Joi.string().optional()
  }).optional()
});

const updateProfileSchema = Joi.object({
  full_name: Joi.string().optional(),
  phone: Joi.string().pattern(/^[0-9]{10,11}$/).optional(),
  avatar_url: Joi.string().uri().optional().allow(''),
  emergency_contact: Joi.object({
    name: Joi.string().optional(),
    phone: Joi.string().optional(),
    relationship: Joi.string().optional()
  }).optional()
});

module.exports = {
  createPatientSchema,
  updatePatientSchema,
  updateProfileSchema
};