const bcrypt = require('bcrypt');

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> } 
 */
exports.seed = async function(knex) {
  // Deletes ALL existing entries
  await knex('admins').del();
  
  const salt = await bcrypt.genSalt(10);
  const hashedPassword = await bcrypt.hash('admin123', salt);

  await knex('admins').insert([
    {
      nome: 'Paulo Henrique',
      email: 'ceo1@helpi.com.br',
      senha: hashedPassword,
      role: 'ceo'
    },
    {
      nome: 'Victor',
      email: 'ceo2@helpi.com.br',
      senha: hashedPassword,
      role: 'ceo'
    }
  ]);
};
