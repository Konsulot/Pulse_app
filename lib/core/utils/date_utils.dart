import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd.MM.yyyy').format(date);
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '—';
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime.toLocal());
  }

  static String toIsoDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String formatRussianDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd.MM.yyyy').format(date);
  }

  static DateTime? tryParseRussianDate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final match = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(text);
    if (match == null) return null;

    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;

    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }

  static String? validateRussianBirthDate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;

    final date = tryParseRussianDate(text);
    if (date == null) return 'Введите дату в формате ДД.ММ.ГГГГ';
    if (date.isBefore(DateTime(1900))) return 'Дата рождения не может быть раньше 1900 года';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (date.isAfter(today)) return 'Дата рождения не может быть в будущем';

    return null;
  }
}
