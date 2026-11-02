import 'package:test/test.dart';
import 'package:qelunai_lunar/src/astronomy.dart';
import 'package:qelunai_lunar/src/can_chi.dart';
import 'package:qelunai_lunar/src/hoang_dao.dart';

void main() {
  group('hoangDaoDay — published lịch vạn niên', () {
    // Every date below is one where the lunar-month rule and the tiết-khí
    // month rule give *different* spirits, so each one also decides which
    // month governs. The tiết-month alternative is shown in each comment;
    // no checked source matched it. Sources (fetched 2026-10-28):
    // - 2025-02-01: baoquocte.vn "Lịch âm hôm nay 2025: Xem lịch âm 1/2/2025"
    //   — "ngày Tân Sửu … Minh Đường Hoàng Đạo", with all 12 hour spirits.
    // - 2025-05-01: vtcnews.vn "Lịch âm 1/5 …" — "4/4/2025 âm lịch nhằm ngày
    //   Thanh long hoàng đạo", Canh Ngọ; giờ hoàng đạo also on baolamdong.vn.
    // - 2025-08-14, 2026-02-10, 2026-06-10, 2026-08-09, 2026-10-09:
    //   ngaydep.com "xem-ngay-<d>-thang-<m>-nam-<y>"; 2026-10-09 also names
    //   Thiên Hình Hắc Đạo on xemlicham.com.
    // - 2026-11-08: ngaydep.com "Bạch Hổ Hắc Đạo", trực Bế; xemlicham.com
    //   lists "Bạch Hổ Hắc Đạo" among the day's sao xấu. 2026-12-08:
    //   ngaydep.com "Ngày Tư Mệnh Hoàng Đạo", trực Định.
    const cases = [
      // Lunar 4/1 Ất Tỵ, before Lập Xuân (tiết month Sửu → Chu Tước).
      (d: 1, m: 2, y: 2025, can: 'Tân Sửu', than: TrucThan.minhDuong),
      // Lunar 4/4, before Lập Hạ (tiết month Thìn → Thiên Hình).
      (d: 1, m: 5, y: 2025, can: 'Canh Ngọ', than: TrucThan.thanhLong),
      // Lunar 21/6 nhuận, after Lập Thu (tiết month Thân → Chu Tước).
      (d: 14, m: 8, y: 2025, can: 'Ất Mão', than: TrucThan.kimDuong),
      // Lunar 23/12 Ất Tỵ, after Lập Xuân (tiết month Dần → Chu Tước).
      (d: 10, m: 2, y: 2026, can: 'Ất Mão', than: TrucThan.kimDuong),
      // Lunar 25/4, after Mang Chủng (tiết month Ngọ → Ngọc Đường); printed
      // as "Nguyên Vũ Hắc Đạo".
      (d: 10, m: 6, y: 2026, can: 'Ất Mão', than: TrucThan.huyenVu),
      // Lunar 27/6, after Lập Thu (tiết month Thân → Chu Tước).
      (d: 9, m: 8, y: 2026, can: 'Ất Mão', than: TrucThan.kimDuong),
      // Lunar 29/8, after Hàn Lộ (tiết month Tuất → Thanh Long).
      (d: 9, m: 10, y: 2026, can: 'Bính Thìn', than: TrucThan.thienHinh),
      // Lunar 30/9, after Lập Đông (tiết month Hợi → Kim Quỹ, hoàng đạo).
      (d: 8, m: 11, y: 2026, can: 'Bính Tuất', than: TrucThan.bachHo),
      // Lunar 30/10, after Đại Tuyết (tiết month Tý → Thiên Lao, hắc đạo).
      (d: 8, m: 12, y: 2026, can: 'Bính Thìn', than: TrucThan.tuMenh),
    ];

    for (final c in cases) {
      test('${c.y}-${c.m}-${c.d} (${c.can}) is ${c.than.label}', () {
        expect(dayCanChi(jdnFromDate(day: c.d, month: c.m, year: c.y)), c.can);
        final hd = hoangDaoDay(day: c.d, month: c.m, year: c.y);
        expect(hd.than, c.than);
        expect(hd.isHoangDao, c.than.isHoangDao);
      });
    }
  });

  group('gioHoangDao — published lịch vạn niên', () {
    List<String> names(int d, int m, int y) => [
          for (final h in gioHoangDao(day: d, month: m, year: y)) h.branchName,
        ];

    test('2025-02-01 (Tân Sửu): every hour spirit as on baoquocte.vn', () {
      final hours = hoangDaoHours(day: 1, month: 2, year: 2025);
      expect(
        [for (final h in hours) h.than],
        [
          TrucThan.thienHinh, // Tý
          TrucThan.chuTuoc, // Sửu
          TrucThan.kimQuy, // Dần
          TrucThan.kimDuong, // Mão
          TrucThan.bachHo, // Thìn
          TrucThan.ngocDuong, // Tỵ
          TrucThan.thienLao, // Ngọ
          TrucThan.huyenVu, // Mùi ("Nguyên vũ" on that page)
          TrucThan.tuMenh, // Thân
          TrucThan.cauTran, // Dậu
          TrucThan.thanhLong, // Tuất
          TrucThan.minhDuong, // Hợi
        ],
      );
    });

    test('2025-05-01 (Canh Ngọ), vtcnews.vn and baolamdong.vn', () {
      expect(names(1, 5, 2025), ['Tý', 'Sửu', 'Mão', 'Ngọ', 'Thân', 'Dậu']);
    });

    test('2026-02-10 (Ất Mão), xemlicham.com, baohatinh.vn, ngaydep.com', () {
      expect(names(10, 2, 2026), ['Tý', 'Dần', 'Mão', 'Ngọ', 'Mùi', 'Dậu']);
    });

    test('2026-10-09 (Bính Thìn), xemlicham.com and ngaydep.com', () {
      expect(names(9, 10, 2026), ['Dần', 'Thìn', 'Tỵ', 'Thân', 'Dậu', 'Hợi']);
    });
  });

  group('properties', () {
    final first = jdnFromDate(day: 1, month: 1, year: 2025);
    final last = jdnFromDate(day: 31, month: 12, year: 2026);

    test('each day has exactly 6 giờ hoàng đạo out of 12 hours', () {
      for (var jdn = first; jdn <= last; jdn++) {
        final d = dateFromJdn(jdn);
        final hours = hoangDaoHours(day: d.day, month: d.month, year: d.year);
        expect(hours, hasLength(12));
        expect([for (final h in hours) h.branch], List.generate(12, (i) => i));
        expect(hours.map((h) => h.than).toSet(), TrucThan.values.toSet());
        expect(gioHoangDao(day: d.day, month: d.month, year: d.year).length, 6);
      }
    });

    test('hour spirits repeat with a 12-day period', () {
      for (var jdn = first; jdn <= last; jdn++) {
        final a = dateFromJdn(jdn);
        final b = dateFromJdn(jdn + 12);
        final ha = hoangDaoHours(day: a.day, month: a.month, year: a.year);
        final hb = hoangDaoHours(day: b.day, month: b.month, year: b.year);
        expect(hb.map((h) => h.than), ha.map((h) => h.than), reason: '$a');
      }
    });

    test('within a lunar month, day spirits repeat with a 12-day period', () {
      for (var jdn = first; jdn <= last; jdn++) {
        final a = dateFromJdn(jdn);
        final b = dateFromJdn(jdn + 12);
        final da = hoangDaoDay(day: a.day, month: a.month, year: a.year);
        final db = hoangDaoDay(day: b.day, month: b.month, year: b.year);
        if (da.monthBranch != db.monthBranch) continue;
        expect(db.than, da.than, reason: '$a');
      }
    });

    test('six of the 12 spirits are hoàng đạo', () {
      expect(TrucThan.values.where((t) => t.isHoangDao).toList(), [
        TrucThan.thanhLong,
        TrucThan.minhDuong,
        TrucThan.kimQuy,
        TrucThan.kimDuong,
        TrucThan.ngocDuong,
        TrucThan.tuMenh,
      ]);
    });

    test('giờ Tý spans 23:00–01:00 and the hours tile the clock', () {
      final hours = hoangDaoHours(day: 1, month: 1, year: 2026);
      expect((hours.first.startHour, hours.first.endHour), (23, 1));
      expect((hours[1].startHour, hours[1].endHour), (1, 3));
      expect((hours.last.startHour, hours.last.endHour), (21, 23));
      for (var i = 0; i < 12; i++) {
        expect(hours[(i + 1) % 12].startHour, hours[i].endHour % 24);
      }
      expect(hourBranch(23), 0);
      expect(hourBranch(0), 0);
      expect(hourBranch(1), 1);
      expect(hourBranch(22), 11);
      for (var hour = 0; hour < 24; hour++) {
        final h = hours[hourBranch(hour)];
        final inRange = h.startHour < h.endHour
            ? hour >= h.startHour && hour < h.endHour
            : hour >= h.startHour || hour < h.endHour;
        expect(inRange, isTrue, reason: '$hour');
      }
    });

    test('Thanh Long table: Dần/Thân month → Tý, …, Mùi/Sửu → Tuất', () {
      const thanhLongAt = {
        2: 0, 8: 0, 3: 2, 9: 2, 4: 4, 10: 4, //
        5: 6, 11: 6, 6: 8, 0: 8, 7: 10, 1: 10,
      };
      thanhLongAt.forEach((governing, target) {
        expect(
          trucThanFor(governingBranch: governing, targetBranch: target),
          TrucThan.thanhLong,
        );
      });
    });
  });
}
