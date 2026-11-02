/// Approximate ΔT = TT − UT1, in seconds, for a given decimal year.
///
/// The Sun/Moon formulas in [sun_longitude.dart] and [new_moon.dart] are
/// expressed in Terrestrial Time (TT), the uniform time scale used in
/// ephemerides, while calendar day boundaries are civil (UT1-based)
/// clock time. The two differ by ΔT, a slowly drifting quantity caused
/// by the tidal deceleration of Earth's rotation; it must be measured,
/// not computed from first principles.
///
/// This uses the polynomial fit published by F. Espenak and J. Meeus,
/// "Five Millennium Canon of Solar Eclipses" (NASA TP-2006-214141,
/// 2006), section "Polynomial Expressions for ΔT" — a standard,
/// publicly documented empirical fit (also summarized on NASA's eclipse
/// website), unrelated to any lunar-calendar implementation. Only the
/// segments covering 1900–2150 are reproduced, which is all this
/// library needs.
library;

double deltaTSeconds(double decimalYear) {
  final y = decimalYear;
  if (y < 1900) {
    // Outside the range this library targets; extend the 1900 segment
    // flatly rather than extrapolating a wildly wrong value.
    return _years1900to1920(1900);
  }
  if (y < 1920) return _years1900to1920(y);
  if (y < 1941) return _years1920to1941(y);
  if (y < 1961) return _years1941to1961(y);
  if (y < 1986) return _years1961to1986(y);
  if (y < 2005) return _years1986to2005(y);
  if (y < 2050) return _years2005to2050(y);
  if (y < 2150) return _years2050to2150(y);
  return _yearsAfter2150(y);
}

double _years1900to1920(double y) {
  final t = y - 1900;
  return -2.79 +
      1.494119 * t -
      0.0598939 * t * t +
      0.0061966 * t * t * t -
      0.000197 * t * t * t * t;
}

double _years1920to1941(double y) {
  final t = y - 1920;
  return 21.20 + 0.84493 * t - 0.076100 * t * t + 0.0020936 * t * t * t;
}

double _years1941to1961(double y) {
  final t = y - 1950;
  return 29.07 + 0.407 * t - (t * t) / 233.0 + (t * t * t) / 2547.0;
}

double _years1961to1986(double y) {
  final t = y - 1975;
  return 45.45 + 1.067 * t - (t * t) / 260.0 - (t * t * t) / 718.0;
}

double _years1986to2005(double y) {
  final t = y - 2000;
  return 63.86 +
      0.3345 * t -
      0.060374 * t * t +
      0.0017275 * t * t * t +
      0.000651814 * t * t * t * t +
      0.00002373599 * t * t * t * t * t;
}

double _years2005to2050(double y) {
  final t = y - 2000;
  return 62.92 + 0.32217 * t + 0.005589 * t * t;
}

double _years2050to2150(double y) {
  final u = (y - 1820) / 100.0;
  return -20.0 + 32.0 * u * u - 0.5628 * (2150 - y);
}

double _yearsAfter2150(double y) {
  final u = (y - 1820) / 100.0;
  return -20.0 + 32.0 * u * u;
}
