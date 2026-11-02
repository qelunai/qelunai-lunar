/// Thập nhị trực (Kiến, Trừ, Mãn … Bế): the 12 "officers" printed for each
/// day in Vietnamese lịch vạn niên.
///
/// Rule: Kiến falls on the day whose branch equals the branch of the month,
/// and the rest follow in branch order, i.e.
/// `trực = (dayBranch − monthBranch) mod 12`.
///
/// Unlike hoàng đạo ([hoangDaoDay]), the month here is the *tiết khí* month:
/// it changes at each tiết (Lập xuân → Dần, Kinh trập → Mão, …), not at the
/// lunar new moon. Checked on 2026-02-10 (lunar 23/12 but after Lập xuân):
/// xemlicham.com and ngaydep.com both print Trực Trừ, which only the tiết
/// month (Dần) gives; the lunar month (Sửu) would give Mãn. See
/// `test/thap_nhi_truc_test.dart`.
library;

import 'astronomy.dart';
import 'hoang_dao.dart';
import 'lunar_calendar.dart';

enum Truc {
  kien('Kiến'),
  tru('Trừ'),
  man('Mãn'),
  binh('Bình'),
  dinh('Định'),
  chap('Chấp'),
  pha('Phá'),
  nguy('Nguy'),
  thanh('Thành'),
  thu('Thu'),
  khai('Khai'),
  be('Bế');

  const Truc(this.label);

  final String label;
}

int _mod(int value, int modulus) => ((value % modulus) + modulus) % modulus;

/// Branch of the tiết month containing solar-term sector [termIndex]
/// (index into [solarTermNames], 0 = Xuân phân). Each month spans a tiết and
/// the trung khí after it, starting with Lập xuân (21) → Dần.
int tietMonthBranch(int termIndex) =>
    _mod(2 + _mod(termIndex - 21, 24) ~/ 2, 12);

/// The trực of a day with [dayBranch] in a month with [monthBranch]
/// (indices into the earthly branches, Tý = 0).
Truc trucFor({required int monthBranch, required int dayBranch}) =>
    Truc.values[_mod(dayBranch - monthBranch, 12)];

/// The trực of the civil date.
Truc thapNhiTruc({
  required int day,
  required int month,
  required int year,
  double timeZone = vietnamTimeZone,
}) {
  final jdn = jdnFromDate(day: day, month: month, year: year);
  return trucFor(
    monthBranch: tietMonthBranch(solarTermIndex(jdn, timeZone)),
    dayBranch: dayBranch(jdn),
  );
}
