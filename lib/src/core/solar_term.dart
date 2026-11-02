import 'delta_t.dart';
import 'julian_day.dart';
import 'sun_longitude.dart';

const double _radToDeg = 180.0 / 3.141592653589793;

/// Apparent solar ecliptic longitude, in degrees, at local midnight
/// (00:00) of the given local Julian Day Number and time zone.
///
/// Local midnight of [localJdn] is the instant `localJdn - 0.5` days
/// local time; converted to UT by subtracting the zone offset, then to
/// Terrestrial Time (what [sunLongitude] expects) by adding ΔT — see
/// `delta_t.dart`.
double _sunLongitudeDegAtLocalMidnight(int localJdn, double timeZone) {
  final jdUt = (localJdn - 0.5) - timeZone / 24.0;
  final approxYear = 1900.0 + (localJdn - 2415021) / 365.25;
  final jdTt = jdUt + deltaTSeconds(approxYear) / 86400.0;
  return sunLongitude(jdTt) * _radToDeg;
}

/// Index (0–11) of the 30°-wide solar-term sector ("major" term, the 12
/// that carry a zodiac-month meaning in the lunar calendar — e.g. 9 =
/// Đông chí / Winter Solstice at 270°) in effect at local midnight of
/// [localJdn].
int majorSolarTermIndex(int localJdn, double timeZone) {
  final lonDeg = _sunLongitudeDegAtLocalMidnight(localJdn, timeZone);
  return (lonDeg / 30.0).floor() % 12;
}

/// Index (0–23) of the 15°-wide solar-term sector in effect at local
/// midnight of [localJdn]; 0 = Xuân phân / Spring Equinox (0°), 18 =
/// Đông chí / Winter Solstice (270°).
int solarTermIndex(int localJdn, double timeZone) {
  final lonDeg = _sunLongitudeDegAtLocalMidnight(localJdn, timeZone);
  return (lonDeg / 15.0).floor() % 24;
}

double _normalizeDegDiff(double diff) {
  var d = diff % 360.0;
  if (d > 180.0) d -= 360.0;
  if (d < -180.0) d += 360.0;
  return d;
}

/// Refines an approximate Terrestrial-Time Julian Date near a solar
/// longitude crossing of [targetDeg] to the precise instant, by a few
/// corrections using the Sun's mean rate of motion (≈0.9856°/day) as
/// the step size. [sunLongitude] is close enough to linear in time over
/// the few-day span these corrections cover that this converges to
/// well under a second of time in a handful of iterations.
double _refineLongitudeCrossing(double targetDeg, double guessJdTt) {
  var jd = guessJdTt;
  for (var i = 0; i < 8; i++) {
    final lonDeg = sunLongitude(jd) * _radToDeg;
    final diff = _normalizeDegDiff(targetDeg - lonDeg);
    jd += diff / 0.9856;
  }
  return jd;
}

final Map<(int, double), int> _winterSolsticeCache = {};

/// Local JDN of the civil day that *contains the instant* the Sun's
/// longitude reaches 270° (Đông chí / Winter Solstice) nearest December
/// of Gregorian year [year] — the same "which local day holds this
/// instant" convention [newMoonDay] uses for new moons, found here by:
/// a coarse day-level scan to locate the sector change (cheap, since
/// the Sun moves about 1°/day), then a numeric refinement of the exact
/// crossing instant, then re-deriving its containing local day from
/// that instant directly.
///
/// This deliberately does *not* reuse [majorSolarTermIndex]'s
/// "midnight-sampled" day — that answers "which day already shows
/// sector 9 at 00:00", which (because the coarse scan can only detect
/// the sector change at whole-day resolution) is one day later than the
/// containing day whenever the crossing instant falls after local
/// midnight, as it does roughly half the time; using it directly to
/// pick month 11 would misattribute the Winter Solstice to the
/// following lunation on those occasions. Results are cached since the
/// lunar month/leap-month search in `lunar_month.dart` calls this
/// repeatedly for the same years.
int winterSolsticeJdn(int year, double timeZone) {
  final cacheKey = (year, timeZone);
  final cached = _winterSolsticeCache[cacheKey];
  if (cached != null) return cached;

  var coarseJdn = jdnFromDate(1, 12, year);
  while (majorSolarTermIndex(coarseJdn, timeZone) != 9) {
    coarseJdn++;
  }

  final approxYear = year.toDouble();
  final guessJdUt = (coarseJdn - 0.5) - timeZone / 24.0;
  final guessJdTt = guessJdUt + deltaTSeconds(approxYear) / 86400.0;
  final crossingJdTt = _refineLongitudeCrossing(270.0, guessJdTt);
  final crossingJdUt = crossingJdTt - deltaTSeconds(approxYear) / 86400.0;
  final crossingLocalJd = crossingJdUt + timeZone / 24.0;
  final jdn = (crossingLocalJd + 0.5).floor();

  _winterSolsticeCache[cacheKey] = jdn;
  return jdn;
}
