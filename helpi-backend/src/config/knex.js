// =============================================================
// HELPI - Configuração do Knex.js
// Exporta a instância do Knex pronta a usar
// =============================================================

const environment = process.env.NODE_ENV || 'development';
const knexConfig = require('../../knexfile.js')[environment];
const knex = require('knex')(knexConfig);

module.exports = knex;
