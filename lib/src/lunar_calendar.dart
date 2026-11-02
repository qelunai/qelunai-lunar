/// Solar ↔ lunar (Vietnamese) calendar conversion.
///
/// The method: locate the new moon starting the day's lunar month, locate the
/// new moon starting lunar month 11 (the month containing Đông chí / winter
/// solstice) for the years around the date, and insert a leap month when a
/// 13-month solar year contains a lunar month with no "trung khí" (principal
/// solar term). The astronomy and month numbering live in `core/` (see
/// `CLEANROOM.md`); this file is a thin wrapper over it. Results are
/// cross-checked in `test/lunar_calendar_test.dart` against published
/// Vietnamese calendar dates and in `test/jpl_test.dart` against NASA JPL's
/// DE440s ephemeris.
///
/// Vietnam's civil calendar uses UTC+7, which this package defaults to; it
/// can diverge from the Chinese/Korean lunar calendars (UTC+8/+9) when a new
/// moon or solstice falls near a timezone-dependent day boundary.
library;

import 'astronomy.dart';
import 'core/lunar_month.dart';

/// Default civil timezone offset used for Vietnamese lunar calendar
/// calculations (UTC+7), regardless of the device's local timezone.
const double vietnamTimeZone = 7.0;

class LunarDay {
  const LunarDay({
    required this.day,
    required this.month,
    required this.year,
    required this.isLeapMonth,
  });

  final int day, month, year;
  final bool isLeapMonth;

  @override
  bool operator ==(Object other) =>
      other is LunarDay &&
      other.day == day &&
      other.month == month &&
      other.year == year &&
      other.isLeapMonth == isLeapMonth;

  @override
  int get hashCode => Object.hash(day, month, year, isLeapMonth);

  @override
  String toString() =>
      'LunarDay($day/$month${isLeapMonth ? ' nhuận' : ''}/$year)';
}

/// Name of the tiết khí in effect on the given Gregorian date at local
/// midnight (civil [timeZone], default UTC+7).
String solarTermNameFor({
  required int day,
  required int month,
  required int year,
  double timeZone = vietnamTimeZone,
}) {
  final jdn = jdnFromDate(day: day, month: month, year: year);
  return solarTermNames[solarTermIndex(jdn, timeZone)];
}

/// Converts a Gregorian calendar date to its Vietnamese lunar-calendar
/// equivalent, for the given [timeZone] offset in hours (defaults to
/// Vietnam's UTC+7).
LunarDay solarToLunar({
  required int day,
  required int month,
  required int year,
  double timeZone = vietnamTimeZone,
}) {
  final jdn = jdnFromDate(day: day, month: month, year: year);
  final k = lunationIndexForJdn(jdn, timeZone);
  final resolved = resolveMonth(k, timeZone);
  return LunarDay(
    day: jdn - newMoonDay(k, timeZone) + 1,
    month: resolved.number,
    year: resolved.lunarYear,
    isLeapMonth: resolved.isLeap,
  );
}

/// Converts a Vietnamese lunar-calendar date back to its Gregorian
/// equivalent. Returns `null` for an impossible input, e.g. [isLeapMonth]
/// true for a lunar month/year that has no leap month.
({int day, int month, int year})? lunarToSolar({
  required int day,
  required int month,
  required int year,
  bool isLeapMonth = false,
  double timeZone = vietnamTimeZone,
}) {
  final entry = findMonth(
    lunarYear: year,
    month: month,
    isLeapMonth: isLeapMonth,
    timeZone: timeZone,
  );
  if (entry == null) return null;
  return dateFromJdn(newMoonDay(entry.k, timeZone) + day - 1);
}
