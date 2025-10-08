import 'package:intl/intl.dart';

class DateUtils {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _monthYearFormat = DateFormat('MM/yyyy');

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatDisplayDate(DateTime date) {
    return _displayFormat.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  static DateTime? parseDate(String dateString) {
    try {
      return _dateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static String getCurrentDate() {
    return formatDate(DateTime.now());
  }

  static String getCurrentMonth() {
    return formatMonthYear(DateTime.now());
  }

  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static List<DateTime> getDaysInMonth(DateTime date) {
    final startOfMonth = getStartOfMonth(date);
    final endOfMonth = getEndOfMonth(date);
    final days = <DateTime>[];
    
    for (int i = 1; i <= endOfMonth.day; i++) {
      days.add(DateTime(date.year, date.month, i));
    }
    
    return days;
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static int getDaysDifference(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Ayer';
    } else if (difference < 7) {
      return 'Hace $difference días';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return 'Hace $weeks semana${weeks > 1 ? 's' : ''}';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return 'Hace $months mes${months > 1 ? 'es' : ''}';
    } else {
      final years = (difference / 365).floor();
      return 'Hace $years año${years > 1 ? 's' : ''}';
    }
  }
}
