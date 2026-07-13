import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// ═══════════════════════════════════════════════════════════════
// Status Badge — Badge de status colorido reutilizável
// ═══════════════════════════════════════════════════════════════

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  factory StatusBadge.fromStatus(String status) {
    Color color;
    switch (status) {
      case 'Pendente':
        color = AppColors.statusPending;
        break;
      case 'A Caminho':
        color = AppColors.statusEnRoute;
        break;
      case 'Em Andamento':
        color = AppColors.statusInProgress;
        break;
      case 'Concluído':
        color = AppColors.statusCompleted;
        break;
      case 'Pago':
        color = AppColors.statusPaid;
        break;
      case 'Ativo':
        color = AppColors.success;
        break;
      case 'Suspenso':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textMuted;
    }
    return StatusBadge(label: status, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
