/// Can Chi (Heavenly Stem / Earthly Branch, sexagenary cycle) naming.
///
/// These are standard, public sexagenary-cycle facts — the stem/branch name
/// lists and the day/month/year formulas below are cross-checked in
/// `test/lunar_calendar_test.dart` against officially
/// published Can Chi names for several real dates (not invented).
library;

/// The 10 Heavenly Stems (Thiên Can), in cycle order starting at Giáp.
const List<String> heavenlyStems = [
  'Giáp',
  'Ất',
  'Bính',
  'Đinh',
  'Mậu',
  'Kỷ',
  'Canh',
  'Tân',
  'Nhâm',
  'Quý',
];

/// The 12 Earthly Branches (Địa Chi), in cycle order starting at Tý.
const List<String> earthlyBranches = [
  'Tý',
  'Sửu',
  'Dần',
  'Mão',
  'Thìn',
  'Tỵ',
  'Ngọ',
  'Mùi',
  'Thân',
  'Dậu',
  'Tuất',
  'Hợi',
];

int _mod(int value, int modulus) => ((value % modulus) + modulus) % modulus;

String _stemBranch(int stemIndex, int branchIndex) =>
    '${heavenlyStems[_mod(stemIndex, 10)]} ${earthlyBranches[_mod(branchIndex, 12)]}';

/// Can Chi of the solar/civil day with the given Julian Day Number.
/// 1984-02-02 (JDN 2445730, lunar year 1984) is the reference Giáp Tý day;
/// equivalently `can = (jdn + 9) % 10`, `chi = (jdn + 1) % 12`, cross-checked
/// against 2024-02-10 (JDN 2460351), officially reported as the Giáp Thìn
/// day — see the engine test for the citation.
String dayCanChi(int jdn) => _stemBranch(jdn + 9, jdn + 1);

/// Can Chi of a lunar year. 1984 is the reference Giáp Tý year.
String yearCanChi(int lunarYear) {
  final offset = lunarYear - 1984;
  return _stemBranch(offset, offset);
}

/// Can Chi of a lunar month, via the "ngũ hổ độn" rule: the stem of lunar
/// month 1 (tháng Giêng, branch Dần) is fixed by the year's stem
/// (`2 * yearStem + 2`, mod 10), and stems advance by one each month; the
/// branch cycle is fixed regardless of year (tháng Giêng = Dần, ...,
/// tháng Chạp = Sửu).
String monthCanChi(int lunarMonth, int lunarYear) {
  final yearStem = _mod(lunarYear - 1984, 10);
  final stem = 2 * yearStem + 2 + (lunarMonth - 1);
  final branch = lunarMonth + 1;
  return _stemBranch(stem, branch);
}
