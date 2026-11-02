/// Conversion between a proleptic Gregorian calendar date and a Julian Day
/// Number (JDN), the integer day count used throughout astronomy (JDN 0 is
/// 1 January 4713 BC Julian; a JDN increments at noon UT).
///
/// The formulas here are the closed-form integer algorithm published by
/// H. F. Fliegel and T. C. Van Flandern, "A Machine Algorithm for
/// Processing Calendar Dates", Communications of the ACM 11(10), 1968 —
/// a generic, language-agnostic result that predates and is unrelated to
/// any lunar-calendar software; it is reproduced in many astronomy
/// references, including Meeus, *Astronomical Algorithms*, as an
/// alternative to the chapter 7 floating-point method.
library;

/// Julian Day Number of the given proleptic Gregorian calendar date.
///
/// [year] uses astronomical numbering (… -1, 0, 1 …; 0 = 1 BC). The
/// result is the integer JDN that is in effect from local noon of that
/// date onward. Valid for any year for which `year + 4800` is positive
/// (everything of practical calendar interest; in particular all of
/// 1900–2100), since every intermediate quantity below is then
/// non-negative and Dart's truncating `~/` agrees with the floor
/// division the original 1968 Fortran algorithm assumed.
int jdnFromDate(int day, int month, int year) {
  final a = (month - 14) ~/ 12;
  final jdn = 1461 * (year + 4800 + a) ~/ 4 +
      367 * (month - 2 - 12 * a) ~/ 12 -
      3 * ((year + 4900 + a) ~/ 100) ~/ 4 +
      day -
      32075;
  return jdn;
}

/// Inverse of [jdnFromDate]: the proleptic Gregorian calendar date that
/// is in effect at the given Julian Day Number.
({int day, int month, int year}) dateFromJdn(int jdn) {
  var l = jdn + 68569;
  final n = 4 * l ~/ 146097;
  l = l - (146097 * n + 3) ~/ 4;
  final i = 4000 * (l + 1) ~/ 1461001;
  l = l - 1461 * i ~/ 4 + 31;
  final j = 80 * l ~/ 2447;
  final day = l - 2447 * j ~/ 80;
  l = j ~/ 11;
  final month = j + 2 - 12 * l;
  final year = 100 * (n - 49) + i + l;
  return (day: day, month: month, year: year);
}
