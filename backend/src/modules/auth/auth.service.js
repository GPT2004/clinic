const prisma = require('../../config/database');
const { hashPassword, comparePassword } = require('../../utils/bcrypt');
const { generateToken, generateRefreshToken } = require('../../utils/jwt');
const { ROLES } = require('../../config/constants');

class AuthService {
  async register(userData) {
    // Check if email exists
    const existingUser = await prisma.users.findUnique({
      where: { email: userData.email },
    });

    if (existingUser) {
      throw new Error('Email already registered');
    }

    // Get Patient role
    const patientRole = await prisma.roles.findUnique({
      where: { name: ROLES.PATIENT },
    });

    if (!patientRole) {
      throw new Error('Patient role not found');
    }

    // Hash password
    const hashedPassword = await hashPassword(userData.password);

    // Create user and patient profile in transaction
    const result = await prisma.$transaction(async (tx) => {
      const user = await tx.users.create({
        data: {
          email: userData.email,
          password: hashedPassword,
          full_name: userData.full_name,
          phone: userData.phone,
          dob: userData.dob,
          role_id: patientRole.id,
        },
        include: { role: true },
      });

      const patient = await tx.patients.create({
        data: {
          user_id: user.id,
          gender: userData.gender,
          blood_type: userData.blood_type,
          allergies: userData.allergies,
        },
      });

      return { user, patient };
    });

    // Generate tokens
    const token = generateToken({ userId: result.user.id });
    const refreshToken = generateRefreshToken({ userId: result.user.id });

    return {
      user: this.sanitizeUser(result.user),
      token,
      refreshToken,
    };
  }

  async login(email, password) {
    const user = await prisma.users.findUnique({
      where: { email },
      include: { role: true },
    });

    if (!user) {
      throw new Error('Invalid email or password');
    }

    if (!user.is_active) {
      throw new Error('Account is inactive. Please contact administrator.');
    }

    const isPasswordValid = await comparePassword(password, user.password);

    if (!isPasswordValid) {
      throw new Error('Invalid email or password');
    }

    const token = generateToken({ userId: user.id });
    const refreshToken = generateRefreshToken({ userId: user.id });

    return {
      user: this.sanitizeUser(user),
      token,
      refreshToken,
    };
  }

  async changePassword(userId, currentPassword, newPassword) {
    const user = await prisma.users.findUnique({
      where: { id: userId },
    });

    const isPasswordValid = await comparePassword(currentPassword, user.password);

    if (!isPasswordValid) {
      throw new Error('Current password is incorrect');
    }

    const hashedPassword = await hashPassword(newPassword);

    await prisma.users.update({
      where: { id: userId },
      data: { password: hashedPassword },
    });

    return { message: 'Password changed successfully' };
  }

  async getProfile(userId) {
    const user = await prisma.users.findUnique({
      where: { id: userId },
      include: {
        role: true,
        patients: true,
        doctors: true,
      },
    });

    if (!user) {
      throw new Error('User not found');
    }

    return this.sanitizeUser(user);
  }

  sanitizeUser(user) {
    const { ...userWithoutPassword } = user;
    return userWithoutPassword;
  }
}

module.exports = new AuthService();