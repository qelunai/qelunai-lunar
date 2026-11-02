import 'package:qelunai_lunar/qelunai_lunar.dart';
import 'package:test/test.dart';

/// 2012 has a leap month 4 in China (UTC+8) and a leap month 3 in Korea
/// (UTC+9). Results for one time zone must not depend on which time zone
/// was asked first in the same process.
void main() {
  ({int day, int month, bool leap}) at(double timeZone) {
    final d = solarToLunar(day: 1, month: 5, year: 2012, timeZone: timeZone);
    return (day: d.day, month: d.month, leap: d.isLeapMonth);
  }

  const china = (day: 11, month: 4, leap: false);
  const korea = (day: 11, month: 3, leap: true);

  test('UTC+8 then UTC+9', () {
    expect(at(8), china);
    expect(at(9), korea);
  });

  test('UTC+9 then UTC+8, with UTC+7 in between', () {
    expect(at(9), korea);
    at(7);
    expect(at(8), china);
    expect(at(9), korea);
  });
}
