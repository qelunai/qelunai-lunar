# qelunai_lunar

Vietnamese lunisolar calendar (âm lịch Việt Nam) in pure Dart — no Flutter
dependency. Extracted from the [Qelunai](https://qelunai.com) app.

- Solar ↔ lunar conversion, including leap months (tháng nhuận)
- Can Chi of the day, lunar month and lunar year
- The 24 solar terms (tiết khí) and their date spans
- Ngày / giờ hoàng đạo (12 trực thần: Thanh Long … Câu Trận)
- Thập nhị trực (Kiến, Trừ … Bế)
- Ngày giỗ (death anniversaries kept by the lunar calendar), mùng một / rằm,
  Tết countdown

All functions are pure: dates are plain `day`/`month`/`year` integers and any
"today" is passed in by the caller. Calculations use **UTC+7 (Vietnam civil
time)** by default, whatever the device's time zone.

[Tiếng Việt bên dưới](#tiếng-việt) · [Methodology](METHODOLOGY.md)

## Install

```sh
dart pub add qelunai_lunar
```

```dart
import 'package:qelunai_lunar/qelunai_lunar.dart';
```

## Examples

The outputs in the comments are what `example/main.dart` prints.

### Solar → lunar

```dart
final tet = solarToLunar(day: 10, month: 2, year: 2024);
print(tet); // LunarDay(1/1/2024)
print('${tet.day}/${tet.month}/${tet.year} leap=${tet.isLeapMonth}');
```

### Lunar → solar, with a leap month

The lunar year 2025 has a leap 6th month (tháng 6 nhuận). `lunarToSolar`
returns `null` for a leap month that does not exist.

```dart
lunarToSolar(day: 1, month: 6, year: 2025);
// (day: 25, month: 6, year: 2025)
lunarToSolar(day: 1, month: 6, year: 2025, isLeapMonth: true);
// (day: 25, month: 7, year: 2025)
lunarToSolar(day: 1, month: 6, year: 2026, isLeapMonth: true);
// null — 2026 has no leap month
```

### Can Chi of day, month and year

```dart
final info = lunarDateInfo(day: 10, month: 2, year: 2024);
print(info.dayCanChi);   // Giáp Thìn
print(info.monthCanChi); // Bính Dần
print(info.yearCanChi);  // Giáp Thìn

// Or one at a time:
dayCanChi(jdnFromDate(day: 10, month: 2, year: 2024)); // Giáp Thìn
monthCanChi(1, 2024); // Bính Dần
yearCanChi(2026);     // Bính Ngọ
```

### Solar terms (tiết khí)

```dart
solarTermNameFor(day: 10, month: 2, year: 2024); // Lập xuân

final span = solarTermSpanFor(day: 28, month: 10, year: 2026);
print(span.name);     // Sương giáng
print(span.start);    // (day: 24, month: 10, year: 2026)
print(span.end);      // (day: 7, month: 11, year: 2026)
print(span.nextName); // Lập đông
```

A day carries the term in effect at its local midnight, so a term "starts"
on the day after the crossing. `lunarCalendarEvents` lists each term on the
day of the crossing, as printed calendars do (Sương giáng on 2026-10-23).

### Ngày and giờ hoàng đạo

```dart
final day = hoangDaoDay(day: 1, month: 5, year: 2025);
print(day.than.label); // Thanh Long
print(day.isHoangDao); // true

for (final h in gioHoangDao(day: 1, month: 5, year: 2025)) {
  print('${h.branchName} ${h.startHour}–${h.endHour}h');
}
// Tý 23–1h, Sửu 1–3h, Mão 5–7h, Ngọ 11–13h, Thân 15–17h, Dậu 17–19h
```

### Thập nhị trực

```dart
thapNhiTruc(day: 28, month: 10, year: 2026).label; // Trừ
```

## Time zone

Every function that depends on a new moon or solar term takes an optional
`timeZone` (hours from UTC, default `vietnamTimeZone = 7.0`). Vietnamese and
Chinese (UTC+8) or Korean (UTC+9) lunar calendars can differ by a day — and
so by a month or a year — when a new moon or solstice falls close to
midnight. Hour-based functions (`hoangDaoHours`, `hourStatus`) use civil
clock hours as printed calendars do.

## Verified range and limitations

- **Checked years.** The test suite compares results with published
  Vietnamese calendars for dates in **2023–2027** (Tết, Giỗ Tổ Hùng Vương,
  leap months, Can Chi, hoàng đạo, trực). Results outside that range are
  computed with the same method but are not checked against published
  calendars. The method is commonly described as reliable for roughly
  1200–3000 CE; this package has not verified that range itself. See
  [METHODOLOGY.md](METHODOLOGY.md) for exactly what is checked.
- **Gregorian only.** `jdnFromDate` has no Julian-calendar branch; dates
  before 1582-10-15 are proleptic Gregorian.
- **Truncated series.** New moons and solar longitude use short
  approximations (no nutation/aberration). In rare cases this, together with
  the ΔT approximation, can move a new moon or term across local midnight
  and shift a month boundary by one day.
- **Giờ Tý.** Whether 23:00–24:00 belongs to the given date's giờ Tý or the
  next day's differs between schools; this package treats it as the given
  date's.
- **Conventions.** Hoàng đạo days use the lunar month; thập nhị trực uses
  the solar-term month; ngày giỗ in a leap month is kept in the regular
  month. These follow the Vietnamese calendars checked in the tests; other
  traditions may differ.
- Not suitable for high-precision astronomy.

## License

MIT © 2026 Qelunai. See [LICENSE](LICENSE).

---

## Tiếng Việt

Thư viện lịch âm Việt Nam viết bằng Dart thuần (không cần Flutter), tách từ
ứng dụng [Qelunai](https://qelunai.com).

- Đổi dương lịch ↔ âm lịch, có tháng nhuận
- Can Chi ngày, tháng, năm
- 24 tiết khí và khoảng ngày của từng tiết
- Ngày và giờ hoàng đạo (12 thần: Thanh Long … Câu Trận)
- Thập nhị trực (Kiến, Trừ … Bế)
- Ngày giỗ theo âm lịch, mùng một / rằm, đếm ngày đến Tết

Mọi hàm đều thuần: ngày là ba số nguyên `day`/`month`/`year`, ngày "hôm nay"
do người gọi truyền vào. Mặc định tính theo **giờ Việt Nam (UTC+7)**, không
phụ thuộc múi giờ của máy.

### Cài đặt

```sh
dart pub add qelunai_lunar
```

### Ví dụ

```dart
import 'package:qelunai_lunar/qelunai_lunar.dart';

// Dương → âm
solarToLunar(day: 10, month: 2, year: 2024); // LunarDay(1/1/2024) — Tết Giáp Thìn

// Âm → dương, có tháng nhuận (năm 2025 có tháng 6 nhuận)
lunarToSolar(day: 1, month: 6, year: 2025);                    // 25/6/2025
lunarToSolar(day: 1, month: 6, year: 2025, isLeapMonth: true); // 25/7/2025
lunarToSolar(day: 1, month: 6, year: 2026, isLeapMonth: true); // null

// Can Chi ngày / tháng / năm và tiết khí
final info = lunarDateInfo(day: 10, month: 2, year: 2024);
// ngày Giáp Thìn, tháng Bính Dần, năm Giáp Thìn, tiết Lập xuân

// Giờ hoàng đạo
gioHoangDao(day: 1, month: 5, year: 2025).map((h) => h.branchName);
// Tý, Sửu, Mão, Ngọ, Thân, Dậu
```

### Phạm vi đã kiểm và giới hạn

- Bộ test đối chiếu với lịch Việt Nam đã công bố cho các ngày trong
  **2023–2027**. Ngoài khoảng này kết quả tính cùng phương pháp nhưng chưa
  được đối chiếu. Chi tiết: [METHODOLOGY.md](METHODOLOGY.md).
- Múi giờ mặc định UTC+7. Lịch Trung Quốc (UTC+8), Hàn Quốc (UTC+9) có thể
  lệch một ngày (kéo theo lệch tháng, năm) khi sóc hoặc trung khí rơi gần nửa
  đêm.
- Chỉ dùng lịch Gregory (không có nhánh lịch Julius).
- Chuỗi thiên văn rút gọn: hiếm khi có thể lệch ranh giới tháng một ngày.
- Giờ Tý 23:00–24:00 thuộc ngày hôm đó hay ngày hôm sau tùy trường phái; thư
  viện tính cho ngày hôm đó.
- Ngày hoàng đạo theo tháng âm; thập nhị trực theo tháng tiết khí; giỗ người
  mất trong tháng nhuận làm vào tháng thường cùng số.

### Giấy phép

MIT © 2026 Qelunai.
