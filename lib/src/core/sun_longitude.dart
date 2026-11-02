import 'dart:math' as math;

/// Apparent geocentric ecliptic longitude of the Sun, in radians,
/// normalized to [0, 2π).
///
/// [jd] is a Julian Date in Terrestrial Time (TT/TDT), *not* UT — callers
/// that start from a UT instant must add ΔT/86400 days first (see
/// `delta_t.dart`).
///
/// This is the "low accuracy" solar position method of Jean Meeus,
/// *Astronomical Algorithms*, 2nd ed., chapter 25: geometric mean
/// longitude and mean anomaly of the Sun, the equation of center (three
/// leading terms of the series in the Sun's mean anomaly), and a
/// correction for nutation and aberration via the Moon's ascending-node
/// longitude Ω. Meeus states this reproduces the Sun's apparent
/// longitude to about 0.01°, which is the precision this library relies
/// on for placing a date in one of the 24 solar-term sectors (see
/// `CLEANROOM.md` for how that error propagates to calendar dates).
double sunLongitude(double jd) {
  final t = (jd - 2451545.0) / 36525.0;

  final meanLongitudeDeg = _normalizeDeg(
    280.46646 + t * (36000.76983 + t * 0.0003032),
  );
  final meanAnomalyDeg = 357.52911 + t * (35999.05029 - t * 0.0001537);
  final meanAnomalyRad = meanAnomalyDeg * _degToRad;

  final centerDeg =
      (1.914602 - t * (0.004817 + t * 0.000014)) * math.sin(meanAnomalyRad) +
          (0.019993 - 0.000101 * t) * math.sin(2 * meanAnomalyRad) +
          0.000289 * math.sin(3 * meanAnomalyRad);

  final trueLongitudeDeg = meanLongitudeDeg + centerDeg;

  final omegaDeg = 125.04 - 1934.136 * t;
  final apparentLongitudeDeg =
      trueLongitudeDeg - 0.00569 - 0.00478 * math.sin(omegaDeg * _degToRad);

  return _normalizeDeg(apparentLongitudeDeg) * _degToRad;
}

const double _degToRad = math.pi / 180.0;

double _normalizeDeg(double deg) {
  final r = deg % 360.0;
  return r < 0 ? r + 360.0 : r;
}
