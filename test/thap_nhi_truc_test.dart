import 'package:test/test.dart';
import 'package:qelunai_lunar/src/thap_nhi_truc.dart';

void main() {
  group('thapNhiTruc — published lịch vạn niên', () {
    // Sources (fetched 2026-10-28, xemlicham.com day pages):
    // - 2026-10-28: Ất Hợi, tiết Sương giáng → "Trực Trừ".
    // - 2026-02-10: Ất Mão, lunar 23/12 Ất Tỵ but after Lập xuân → "Trực
    //   Trừ". The lunar month (Sửu) would give Mãn, so the tiết month
    //   governs; ngaydep.com prints the same trực for that day.
    const cases = [
      (d: 28, m: 10, y: 2026, truc: Truc.tru),
      (d: 10, m: 2, y: 2026, truc: Truc.tru),
    ];

    for (final c in cases) {
      test('${c.y}-${c.m}-${c.d} is Trực ${c.truc.label}', () {
        expect(thapNhiTruc(day: c.d, month: c.m, year: c.y), c.truc);
      });
    }
  });

  group('tietMonthBranch', () {
    test('Lập xuân and Vũ thủy are Dần, Kinh trập and Xuân phân Mão', () {
      expect(tietMonthBranch(21), 2);
      expect(tietMonthBranch(22), 2);
      expect(tietMonthBranch(23), 3);
      expect(tietMonthBranch(0), 3);
    });

    test('Hàn lộ and Sương giáng are Tuất, Tiểu hàn and Đại hàn Sửu', () {
      expect(tietMonthBranch(13), 10);
      expect(tietMonthBranch(14), 10);
      expect(tietMonthBranch(19), 1);
      expect(tietMonthBranch(20), 1);
    });
  });

  test('Kiến falls on the day whose branch is the month branch', () {
    expect(trucFor(monthBranch: 10, dayBranch: 10), Truc.kien);
    expect(trucFor(monthBranch: 10, dayBranch: 9), Truc.be);
  });

  test('labels and order', () {
    expect(Truc.values.map((t) => t.label), [
      'Kiến',
      'Trừ',
      'Mãn',
      'Bình',
      'Định',
      'Chấp',
      'Phá',
      'Nguy',
      'Thành',
      'Thu',
      'Khai',
      'Bế',
    ]);
  });
}
