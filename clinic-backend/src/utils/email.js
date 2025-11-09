const nodemailer = require('nodemailer');
const logger = require('./logger');

class EmailService {
  constructor() {
    this.transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: parseInt(process.env.SMTP_PORT),
      secure: false,
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASSWORD,
      },
    });
  }

  async sendEmail({ to, subject, html, attachments = [] }) {
    try {
      const info = await this.transporter.sendMail({
        from: `"Clinic Management" <${process.env.SMTP_USER}>`,
        to,
        subject,
        html,
        attachments,
      });

      logger.info(`Email sent: ${info.messageId}`);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      logger.error('Email send error:', error);
      throw new Error('Failed to send email');
    }
  }

  async sendAppointmentConfirmation(appointment, patientEmail) {
    const html = `
      <h2>Xác nhận lịch hẹn</h2>
      <p>Kính gửi bệnh nhân,</p>
      <p>Lịch hẹn của bạn đã được xác nhận với thông tin sau:</p>
      <ul>
        <li><strong>Bác sĩ:</strong> ${appointment.doctor.user.full_name}</li>
        <li><strong>Ngày khám:</strong> ${new Date(appointment.appointment_date).toLocaleDateString('vi-VN')}</li>
        <li><strong>Giờ khám:</strong> ${appointment.appointment_time}</li>
        <li><strong>Lý do khám:</strong> ${appointment.reason || 'Không có'}</li>
      </ul>
      <p>Vui lòng đến đúng giờ. Nếu cần thay đổi, vui lòng liên hệ phòng khám.</p>
      <p>Trân trọng,<br>Phòng khám</p>
    `;

    return this.sendEmail({
      to: patientEmail,
      subject: 'Xác nhận lịch hẹn khám bệnh',
      html,
    });
  }

  async sendAppointmentReminder(appointment, patientEmail) {
    const html = `
      <h2>Nhắc nhở lịch hẹn</h2>
      <p>Kính gửi bệnh nhân,</p>
      <p>Đây là email nhắc nhở lịch hẹn của bạn:</p>
      <ul>
        <li><strong>Bác sĩ:</strong> ${appointment.doctor.user.full_name}</li>
        <li><strong>Ngày khám:</strong> ${new Date(appointment.appointment_date).toLocaleDateString('vi-VN')}</li>
        <li><strong>Giờ khám:</strong> ${appointment.appointment_time}</li>
      </ul>
      <p>Vui lòng đến đúng giờ. Xin cảm ơn!</p>
      <p>Trân trọng,<br>Phòng khám</p>
    `;

    return this.sendEmail({
      to: patientEmail,
      subject: 'Nhắc nhở lịch hẹn khám bệnh',
      html,
    });
  }

  async sendPrescription(prescription, patientEmail, pdfPath) {
    const html = `
      <h2>Đơn thuốc điện tử</h2>
      <p>Kính gửi bệnh nhân,</p>
      <p>Đơn thuốc của bạn đã sẵn sàng. Vui lòng xem file đính kèm.</p>
      <p>Tổng tiền: ${prescription.total_amount.toLocaleString('vi-VN')} VNĐ</p>
      <p>Trân trọng,<br>Phòng khám</p>
    `;

    return this.sendEmail({
      to: patientEmail,
      subject: 'Đơn thuốc điện tử',
      html,
      attachments: pdfPath ? [{
        filename: 'prescription.pdf',
        path: pdfPath,
      }] : [],
    });
  }

  async sendLabResults(labOrder, patientEmail, pdfPath) {
    const html = `
      <h2>Kết quả xét nghiệm</h2>
      <p>Kính gửi bệnh nhân,</p>
      <p>Kết quả xét nghiệm của bạn đã có. Vui lòng xem file đính kèm.</p>
      <p>Nếu có thắc mắc, vui lòng liên hệ bác sĩ điều trị.</p>
      <p>Trân trọng,<br>Phòng khám</p>
    `;

    return this.sendEmail({
      to: patientEmail,
      subject: 'Kết quả xét nghiệm',
      html,
      attachments: pdfPath ? [{
        filename: 'lab-results.pdf',
        path: pdfPath,
      }] : [],
    });
  }
}

module.exports = new EmailService();