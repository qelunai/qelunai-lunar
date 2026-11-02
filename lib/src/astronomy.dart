/// Calendar arithmetic shared by the whole package: Julian Day Number
/// conversion, the mean synodic month, the new-moon numbering epoch and the
/// names of the 24 tiết khí.
///
/// The truncated New Moon and solar longitude series ([newMoonDay],
/// [sunLongitude], [majorSolarTermIndex], [solarTermIndex]) live in
/// `conversion_core.dart` and are re-exported from here.
library;

export 'conversion_core.dart'
    show newMoonDay, sunLongitude, majorSolarTermIndex, solarTermIndex;

/// Converts a proleptic-Gregorian calendar date to an integer Julian Day
/// Number (JDN) — the Fliegel & Van Flandern (1968) algorithm, see Meeus
/// ch. 7. Valid for the Gregorian calendar (post 1582-10-15) only; there is
/// no Julian-calendar branch.
int jdnFromDate({required int day, required int month, required int year}) {
  final a = (14 - month) ~/ 12;
  final y = year + 4800 - a;
  final m = month + 12 * a - 3;
  return day +
      (153 * m + 2) ~/ 5 +
      365 * y +
      y ~/ 4 -
      y ~/ 100 +
      y ~/ 400 -
      32045;
}

/// Inverse of [jdnFromDate].
({int day, int month, int year}) dateFromJdn(int jdn) {
  final a = jdn + 32044;
  final b = (4 * a + 3) ~/ 146097;
  final c = a - (146097 * b) ~/ 4;
  final d = (4 * c + 3) ~/ 1461;
  final e = c - (1461 * d) ~/ 4;
  final m = (5 * e + 2) ~/ 153;
  final day = e - (153 * m + 2) ~/ 5 + 1;
  final month = m + 3 - 12 * (m ~/ 10);
  final year = 100 * b + d - 4800 + m ~/ 10;
  return (day: day, month: month, year: year);
}

/// Synodic month length (mean time between new moons), in days. A physical
/// constant (IAU accepted value), not specific to any implementation.
const double synodicMonth = 29.530588853;

/// Julian Day of new moon k = 0, the new moon nearest 1900-01-01 — the
/// conventional epoch used when numbering new moons by an integer `k` in
/// this family of algorithms.
const double newMoonEpochJd = 2415021.076998695;

/// Names of the 24 tiết khí in order, starting at Xuân phân (vernal
/// equinox, solar longitude 0°). Standard public terminology, not sourced
/// from any single codebase.
const List<String> solarTermNames = [
  'Xuân phân',
  'Thanh minh',
  'Cốc vũ',
  'Lập hạ',
  'Tiểu mãn',
  'Mang chủng',
  'Hạ chí',
  'Tiểu thử',
  'Đại thử',
  'Lập thu',
  'Xử thử',
  'Bạch lộ',
  'Thu phân',
  'Hàn lộ',
  'Sương giáng',
  'Lập đông',
  'Tiểu tuyết',
  'Đại tuyết',
  'Đông chí',
  'Tiểu hàn',
  'Đại hàn',
  'Lập xuân',
  'Vũ thủy',
  'Kinh trập',
];
