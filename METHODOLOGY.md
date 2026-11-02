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

- **Sóc:** sóc thứ *k* tính từ sóc gần ngày 1/1/1900 (JD 2415021.076998695),
  chu kỳ giao hội trung bình 29.530588853 ngày, cộng một chuỗi tuần hoàn rút
  gọn (các số hạng theo dị thường trung bình của Mặt Trời *M*, của Mặt Trăng
  *M′* và đối số vĩ độ *F*) và trừ một xấp xỉ ΔT (TT − UT) dạng đa thức.
  Ngày sóc theo giờ địa phương = `floor(JDE + 0.5 + múi_giờ/24)`.
- **Kinh độ Mặt Trời:** chuỗi rút gọn ba số hạng của phương trình tâm,
  không hiệu chỉnh chương động và quang sai (tính từ J2000.0).
- Chú thích trong mã ghi nguồn là Meeus, chương 7, 25 và 47.
  [Chưa kiểm chứng] Số chương cho phần sóc: tài liệu nghiên cứu của dự án
  ghi nhận các nguồn lệch nhau (47 hoặc 49), và một tài liệu khác của dự án
  gọi chương 47 là "Position of the Moon". Hệ số sóc dùng gốc thời gian 1900,
  không phải gốc J2000; ấn bản và chương chính xác của bộ hệ số này chưa đối
  chiếu với sách gốc.
- Cấu trúc thuật toán đổi lịch (sóc, tháng 11, tháng nhuận) là thuật toán
  âm lịch Việt Nam do Hồ Ngọc Đức công bố, được nhiều thư viện dùng lại.

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
2. **Tháng 11** là tháng âm chứa Đông chí: lấy ngày sóc gần 31/12; nếu tại
   nửa đêm ngày sóc đó Mặt Trời đã ở cung trung khí từ 270° trở đi (chỉ số
   ≥ 9), lùi về sóc trước.
3. **Tháng nhuận:** nếu từ đầu tháng 11 năm trước đến đầu tháng 11 năm sau
   dài hơn 365 ngày (năm có 13 tháng âm), tháng nhuận là tháng đầu tiên sau
   tháng 11 mà cung trung khí (30°) tại nửa đêm ngày sóc **không đổi** so với
   tháng trước, tức tháng không chứa trung khí. Tháng nhuận mang số của tháng
   liền trước, cờ `isLeapMonth = true`.
4. Năm âm đổi vào mùng 1 tháng Giêng.
- `lunarToSolar` trả về `null` khi hỏi tháng nhuận mà năm đó không có.
- [Chưa kiểm chứng] Tháng 12 nhuận: theo mã, `lunarToSolar` tính số tháng
  nhuận là `(leapOff − 2) mod` theo cách chỉ cộng 12 khi âm, nên tháng 12
  nhuận sẽ không được nhận. Trong 1900–2100 không có năm nào có tháng 12
  nhuận theo thuật toán này (kiểm bằng phép quét toàn bộ ngày), nên chưa có
  ca thử thực tế.

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

Bộ test (`dart test`, 75 ca) đối chiếu như sau. "Nguồn" là ghi chú có trong
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

**Tiết khí** (`test/solar_term_span_test.dart`, `test/calendar_events_test.dart`)

- Mọi ngày 2026–2027: khoảng tiết khí khớp `solarTermNameFor`, dài 14–16
  ngày, ranh giới là chỗ đổi tiết thật. Đây là kiểm nhất quán nội bộ.
- [Chưa kiểm chứng] Ngày giao tiết trong test (Hàn lộ 08/10/2026, Sương
  giáng 23/10/2026, Lập đông 07/11/2026) không ghi nguồn ngoài. Thư viện
  chưa có ca đối chiếu ngày giao tiết với nguồn thiên văn chính thức. (Ứng
  dụng Qelunai có kiểm hàm kinh độ Mặt Trời với thời điểm xuân phân, hạ chí,
  thu phân, đông chí 2024 của U.S. Naval Observatory, trong một test không
  chép sang thư viện này.)

**Sự kiện và ngày giỗ** (`test/calendar_events_test.dart`, `test/gio_test.dart`)

- Tết 2024, 2025, 2027 khớp bảng Tết ở trên.
- [Chưa kiểm chứng] Các ngày còn lại trong hai file này (mùng 1 tháng 9 âm =
  10/10/2026, rằm = 24/10/2026, 23 tháng Chạp năm Bính Ngọ = 30/01/2027, độ dài tháng 1 và 2 năm 2026, các ngày giỗ
  mẫu, ngày bắt đầu tháng 6 nhuận 2025 = 25/07/2025) là giá trị do thuật toán
  tính, không ghi nguồn ngoài.

