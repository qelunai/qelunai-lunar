import 'package:test/test.dart';
import 'package:qelunai_lunar/src/calendar_events.dart';
import 'package:qelunai_lunar/src/lunar_calendar.dart';
import 'package:qelunai_lunar/src/solar_term_span.dart';

CivilDate d(int y, int m, int day) => (day: day, month: m, year: y);

void main() {
  group('lunarCalendarEvents', () {
    // October 2026: mùng 1 tháng 9 is 10.10, rằm
    // is 24.10, Hàn lộ begins 08.10 and Sương giáng 23.10.
    final october = lunarCalendarEvents(d(2026, 10, 1), d(2026, 10, 31));

    test('lists mùng một and rằm', () {
      final moons = [
        for (final e in october)
          if (e.kind == CalendarEventKind.newMoon ||
              e.kind == CalendarEventKind.fullMoon)
            (e.kind, e.date, e.lunar.day, e.lunar.month),
      ];
      expect(moons, [
        (CalendarEventKind.newMoon, d(2026, 10, 10), 1, 9),
        (CalendarEventKind.fullMoon, d(2026, 10, 24), 15, 9),
      ]);
    });

    test('lists tiết khí on the day calendars print them', () {
      final terms = [
        for (final e in october)
          if (e.kind == CalendarEventKind.solarTerm) (e.title, e.date),
      ];
      expect(terms, [
        ('Hàn lộ', d(2026, 10, 8)),
        ('Sương giáng', d(2026, 10, 23)),
      ]);
      final next = lunarCalendarEvents(d(2026, 11, 1), d(2026, 11, 30));
      expect(
        next.where((e) => e.kind == CalendarEventKind.solarTerm).first.date,
        d(2026, 11, 7),
      );
    });

    test('lists mùng 1 tháng Giêng once, as Tết', () {
      final feb = lunarCalendarEvents(d(2027, 2, 1), d(2027, 2, 28));
      final onTet = feb.where((e) => e.date == d(2027, 2, 6)).toList();
      expect(onTet.map((e) => e.kind), [CalendarEventKind.tet]);
      // Tết 2024 (Giáp Thìn) was on 10.02.2024.
      final tet2024 = lunarCalendarEvents(
        d(2024, 2, 1),
        d(2024, 2, 29),
      ).where((e) => e.kind == CalendarEventKind.tet).map((e) => e.date);
      expect(tet2024, [d(2024, 2, 10)]);
    });

    test('is in date order and inclusive at both ends', () {
      final events = lunarCalendarEvents(d(2026, 10, 10), d(2026, 10, 10));
      expect(events.single.kind, CalendarEventKind.newMoon);
      final jdns = [for (final e in october) e.jdn];
      expect(jdns, [...jdns]..sort());
    });
  });

  group('upcomingEvents', () {
    test('merges every source in date order', () {
      List<CalendarEvent> other(CivilDate from, CivilDate to) => [
            CalendarEvent(
              date: d(2026, 11, 2),
              lunar: solarToLunar(day: 2, month: 11, year: 2026),
              kind: CalendarEventKind.other,
              title: 'Giỗ',
            ),
          ];
      final events = upcomingEvents(
        today: d(2026, 10, 28),
        days: 14,
        sources: [lunarCalendarEvents, other],
      );
      expect(
        [for (final e in events) (e.kind, e.date)],
        [
          (CalendarEventKind.other, d(2026, 11, 2)),
          (CalendarEventKind.solarTerm, d(2026, 11, 7)),
          (CalendarEventKind.newMoon, d(2026, 11, 9)),
        ],
      );
    });

    test('counts today', () {
      final events = upcomingEvents(today: d(2026, 10, 24), days: 0);
      expect(events.single.kind, CalendarEventKind.fullMoon);
    });
  });

  test('daysBetween', () {
    expect(daysBetween(d(2026, 10, 28), d(2026, 11, 9)), 12);
    expect(daysBetween(d(2026, 11, 9), d(2026, 10, 28)), -12);
    expect(daysBetween(d(2026, 12, 31), d(2027, 1, 1)), 1);
  });

  group('nextTet', () {
    test('Tết Đinh Mùi is 101 days after 28.10.2026', () {
      final tet = nextTet(d(2026, 10, 28));
      expect(tet.lunarYear, 2027);
      expect(tet.yearCanChi, 'Đinh Mùi');
      expect(tet.yearBranch, 7);
      expect(tet.newYear, d(2027, 2, 6));
      expect(tet.eve, d(2027, 2, 5));
      expect(tet.kitchenGods, d(2027, 1, 30));
      expect(tet.daysUntil, 101);
      expect(tet.dayOfTet, isNull);
    });

    test('during Tết it is the current one', () {
      final tet = nextTet(d(2027, 2, 7));
      expect(tet.lunarYear, 2027);
      expect(tet.daysUntil, 0);
      expect(tet.dayOfTet, 2);
    });

    test('after mùng 3 it is next year', () {
      final tet = nextTet(d(2027, 2, 9));
      expect(tet.lunarYear, 2028);
      expect(tet.yearCanChi, 'Mậu Thân');
      expect(tet.dayOfTet, isNull);
      expect(tet.daysUntil, greaterThan(300));
    });

    test('on giao thừa it is one day away', () {
      final tet = nextTet(d(2027, 2, 5));
      expect(tet.daysUntil, 1);
      // Tết 2025 (Ất Tỵ) was on 29.01.2025.
      expect(nextTet(d(2025, 1, 1)).newYear, d(2025, 1, 29));
      expect(nextTet(d(2025, 1, 1)).yearCanChi, 'Ất Tỵ');
    });
  });
}
