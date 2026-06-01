
export '../../theme/app_colors.dart';

String initials(String name) {
  final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '??';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
