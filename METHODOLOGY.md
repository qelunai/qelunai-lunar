# Phương pháp / Methodology

[Tiếng Việt](#tiếng-việt) · [English](#english)

---

## Tiếng Việt

Trang này mô tả cách thư viện `qelunai_lunar` tính lịch âm Việt Nam và
**chính xác những gì đã được kiểm chứng**. Điều chưa kiểm được ghi
**[Chưa kiểm chứng]**.

### 1. Trục thời gian: số ngày Julius (JDN)

- Ngày dương lịch được đổi sang số ngày Julius nguyên (JDN) bằng công thức
  Fliegel & Van Flandern (1968), xem Meeus, *Astronomical Algorithms*
  (ấn bản 2, 1998), chương 7 (`jdnFromDate`, `dateFromJdn`).
- Chỉ dùng lịch Gregory. Không có nhánh lịch Julius; ngày trước
  15/10/1582 được tính theo lịch Gregory ngoại suy.

### 2. Điểm sóc (trăng non) và kinh độ Mặt Trời

Phần thiên văn nằm trong `lib/src/core/`, viết độc lập (clean-room) từ các
nguồn thiên văn công khai; quy trình và nguồn ghi trong
[CLEANROOM.md](CLEANROOM.md).

- **Sóc** (`core/new_moon.dart`): Meeus, *Astronomical Algorithms*
  (ấn bản 2, 1998), chương 49 ("Phases of the Moon"): thời điểm sóc trung
  bình cộng chuỗi số hạng tuần hoàn rút gọn theo dị thường trung bình của
  Mặt Trời *M*, của Mặt Trăng *M′* và đối số vĩ độ *F*. Kết quả ở giờ TT,
  trừ ΔT để ra UT. Sóc *k* = 0 là sóc gần JD 2415021.077 (6/1/1900). Ngày
  sóc theo giờ địa phương = `floor(JD_UT + múi_giờ/24 + 0.5)`.
- **Kinh độ Mặt Trời** (`core/sun_longitude.dart`): Meeus chương 25,
  phương pháp độ chính xác thấp: kinh độ và dị thường trung bình, ba số hạng
  của phương trình tâm, hiệu chỉnh **chương động và quang sai** qua kinh độ
  nút lên Ω của Mặt Trăng. Hàm công khai `sunLongitude(jd)` nhận `jd` theo
  **UT**, đổi sang TT bằng
  ΔT rồi tính; kết quả tính bằng radian trong [0, 2π).
- **ΔT = TT − UT** (`core/delta_t.dart`): đa thức của F. Espenak và
  J. Meeus, *Five Millennium Canon of Solar Eclipses*, NASA
  TP-2006-214141, các đoạn 1900–2150. Trước 1900 giữ giá trị năm 1900.

### 3. Múi giờ

- Mặc định UTC+7 (`vietnamTimeZone = 7.0`), không phụ thuộc múi giờ của
  máy. Mọi hàm dựa trên sóc hoặc tiết khí nhận tham số `timeZone`.
- Lịch Trung Quốc (UTC+8) hoặc Hàn Quốc (UTC+9) có thể lệch một ngày (kéo
  theo lệch tháng hoặc năm) khi sóc hoặc trung khí rơi gần nửa đêm.
  [Chưa kiểm chứng] Bộ test của thư viện không có ca so sánh lịch Việt Nam
  với lịch Trung Quốc hoặc Hàn Quốc.

### 4. Tháng âm và tháng nhuận

1. Tháng âm bắt đầu vào ngày sóc (giờ địa phương). Ngày âm = số ngày kể từ
   ngày sóc gần nhất không sau ngày cần đổi, cộng 1.
2. **Tháng 11** là tháng âm chứa ngày Đông chí: tìm ngày đầu tiên từ 1/12
   mà tại nửa đêm Mặt Trời đã ở cung trung khí từ 270° (chỉ số 9), tinh
   chỉnh thời điểm Mặt Trời qua 270° rồi lấy ngày địa phương chứa thời điểm
   đó; tháng 11 là tháng âm chứa ngày này (`core/solar_term.dart`,
   `core/lunar_month.dart`).
3. **Tháng nhuận:** nếu từ đầu tháng 11 năm này đến đầu tháng 11 năm sau có
   13 tháng âm, tháng nhuận là tháng đầu tiên sau tháng 11 không chứa trung
   khí: cung trung khí (30°) tại nửa đêm ngày đầu tháng đó **bằng** cung tại
   nửa đêm ngày đầu tháng kế tiếp. Tháng nhuận mang số của tháng liền
   trước, cờ `isLeapMonth = true`.
4. Năm âm đổi vào mùng 1 tháng Giêng.
- `lunarToSolar` trả về `null` khi hỏi tháng (hoặc tháng nhuận) mà năm đó
  không có. Hàm không kiểm `day` có vượt độ dài tháng hay không: ngày 30 của
  tháng thiếu cho ra mùng 1 tháng sau.

### 5. Tiết khí

- 24 tiết khí chia kinh độ hoàng đạo của Mặt Trời thành 24 phần 15°, chỉ số
  0 = Xuân phân (0°), …, 18 = Đông chí (270°).
- Một ngày mang tiết khí có hiệu lực tại **nửa đêm đầu ngày** (giờ địa
  phương) (`solarTermNameFor`, `solarTermSpanFor`). Vì vậy ngày giao tiết là
  ngày cuối của tiết trước; `lunarCalendarEvents` ghi tên tiết mới vào đúng
  ngày giao, như lịch in.

### 6. Can Chi

- **Ngày:** can = (JDN + 9) mod 10, chi = (JDN + 1) mod 12. Mốc: 10/02/2024
  (JDN 2460351) là ngày Giáp Thìn.
- **Năm âm:** 1984 là năm Giáp Tý; can = (năm − 1984) mod 10, chi =
  (năm − 1984) mod 12.
- **Tháng âm:** quy tắc "ngũ hổ độn": can tháng Giêng = 2 × can năm + 2
  (mod 10), mỗi tháng tăng một can; chi cố định, tháng Giêng = Dần … tháng
  Chạp = Sửu. Tháng nhuận dùng Can Chi của tháng cùng số.

### 7. Ngày và giờ hoàng đạo

- 12 thần theo thứ tự cố định: Thanh Long, Minh Đường, Thiên Hình, Chu
  Tước, Kim Quỹ, Kim Đường (Bảo Quang), Bạch Hổ, Ngọc Đường, Thiên Lao,
  Huyền Vũ (Nguyên Vũ), Tư Mệnh, Câu Trận. Sáu thần hoàng đạo: Thanh Long,
  Minh Đường, Kim Quỹ, Kim Đường, Ngọc Đường, Tư Mệnh.
- Bảng "hoàng đạo hắc đạo" như các lịch vạn niên tiếng Việt in theo ngày:
  chi chi phối Dần/Thân → Thanh Long ở Tý; Mão/Dậu → Dần; Thìn/Tuất → Thìn;
  Tỵ/Hợi → Ngọ; Ngọ/Tý → Thân; Mùi/Sửu → Tuất; các thần còn lại theo thứ tự
  chi.
- **Ngày:** chi chi phối là chi của **tháng âm**; tháng nhuận dùng chi của
  tháng cùng số. **Giờ:** chi chi phối là chi của ngày; 12 giờ là giờ đồng
  hồ dân sự: Tý 23–1 giờ, Sửu 1–3 giờ, …, Hợi 21–23 giờ.
- Chọn tháng âm (không phải tháng tiết khí) vì trên 9 ngày hai cách cho kết
  quả khác nhau, mọi lịch vạn niên tiếng Việt đã kiểm đều theo tháng âm (xem
  mục 10).
- [Chưa kiểm chứng] Lịch Trung Quốc hoặc sách gốc có dùng tháng tiết cho
  hoàng đạo hay không.
- [Chưa kiểm chứng] Giờ 23:00–24:00 thuộc giờ Tý của ngày hôm đó hay hôm sau
  tùy trường phái; thư viện coi là của ngày hôm đó.

### 8. Thập nhị trực

- Thứ tự: Kiến, Trừ, Mãn, Bình, Định, Chấp, Phá, Nguy, Thành, Thu, Khai,
  Bế. Trực Kiến rơi vào ngày có chi trùng chi tháng; trực =
  (chi ngày − chi tháng) mod 12.
- Tháng ở đây là **tháng tiết khí**: đổi tại mỗi tiết (Lập xuân → Dần,
  Kinh trập → Mão, …), không đổi tại ngày sóc.

### 9. Ngày giỗ (quy ước của thư viện)

- Người mất trong tháng nhuận: giỗ vào tháng thường cùng số. Năm có tháng
  nhuận trùng số: giỗ vào tháng thường.
- Mất ngày 30: giỗ ngày 30 nếu tháng đủ, ngày 29 nếu tháng thiếu; không dời
  sang tháng sau.
- Biết năm mất: giỗ đầu vào năm âm kế tiếp.
- Đây là quy ước chọn cho thư viện, không phải quy tắc được đối chiếu với
  nguồn ngoài.

### 10. Kiểm chứng

Bộ test (`dart test`, 77 ca) đối chiếu như sau. "Nguồn" là ghi chú có trong
mã test.

**Đổi lịch, Can Chi** (`test/lunar_calendar_test.dart`)

| Nội dung | Giá trị đối chiếu | Nguồn ghi trong test |
|---|---|---|
| Mùng 1 Tết | 22/01/2023, 10/02/2024, 29/01/2025, 17/02/2026, 06/02/2027 | "nhiều nguồn tin Việt Nam độc lập" (không ghi URL) |
| Giỗ Tổ Hùng Vương 10/3 âm | 18/04/2024, 07/04/2025 | không ghi URL |
| Có tháng nhuận | năm âm 2023 có tháng 2 nhuận; 2025 có tháng 6 nhuận (chỉ kiểm có tồn tại trong khoảng Tết–Tết, không kiểm ngày bắt đầu) | "được công bố công khai" (không ghi URL) |
| Can Chi năm | 2023 Quý Mão, 2024 Giáp Thìn, 2025 Ất Tỵ, 2026 Bính Ngọ, 2027 Đinh Mùi | tên năm của các Tết trên |
| Can Chi ngày | 10/02/2024 = Giáp Thìn; JDN = 2460351 | "nhiều lịch vạn niên tiếng Việt" (không ghi URL) |
| Can Chi tháng | tháng Giêng 2024 = Bính Dần | không ghi nguồn riêng |
| Nhất quán nội bộ | đổi dương → âm → dương trả lại đúng ngày cho **mọi ngày 1900–2100** | không có nguồn ngoài |

**Hoàng đạo** (`test/hoang_dao_test.dart`, nguồn truy cập 28/10/2026)

| Ngày | Can Chi | Thần ngày | Nguồn |
|---|---|---|---|
| 01/02/2025 | Tân Sửu | Minh Đường | baoquocte.vn (kèm đủ 12 thần giờ) |
| 01/05/2025 | Canh Ngọ | Thanh Long | vtcnews.vn; giờ hoàng đạo thêm baolamdong.vn |
| 14/08/2025 (âm 21/6 nhuận) | Ất Mão | Kim Đường | ngaydep.com |
| 10/02/2026 | Ất Mão | Kim Đường | ngaydep.com |
| 10/06/2026 | Ất Mão | Huyền Vũ (in là "Nguyên Vũ") | ngaydep.com |
| 09/08/2026 | Ất Mão | Kim Đường | ngaydep.com |
| 09/10/2026 | Bính Thìn | Thiên Hình | ngaydep.com, xemlicham.com |
| 08/11/2026 | Bính Tuất | Bạch Hổ | ngaydep.com, xemlicham.com |
| 08/12/2026 | Bính Thìn | Tư Mệnh | ngaydep.com |

Cả 9 ngày đều là ngày mà tháng âm và tháng tiết cho kết quả khác nhau. Giờ
hoàng đạo đối chiếu: 01/02/2025 (đủ 12 giờ, baoquocte.vn), 01/05/2025
(vtcnews.vn, baolamdong.vn), 10/02/2026 (xemlicham.com, baohatinh.vn,
ngaydep.com), 09/10/2026 (xemlicham.com, ngaydep.com), 28/10/2026 Ất Hợi
(`test/hour_status_test.dart`, xemlicham.com). Thuộc tính kiểm cho mọi ngày
2025–2026: mỗi ngày đúng 6 giờ hoàng đạo; thần giờ lặp chu kỳ 12 ngày;
trong cùng tháng, thần ngày lặp chu kỳ 12 ngày.

**Thập nhị trực** (`test/thap_nhi_truc_test.dart`): 28/10/2026 = Trừ;
10/02/2026 = Trừ (xemlicham.com, ngaydep.com). Ngày 10/02/2026 là âm 23/12
nhưng đã qua Lập xuân: tháng tiết (Dần) cho Trừ, tháng âm (Sửu) sẽ cho Mãn.

**Thiên văn: NASA JPL DE440s, 01/01/1900–31/12/2100** (`test/jpl_test.dart`)

`reference/jpl_new_moons.csv` và `reference/jpl_solar_terms.csv` (thời điểm
sóc và thời điểm Mặt Trời qua bội số 15°, giờ UTC+7) được sinh từ lịch thiên
văn DE440s của NASA JPL bằng `tool/jpl_reference.py` (thư viện Skyfield),
độc lập với mọi mã lịch âm. Kết quả trên 73.414 ngày (theo
[CLEANROOM.md](CLEANROOM.md)):

| Kiểm tra | Thư viện này |
|---|---|
| Sóc rơi sai ngày địa phương | 2 (1944-06-20 23:59:17 và 1967-07-07 23:59:59, cả hai cách nửa đêm không quá 43 giây) |
| Chỉ số tiết khí tại nửa đêm khác JPL | 11 ngày, đều cách thời điểm giao tiết không quá 8 phút |

Test chấp nhận sai lệch chỉ khi thời điểm JPL cách nửa đêm không quá
2 phút (sóc) hoặc 10 phút (tiết khí), và giới hạn số ca chấp nhận ở 2 và 11.

**Tiết khí** (`test/solar_term_span_test.dart`, `test/calendar_events_test.dart`)

- Mọi ngày 2026–2027: khoảng tiết khí khớp `solarTermNameFor`, dài 14–16
  ngày, ranh giới là chỗ đổi tiết thật. Đây là kiểm nhất quán nội bộ.
- Ngày giao tiết trong test (Hàn lộ 08/10/2026, Sương giáng 23/10/2026,
  Lập đông 07/11/2026) không ghi nguồn ngoài trong file test, nhưng chỉ số
  tiết khí của mọi ngày 1900–2100 được `test/jpl_test.dart` đối chiếu với
  JPL như trên.

**Sự kiện và ngày giỗ** (`test/calendar_events_test.dart`, `test/gio_test.dart`)

- Tết 2024, 2025, 2027 khớp bảng Tết ở trên.
- [Chưa kiểm chứng] Các ngày còn lại trong hai file này (mùng 1 tháng 9 âm =
  10/10/2026, rằm = 24/10/2026, 23 tháng Chạp năm Bính Ngọ = 30/01/2027, độ dài tháng 1 và 2 năm 2026, các ngày giỗ
  mẫu, ngày bắt đầu tháng 6 nhuận 2025 = 25/07/2025) là giá trị do thuật toán
  tính, không ghi nguồn ngoài.

### 11. Phạm vi và giới hạn

- Đã đối chiếu với lịch công bố: các ngày nêu trên, trong **2023–2027**.
- Đã đối chiếu thiên văn với JPL DE440s: **1900–2100** (mục 10). Ngoài
  khoảng này chưa kiểm.
- Sóc hoặc tiết khí rơi trong vòng vài phút quanh nửa đêm địa phương có thể
  bị xếp vào ngày bên kia; sai số này nằm dưới độ chính xác của các chuỗi
  rút gọn và của ΔT dự báo cho các năm tương lai. Ca 2072-12-09 (sóc lúc
  23:59:56) đúng là nhờ may, không phải nhờ độ chính xác.
- ΔT trước 1900 giữ giá trị năm 1900: ngày trước 1900 vẫn đổi được nhưng
  ít được kiểm hơn.
- Không dùng cho thiên văn chính xác cao.

---

## English

This page describes how `qelunai_lunar` computes the Vietnamese lunisolar
calendar and **exactly what has been verified**. Anything not verified is
marked **[Unverified]**.

### 1. Time axis: Julian Day Number

- Gregorian dates are converted to integer JDN with the Fliegel & Van
  Flandern (1968) formula, see Meeus, *Astronomical Algorithms* (2nd ed.,
  1998), ch. 7 (`jdnFromDate`, `dateFromJdn`).
- Gregorian only; there is no Julian-calendar branch. Dates before
  1582-10-15 are proleptic Gregorian.

### 2. New moons and solar longitude

The astronomy lives in `lib/src/core/`, written independently (clean-room)
from public astronomy sources; the process and sources are recorded in
[CLEANROOM.md](CLEANROOM.md).

- **New moon** (`core/new_moon.dart`): Meeus, *Astronomical Algorithms*
  (2nd ed., 1998), ch. 49 ("Phases of the Moon"): mean New Moon time plus a
  truncated periodic series in the Sun's mean anomaly *M*, the Moon's mean
  anomaly *M′* and argument of latitude *F*. The result is in TT; ΔT is
  subtracted to get UT. New moon *k* = 0 is the one near JD 2415021.077
  (1900-01-06). Local new-moon date = `floor(JD_UT + timeZone/24 + 0.5)`.
- **Solar longitude** (`core/sun_longitude.dart`): Meeus ch. 25, low
  accuracy method: mean longitude and mean anomaly, three terms of the
  equation of centre, and a **nutation and aberration** correction through
  the Moon's ascending-node longitude Ω. The public `sunLongitude(jd)` takes
  `jd` in **UT**, converts it to
  TT with ΔT and returns radians in [0, 2π).
- **ΔT = TT − UT** (`core/delta_t.dart`): the polynomials of F. Espenak and
  J. Meeus, *Five Millennium Canon of Solar Eclipses*, NASA
  TP-2006-214141, segments 1900–2150. Before 1900 the 1900 value is held.

### 3. Time zone

- Default UTC+7 (`vietnamTimeZone = 7.0`), regardless of the device time
  zone. Every new-moon or solar-term based function takes `timeZone`.
- Chinese (UTC+8) and Korean (UTC+9) lunar calendars can differ by a day
  (and so by a month or year) when a new moon or principal term falls near
  midnight. [Unverified] The test suite has no case comparing Vietnamese
  dates with Chinese or Korean ones.

### 4. Lunar months and leap months

1. A lunar month starts on the local date of a new moon. Lunar day = days
   since the latest new moon not after the date, plus 1.
2. **Month 11** is the lunar month containing the day of the winter
   solstice: find the first day from 1 December whose local midnight is in
   the principal-term sector starting at 270° (index 9), refine the instant
   the Sun crosses 270°, and take the local day containing that instant;
   month 11 is the lunar month containing that day (`core/solar_term.dart`,
   `core/lunar_month.dart`).
3. **Leap month:** if month 11 to the next month 11 holds 13 lunar months,
   the leap month is the first month after month 11 with no principal term:
   the 30° sector index at the local midnight of its first day **equals**
   the index at the first day of the following month. It takes the number
   of the month before it, with `isLeapMonth = true`.
4. The lunar year changes on the first day of month 1.
- `lunarToSolar` returns `null` for a month (or leap month) the year does
  not have. It does not check `day` against the month length: day 30 of a
  29-day month gives the first day of the next month.

### 5. Solar terms (tiết khí)

- The 24 terms divide the Sun's ecliptic longitude into 15° sectors; index
  0 = Xuân phân (0°), …, 18 = Đông chí (270°).
- A day carries the term in effect at its **local midnight**
  (`solarTermNameFor`, `solarTermSpanFor`), so the crossing day is the last
  day of the previous term; `lunarCalendarEvents` lists the new term on the
  crossing day, as printed calendars do.

### 6. Can Chi

- **Day:** stem = (JDN + 9) mod 10, branch = (JDN + 1) mod 12. Anchor:
  2024-02-10 (JDN 2460351) is a Giáp Thìn day.
- **Lunar year:** 1984 is Giáp Tý; stem = (year − 1984) mod 10, branch =
  (year − 1984) mod 12.
- **Lunar month:** the "ngũ hổ độn" rule: stem of month 1 = 2 × year stem +
  2 (mod 10), one stem per month; branches fixed, month 1 = Dần … month 12 =
  Sửu. A leap month uses the Can Chi of the month with the same number.

### 7. Lucky days and hours (hoàng đạo)

- 12 spirits in fixed order: Thanh Long, Minh Đường, Thiên Hình, Chu Tước,
  Kim Quỹ, Kim Đường (Bảo Quang), Bạch Hổ, Ngọc Đường, Thiên Lao, Huyền Vũ
  (Nguyên Vũ), Tư Mệnh, Câu Trận. Six are hoàng đạo: Thanh Long, Minh
  Đường, Kim Quỹ, Kim Đường, Ngọc Đường, Tư Mệnh.
- The "hoàng đạo hắc đạo" table as printed day by day in Vietnamese lịch
  vạn niên: governing branch Dần/Thân → Thanh Long on Tý; Mão/Dậu → Dần;
  Thìn/Tuất → Thìn; Tỵ/Hợi → Ngọ; Ngọ/Tý → Thân; Mùi/Sửu → Tuất; the rest
  follow in branch order.
- **Day:** governed by the branch of the **lunar month**; a leap month uses
  the branch of the month with the same number. **Hour:** governed by the
  day's branch; the 12 hours are civil clock hours: Tý 23–1, Sửu 1–3, …,
  Hợi 21–23.
- The lunar month (not the solar-term month) is used because on 9 days
  where the two give different results, every Vietnamese calendar checked
  used the lunar month (see section 10).
- [Unverified] Whether Chinese almanacs or classical sources use the
  solar-term month for hoàng đạo.
- [Unverified] Whether 23:00–24:00 belongs to that date's giờ Tý or the next
  day's depends on the school; this package treats it as that date's.

### 8. Thập nhị trực

- Order: Kiến, Trừ, Mãn, Bình, Định, Chấp, Phá, Nguy, Thành, Thu, Khai,
  Bế. Kiến falls on the day whose branch equals the month's branch; trực =
  (day branch − month branch) mod 12.
- The month here is the **solar-term month**: it changes at each tiết
  (Lập xuân → Dần, Kinh trập → Mão, …), not at the new moon.

### 9. Death anniversaries (package conventions)

- A death in a leap month is remembered in the regular month with the same
  number; in years with a leap month of that number, the regular month is
  used.
- A death on day 30 is remembered on day 30 in a 30-day month and on day 29
  in a 29-day month; it never moves into the next month.
- With a known year of death, the first anniversary is in the next lunar
  year.
- These are conventions chosen by the package, not rules checked against an
  external source.

### 10. Verification

The test suite (`dart test`, 77 tests) checks the following. "Source" is
what the test code records.

**Conversion and Can Chi** (`test/lunar_calendar_test.dart`)

| What | Values | Source recorded in the test |
|---|---|---|
| Tết (lunar 1/1) | 2023-01-22, 2024-02-10, 2025-01-29, 2026-02-17, 2027-02-06 | "multiple independent Vietnamese news sources" (no URL) |
| Giỗ Tổ Hùng Vương (lunar 10/3) | 2024-04-18, 2025-04-07 | no URL |
| Leap month exists | lunar 2023 has leap month 2; 2025 has leap month 6 (existence within the Tết-to-Tết span only; start date not checked) | "publicly documented" (no URL) |
| Year Can Chi | 2023 Quý Mão, 2024 Giáp Thìn, 2025 Ất Tỵ, 2026 Bính Ngọ, 2027 Đinh Mùi | names of the Tết years above |
| Day Can Chi | 2024-02-10 = Giáp Thìn; JDN = 2460351 | "multiple Vietnamese lịch vạn niên" (no URL) |
| Month Can Chi | month 1 of 2024 = Bính Dần | no separate source |
| Internal consistency | solar → lunar → solar returns the same date for **every day of 1900–2100** | no external source |

**Hoàng đạo** (`test/hoang_dao_test.dart`, sources fetched 2026-10-28)

| Date | Can Chi | Day spirit | Source |
|---|---|---|---|
| 2025-02-01 | Tân Sửu | Minh Đường | baoquocte.vn (with all 12 hour spirits) |
| 2025-05-01 | Canh Ngọ | Thanh Long | vtcnews.vn; lucky hours also baolamdong.vn |
| 2025-08-14 (lunar 21/6 leap) | Ất Mão | Kim Đường | ngaydep.com |
| 2026-02-10 | Ất Mão | Kim Đường | ngaydep.com |
| 2026-06-10 | Ất Mão | Huyền Vũ (printed "Nguyên Vũ") | ngaydep.com |
| 2026-08-09 | Ất Mão | Kim Đường | ngaydep.com |
| 2026-10-09 | Bính Thìn | Thiên Hình | ngaydep.com, xemlicham.com |
| 2026-11-08 | Bính Tuất | Bạch Hổ | ngaydep.com, xemlicham.com |
| 2026-12-08 | Bính Thìn | Tư Mệnh | ngaydep.com |

All 9 are days where the lunar month and the solar-term month give
different spirits. Lucky hours checked: 2025-02-01 (all 12 hours,
baoquocte.vn), 2025-05-01 (vtcnews.vn, baolamdong.vn), 2026-02-10
(xemlicham.com, baohatinh.vn, ngaydep.com), 2026-10-09 (xemlicham.com,
ngaydep.com), 2026-10-28 Ất Hợi (`test/hour_status_test.dart`,
xemlicham.com). Properties checked for every day of 2025–2026: exactly 6
lucky hours per day; hour spirits repeat every 12 days; within a month, day
spirits repeat every 12 days.

**Thập nhị trực** (`test/thap_nhi_truc_test.dart`): 2026-10-28 = Trừ;
2026-02-10 = Trừ (xemlicham.com, ngaydep.com). 2026-02-10 is lunar 23/12
but after Lập xuân: the solar-term month (Dần) gives Trừ, the lunar month
(Sửu) would give Mãn.

**Astronomy: NASA JPL DE440s, 1900-01-01 to 2100-12-31** (`test/jpl_test.dart`)

`reference/jpl_new_moons.csv` and `reference/jpl_solar_terms.csv` (New Moon
instants and the instants the Sun crosses each multiple of 15°, UTC+7) are
generated from NASA JPL's DE440s ephemeris by `tool/jpl_reference.py`
(Skyfield library), independently of any lunar-calendar code. Results over
73,414 days (from [CLEANROOM.md](CLEANROOM.md)):

| Check | This package |
|---|---|
| New Moon on the wrong local day | 2 (1944-06-20 23:59:17 and 1967-07-07 23:59:59, both within 43 s of midnight) |
| Solar-term index at local midnight differs from JPL | 11 days, all within 8 minutes of a crossing |

The test accepts a disagreement only when the JPL instant is within
2 minutes (New Moon) or 10 minutes (solar term) of midnight, and caps the
accepted cases at 2 and 11.

**Solar terms** (`test/solar_term_span_test.dart`, `test/calendar_events_test.dart`)

- Every day of 2026–2027: the term span agrees with `solarTermNameFor`, is
  14–16 days long, and its bounds are real term changes. This is an internal
  consistency check.
- The term crossing dates in these tests (Hàn lộ 2026-10-08, Sương giáng
  2026-10-23, Lập đông 2026-11-07) record no external source in the test
  file, but the term index of every day of 1900–2100 is checked against
  JPL by `test/jpl_test.dart` as above.

**Events and death anniversaries** (`test/calendar_events_test.dart`, `test/gio_test.dart`)

- Tết 2024, 2025 and 2027 match the Tết table above.
- [Unverified] The other dates in these two files (lunar 1/9 = 2026-10-10,
  full moon = 2026-10-24, lunar 23/12 of Bính Ngọ = 2027-01-30, the lengths of lunar months 1 and 2 of 2026, the
  sample anniversaries, the start of leap month 6 of 2025 = 2025-07-25) are
  values computed by the algorithm, with no external source recorded.

### 11. Range and limitations

- Checked against published calendars: the dates above, within
  **2023–2027**.
- Astronomy checked against JPL DE440s: **1900–2100** (section 10). Not
  checked outside that range.
- A New Moon or solar term within a few minutes of local midnight can land
  on either day; that is below the accuracy of the truncated series and of
  ΔT forecasts for future years. The 2072-12-09 case (New Moon at
  23:59:56) is right by luck, not by precision.
- ΔT before 1900 is held at its 1900 value: dates before 1900 still convert,
  with less checking.
- Not suitable for high-precision astronomy.
