import express from 'express';
const router = express.Router();
import * as ctrl from './ai.controller.js';
router.get('/', ctrl.index);
export default router;
