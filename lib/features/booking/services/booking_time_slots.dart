import 'package:hossy_barbers/core/constants/development_content.dart';
import 'package:hossy_barbers/features/services/domain/service.dart';

abstract final class BookingTimeSlots {
  static List<String> forAppointment({
    required DateTime date,
    required Map<String, String> openingHours,
    Service? service,
    DateTime? now,
  }) {
    final range = _openingRangeFor(date, openingHours);
    if (range == null) return const [];

    final duration = _durationFor(service);
    final referenceNow = now ?? DateTime.now();
    final isToday = _isSameDate(date, referenceNow);
    final currentMinute = referenceNow.hour * 60 + referenceNow.minute;
    final slots = <String>[];
    for (
      var minute = range.start;
      minute + duration <= range.end;
      minute += duration
    ) {
      if (isToday && minute <= currentMinute) continue;
      slots.add(_formatMinute(minute));
    }
    return slots;
  }

  static bool isOpenOnDate(DateTime date, Map<String, String> openingHours) =>
      _openingRangeFor(date, openingHours) != null;

  static _OpeningRange? _openingRangeFor(
    DateTime date,
    Map<String, String> configuredHours,
  ) {
    final hours = configuredHours.isEmpty
        ? DevelopmentContent.openingHours
        : configuredHours;
    final weekday = _weekdays[date.weekday - 1];
    for (final entry in hours.entries) {
      if (_includesDay(entry.key, weekday)) return _parseRange(entry.value);
    }
    return null;
  }

  static bool _includesDay(String dayLabel, String weekday) {
    final normalized = dayLabel.toLowerCase().replaceAll('–', '-').trim();
    if (normalized == 'daily' ||
        normalized == 'every day' ||
        normalized == 'all days' ||
        normalized == 'monday-sunday') {
      return true;
    }
    if (!normalized.contains('-')) return normalized == weekday;

    final days = _weekdays;
    final range = normalized.split('-').map((value) => value.trim()).toList();
    if (range.length != 2) return false;
    final first = days.indexOf(range.first);
    final last = days.indexOf(range.last);
    final selected = days.indexOf(weekday);
    if (first < 0 || last < 0 || selected < 0) return false;
    return first <= last
        ? selected >= first && selected <= last
        : selected >= first || selected <= last;
  }

  static _OpeningRange? _parseRange(String value) {
    if (value.toLowerCase().contains('closed')) return null;
    final match = RegExp(
      r'^\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm)\s*[-–]\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm)\s*$',
      caseSensitive: false,
    ).firstMatch(value);
    if (match == null) return null;
    final start = _toMinute(match.group(1)!, match.group(2), match.group(3)!);
    final end = _toMinute(match.group(4)!, match.group(5), match.group(6)!);
    if (start == null || end == null || end <= start) return null;
    return _OpeningRange(start, end);
  }

  static int? _toMinute(String hourText, String? minuteText, String meridiem) {
    final hour = int.tryParse(hourText);
    final minute = int.tryParse(minuteText ?? '0');
    if (hour == null ||
        minute == null ||
        hour < 1 ||
        hour > 12 ||
        minute > 59) {
      return null;
    }
    var normalizedHour = hour % 12;
    if (meridiem.toLowerCase() == 'pm') normalizedHour += 12;
    return normalizedHour * 60 + minute;
  }

  static int _durationFor(Service? service) {
    final value = service?.duration?.toLowerCase() ?? '';
    final hours = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:hour|hours|hr|hrs)',
    ).firstMatch(value);
    final minutes = RegExp(
      r'(\d+)\s*(?:minute|minutes|min|mins)',
    ).firstMatch(value);
    final hourMinutes = hours == null
        ? 0
        : ((double.tryParse(hours.group(1)!) ?? 0) * 60).round();
    final minuteValue = minutes == null
        ? 0
        : int.tryParse(minutes.group(1)!) ?? 0;
    final duration = hourMinutes + minuteValue;
    return duration >= 15 ? duration : 30;
  }

  static String _formatMinute(int totalMinutes) {
    final hour = totalMinutes ~/ 60;
    final minute = totalMinutes % 60;
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  static bool _isSameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  static const _weekdays = <String>[
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
}

class _OpeningRange {
  const _OpeningRange(this.start, this.end);

  final int start;
  final int end;
}
