import 'package:intl/intl.dart';

class AppFormatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final DateFormat _monthYearFormat = DateFormat('MMMM \'de\' yyyy', 'pt_BR');
  static final DateFormat _monthYearShort = DateFormat('MMMM yyyy', 'pt_BR');
  static final NumberFormat _currencyShortFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat _dateShortFormat = DateFormat('dd/MM', 'pt_BR');
  static final DateFormat _dayOfWeek = DateFormat('EEEE', 'pt_BR');

  static String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  static String formatCurrencyShort(double value) {
    if (value >= 1000) {
      return _currencyShortFormat.format(value);
    }
    return _currencyFormat.format(value);
  }

  static String formatDateShort(DateTime date) {
    return _dateShortFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static String formatMonthYearShort(DateTime date) {
    return _monthYearShort.format(date);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDayOfWeek(DateTime date) {
    return _dayOfWeek.format(date);
  }

  static String formatHours(double hours) {
    final h = hours.toInt();
    final m = ((hours - h) * 60).toInt();
    if (m == 0) return '${h}h';
    return '${h}h${m.toString().padLeft(2, '0')}';
  }

  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(0)}%';
  }

  /// Formata valor por hora (R$/h). Retorna "—" quando [totalHours] <= 0.
  static String formatCurrencyPerHour(double totalValue, double totalHours) {
    if (totalHours <= 0) return '—';
    return _currencyFormat.format(totalValue / totalHours) + '/h';
  }

  static double calculateDurationHours(String startTime, String endTime) {
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);

    double diff = end - start;
    if (diff <= 0) diff += 24.0;

    return diff;
  }

  static double _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return hours + minutes / 60.0;
  }
}
