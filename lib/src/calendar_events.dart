/// Dated events derived only from the lunar calendar: mùng một, rằm, the
/// start of each tiết khí and Tết Nguyên đán. Callers can merge their own
/// events (e.g. ngày giỗ) by passing another [CalendarEventSource] to
/// [upcomingEvents].
library;

import 'astronomy.dart';
import 'can_chi.dart' as can_chi;
import 'lunar_calendar.dart';
import 'solar_term_span.dart';

/// What an event is. [other] is for
/// events from other sources, which carry their own [CalendarEvent.title].
enum CalendarEventKind { tet, newMoon, fullMoon, solarTerm, other }

/// One dated event. [title] is the event's own name when it cannot be
/// derived from [kind] (the tiết khí name, or a name given by another
/// source); [lunar] is the lunar date of [date].
class CalendarEvent {
  const CalendarEvent({
    required this.date,
    required this.lunar,
    required this.kind,
    this.title,
    this.ref,
  });

  final CivilDate date;
  final LunarDay lunar;
  final CalendarEventKind kind;
  final String? title;

  /// Id of the record this event comes from, for sources that own one
  /// (e.g. the ngày giỗ); null for events derived from the calendar.
  final String? ref;

  int get jdn => jdnFromDate(day: date.day, month: date.month, year: date.year);
}

/// Events between [from] and [to], both inclusive.
typedef CalendarEventSource = List<CalendarEvent> Function(
  CivilDate from,
  CivilDate to,
);

/// Mùng một, rằm, tiết khí and Tết from [from] to [to] (inclusive), in date
/// order. Mùng một tháng Giêng is listed once, as [CalendarEventKind.tet].
///
/// A tiết khí is listed on the day it begins as calendars print it: the
/// engine assigns each day the term in effect at its local midnight, so the
/// crossing falls on the last day of the previous term (see
/// [SolarTermSpan]).
List<CalendarEvent> lunarCalendarEvents(
  CivilDate from,
  CivilDate to, {
  double timeZone = vietnamTimeZone,
}) {
  final first = jdnFromDate(day: from.day, month: from.month, year: from.year);
  final last = jdnFromDate(day: to.day, month: to.month, year: to.year);
  final events = <CalendarEvent>[];
  for (var jdn = first; jdn <= last; jdn++) {
    final date = dateFromJdn(jdn);
    final lunar = solarToLunar(
      day: date.day,
      month: date.month,
      year: date.year,
      timeZone: timeZone,
    );
    final kind = switch (lunar) {
      LunarDay(day: 1, month: 1, isLeapMonth: false) => CalendarEventKind.tet,
      LunarDay(day: 1) => CalendarEventKind.newMoon,
      LunarDay(day: 15) => CalendarEventKind.fullMoon,
      _ => null,
    };
    if (kind != null) {
      events.add(CalendarEvent(date: date, lunar: lunar, kind: kind));
    }
    final next = solarTermIndex(jdn + 1, timeZone);
    if (next != solarTermIndex(jdn, timeZone)) {
      events.add(
        CalendarEvent(
          date: date,
          lunar: lunar,
          kind: CalendarEventKind.solarTerm,
          title: solarTermNames[next],
        ),
      );
    }
  }
  return events;
}

/// The sources [upcomingEvents] reads by default.
const List<CalendarEventSource> defaultEventSources = [lunarCalendarEvents];

/// Events from [today] through the next [days] days from every source,
/// sorted by date and then by [CalendarEventKind] order.
List<CalendarEvent> upcomingEvents({
  required CivilDate today,
  int days = 45,
  List<CalendarEventSource> sources = defaultEventSources,
}) {
  final start = jdnFromDate(
    day: today.day,
    month: today.month,
    year: today.year,
  );
  final end = dateFromJdn(start + days);
  final events = [for (final source in sources) ...source(today, end)]
    ..sort((a, b) {
      final byDate = a.jdn.compareTo(b.jdn);
      return byDate != 0 ? byDate : a.kind.index.compareTo(b.kind.index);
    });
  return events;
}

/// Whole days from [from] to [to] (negative when [to] is earlier).
int daysBetween(CivilDate from, CivilDate to) =>
    jdnFromDate(day: to.day, month: to.month, year: to.year) -
    jdnFromDate(day: from.day, month: from.month, year: from.year);

/// Days of Tết counted as "during Tết" by [nextTet]: mùng 1 to mùng 3.
const int tetHolidayDays = 3;

/// The Tết Nguyên đán that is coming (or under way) on a given day.
class TetInfo {
  const TetInfo({
    required this.lunarYear,
    required this.newYear,
    required this.eve,
    required this.kitchenGods,
    required this.daysUntil,
    required this.dayOfTet,
  });

  /// The lunar year that Tết opens.
  final int lunarYear;

  /// Mùng 1 tháng Giêng.
  final CivilDate newYear;

  /// Giao thừa: the night of the last day of tháng Chạp.
  final CivilDate eve;

  /// 23 tháng Chạp, when ông Công ông Táo are seen off.
  final CivilDate kitchenGods;

  /// 0 from mùng 1 onwards.
  final int daysUntil;

  /// 1 to [tetHolidayDays] during Tết, otherwise null.
  final int? dayOfTet;

  String get yearCanChi => can_chi.yearCanChi(lunarYear);

  /// Index into [can_chi.earthlyBranches] (Tý = 0) of the year: its con giáp.
  int get yearBranch => ((lunarYear - 1984) % 12 + 12) % 12;
}

/// The next Tết from [today], or the current one from mùng 1 to mùng
/// [tetHolidayDays].
TetInfo nextTet(CivilDate today, {double timeZone = vietnamTimeZone}) {
  final lunar = solarToLunar(
    day: today.day,
    month: today.month,
    year: today.year,
    timeZone: timeZone,
  );
  final during =
      lunar.month == 1 && !lunar.isLeapMonth && lunar.day <= tetHolidayDays;
  final year = during ? lunar.year : lunar.year + 1;
  final newYear = lunarToSolar(
    day: 1,
    month: 1,
    year: year,
    timeZone: timeZone,
  )!;
  final newYearJdn = jdnFromDate(
    day: newYear.day,
    month: newYear.month,
    year: newYear.year,
  );
  final kitchenGods = lunarToSolar(
    day: 23,
    month: 12,
    year: year - 1,
    timeZone: timeZone,
  )!;
  final until = daysBetween(today, newYear);
  return TetInfo(
    lunarYear: year,
    newYear: newYear,
    eve: dateFromJdn(newYearJdn - 1),
    kitchenGods: kitchenGods,
    daysUntil: until < 0 ? 0 : until,
    dayOfTet: during ? lunar.day : null,
  );
}
