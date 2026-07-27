// =============================================================
// HELPI - Firebase Cloud Messaging (Push Notifications)
// Utilitário mock para envio de Push Notifications (FCM).
// =============================================================

const logger = require('./logger');

const sendPushNotification = async (userId, title, body, data = {}) => {
    try {
        // -------------------------------------------------------------
        // TODO: Substituir por "firebase-admin" real quando instalado.
        // ex: await admin.messaging().send({ token: '...', notification: {...} })
        // -------------------------------------------------------------
        logger.info(`[FCM MOCK] Push Notification enviada para Utilizador [${userId}]:`);
        logger.info(`[FCM MOCK] 🔔 Título: ${title}`);
        logger.info(`[FCM MOCK] 📄 Mensagem: ${body}`);
        if (Object.keys(data).length > 0) {
            logger.info(`[FCM MOCK] 📦 Dados Adicionais:`, data);
        }
        
        return true;
    } catch (error) {
        logger.error(`[FCM MOCK ERRO] Falha ao simular envio para ${userId}`, { error: error.message });
        return false;
    }
};

module.exports = {
    sendPushNotification
};
