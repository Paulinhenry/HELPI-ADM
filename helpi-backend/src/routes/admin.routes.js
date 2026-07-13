// =============================================================
// HELPI - Rotas de Administração (Admin Vault)
// =============================================================

const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin.controller');
const authAdmin = require('../middlewares/authAdmin');

// Todas as rotas admin requerem token JWT válido de Admin
router.use(authAdmin);

// Rotas
router.get('/dashboard', adminController.getDashboardStats);
router.get('/kyp', adminController.getPendingProfessionals);
router.post('/kyp-approve/:id', adminController.approveProfessional);
router.post('/kyp-reject/:id', adminController.rejectProfessional);
router.get('/diretorio', adminController.getDirectory);
router.post('/diretorio/suspend/:type/:id', adminController.toggleUserStatus);
router.get('/radar', adminController.getRadarServices);

module.exports = router;
