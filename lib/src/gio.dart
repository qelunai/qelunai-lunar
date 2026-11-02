/// Ngày giỗ: which solar day a death anniversary kept by the lunar calendar
/// falls on, and the rằm / mùng một days. Pure: every "today" comes in as a
/// parameter.
///
/// Conventions (a choice of this package; other families may keep giỗ
/// differently):
///
/// * **Tháng nhuận.** A death in a leap month is remembered in the regular
///   month of the same number every year (người mất tháng 4 nhuận giỗ vào
///   tháng 4 thường), since most years have no such leap month. A death in a
///   regular month whose number is repeated as a leap month in some year is
///   also remembered in the regular month, never in the leap one.
/// * **Tháng thiếu.** A death on day 30 is remembered on the last day of the
///   month: day 30 when the month has 30 days (tháng đủ), day 29 when it has
///   only 29 (tháng thiếu). The giỗ never moves into the next month.
/// * **Năm.** With a known year of death, the first giỗ (giỗ đầu) is in the
///   next lunar year; no giỗ is returned for the year of death or earlier.
///   Without one, every lunar year has a giỗ.
library;

import 'astronomy.dart' show dateFromJdn, jdnFromDate;
import 'lunar_calendar.dart';

/// Number of days (29 or 30) in a lunar month, or null when the month does
/// not exist (a leap month in a year without it).
int? lunarMonthLength({
  required int month,
  required int year,
  bool isLeapMonth = false,
}) {
  final first = lunarToSolar(
    day: 1,
    month: month,
    year: year,
    isLeapMonth: isLeapMonth,
  );
  if (first == null) return null;
  final jdn30 =
      jdnFromDate(day: first.day, month: first.month, year: first.year) + 29;
  final d30 = dateFromJdn(jdn30);
  final lunar = solarToLunar(day: d30.day, month: d30.month, year: d30.year);
  return lunar.day == 30 ? 30 : 29;
}

/// One giỗ: the solar date it falls on and the lunar date kept that year.
class GioOccurrence {
  const GioOccurrence({
    required this.date,
    required this.lunarYear,
    required this.lunarDay,
    required this.lunarMonth,
    this.ordinal,
  });

  /// Solar date (year, month, day only; local midnight).
  final DateTime date;

  /// Lunar year of this giỗ, and the day/month actually kept (day 29 when
  /// the death day 30 does not exist that year).
  final int lunarYear, lunarDay, lunarMonth;

  /// 1 for giỗ đầu, 2 for giỗ thứ hai...; null when the year of death is
  /// unknown.
  final int? ordinal;

  @override
  bool operator ==(Object other) =>
      other is GioOccurrence &&
      other.date == date &&
      other.lunarYear == lunarYear &&
      other.lunarDay == lunarDay &&
      other.lunarMonth == lunarMonth &&
      other.ordinal == ordinal;

  @override
  int get hashCode =>
      Object.hash(date, lunarYear, lunarDay, lunarMonth, ordinal);

  @override
  String toString() => 'GioOccurrence(${date.year}-${date.month}-${date.day}, '
      '$lunarDay/$lunarMonth/$lunarYear, #$ordinal)';
}

/// The giỗ of a death on lunar [deathDay]/[deathMonth] kept in [lunarYear]
/// (see the library conventions), or null for [lunarYear] at or before
/// [deathYear].
GioOccurrence? gioInLunarYear({
  required int deathDay,
  required int deathMonth,
  required int lunarYear,
  int? deathYear,
}) {
  RangeError.checkValueInInterval(deathDay, 1, 30, 'deathDay');
  RangeError.checkValueInInterval(deathMonth, 1, 12, 'deathMonth');
  if (deathYear != null && lunarYear <= deathYear) return null;
  var day = deathDay;
  if (day == 30 && lunarMonthLength(month: deathMonth, year: lunarYear) != 30) {
    day = 29;
  }
  final solar = lunarToSolar(day: day, month: deathMonth, year: lunarYear)!;
  return GioOccurrence(
    date: DateTime(solar.year, solar.month, solar.day),
    lunarYear: lunarYear,
    lunarDay: day,
    lunarMonth: deathMonth,
    ordinal: deathYear == null ? null : lunarYear - deathYear,
  );
}

int _jdn(DateTime d) => jdnFromDate(day: d.day, month: d.month, year: d.year);

/// Whole days from [from] to [to], by calendar date (no DST effects).
int daysBetween(DateTime from, DateTime to) => _jdn(to) - _jdn(from);

/// The first giỗ on or after the solar day [from] (time of day ignored).
GioOccurrence nextGio({
  required int deathDay,
  required int deathMonth,
  required DateTime from,
  int? deathYear,
}) {
  final today = solarToLunar(day: from.day, month: from.month, year: from.year);
  var year = today.year;
  if (deathYear != null && year <= deathYear) year = deathYear + 1;
  while (true) {
    final g = gioInLunarYear(
      deathDay: deathDay,
      deathMonth: deathMonth,
      lunarYear: year,
      deathYear: deathYear,
    )!;
    if (daysBetween(from, g.date) >= 0) return g;
    year++;
  }
}

/// Every giỗ whose solar date is in [from]..[to] (both inclusive), oldest
/// first.
List<GioOccurrence> gioBetween({
  required int deathDay,
  required int deathMonth,
  required DateTime from,
  required DateTime to,
  int? deathYear,
}) {
  if (daysBetween(from, to) < 0) return const [];
  final result = <GioOccurrence>[];
  var g = nextGio(
    deathDay: deathDay,
    deathMonth: deathMonth,
    from: from,
    deathYear: deathYear,
  );
  while (daysBetween(g.date, to) >= 0) {
    result.add(g);
    g = gioInLunarYear(
      deathDay: deathDay,
      deathMonth: deathMonth,
      lunarYear: g.lunarYear + 1,
      deathYear: deathYear,
    )!;
  }
  return result;
}

/// A mùng một (day 1) or rằm (day 15) of a lunar month.
class MoonDay {
  const MoonDay({required this.date, required this.lunar});

  /// Solar date (local midnight).
  final DateTime date;
  final LunarDay lunar;

  bool get isFullMoon => lunar.day == 15;
}

/// The next [count] mùng một and rằm days on or after [from].
List<MoonDay> nextMoonDays({required DateTime from, int count = 2}) {
  final result = <MoonDay>[];
  var jdn = _jdn(from);
  while (result.length < count) {
    final d = dateFromJdn(jdn);
    final lunar = solarToLunar(day: d.day, month: d.month, year: d.year);
    if (lunar.day == 1 || lunar.day == 15) {
      result.add(MoonDay(date: DateTime(d.year, d.month, d.day), lunar: lunar));
      // The next one is at least 13 days away.
      jdn += 13;
    } else {
      jdn += 1;
    }
  }
  return result;
}
