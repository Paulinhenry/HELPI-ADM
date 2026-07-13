import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/stat_card.dart';
import '../auth/auth_provider.dart';
import 'dashboard_provider.dart';
import 'widgets/revenue_chart.dart';

// ═══════════════════════════════════════════════════════════════
// Dashboard Screen — Métricas centrais e gráficos
// ═══════════════════════════════════════════════════════════════

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isWide = MediaQuery.of(context).size.width > 800;

    if (dashboard.isLoading && dashboard.stats == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final stats = dashboard.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Welcome Header ────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo, ${auth.currentUser?.name ?? 'Admin'}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            auth.currentUser?.role.toUpperCase() ?? '',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Painel de Controlo • ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          if (dashboard.error != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              color: AppColors.error.withValues(alpha: 0.2),
              child: Text(dashboard.error!, style: const TextStyle(color: AppColors.error)),
            ),

          // ─── Stat Cards Grid ───────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: FontAwesomeIcons.brazilianRealSign,
                        title: 'FATURAÇÃO DO DIA',
                        value: currencyFormat.format(stats?.faturacaoDiaria ?? 0),
                        accentColor: AppColors.gold,
                        subtitle: 'Atualizado ao vivo',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        icon: FontAwesomeIcons.headset,
                        title: 'CHAMADOS ATIVOS',
                        value: '${stats?.chamadosAtivos ?? 0}',
                        accentColor: AppColors.primary,
                        subtitle: 'Em progresso / pendentes',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        icon: FontAwesomeIcons.userCheck,
                        title: 'PROFISSIONAIS ONLINE',
                        value: '${stats?.profissionaisOnline ?? 0}',
                        accentColor: AppColors.success,
                        subtitle: 'Em tempo real',
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  StatCard(
                    icon: FontAwesomeIcons.brazilianRealSign,
                    title: 'FATURAÇÃO DO DIA',
                    value: currencyFormat.format(stats?.faturacaoDiaria ?? 0),
                    accentColor: AppColors.gold,
                    subtitle: 'Atualizado ao vivo',
                  ),
                  const SizedBox(height: 12),
                  StatCard(
                    icon: FontAwesomeIcons.headset,
                    title: 'CHAMADOS ATIVOS',
                    value: '${stats?.chamadosAtivos ?? 0}',
                    accentColor: AppColors.primary,
                    subtitle: 'Em progresso / pendentes',
                  ),
                  const SizedBox(height: 12),
                  StatCard(
                    icon: FontAwesomeIcons.userCheck,
                    title: 'PROFISSIONAIS ONLINE',
                    value: '${stats?.profissionaisOnline ?? 0}',
                    accentColor: AppColors.success,
                    subtitle: 'Em tempo real',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // ─── Revenue Chart ─────────────────────────────
          const RevenueChart(),
        ],
      ),
    );
  }
}
