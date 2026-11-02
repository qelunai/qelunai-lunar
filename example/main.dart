import 'package:qelunai_lunar/qelunai_lunar.dart';

void main() {
  // Solar → lunar (UTC+7 by default).
  final tet = solarToLunar(day: 10, month: 2, year: 2024);
  print('2024-02-10 → $tet'); // LunarDay(1/1/2024)

  // Lunar → solar, including a leap month (2025 has tháng 6 nhuận).
  print('1/6/2025      → ${lunarToSolar(day: 1, month: 6, year: 2025)}');
  print('1/6 nhuận/2025 → '
      '${lunarToSolar(day: 1, month: 6, year: 2025, isLeapMonth: true)}');
  // A leap month that does not exist gives null.
  print('1/6 nhuận/2026 → '
      '${lunarToSolar(day: 1, month: 6, year: 2026, isLeapMonth: true)}');

  // Can Chi of day, month and year, and the tiết khí, in one call.
  final info = lunarDateInfo(day: 10, month: 2, year: 2024);
  print('Ngày ${info.dayCanChi}, tháng ${info.monthCanChi}, '
      'năm ${info.yearCanChi}, tiết ${info.solarTermName}');

  // Or separately.
  final jdn = jdnFromDate(day: 10, month: 2, year: 2024);
  print('dayCanChi: ${dayCanChi(jdn)}, yearCanChi(2026): ${yearCanChi(2026)}');

  // Span of the current tiết khí.
  final span = solarTermSpanFor(day: 28, month: 10, year: 2026);
  print('${span.name}: ${span.start} → ${span.end}, next ${span.nextName}');

  // Ngày and giờ hoàng đạo.
  final day = hoangDaoDay(day: 1, month: 5, year: 2025);
  print('2025-05-01: ${day.than.label} '
      '(${day.isHoangDao ? 'hoàng đạo' : 'hắc đạo'})');
  final hours = gioHoangDao(day: 1, month: 5, year: 2025);
  print('Giờ hoàng đạo: ${[
    for (final h in hours) '${h.branchName} ${h.startHour}–${h.endHour}h'
  ].join(', ')}');

  // Thập nhị trực.
  print('Trực: ${thapNhiTruc(day: 28, month: 10, year: 2026).label}');
}
