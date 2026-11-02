/// Solar ↔ lunar (Vietnamese) calendar conversion.
///
/// The method: locate the new moon starting the day's lunar month, locate the
/// new moon starting lunar month 11 (the month containing Đông chí / winter
/// solstice) for the years around the date, and insert a leap month when a
/// 13-month solar year contains a lunar month with no "trung khí" (principal
/// solar term). [solarToLunar] and [lunarToSolar] live in
/// `conversion_core.dart` and are re-exported from here. Date-specific
/// results are cross-checked in `test/lunar_calendar_test.dart` against
/// published Vietnamese calendar dates.
///
/// Vietnam's civil calendar uses UTC+7, which this package defaults to; it
/// can diverge from the Chinese/Korean lunar calendars (UTC+8/+9) when a new
/// moon or solstice falls near a timezone-dependent day boundary.
library;

import 'astronomy.dart';

export 'conversion_core.dart' show solarToLunar, lunarToSolar;

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
