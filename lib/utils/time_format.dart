String formatTimestamp(DateTime? value) {
  if (value == null) return '';

  final local = value.toLocal();
  final now = DateTime.now();
  final difference = now.difference(local);

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inHours < 1) return '${difference.inMinutes}m ago';

  final isToday = local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  if (isToday) return _clockTime(local);

  final yesterday = now.subtract(const Duration(days: 1));
  final isYesterday = local.year == yesterday.year &&
      local.month == yesterday.month &&
      local.day == yesterday.day;
  if (isYesterday) return 'Yesterday';

  if (difference.inDays < 7) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[local.weekday - 1];
  }

  return '${local.day}/${local.month}/${local.year}';
}

String _clockTime(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}
