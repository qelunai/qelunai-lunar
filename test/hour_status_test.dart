import 'package:test/test.dart';
import 'package:qelunai_lunar/src/hoang_dao.dart';
import 'package:qelunai_lunar/src/hour_status.dart';

void main() {
  // 2026-10-28 is an Ất Hợi day; its giờ hoàng đạo are Sửu, Thìn, Ngọ, Mùi,
  // Tuất, Hợi (xemlicham.com, fetched 2026-10-28).
  HourStatus at(int hour, int minute) =>
      hourStatus(day: 28, month: 10, year: 2026, hour: hour, minute: minute);

  test('14:20 is giờ Mùi, hoàng đạo, 40 minutes left', () {
    final s = at(14, 20);
    expect(s.current.branchName, 'Mùi');
    expect(s.current.isHoangDao, isTrue);
    expect(s.minutesLeft, 40);
    expect(s.upcomingGood.map((h) => h.branchName), ['Tuất', 'Hợi']);
  });

  test('a hắc đạo hour lists the good hours still to come', () {
    final s = at(9, 0);
    expect(s.current.branchName, 'Tỵ');
    expect(s.current.isHoangDao, isFalse);
    expect(s.minutesLeft, 120);
    expect(s.upcomingGood.map((h) => h.branchName), [
      'Ngọ',
      'Mùi',
      'Tuất',
      'Hợi',
    ]);
  });

  test('giờ Tý spans midnight', () {
    final early = at(0, 10);
    expect(early.current.branchName, 'Tý');
    expect(early.minutesLeft, 50);
    expect(early.upcomingGood.first.branchName, 'Sửu');

    final late = at(23, 30);
    expect(late.current.branchName, 'Tý');
    expect(late.minutesLeft, 90);
    // Whether 23:00 belongs to today or tomorrow is unresolved, so nothing
    // later "today" is listed.
    expect(late.upcomingGood, isEmpty);
  });

  test('the current hour matches hoangDaoHours for every hour', () {
    final hours = hoangDaoHours(day: 28, month: 10, year: 2026);
    for (var h = 0; h < 24; h++) {
      expect(at(h, 0).current.than, hours[hourBranch(h)].than, reason: '$h');
    }
  });
}
