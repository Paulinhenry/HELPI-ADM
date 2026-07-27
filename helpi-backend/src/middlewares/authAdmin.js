// =============================================================
// HELPI - Middleware de Autenticação de Admins
// Verifica o JWT e garante que o utilizador é um administrador (CEO).
// =============================================================

const jwt = require('jsonwebtoken');
const logger = require('../utils/logger');

const authAdmin = (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                erro: 'Token não fornecido. Envie no formato: Bearer <token>'
            });
        }

        const token = authHeader.split(' ')[1];

        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        if (decoded.tipo !== 'CEO' && decoded.tipo !== 'SOCIO' && decoded.role !== 'CEO' && decoded.role !== 'SOCIO') {
            logger.warn(`[SEGURANÇA] Tentativa de invasão detectada Painel Admin! Token ID: ${decoded.id}, Tipo: ${decoded.tipo || decoded.role}`);
            return res.status(403).json({
                erro: 'Acesso negado. Apenas CEO e Sócios têm permissão.'
            });
        }

        req.usuario = decoded;
        next();

    } catch (erro) {
        if (erro.name === 'TokenExpiredError') {
            return res.status(401).json({
                erro: 'Token expirado. Faça login novamente.'
            });
        }

        return res.status(401).json({
            erro: 'Token inválido'
        });
    }
};

module.exports = authAdmin;
