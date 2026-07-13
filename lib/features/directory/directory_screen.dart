import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/status_badge.dart';
import 'directory_provider.dart';

// ═══════════════════════════════════════════════════════════════
// Directory Screen — Diretório de Clientes e Profissionais
// ═══════════════════════════════════════════════════════════════

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DirectoryProvider>().loadDirectory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dir = context.watch<DirectoryProvider>();
    final isWide = MediaQuery.of(context).size.width > 900;

    if (dir.isLoading && dir.clients.isEmpty && dir.professionals.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────
            const Text(
              'Diretório',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Gestão de Clientes e Profissionais',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),

            if (dir.error != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                color: AppColors.error.withValues(alpha: 0.2),
                child: Text(dir.error!, style: const TextStyle(color: AppColors.error)),
              ),

            // ─── Tab Bar ─────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'Clientes'),
                  Tab(text: 'Profissionais'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── Tab Views ───────────────────────────────
            Expanded(
              child: TabBarView(
                children: [
                  _ClientsTab(dir: dir, isWide: isWide),
                  _ProfessionalsTab(dir: dir, isWide: isWide),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Clients Tab ─────────────────────────────────────────────

class _ClientsTab extends StatelessWidget {
  final DirectoryProvider dir;
  final bool isWide;

  const _ClientsTab({required this.dir, required this.isWide});

  @override
  Widget build(BuildContext context) {
    if (dir.clients.isEmpty) {
      return const Center(
        child: Text('Nenhum cliente encontrado', style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return isWide ? _buildClientTable() : _buildClientsList();
  }

  Widget _buildClientTable() {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: DataTable(
          headingTextStyle: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          dataRowMaxHeight: 65,
          dataRowMinHeight: 65,
          horizontalMargin: 24,
          columns: const [
            DataColumn(label: Text('CLIENTE')),
            DataColumn(label: Text('EMAIL')),
            DataColumn(label: Text('REGISTRO')),
            DataColumn(label: Text('AVALIAÇÃO')),
            DataColumn(label: Text('STATUS')),
          ],
          rows: dir.clients.map((client) {
            return DataRow(cells: [
              DataCell(Text(client.name,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500))),
              DataCell(Text(client.email,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
              DataCell(Text(client.joinDate,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
                  const SizedBox(width: 4),
                  Text('${client.rating}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                ],
              )),
              DataCell(StatusBadge.fromStatus(client.status)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildClientsList() {
    return ListView.builder(
      itemCount: dir.clients.length,
      itemBuilder: (context, index) {
        final client = dir.clients[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(client.name,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                  ),
                  StatusBadge.fromStatus(client.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(client.email,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
                  const SizedBox(width: 4),
                  Text('${client.rating}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                  const SizedBox(width: 16),
                  Text('Registro: ${client.joinDate}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Professionals Tab ───────────────────────────────────────

class _ProfessionalsTab extends StatelessWidget {
  final DirectoryProvider dir;
  final bool isWide;

  const _ProfessionalsTab({required this.dir, required this.isWide});

  @override
  Widget build(BuildContext context) {
    if (dir.professionals.isEmpty) {
      return const Center(
        child: Text('Nenhum profissional encontrado', style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return isWide ? _buildProfessionalTable(context) : _buildProfessionalsList(context);
  }

  Widget _buildProfessionalTable(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: DataTable(
          headingTextStyle: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          dataRowMaxHeight: 65,
          dataRowMinHeight: 65,
          horizontalMargin: 24,
          columns: const [
            DataColumn(label: Text('PROFISSIONAL')),
            DataColumn(label: Text('EMAIL')),
            DataColumn(label: Text('REGISTRO')),
            DataColumn(label: Text('AVALIAÇÃO')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('AÇÕES')),
          ],
          rows: dir.professionals.map((prof) {
            return DataRow(cells: [
              DataCell(Text(prof.name,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
              DataCell(Text(prof.email,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
              DataCell(Text(prof.joinDate,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
                  const SizedBox(width: 4),
                  Text('${prof.rating}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                ],
              )),
              DataCell(StatusBadge.fromStatus(prof.status)),
              DataCell(
                TextButton.icon(
                  icon: FaIcon(
                    prof.status == 'ativo' ? FontAwesomeIcons.ban : FontAwesomeIcons.check,
                    color: prof.status == 'ativo' ? AppColors.error : AppColors.success,
                    size: 14,
                  ),
                  label: Text(
                    prof.status == 'ativo' ? 'Bloquear' : 'Ativar',
                    style: TextStyle(
                      color: prof.status == 'ativo' ? AppColors.error : AppColors.success,
                      fontSize: 12,
                    ),
                  ),
                  onPressed: () => dir.toggleStatus('profissional', prof.id),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProfessionalsList(BuildContext context) {
    return ListView.builder(
      itemCount: dir.professionals.length,
      itemBuilder: (context, index) {
        final prof = dir.professionals[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(prof.name,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                  ),
                  StatusBadge.fromStatus(prof.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(prof.email,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
                  const SizedBox(width: 4),
                  Text('${prof.rating}',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                  const SizedBox(width: 16),
                  Text('Registro: ${prof.joinDate}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const Spacer(),
                  TextButton.icon(
                    icon: FaIcon(
                      prof.status == 'ativo' ? FontAwesomeIcons.ban : FontAwesomeIcons.check,
                      color: prof.status == 'ativo' ? AppColors.error : AppColors.success,
                      size: 14,
                    ),
                    label: Text(
                      prof.status == 'ativo' ? 'Bloquear' : 'Ativar',
                      style: TextStyle(
                        color: prof.status == 'ativo' ? AppColors.error : AppColors.success,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () => dir.toggleStatus('profissional', prof.id),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
