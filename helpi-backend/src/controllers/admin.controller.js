// =============================================================
// HELPI - Controlador do Admin Vault
// Fornece dados consolidados para o dashboard, diretório e radar.
// =============================================================

const pool = require('../config/database');
const knex = require('../config/knex');

// ─── DASHBOARD ───────────────────────────────────────────────
const getDashboardStats = async (req, res, next) => {
    try {
        // 1. Faturação do Dia (Knex)
        const todayStr = new Date().toISOString().split('T')[0];
        const resFaturacao = await knex('pagamentos')
            .whereRaw('DATE(criado_em) = ?', [todayStr])
            .andWhere('status', 'pago')
            .sum('valor_total as faturacao_diaria')
            .first();
        
        const faturacaoDiaria = parseFloat(resFaturacao?.faturacao_diaria || 0);

        // 2. Gráfico de 7 Dias (Knex)
        const seteDiasAtras = new Date();
        seteDiasAtras.setDate(seteDiasAtras.getDate() - 6);
        const seteDiasStr = seteDiasAtras.toISOString().split('T')[0];
        
        const resGrafico = await knex('pagamentos')
            .select(knex.raw('DATE(criado_em) as data'))
            .sum('valor_total as total')
            .whereRaw('DATE(criado_em) >= ?', [seteDiasStr])
            .andWhere('status', 'pago')
            .groupByRaw('DATE(criado_em)')
            .orderBy('data', 'asc');
            
        const faturacao_7_dias = [];
        for (let i = 6; i >= 0; i--) {
            const d = new Date();
            d.setDate(d.getDate() - i);
            const dateStr = d.toISOString().split('T')[0];
            const found = resGrafico.find(r => {
                 const rowDate = r.data instanceof Date ? r.data.toISOString().split('T')[0] : r.data;
                 return rowDate === dateStr || rowDate?.toString().startsWith(dateStr);
            });
            faturacao_7_dias.push(parseFloat(found?.total || 0));
        }

        // Chamados Ativos (não concluídos)
        const resChamados = await pool.query(`
            SELECT COUNT(*) as count 
            FROM chamados_express 
            WHERE status IN ('procurando_profissional', 'a_caminho', 'em_servico')
        `);
        const ativos = parseInt(resChamados.rows[0]?.count || 0);

        // 3. Profissionais Online (Socket.IO - sala "radar")
        const io = req.app.get('io');
        const radarRoom = io ? io.sockets.adapter.rooms.get('radar') : null;
        const onlineCount = radarRoom ? radarRoom.size : 0;

        res.json({
            faturacao_diaria: faturacaoDiaria,
            chamados_ativos: ativos,
            profissionais_online: onlineCount,
            faturacao_7_dias: faturacao_7_dias
        });
    } catch (erro) {
        next(erro);
    }
};

// ─── KYP APROVAÇÕES ──────────────────────────────────────────
const getPendingProfessionals = async (req, res, next) => {
    try {
        const resultado = await pool.query(`
            SELECT id, nome, email, status, criado_em 
            FROM profissionais 
            WHERE status IN ('pendente', 'pendente_aprovacao', 'pendente_aprovação')
            ORDER BY criado_em DESC
        `);
        
        // Mapear para o formato do Frontend
        const mapped = resultado.rows.map(r => ({
            id: r.id,
            name: r.nome,
            email: r.email,
            status: r.status,
            date: new Date(r.criado_em).toLocaleDateString('pt-BR'),
            // Dummy data for now
            category: 'Eletricista',
            cpf: '123.456.789-00',
            city: 'São Paulo, SP',
            phone: '(11) 98765-4321',
            documentUrl: 'https://exemplo.com/doc.pdf'
        }));
        
        res.json(mapped);
    } catch (erro) {
        next(erro);
    }
};

const fcm = require('../utils/fcm');

const approveProfessional = async (req, res, next) => {
    try {
        const { id } = req.params;
        await pool.query('UPDATE profissionais SET status = $1 WHERE id = $2', ['aprovado', id]);
        
        // Dispara um Push Notification automático para o profissional
        await fcm.sendPushNotification(
            id,
            'Perfil Aprovado!',
            'Parabéns! O seu perfil foi aprovado. Ligue o radar para começar a faturar.'
        );
        
        res.json({ mensagem: 'Profissional aprovado com sucesso' });
    } catch (erro) {
        next(erro);
    }
};

