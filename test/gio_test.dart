import 'package:test/test.dart';
import 'package:qelunai_lunar/src/gio.dart';

void main() {
  group('lunarMonthLength', () {
    test('tells tháng đủ from tháng thiếu', () {
      // Lunar 2026: tháng 1 đủ (30), tháng 2 thiếu (29).
      expect(lunarMonthLength(month: 1, year: 2026), 30);
      expect(lunarMonthLength(month: 2, year: 2026), 29);
    });

    test('knows which years have a leap month', () {
      // 2023 has tháng 2 nhuận, 2025 has tháng 6 nhuận, 2026 has none.
      expect(
        lunarMonthLength(month: 2, year: 2023, isLeapMonth: true),
        isNotNull,
      );
      expect(
        lunarMonthLength(month: 6, year: 2025, isLeapMonth: true),
        isNotNull,
      );
      expect(lunarMonthLength(month: 6, year: 2026, isLeapMonth: true), isNull);
    });
  });

  group('gioInLunarYear', () {
    test('converts a regular day to the solar date of that year', () {
      final g = gioInLunarYear(deathDay: 12, deathMonth: 10, lunarYear: 2026)!;
      expect(g.date, DateTime(2026, 11, 20));
      expect((g.lunarDay, g.lunarMonth, g.lunarYear), (12, 10, 2026));
      expect(g.ordinal, isNull);
    });

    test('day 30 falls back to day 29 in a tháng thiếu', () {
      // Tháng 2/2026 has 29 days: kept on 29/2, not moved into tháng 3.
      final short = gioInLunarYear(
        deathDay: 30,
        deathMonth: 2,
        lunarYear: 2026,
      )!;
      expect(short.lunarDay, 29);
      expect(short.date, DateTime(2026, 4, 16));
      // Tháng 1/2026 has 30 days: kept on 30/1.
      final full = gioInLunarYear(
        deathDay: 30,
        deathMonth: 1,
        lunarYear: 2026,
      )!;
      expect(full.lunarDay, 30);
      expect(full.date, DateTime(2026, 3, 18));
    });

    test('a year with a leap month uses the regular month', () {
      // 2025 has tháng 6 nhuận (from 25/7/2025); tháng 6 thường starts 25/6.
      final g = gioInLunarYear(deathDay: 1, deathMonth: 6, lunarYear: 2025)!;
      expect(g.date, DateTime(2025, 6, 25));
    });

    test('nothing in or before the year of death; giỗ đầu the year after', () {
      expect(
        gioInLunarYear(
          deathDay: 5,
          deathMonth: 3,
          lunarYear: 2024,
          deathYear: 2024,
        ),
        isNull,
      );
      final first = gioInLunarYear(
        deathDay: 5,
        deathMonth: 3,
        lunarYear: 2025,
        deathYear: 2024,
      )!;
      expect(first.ordinal, 1);
    });

    test('rejects impossible lunar dates', () {
      expect(
        () => gioInLunarYear(deathDay: 31, deathMonth: 1, lunarYear: 2026),
        throwsRangeError,
      );
      expect(
        () => gioInLunarYear(deathDay: 1, deathMonth: 13, lunarYear: 2026),
        throwsRangeError,
      );
    });
  });

  group('nextGio', () {
    test('this year when still ahead, next year once passed', () {
      final ahead = nextGio(
        deathDay: 12,
        deathMonth: 10,
        from: DateTime(2026, 10, 28),
      );
      expect(ahead.date, DateTime(2026, 11, 20));
      expect(daysBetween(DateTime(2026, 10, 28), ahead.date), 23);

      final passed = nextGio(
        deathDay: 12,
        deathMonth: 10,
        from: DateTime(2026, 11, 21),
      );
      expect(passed.lunarYear, 2027);
      expect(passed.date.isAfter(DateTime(2027, 10, 1)), isTrue);
    });

    test('the giỗ day itself counts as upcoming, time of day ignored', () {
      final g = nextGio(
        deathDay: 12,
        deathMonth: 10,
        from: DateTime(2026, 11, 20, 23, 59),
      );
      expect(g.date, DateTime(2026, 11, 20));
    });

    test('a recent death waits for giỗ đầu', () {
      // Died 5/3 âm 2026 (21/4/2026): no giỗ until lunar 2027.
      final g = nextGio(
        deathDay: 5,
        deathMonth: 3,
        deathYear: 2026,
        from: DateTime(2026, 4, 22),
      );
      expect(g.lunarYear, 2027);
      expect(g.ordinal, 1);
    });
  });

  group('gioBetween', () {
    test('lists each year in range, oldest first', () {
      final list = gioBetween(
        deathDay: 27,
        deathMonth: 10,
        from: DateTime(2026),
        to: DateTime(2028, 12, 31),
      );
      expect(list.map((g) => g.lunarYear), [2026, 2027, 2028]);
      expect(list.first.date, DateTime(2026, 12, 5));
    });

    test('is empty for an inverted range', () {
      expect(
        gioBetween(
          deathDay: 1,
          deathMonth: 1,
          from: DateTime(2027),
          to: DateTime(2026),
        ),
        isEmpty,
      );
    });
  });

  group('nextMoonDays', () {
    test('returns mùng một then rằm', () {
      final days = nextMoonDays(from: DateTime(2026, 10, 28), count: 3);
      expect(days.map((d) => d.date), [
        DateTime(2026, 11, 9),
        DateTime(2026, 11, 23),
        DateTime(2026, 12, 9),
      ]);
      expect(days.map((d) => d.isFullMoon), [false, true, false]);
      expect(days.first.lunar.month, 10);
    });

    test('includes the starting day', () {
      final days = nextMoonDays(from: DateTime(2026, 11, 9), count: 1);
      expect(days.single.date, DateTime(2026, 11, 9));
    });
  });
}
