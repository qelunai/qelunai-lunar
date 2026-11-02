import 'julian_day.dart';
import 'new_moon.dart';
import 'solar_term.dart';

/// JDN (local, time zone [timeZone]) of lunation `k = 0`, used only as a
/// coarse starting point for the search in [lunationIndexForJdn] below;
/// any value within a handful of months of the truth works equally well,
/// since that search self-corrects.
const int _roughK0Jdn = 2415021;

/// Index `k` of the synodic month (as used by [newMoonDay]) that
/// contains local day [jdn]: the unique `k` with
/// `newMoonDay(k, timeZone) <= jdn < newMoonDay(k + 1, timeZone)`.
int lunationIndexForJdn(int jdn, double timeZone) {
  var k = ((jdn - _roughK0Jdn) / 29.530588861).floor() - 1;
  while (newMoonDay(k + 1, timeZone) <= jdn) {
    k++;
  }
  while (newMoonDay(k, timeZone) > jdn) {
    k--;
  }
  return k;
}

/// One lunar month within a month-11-to-month-11 cycle (see
/// [cycleMonths]): its lunation index, its calendar number 1–12, and
/// whether it is a leap month (repeating the preceding month's number).
class MonthEntry {
  final int k;
  final int number;
  final bool isLeap;

  const MonthEntry(this.k, this.number, this.isLeap);
}

final Map<int, List<MonthEntry>> _cycleCache = {};

int _cacheKey(int k, double timeZone) => k * 2 + (timeZone == 7.0 ? 0 : 1);

/// The lunation index `k` of the month-11 (the month containing the
/// Winter Solstice, 270° solar longitude) of the cycle that contains
/// lunation [k].
///
/// Looks at the Winter Solstices of the Gregorian years immediately
/// before, of, and after the one lunation [k] starts in — a lunar year
/// (12 or 13 synodic months, 354–384 days) can never span more than
/// that, so the month-11 immediately at or before [k] is always among
/// these three candidates.
int month11IndexForLunation(int k, double timeZone) {
  final yearGuess = dateFromJdn(newMoonDay(k, timeZone)).year;
  var best = -1 << 30;
  for (final y in [yearGuess - 1, yearGuess, yearGuess + 1]) {
    final candidate =
        lunationIndexForJdn(winterSolsticeJdn(y, timeZone), timeZone);
    if (candidate <= k && candidate > best) best = candidate;
  }
  return best;
}

/// The full run of lunar months, in order, from month 11 of one cycle
/// (lunation index [ka11]) up to (but excluding) month 11 of the next —
/// 12 entries normally, 13 when the cycle has a leap month.
///
/// Rule applied (per the Vietnamese/Chinese lunar calendar): a lunar
/// year runs from one month-11 to the next; when that span covers 13
/// synodic months, the leap month is the first one after month 11 that
/// contains no "major" solar term (no multiple of 30° of solar
/// longitude falls inside it — detected here as the 30°-sector index
/// from [majorSolarTermIndex] being the same at the start of the month
/// as at the start of the *next* month, since the index is only
/// guaranteed unchanged throughout if no crossing occurred by that next
/// midnight — checking against the current month's own last day instead
/// would miss a crossing landing in the final hours of that last day),
/// and it carries the number of the month before it.
List<MonthEntry> cycleMonths(int ka11, double timeZone) {
  final cacheKey = _cacheKey(ka11, timeZone);
  final cached = _cycleCache[cacheKey];
  if (cached != null) return cached;

  final a11Jdn = newMoonDay(ka11, timeZone);
  final yearOfA11 = dateFromJdn(a11Jdn).year;
  final nextSolsticeJdn = winterSolsticeJdn(yearOfA11 + 1, timeZone);
  final kb11 = lunationIndexForJdn(nextSolsticeJdn, timeZone);
  final cycleLength = kb11 - ka11;

  final entries = <MonthEntry>[MonthEntry(ka11, 11, false)];
  var number = 11;
  var leapAssigned = false;
  for (var offset = 1; offset < cycleLength; offset++) {
    final k = ka11 + offset;
    final monthStart = newMoonDay(k, timeZone);
    final nextMonthStart = newMoonDay(k + 1, timeZone);
    final lacksMajorTerm = majorSolarTermIndex(monthStart, timeZone) ==
        majorSolarTermIndex(nextMonthStart, timeZone);
    if (!leapAssigned && cycleLength == 13 && lacksMajorTerm) {
      entries.add(MonthEntry(k, number, true));
      leapAssigned = true;
    } else {
      number = number % 12 + 1;
      entries.add(MonthEntry(k, number, false));
    }
  }

  _cycleCache[cacheKey] = entries;
  return entries;
}

/// Calendar number, leap flag, and lunar year of lunation [k].
///
/// The lunar year number follows the convention that it changes on
/// lunar 1/1: month 11 and month 12 (the last two months before the
/// next Tết) keep the Gregorian year their month-11 started in, while
/// months 1–10 (and any leap month among them) belong to the following
/// one.
({int number, bool isLeap, int lunarYear}) resolveMonth(
  int k,
  double timeZone,
) {
  final ka11 = month11IndexForLunation(k, timeZone);
  final yearOfA11 = dateFromJdn(newMoonDay(ka11, timeZone)).year;
  final cycle = cycleMonths(ka11, timeZone);
  final entry = cycle.firstWhere((e) => e.k == k);
  final lunarYear =
      yearOfA11 + (entry.number == 11 || entry.number == 12 ? 0 : 1);
  return (number: entry.number, isLeap: entry.isLeap, lunarYear: lunarYear);
}

/// The [MonthEntry] for calendar month [month] (leap iff [isLeapMonth])
/// of lunar year [lunarYear], or `null` if no such month exists in that
/// year (e.g. a leap month was requested but that year has none, or it
/// falls on a different month number).
MonthEntry? findMonth({
  required int lunarYear,
  required int month,
  required bool isLeapMonth,
  required double timeZone,
}) {
  final yearOfA11 = lunarYear - (month == 11 || month == 12 ? 0 : 1);
  final a11Jdn = winterSolsticeJdn(yearOfA11, timeZone);
  final ka11 = lunationIndexForJdn(a11Jdn, timeZone);
  final cycle = cycleMonths(ka11, timeZone);
  for (final e in cycle) {
    if (e.number == month && e.isLeap == isLeapMonth) return e;
  }
  return null;
}
