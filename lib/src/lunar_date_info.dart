/// One call that gathers what a Vietnamese calendar prints for a solar date:
/// the lunar date, the Can Chi of the day, month and year, and the tiết khí.
library;

import 'astronomy.dart' show jdnFromDate;
import 'can_chi.dart' as can_chi;
import 'lunar_calendar.dart';

/// The lunar-calendar reading of one solar (Gregorian) date.
class LunarDateInfo {
  const LunarDateInfo({
    required this.lunar,
    required this.dayCanChi,
    required this.monthCanChi,
    required this.yearCanChi,
    required this.solarTermName,
  });

  /// The lunar date (day, month, year, leap-month flag).
  final LunarDay lunar;

  /// Can Chi of the day, lunar month and lunar year, e.g. "Giáp Thìn".
  final String dayCanChi, monthCanChi, yearCanChi;

  /// Name of the tiết khí in effect at local midnight of the date.
  final String solarTermName;

  @override
  String toString() =>
      'LunarDateInfo($lunar, ngày $dayCanChi, tháng $monthCanChi, '
      'năm $yearCanChi, $solarTermName)';
}

/// Lunar date, Can Chi and tiết khí of the Gregorian date [day]/[month]/
/// [year], computed for the civil [timeZone] (hours from UTC, default
/// UTC+7). Can Chi of the day does not depend on [timeZone].
LunarDateInfo lunarDateInfo({
  required int day,
  required int month,
  required int year,
  double timeZone = vietnamTimeZone,
}) {
  final lunar = solarToLunar(
    day: day,
    month: month,
    year: year,
    timeZone: timeZone,
  );
  final jdn = jdnFromDate(day: day, month: month, year: year);
  return LunarDateInfo(
    lunar: lunar,
    dayCanChi: can_chi.dayCanChi(jdn),
    monthCanChi: can_chi.monthCanChi(lunar.month, lunar.year),
    yearCanChi: can_chi.yearCanChi(lunar.year),
    solarTermName: solarTermNameFor(
      day: day,
      month: month,
      year: year,
      timeZone: timeZone,
    ),
  );
}
