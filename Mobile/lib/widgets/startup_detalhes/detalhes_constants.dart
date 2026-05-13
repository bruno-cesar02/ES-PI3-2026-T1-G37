/* Ponte entre os widgets de detalhes e o AppColors unificado.
   Todos os widgets desta pasta importam deste arquivo.
   As cores vêm de app_colors.dart — fonte única de verdade. */

export '../../theme/app_colors.dart';

String initials(String name) {
  final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '??';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
