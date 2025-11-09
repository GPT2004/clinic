const Joi = require('joi');

const createDoctorSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  full_name: Joi.string().required(),
  phone: Joi.string().pattern(/^[0-9]{10,11}$/).required(),
  dob: Joi.date().max('now').optional(),
  license_number: Joi.string().required(),

  // SỬA TẠI ĐÂY: CHO PHÉP CẢ CHUỖI HOẶC MẢNG
  specialties: Joi.alternatives().try(
    Joi.array().items(Joi.string()).min(1),
    Joi.string().min(1)
  ).required(),

  bio: Joi.string().max(1000).optional().allow(''),
  consultation_fee: Joi.number().integer().min(0).optional()
});

const updateDoctorSchema = Joi.object({
  full_name: Joi.string().optional(),
  phone: Joi.string().pattern(/^[0-9]{10,11}$/).optional(),
  email: Joi.string().email().optional(),
  dob: Joi.date().max('now').optional(),
  license_number: Joi.string().optional(),

  // CŨNG SỬA Ở ĐÂY
  specialties: Joi.alternatives().try(
    Joi.array().items(Joi.string()),
    Joi.string()
  ).optional(),

  bio: Joi.string().max(1000).optional().allow(''),
  consultation_fee: Joi.number().integer().min(0).optional()
});

const updateProfileSchema = Joi.object({
  full_name: Joi.string().optional(),
  phone: Joi.string().pattern(/^[0-9]{10,11}$/).optional(),
  avatar_url: Joi.string().uri().optional().allow(''),
  bio: Joi.string().max(1000).optional().allow(''),

  // VÀ ĐÂY
  specialties: Joi.alternatives().try(
    Joi.array().items(Joi.string()),
    Joi.string()
  ).optional()
});

module.exports = {
  createDoctorSchema,
  updateDoctorSchema,
  updateProfileSchema
};