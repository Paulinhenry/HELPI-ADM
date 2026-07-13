/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = async function(knex) {
  const hasAdmins = await knex.schema.hasTable('admins');
  if (!hasAdmins) {
    await knex.schema.createTable('admins', (table) => {
      table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
      table.string('nome').notNullable();
      table.string('email').unique().notNullable();
      table.string('senha').notNullable();
      table.string('role').defaultTo('admin'); // admin, ceo, etc
      table.timestamp('criado_em').defaultTo(knex.fn.now());
    });
  }
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = async function(knex) {
  await knex.schema.dropTableIfExists('admins');
};