const rejectProfessional = async (req, res, next) => {
    try {
        const { id } = req.params;
        await pool.query('UPDATE profissionais SET status = $1 WHERE id = $2', ['rejeitado', id]);
        res.json({ mensagem: 'Profissional rejeitado com sucesso' });
    } catch (erro) {
        next(erro);
    }
};

// ─── DIRETÓRIO ───────────────────────────────────────────────
const getDirectory = async (req, res, next) => {
    try {
        const clientesRes = await pool.query('SELECT id, nome, email, nota_media, criado_em, \'ativo\' as status FROM clientes ORDER BY criado_em DESC');
        const profRes = await pool.query('SELECT id, nome, email, status, nota_media, criado_em FROM profissionais ORDER BY criado_em DESC');
        
        const clientes = clientesRes.rows.map(r => ({
            id: r.id,
            name: r.nome,
            email: r.email,
            role: 'Cliente',
            status: r.status,
            joinDate: new Date(r.criado_em).toLocaleDateString('pt-BR'),
            rating: parseFloat(r.nota_media || 5.0)
        }));
        
        const profissionais = profRes.rows.map(r => ({
            id: r.id,
            name: r.nome,
            email: r.email,
            role: 'Profissional',
            status: r.status,
            joinDate: new Date(r.criado_em).toLocaleDateString('pt-BR'),
            rating: parseFloat(r.nota_media || 5.0)
        }));

        res.json({ clientes, profissionais });
    } catch (erro) {
        next(erro);
    }
};

const toggleUserStatus = async (req, res, next) => {
    try {
        const { type, id } = req.params;
        const tabela = type === 'client' ? 'clientes' : 'profissionais';
        const hasStatusCol = type === 'client' ? false : true; 
        
        if (!hasStatusCol) {
            return res.json({ mensagem: 'Status toggle não suportado nativamente para clientes neste BD simplificado.' });
        }
        
        const statusRes = await pool.query(`SELECT status FROM ${tabela} WHERE id = $1`, [id]);
        if(statusRes.rows.length > 0){
            const newStatus = statusRes.rows[0].status === 'ativo' ? 'suspenso' : 'ativo';
            await pool.query(`UPDATE ${tabela} SET status = $1 WHERE id = $2`, [newStatus, id]);
            
            if (tabela === 'profissionais' && newStatus === 'suspenso') {
                const io = req.app.get('io');
                if (io) {
                    io.to('profissional_' + id).emit('conta_bloqueada', {
                        mensagem: 'Conta Suspensa pela Administração'
                    });
                    
                    const profMap = req.app.get('profissionaisConectados');
                    const profSocketId = profMap ? profMap.get(id) : null;
                    if (profSocketId) {
                        io.to(profSocketId).emit('conta_bloqueada', {
                            mensagem: 'Conta Suspensa pela Administração'
                        });
                    }
                }
            }
            
            res.json({ mensagem: `Status atualizado para ${newStatus}` });
        } else {
            res.status(404).json({ erro: 'Usuário não encontrado' });
        }
    } catch (erro) {
        next(erro);
    }
};

// ─── RADAR ───────────────────────────────────────────────────
const getRadarServices = async (req, res, next) => {
    try {
        const chamadosRes = await pool.query(`
            SELECT c.id, c.status, c.criado_em, cl.nome as cliente_nome, pr.nome as profissional_nome
            FROM chamados_express c
            LEFT JOIN clientes cl ON c.cliente_id = cl.id
            LEFT JOIN profissionais pr ON c.profissional_id = pr.id
            ORDER BY c.criado_em DESC
            LIMIT 50
        `);

        const servicos = chamadosRes.rows.map(c => ({
            id: c.id.substring(0,8).toUpperCase(),
            clientName: c.cliente_nome || 'Desconhecido',
            professionalName: c.profissional_nome || 'Desconhecido',
            category: 'Geral', // Fallback
            value: 150.00,
            status: c.status,
            date: new Date(c.criado_em).toLocaleDateString('pt-BR')
        }));

        // Simulação online
        const profOnlineRes = await pool.query("SELECT nome, nota_media FROM profissionais WHERE status = 'ativo' LIMIT 10");
        const online = profOnlineRes.rows.map(p => ({
            name: p.nome,
            category: 'Geral',
            location: 'Localização Desconhecida',
            rating: parseFloat(p.nota_media || 5.0)
        }));

        res.json({
            services: servicos,
            onlineProfessionals: online
        });
    } catch (erro) {
        next(erro);
    }
};

module.exports = {
    getDashboardStats,
    getPendingProfessionals,
    approveProfessional,
    rejectProfessional,
    getDirectory,
    toggleUserStatus,
    getRadarServices
};
