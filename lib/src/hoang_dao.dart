/// Ngày và giờ hoàng đạo / hắc đạo (12 trực thần: Thanh Long … Câu Trận).
///
/// Rule (the standard "hoàng đạo hắc đạo" table, as printed day by day in
/// Vietnamese lịch vạn niên): the 12 spirits below always occur in the fixed
/// order of [TrucThan.values], one per branch. A *governing* branch fixes
/// which branch Thanh Long falls on, and the rest follow in branch order:
///
/// | governing branch | Thanh Long at |
/// |------------------|---------------|
/// | Dần, Thân        | Tý            |
/// | Mão, Dậu         | Dần           |
/// | Thìn, Tuất       | Thìn          |
/// | Tỵ, Hợi          | Ngọ           |
/// | Ngọ, Tý          | Thân          |
/// | Mùi, Sửu         | Tuất          |
///
/// i.e. `thanhLong = 2 * ((governing - 2) mod 6) mod 12` (branch indices
/// into [earthlyBranches], Tý = 0).
///
/// - **Day**: governing branch = branch of the *lunar month* (tháng Giêng =
///   Dần, …, tháng Chạp = Sửu, same as [monthCanChi]); the target is the
///   day's branch ([dayCanChi]).
/// - **Hour**: governing branch = the day's branch; targets are the 12
///   double-hours Tý … Hợi. E.g. a Tý or Ngọ day has Thanh Long at giờ Thân,
///   so its giờ hoàng đạo are Tý, Sửu, Mão, Ngọ, Thân, Dậu.
///
/// Which "month" governs the day (decided, see below): the lunar month, not
/// the tiết khí month (Lập Xuân → Dần, …). The two only disagree on days
/// between a tiết boundary and the next lunar-month start. On 9 such days
/// (2025–2026, incl. one in nhuận tháng 6, 2026-11-08 and 2026-12-08),
/// every Vietnamese lịch vạn niên
/// checked (baoquocte.vn, vtcnews.vn, ngaydep.com, xemlicham.com) used the
/// lunar month; none matched the tiết month. Whether some other calendar
/// (e.g. Chinese almanacs) uses the tiết month is chưa kiểm chứng here. See
/// `test/hoang_dao_test.dart` for the dates and
/// sources. Notably ngaydep.com uses the tiết month for its 12 trực (Kiến,
/// Trừ …) on 2026-02-10 yet the lunar month for hoàng đạo on the same day, so
/// the choice here is specific to hoàng đạo, not a general month rule
/// (see `thap_nhi_truc.dart`).
///
/// Leap months (tháng nhuận) reuse the branch of the month they repeat
/// (e.g. nhuận tháng 6 → Mùi), cross-checked on one leap-month date
/// (2025-08-14) only. Hours are the civil (UTC+7) double-hours as calendars print them;
/// whether 23:00–24:00 belongs to the given date's giờ Tý or the next day's is
/// school-dependent and not resolved here (chưa thống nhất).
library;

import 'astronomy.dart';
import 'can_chi.dart';
import 'lunar_calendar.dart';

/// The 12 trực thần, in their fixed cycle order starting at Thanh Long.
/// Six are hoàng đạo (auspicious), six hắc đạo.
enum TrucThan {
  thanhLong('Thanh Long', isHoangDao: true),
  minhDuong('Minh Đường', isHoangDao: true),
  thienHinh('Thiên Hình', isHoangDao: false),
  chuTuoc('Chu Tước', isHoangDao: false),
  kimQuy('Kim Quỹ', isHoangDao: true),

  /// Also called Bảo Quang.
  kimDuong('Kim Đường', isHoangDao: true),
  bachHo('Bạch Hổ', isHoangDao: false),
  ngocDuong('Ngọc Đường', isHoangDao: true),
  thienLao('Thiên Lao', isHoangDao: false),

  /// Some calendars print it as Nguyên Vũ.
  huyenVu('Huyền Vũ', isHoangDao: false),
  tuMenh('Tư Mệnh', isHoangDao: true),
  cauTran('Câu Trận', isHoangDao: false);

  const TrucThan(this.label, {required this.isHoangDao});

  final String label;
  final bool isHoangDao;
}

int _mod(int value, int modulus) => ((value % modulus) + modulus) % modulus;

/// The spirit on [targetBranch] when [governingBranch] rules (indices into
/// [earthlyBranches]); see the library comment for the table.
TrucThan trucThanFor({
  required int governingBranch,
  required int targetBranch,
}) {
  final thanhLong = _mod(2 * _mod(governingBranch - 2, 6), 12);
  return TrucThan.values[_mod(targetBranch - thanhLong, 12)];
}

/// Branch of a lunar month: tháng Giêng = Dần (2), …, tháng Chạp = Sửu (1).
int lunarMonthBranch(int lunarMonth) => _mod(lunarMonth + 1, 12);

/// Branch of the solar/civil day with the given JDN, consistent with
/// [dayCanChi].
int dayBranch(int jdn) => _mod(jdn + 1, 12);

/// Branch of the double-hour containing clock hour [hour] (0–23):
/// 23 and 0 → Tý, 1–2 → Sửu, …, 21–22 → Hợi.
int hourBranch(int hour) => _mod((hour + 1) ~/ 2, 12);

class HoangDaoDay {
  const HoangDaoDay({
    required this.than,
    required this.dayBranch,
    required this.monthBranch,
  });

  final TrucThan than;

  /// Indices into [earthlyBranches].
  final int dayBranch, monthBranch;

  bool get isHoangDao => than.isHoangDao;
}

class HoangDaoHour {
  const HoangDaoHour({required this.branch, required this.than});

  /// Index into [earthlyBranches] (Tý = 0).
  final int branch;
  final TrucThan than;

  String get branchName => earthlyBranches[branch];

  /// Clock hours bounding the double-hour, end exclusive: Tý = 23–1,
  /// Sửu = 1–3, …, Hợi = 21–23.
  int get startHour => _mod(2 * branch - 1, 24);
  int get endHour => 2 * branch + 1;

  bool get isHoangDao => than.isHoangDao;
}

/// Spirit of the civil date: governed by the lunar month's branch.
HoangDaoDay hoangDaoDay({
  required int day,
  required int month,
  required int year,
  double timeZone = vietnamTimeZone,
}) {
  final lunar = solarToLunar(
    day: day,
    month: month,
    year: year,
    timeZone: timeZone,
  );
  final monthBranch = lunarMonthBranch(lunar.month);
  final branch = dayBranch(jdnFromDate(day: day, month: month, year: year));
  return HoangDaoDay(
    than: trucThanFor(governingBranch: monthBranch, targetBranch: branch),
    dayBranch: branch,
    monthBranch: monthBranch,
  );
}

/// The 12 double-hours of the civil date, Tý … Hợi, with their spirits
/// (governed by the day's branch).
List<HoangDaoHour> hoangDaoHours({
  required int day,
  required int month,
  required int year,
}) {
  final governing = dayBranch(jdnFromDate(day: day, month: month, year: year));
  return [
    for (var b = 0; b < 12; b++)
      HoangDaoHour(
        branch: b,
        than: trucThanFor(governingBranch: governing, targetBranch: b),
      ),
  ];
}

/// The 6 giờ hoàng đạo of the civil date, in Tý … Hợi order.
List<HoangDaoHour> gioHoangDao({
  required int day,
  required int month,
  required int year,
}) =>
    [
      for (final h in hoangDaoHours(day: day, month: month, year: year))
        if (h.isHoangDao) h,
    ];
