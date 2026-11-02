/// Where a clock time falls among the day's 12 double-hours: the current
/// giờ, how long it lasts, and the giờ hoàng đạo still to come today.
///
/// Built only on [hoangDaoHours] and [hourBranch], so it inherits their
/// rules, including the open question of whether 23:00–24:00 is the given
/// date's giờ Tý or the next day's (chưa thống nhất). This module treats it
/// as the given date's Tý and, for that hour, lists no later hours.
library;

import 'hoang_dao.dart';

class HourStatus {
  const HourStatus({
    required this.current,
    required this.minutesLeft,
    required this.upcomingGood,
  });

  final HoangDaoHour current;

  /// Whole minutes until [current] ends (1–120).
  final int minutesLeft;

  /// Giờ hoàng đạo after [current] on the same date, in clock order.
  final List<HoangDaoHour> upcomingGood;
}

HourStatus hourStatus({
  required int day,
  required int month,
  required int year,
  required int hour,
  required int minute,
}) {
  final hours = hoangDaoHours(day: day, month: month, year: year);
  final current = hours[hourBranch(hour)];
  final elapsed = (hour * 60 + minute - current.startHour * 60) % (24 * 60);
  return HourStatus(
    current: current,
    minutesLeft: 120 - elapsed,
    upcomingGood: hour == 23
        ? const []
        : [
            for (final h in hours)
              if (h.isHoangDao && h.branch > current.branch) h,
          ],
  );
}
