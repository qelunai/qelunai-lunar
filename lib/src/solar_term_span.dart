/// Span of the tiết khí in effect on a date, and the next lunar milestone
/// (mùng 1 or rằm). Both are derived only from the existing engine functions
/// ([solarTermIndex], [solarToLunar]) so they stay consistent with the
/// rest of the package; nothing here is looked up or invented.
library;

import 'astronomy.dart';
import 'lunar_calendar.dart';

typedef CivilDate = ({int day, int month, int year});

/// The tiết khí in effect on a date, where it starts and ends (inclusive
/// local dates, using the same "term at local midnight" rule as
/// [solarTermNameFor]), and the 1-based day of the term.
class SolarTermSpan {
  const SolarTermSpan({
    required this.index,
    required this.name,
    required this.start,
    required this.end,
    required this.dayOfTerm,
    required this.lengthInDays,
  });

  /// Index into [solarTermNames] (0 = Xuân phân).
  final int index;
  final String name;
  final CivilDate start, end;
  final int dayOfTerm, lengthInDays;

  /// Name of the next tiết khí.
  String get nextName => solarTermNames[(index + 1) % solarTermNames.length];
}

SolarTermSpan solarTermSpanFor({
  required int day,
  required int month,
  required int year,
  double timeZone = vietnamTimeZone,
}) {
  final jdn = jdnFromDate(day: day, month: month, year: year);
  final index = solarTermIndex(jdn, timeZone);
  // A sector is 15° of solar longitude, i.e. 14–16 days; 20 is a safe bound.
  var first = jdn;
  while (first > jdn - 20 && solarTermIndex(first - 1, timeZone) == index) {
    first--;
  }
  var last = jdn;
  while (last < jdn + 20 && solarTermIndex(last + 1, timeZone) == index) {
    last++;
  }
  return SolarTermSpan(
    index: index,
    name: solarTermNames[index],
    start: dateFromJdn(first),
    end: dateFromJdn(last),
    dayOfTerm: jdn - first + 1,
    lengthInDays: last - first + 1,
  );
}

/// The next lunar day 1 (mùng một) or 15 (rằm), counting today.
class LunarMilestone {
  const LunarMilestone({
    required this.isFullMoon,
    required this.solar,
    required this.lunar,
    required this.daysAway,
  });

  /// true for rằm (lunar day 15), false for mùng một (lunar day 1).
  final bool isFullMoon;
  final CivilDate solar;
  final LunarDay lunar;

  /// 0 when the milestone is today.
  final int daysAway;
}

LunarMilestone nextLunarMilestone({
  required int day,
  required int month,
  required int year,
  double timeZone = vietnamTimeZone,
}) {
  final jdn = jdnFromDate(day: day, month: month, year: year);
  // A lunar month is at most 30 days, so a 1st or 15th is within 16 days.
  for (var i = 0; i <= 16; i++) {
    final d = dateFromJdn(jdn + i);
    final l = solarToLunar(
      day: d.day,
      month: d.month,
      year: d.year,
      timeZone: timeZone,
    );
    if (l.day == 1 || l.day == 15) {
      return LunarMilestone(
        isFullMoon: l.day == 15,
        solar: d,
        lunar: l,
        daysAway: i,
      );
    }
  }
  throw StateError('No lunar 1st/15th within 16 days of $day/$month/$year');
}
