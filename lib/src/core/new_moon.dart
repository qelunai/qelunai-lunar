import 'dart:math' as math;

import 'delta_t.dart';

/// Epoch: Julian Date (Terrestrial Time) of the *mean* New Moon (mean
/// lunar elongation D ≡ 0) that lunation index `k = 0` refers to — the
/// mean New Moon nearest 6 January 1900, which [_trueNewMoonJde] then
/// refines with the periodic correction below to get the *true* New
/// Moon near JD 2415021.077. `k` increases by 1 per subsequent synodic
/// month and may be negative.
///
/// Solved here (once, by hand) from Meeus's mean-elongation formula
/// (used again in [_trueNewMoonJde]), `D(T) = 297.8501921 +
/// 445267.1114034·T − 0.0018819·T²`, by finding the `T` nearest −1
/// (a century before J2000.0) with `D(T) ≡ 0 (mod 360°)`; one Newton
/// step from `T = −1` already converges, since `D` is linear in `T` to
/// the precision needed here.
const double _epochJde = 2415020.75985;

/// Mean synodic (New Moon to New Moon) month length, in days.
const double _synodicMonthDays = 29.530588861;

const double _degToRad = math.pi / 180.0;

double _deg(double x) {
  final r = x % 360.0;
  return r < 0 ? r + 360.0 : r;
}

/// Julian Date (TT) of the true New Moon for lunation [k].
///
/// Follows the method of Jean Meeus, *Astronomical Algorithms*, 2nd ed.,
/// chapter 49 ("Phases of the Moon"): a mean New Moon time refined by a
/// truncated series of periodic perturbation terms in the Sun's mean
/// anomaly `M`, the Moon's mean anomaly `M'`, and the Moon's argument of
/// latitude `F` (the Moon's mean elongation `D` is identically zero at
/// New Moon by definition, so every ch. 49 term that involves `D` drops
/// out and need not be implemented).
///
/// Rather than reusing Meeus's own lunation numbering (which is anchored
/// at a New Moon near 2000-01-06), `k` here is redefined relative to
/// [_epochJde] (see the public [newMoonDay] docs); `T`, the number of
/// Julian centuries since J2000.0, is then derived from the resulting
/// approximate time rather than from `k` directly, which keeps the mean
/// solar/lunar orbital elements below correct regardless of which New
/// Moon is called "k = 0".
double _trueNewMoonJde(int k) {
  final jdeApprox = _epochJde + _synodicMonthDays * k;
  final t = (jdeApprox - 2451545.0) / 36525.0;
  final t2 = t * t;
  final t3 = t2 * t;
  final t4 = t3 * t;

  // Secular correction to the mean New Moon instant (Meeus 49.1, minus
  // the k-dependent term already folded into jdeApprox above).
  final jdeMean =
      jdeApprox + 0.00015437 * t2 - 0.000000150 * t3 + 0.00000000073 * t4;

  // Mean anomaly of the Sun (degrees).
  final sunAnomalyDeg =
      _deg(357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000.0);
  // Mean anomaly of the Moon (degrees).
  final moonAnomalyDeg = _deg(134.9633964 +
      477198.8675055 * t +
      0.0087414 * t2 +
      t3 / 69699.0 -
      t4 / 14712000.0);
  // Moon's argument of latitude (degrees).
  final moonLatitudeArgDeg = _deg(93.2720950 -
      0.0036539 * t2 -
      t3 / 3526000.0 +
      t4 / 863310000.0 +
      483202.0175233 * t);
  // Eccentricity correction for Earth's orbit (Sun-anomaly terms only).
  final e = 1.0 - 0.002516 * t - 0.0000074 * t2;

  final m = sunAnomalyDeg * _degToRad;
  final mp = moonAnomalyDeg * _degToRad;
  final f = moonLatitudeArgDeg * _degToRad;

  final correctionDays = -0.40720 * math.sin(mp) +
      0.17241 * e * math.sin(m) +
      0.01608 * math.sin(2 * mp) +
      0.01039 * math.sin(2 * f) +
      0.00739 * e * math.sin(mp - m) -
      0.00514 * e * math.sin(mp + m) +
      0.00208 * e * e * math.sin(2 * m) -
      0.00111 * math.sin(mp - 2 * f) -
      0.00057 * math.sin(mp + 2 * f) +
      0.00056 * e * math.sin(2 * mp + m) -
      0.00042 * math.sin(3 * mp) +
      0.00042 * e * math.sin(m + 2 * f) +
      0.00038 * e * math.sin(m - 2 * f) -
      0.00024 * e * math.sin(2 * mp - m);

  return jdeMean + correctionDays;
}

/// JDN of the local calendar day (time zone [timeZone], in hours east of
/// UTC) on which lunation [k]'s New Moon instant falls.
///
/// `k = 0` denotes the New Moon nearest JD 2415021.07603 (6 January
/// 1900); `k` increases by 1 for each following synodic month.
int newMoonDay(int k, double timeZone) {
  final localJd = newMoonJdUt(k) + timeZone / 24.0;
  return (localJd + 0.5).floor();
}

/// Julian Date (Universal Time) of lunation [k]'s New Moon instant: the
/// Terrestrial-Time result of the series above minus ΔT.
double newMoonJdUt(int k) {
  final jde = _trueNewMoonJde(k);
  final approxYear = 1900.0 + (jde - _epochJde) / 365.25;
  return jde - deltaTSeconds(approxYear) / 86400.0;
}
