# Changelog

## 0.1.0

Initial release, extracted from the Qelunai app's lunar calendar engine.

- `solarToLunar` / `lunarToSolar`: Vietnamese lunisolar calendar conversion
  with leap months, UTC+7 by default (any offset can be passed).
- `lunarDateInfo`: lunar date, Can Chi of day/month/year and tiết khí in one
  call.
- Can Chi: `dayCanChi`, `monthCanChi`, `yearCanChi`.
- 24 tiết khí: `solarTermNameFor`, `solarTermIndex`, `solarTermSpanFor`.
- Ngày/giờ hoàng đạo: `hoangDaoDay`, `hoangDaoHours`, `gioHoangDao`,
  `hourStatus`.
- Thập nhị trực: `thapNhiTruc`.
- Ngày giỗ: `lunarMonthLength`, `gioInLunarYear`, `nextGio`, `gioBetween`,
  `nextMoonDays`.
- Calendar events: `lunarCalendarEvents`, `upcomingEvents`, `nextTet`,
  `nextLunarMilestone`.
