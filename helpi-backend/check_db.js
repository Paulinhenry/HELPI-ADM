const pool = require('./src/config/database');

async function run() {
  try {
    const res = await pool.query("SELECT column_name FROM information_schema.columns WHERE table_name = 'chamados_express'");
    console.log("Chamados:", res.rows.map(r => r.column_name));
    
    const res2 = await pool.query("SELECT column_name FROM information_schema.columns WHERE table_name = 'profissionais'");
    console.log("Profissionais:", res2.rows.map(r => r.column_name));
  } catch (e) {
    console.error(e);
  } finally {
    pool.end();
  }
}
run();