### 11. Phạm vi và giới hạn

- Đã đối chiếu với lịch công bố: các ngày nêu trên, trong **2023–2027**.
- [Chưa kiểm chứng] Độ tin cậy khoảng năm 1200–3000: con số này do một thư
  viện khác (`doxuta/amlich`) nêu cho cùng họ thuật toán; thư viện này chưa
  tự kiểm.
- Chuỗi rút gọn và xấp xỉ ΔT có thể, trong ca hiếm, đẩy sóc hoặc tiết khí qua
  nửa đêm và làm lệch ranh giới tháng một ngày.
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

- **New moon:** the *k*-th new moon from the one near 1900-01-01
  (JD 2415021.076998695), with a mean synodic month of 29.530588853 days,
  plus a truncated periodic series (terms in the Sun's mean anomaly *M*, the
  Moon's mean anomaly *M′* and argument of latitude *F*), minus a polynomial
  ΔT (TT − UT) approximation. Local new-moon date =
  `floor(JDE + 0.5 + timeZone/24)`.
- **Solar longitude:** a three-term equation of centre from J2000.0, with
  no nutation or aberration correction.
- The code comments cite Meeus chapters 7, 25 and 47. [Unverified] The
  chapter for the new-moon series: the project's research notes record that
  sources disagree (47 or 49), and another project note calls chapter 47
  "Position of the Moon". The new-moon coefficients use a 1900 epoch, not
  J2000; their exact edition and chapter have not been checked against the
  book.
- The conversion algorithm (new moons, month 11, leap month) is the
  Vietnamese lunar calendar algorithm published by Hồ Ngọc Đức and reused by
  many libraries.

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
2. **Month 11** is the lunar month containing the winter solstice: take the
   new moon near 31 December; if at its local midnight the Sun is already in
   the principal-term sector starting at 270° or later (index ≥ 9), use the
   previous new moon.
3. **Leap month:** if month 11 to the next month 11 spans more than 365 days
   (a 13-month year), the leap month is the first month after month 11 whose
   30° principal-term sector at its new-moon midnight is **unchanged** from
   the previous month's — the month with no principal term. It takes the
   number of the month before it, with `isLeapMonth = true`.
4. The lunar year changes on the first day of month 1.
- `lunarToSolar` returns `null` for a leap month the year does not have.
- [Unverified] Leap month 12: in the code, `lunarToSolar` computes the leap
  month number as `leapOff − 2`, adding 12 only when negative, so a leap
  12th month would not be recognised. No year in 1900–2100 has a leap 12th
  month under this algorithm (found by scanning every day), so there is no
  real case to test.

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

The test suite (`dart test`, 75 tests) checks the following. "Source" is
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

**Solar terms** (`test/solar_term_span_test.dart`, `test/calendar_events_test.dart`)

- Every day of 2026–2027: the term span agrees with `solarTermNameFor`, is
  14–16 days long, and its bounds are real term changes. This is an internal
  consistency check.
- [Unverified] The term crossing dates in the tests (Hàn lộ 2026-10-08,
  Sương giáng 2026-10-23, Lập đông 2026-11-07) record no external source.
  The package has no test comparing term dates with an official
  astronomical source. (The Qelunai app checks the solar longitude function
  against the U.S. Naval Observatory 2024 equinox and solstice times, in a
  test not copied into this package.)

**Events and death anniversaries** (`test/calendar_events_test.dart`, `test/gio_test.dart`)

- Tết 2024, 2025 and 2027 match the Tết table above.
- [Unverified] The other dates in these two files (lunar 1/9 = 2026-10-10,
  full moon = 2026-10-24, lunar 23/12 of Bính Ngọ = 2027-01-30, the lengths of lunar months 1 and 2 of 2026, the
  sample anniversaries, the start of leap month 6 of 2025 = 2025-07-25) are
  values computed by the algorithm, with no external source recorded.

### 11. Range and limitations

- Checked against published calendars: the dates above, within
  **2023–2027**.
- [Unverified] Reliability for roughly 1200–3000: this figure is stated by
  another library (`doxuta/amlich`) for the same family of algorithms; this
  package has not checked it.
- The truncated series and ΔT approximation can, in rare cases, move a new
  moon or solar term across midnight and shift a month boundary by one day.
- Not suitable for high-precision astronomy.
