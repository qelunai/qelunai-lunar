import 'package:test/test.dart';
import 'package:qelunai_lunar/src/astronomy.dart';
import 'package:qelunai_lunar/src/can_chi.dart';
import 'package:qelunai_lunar/src/lunar_calendar.dart';
import 'package:qelunai_lunar/qelunai_lunar.dart' show lunarDateInfo;

void main() {
  group('jdnFromDate / dateFromJdn', () {
    test('round-trips, and matches the Giáp Thìn day anchor', () {
      // 2024-02-10 is independently reported as a Giáp Thìn day by multiple
      // Vietnamese lịch vạn niên sources (cross-checked alongside the Tết
      // Giáp Thìn date itself). JDN 2460351 is the Fliegel & Van Flandern
      // value for this date.
      final jdn = jdnFromDate(day: 10, month: 2, year: 2024);
      expect(jdn, 2460351);
      expect(dateFromJdn(jdn), (day: 10, month: 2, year: 2024));
    });
  });

  group('dayCanChi', () {
    test('2024-02-10 is Giáp Thìn (officially reported Tết Giáp Thìn day)', () {
      expect(
        dayCanChi(jdnFromDate(day: 10, month: 2, year: 2024)),
        'Giáp Thìn',
      );
    });
  });

  group('yearCanChi', () {
    test('matches the officially named year for each confirmed Tết', () {
      expect(yearCanChi(2023), 'Quý Mão');
      expect(yearCanChi(2024), 'Giáp Thìn');
      expect(yearCanChi(2025), 'Ất Tỵ');
      expect(yearCanChi(2026), 'Bính Ngọ');
      expect(yearCanChi(2027), 'Đinh Mùi');
    });
  });

  group('monthCanChi', () {
    test('2024-02-10 (lunar tháng Giêng, Giáp Thìn) is Bính Dần', () {
      expect(monthCanChi(1, 2024), 'Bính Dần');
    });
  });

  group('solarToLunar — Tết (first day of lunar year)', () {
    // Each solar date below is the officially published first day of the
    // lunar year (Tết Nguyên Đán), gathered from multiple independent
    // Vietnamese news sources. None of these pairs are invented.
    const tetDates = [
      (solar: (day: 22, month: 1, year: 2023), lunarYear: 2023),
      (solar: (day: 10, month: 2, year: 2024), lunarYear: 2024),
      (solar: (day: 29, month: 1, year: 2025), lunarYear: 2025),
      (solar: (day: 17, month: 2, year: 2026), lunarYear: 2026),
      (solar: (day: 6, month: 2, year: 2027), lunarYear: 2027),
    ];

    for (final c in tetDates) {
      test(
        '${c.solar.year}-${c.solar.month}-${c.solar.day} is mùng 1 Tết ${c.lunarYear}',
        () {
          final lunar = solarToLunar(
            day: c.solar.day,
            month: c.solar.month,
            year: c.solar.year,
          );
          expect(lunar.day, 1);
          expect(lunar.month, 1);
          expect(lunar.year, c.lunarYear);
          expect(lunar.isLeapMonth, isFalse);
        },
      );
    }
  });

  group('solarToLunar — Giỗ Tổ Hùng Vương (10/3 âm lịch)', () {
    test('2024-04-18 is 10/3 âm lịch Giáp Thìn', () {
      final lunar = solarToLunar(day: 18, month: 4, year: 2024);
      expect(lunar, isA<LunarDay>());
      expect(lunar.day, 10);
      expect(lunar.month, 3);
      expect(lunar.year, 2024);
      expect(lunar.isLeapMonth, isFalse);
    });

    test('2025-04-07 is 10/3 âm lịch Ất Tỵ', () {
      final lunar = solarToLunar(day: 7, month: 4, year: 2025);
      expect(lunar.day, 10);
      expect(lunar.month, 3);
      expect(lunar.year, 2025);
      expect(lunar.isLeapMonth, isFalse);
    });
  });

  group('solarToLunar — leap-month structure', () {
    // Lunar years 2020, 2023 and 2025 are publicly documented as having a
    // leap month (2020: leap tháng 4; 2023: leap tháng 2; 2025: leap tháng
    // 6). Rather than pinning an unverified exact boundary date, this checks
    // the structural fact: converting every day of the known Tết-to-Tết span
    // for that lunar year must produce a thirteenth lunar month with
    // isLeapMonth true, at the documented month number.
    bool yearHasLeapMonth(
      int fromYear,
      int fromMonth,
      int fromDay,
      int toYear,
      int toMonth,
      int toDay,
      int expectedLeapMonth,
    ) {
      var d = DateTime.utc(fromYear, fromMonth, fromDay);
      final end = DateTime.utc(toYear, toMonth, toDay);
      while (d.isBefore(end)) {
        final lunar = solarToLunar(day: d.day, month: d.month, year: d.year);
        if (lunar.isLeapMonth && lunar.month == expectedLeapMonth) return true;
        d = d.add(const Duration(days: 1));
      }
      return false;
    }

    test('lunar year 2023 (Quý Mão) has a leap tháng 2', () {
      expect(yearHasLeapMonth(2023, 1, 22, 2024, 2, 10, 2), isTrue);
    });

    test('lunar year 2025 (Ất Tỵ) has a leap tháng 6', () {
      expect(yearHasLeapMonth(2025, 1, 29, 2026, 2, 17, 6), isTrue);
    });
  });

  group('solarTermNameFor', () {
    test('returns one of the 24 standard tiết khí names', () {
      final name = solarTermNameFor(day: 10, month: 2, year: 2024);
      expect(solarTermNames, contains(name));
    });
  });

  group('lunarToSolar', () {
    // Internal consistency only (no external source): every solar day of
    // 1900–2100 converts to lunar and back to the same day.
    test('inverts solarToLunar for every day of 1900–2100', () {
      final first = jdnFromDate(day: 1, month: 1, year: 1900);
      final last = jdnFromDate(day: 31, month: 12, year: 2100);
      for (var jdn = first; jdn <= last; jdn++) {
        final d = dateFromJdn(jdn);
        final l = solarToLunar(day: d.day, month: d.month, year: d.year);
        final back = lunarToSolar(
          day: l.day,
          month: l.month,
          year: l.year,
          isLeapMonth: l.isLeapMonth,
        );
        expect(back, d, reason: '$d -> $l');
      }
    });

    test('returns null for a leap month the year does not have', () {
      expect(
        lunarToSolar(day: 1, month: 6, year: 2026, isLeapMonth: true),
        isNull,
      );
    });
  });

  group('lunarDateInfo', () {
    test('is consistent for Tết Giáp Thìn (2024-02-10)', () {
      final info = lunarDateInfo(day: 10, month: 2, year: 2024);
      expect(info.lunar.day, 1);
      expect(info.lunar.month, 1);
      expect(info.lunar.year, 2024);
      expect(info.lunar.isLeapMonth, isFalse);
      expect(info.dayCanChi, 'Giáp Thìn');
      expect(info.monthCanChi, 'Bính Dần');
      expect(info.yearCanChi, 'Giáp Thìn');
      expect(solarTermNames, contains(info.solarTermName));
    });
  });
}
