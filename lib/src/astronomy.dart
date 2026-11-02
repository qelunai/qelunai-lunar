/// Calendar arithmetic shared by the whole package: Julian Day Number
/// conversion, the mean synodic month, the new-moon numbering epoch, the
/// names of the 24 tiết khí, and thin wrappers over the astronomical core in
/// `core/` ([newMoonDay], [sunLongitude], [majorSolarTermIndex],
/// [solarTermIndex]). See `CLEANROOM.md` and `METHODOLOGY.md` for the
/// method and its accuracy.
library;

import 'core/delta_t.dart';
import 'core/julian_day.dart' as core;
import 'core/new_moon.dart' as core;
import 'core/solar_term.dart' as core;
import 'core/sun_longitude.dart' as core;

/// Converts a proleptic-Gregorian calendar date to an integer Julian Day
/// Number (JDN) — the Fliegel & Van Flandern (1968) algorithm, see Meeus
/// ch. 7. Valid for the Gregorian calendar (post 1582-10-15) only; there is
/// no Julian-calendar branch.
int jdnFromDate({required int day, required int month, required int year}) =>
    core.jdnFromDate(day, month, year);

/// Inverse of [jdnFromDate].
({int day, int month, int year}) dateFromJdn(int jdn) => core.dateFromJdn(jdn);

/// Local-date JDN of the k-th new moon (k = 0 is the new moon nearest
/// [newMoonEpochJd]; k may be negative), for a civil-time offset [timeZone]
/// from UTC in hours (e.g. 7 for Vietnam). New moon instant from Meeus
/// ch. 49, converted from TT to UT with ΔT (Espenak–Meeus).
int newMoonDay(int k, double timeZone) => core.newMoonDay(k, timeZone);

/// Apparent geocentric ecliptic longitude of the Sun, in radians, normalized
/// to [0, 2π), at the Julian Date [jd] given in Universal Time (UT).
///
/// The instant is converted to Terrestrial Time with ΔT (Espenak–Meeus)
/// before evaluating Meeus ch. 25 (low-accuracy series with nutation and
/// aberration).
double sunLongitude(double jd) {
  final year = 2000.0 + (jd - 2451545.0) / 365.25;
  return core.sunLongitude(jd + deltaTSeconds(year) / 86400.0);
}

/// Index (0–11) of the 30°-wide "major" solar-term sector (one of the 12
/// trung khí) containing local midnight of the given local-date JDN. Index 9
/// is the sector starting at the winter solstice (Đông chí), used to locate
/// lunar month 11.
int majorSolarTermIndex(int localJdn, double timeZone) =>
    core.majorSolarTermIndex(localJdn, timeZone);

/// Index (0–23) of the 15°-wide solar-term sector (one of the 24 tiết khí,
/// alternating tiết and trung khí) containing local midnight of the given
/// local-date JDN; 0 = Xuân phân (0°), 18 = Đông chí (270°).
int solarTermIndex(int localJdn, double timeZone) =>
    core.solarTermIndex(localJdn, timeZone);

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
