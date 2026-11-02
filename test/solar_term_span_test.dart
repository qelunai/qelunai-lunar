import 'package:test/test.dart';
import 'package:qelunai_lunar/src/astronomy.dart';
import 'package:qelunai_lunar/src/lunar_calendar.dart';
import 'package:qelunai_lunar/src/solar_term_span.dart';

void main() {
  group('solarTermSpanFor', () {
    // Every day of 2026 and 2027: the span agrees with solarTermNameFor, has a
    // plausible length, and its boundaries are real term changes.
    test('is consistent with solarTermNameFor across two years', () {
      final first = jdnFromDate(day: 1, month: 1, year: 2026);
      final last = jdnFromDate(day: 31, month: 12, year: 2027);
      for (var jdn = first; jdn <= last; jdn++) {
        final d = dateFromJdn(jdn);
        final span = solarTermSpanFor(day: d.day, month: d.month, year: d.year);
        final name = solarTermNameFor(day: d.day, month: d.month, year: d.year);
        expect(span.name, name, reason: '$d');
        expect(span.lengthInDays, inInclusiveRange(14, 16), reason: '$d');
        expect(span.dayOfTerm, inInclusiveRange(1, span.lengthInDays));

        final start = jdnFromDate(
          day: span.start.day,
          month: span.start.month,
          year: span.start.year,
        );
        expect(jdn - start + 1, span.dayOfTerm);
        final before = dateFromJdn(start - 1);
        final after = dateFromJdn(start + span.lengthInDays);
        expect(
          solarTermNameFor(
            day: before.day,
            month: before.month,
            year: before.year,
          ),
          isNot(name),
        );
        expect(
          solarTermNameFor(
            day: after.day,
            month: after.month,
            year: after.year,
          ),
          span.nextName,
        );
      }
    });
  });

  group('nextLunarMilestone', () {
    // Tết Giáp Thìn is 2024-02-10 (lunar 1/1), cross-checked in
    // lunar_calendar_test.dart.
    test('finds Tết 2024 as the next mùng một', () {
      final m = nextLunarMilestone(day: 5, month: 2, year: 2024);
      expect(m.isFullMoon, isFalse);
      expect(m.solar, (day: 10, month: 2, year: 2024));
      expect(m.daysAway, 5);
      expect((m.lunar.day, m.lunar.month), (1, 1));
    });

    test('is today when today is the milestone', () {
      final m = nextLunarMilestone(day: 10, month: 2, year: 2024);
      expect(m.daysAway, 0);
    });

    test('finds rằm tháng Giêng after Tết 2024', () {
      final m = nextLunarMilestone(day: 11, month: 2, year: 2024);
      expect(m.isFullMoon, isTrue);
      expect((m.lunar.day, m.lunar.month), (15, 1));
      expect(m.solar, (day: 24, month: 2, year: 2024));
      expect(m.daysAway, 13);
    });
  });
}
