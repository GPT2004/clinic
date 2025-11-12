const { errorResponse } = require('../utils/response');
const prisma = require('../config/database');

const authorize = (allowedRoles) => {  // ← Bỏ ...spread
  return (req, res, next) => {
    if (!req.user) {
      return errorResponse(res, 'Unauthorized', 401);
    }

    // Lấy role name, handle cả object và string
    const userRole = req.user.role?.name || req.user.role;

    // Đảm bảo allowedRoles là array
    const roles = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];

    if (!roles.includes(userRole)) {
      return errorResponse(res, 'Forbidden: Insufficient permissions', 403);
    }

    next();
  };
};

const authorizeOwner = (resourceType) => {
  return async (req, res, next) => {
    try {
      const resourceId = parseInt(req.params.id);
      const userId = req.user.id;
      const userRole = req.user.role?.name || req.user.role;  // ← Cũng fix ở đây

      // Admin có quyền truy cập tất cả
      if (userRole === 'Admin') {
        return next();
      }

      let resource;

      switch (resourceType) {
        case 'patient': {
          resource = await prisma.patients.findUnique({
            where: { id: resourceId },
          });
          if (resource && resource.user_id !== userId) {
            return errorResponse(res, 'You can only access your own data', 403);
          }
          break;
        }

        case 'appointment': {
          resource = await prisma.appointments.findUnique({
            where: { id: resourceId },
            include: { patient: true, doctor: true },
          });
          
          const isPatientOwner = resource.patient.user_id === userId;
          const isDoctorOwner = resource.doctor.user_id === userId;
          
          if (!isPatientOwner && !isDoctorOwner && userRole !== 'Receptionist') {
            return errorResponse(res, 'You can only access your own appointments', 403);
          }
          break;
        }

        case 'medical-record': {
          resource = await prisma.medical_records.findUnique({
            where: { id: resourceId },
            include: { patient: true, doctor: true },
          });
          
          const isPatient = resource.patient.user_id === userId;
          const isDoctor = resource.doctor.user_id === userId;
          
          if (!isPatient && !isDoctor) {
            return errorResponse(res, 'You can only access authorized medical records', 403);
          }
          break;
        }

        default:
          return errorResponse(res, 'Invalid resource type', 400);
      }

      if (!resource) {
        return errorResponse(res, 'Resource not found', 404);
      }

      req.resource = resource;
      next();
    } catch (error) {
      next(error);
    }
  };
};

module.exports = { authorize, authorizeOwner };
