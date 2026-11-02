# Clean-room record

`lib/src/core/` converts between the Gregorian and the Vietnamese lunar calendar (UTC+7).
It was written on 2026-11-02 to replace an earlier core that was a translation of
a lunar-calendar program whose licence allows personal, non-commercial use only.

## Process

- The author (a Claude agent with its own account and an empty working directory)
  was told not to open the earlier core, its translations, or any lunar-calendar
  source code online. The audit of its tool calls shows no reads outside this
  directory and the Flutter SDK, and no web access.
- Inputs it was given: this API (function names and signatures, which the app
  already uses), and `oracle/`, a day-by-day table produced by the earlier core,
  used only as test expectations. The table is data, not code. It stays in
  the separate clean-room repository and is not part of this package.
- Sources used for the method (all public, all general astronomy):
  - Jean Meeus, *Astronomical Algorithms*, 2nd ed. (1998): ch. 7 (Julian Day),
    ch. 25 (solar position, low accuracy, with nutation and aberration),
    ch. 49 (New Moon: mean phase plus periodic terms).
  - F. Espenak and J. Meeus, *Five Millennium Canon of Solar Eclipses*,
    NASA TP-2006-214141: polynomial expressions for ΔT, 1900–2150.
  - The public rules of the Vietnamese calendar: a month starts on the local day
    (UTC+7) of the New Moon; month 11 contains the winter solstice; in a year with
    13 months, the first month with no principal solar term is the leap month.

## Method

The files below were written in a separate repository and copied into
`lib/src/core/` unchanged. `lib/src/astronomy.dart` and
`lib/src/lunar_calendar.dart` are thin wrappers that keep this package's
public API.


| Step | File |
|---|---|
| Julian Day Number ↔ Gregorian date | `lib/src/core/julian_day.dart` |
| ΔT = TT − UT | `lib/src/core/delta_t.dart` |
| New Moon instant (TT), then UT and local day | `lib/src/core/new_moon.dart` |
| Apparent solar longitude (TT) | `lib/src/core/sun_longitude.dart` |
| Solar-term sector at local midnight, winter solstice day | `lib/src/core/solar_term.dart` |
| Month 11 cycles, leap month, month numbers | `lib/src/core/lunar_month.dart` |

## Results, 1900-01-01 to 2100-12-31 (73,414 days)

Checked against NASA JPL's DE440s ephemeris (`reference/`, `tool/jpl_reference.py`,
`test/jpl_test.dart`):

| Check | This library | Earlier core (oracle) |
|---|---|---|
| New Moon on the wrong local day | 2 (1944-06-20 23:59:17 and 1967-07-07 23:59:59, both within 43 s of midnight) | 4 (the same 2, plus 2072-12-09 23:59:56 and 2085-10-19 00:01:15) |
| Solar-term index at local midnight differs from JPL | 11, all within 8 minutes of a crossing | 35, up to 20 minutes from a crossing |

Against the oracle, lunar dates differ on 62 days, and JPL sides with this library each time:

| Days | Oracle | This library | JPL New Moon (UTC+7) |
|---|---|---|---|
| 2054-05-07 | day 0 of month 4 (invalid) | 30/3 | 2054-05-08 00:01:00 |
| 2062-04-09 | day 0 of month 3 (invalid) | 30/2 | 2062-04-10 00:17:36 |
| 2072-12-09 to 2073-01-07 | month 11 starts 12-10 | month 11 starts 12-09 | 2072-12-09 23:59:56 |
| 2085-10-18 to 2085-11-16 | month 9 starts 10-18 | month 9 starts 10-19 | 2085-10-19 00:01:15 |

Leap months are the same as the oracle in every year. Round trips
(solar → lunar → solar) pass on the sampled days.

## Limits

- A New Moon or solar term within a few minutes of local midnight can land on
  either day; that is below the accuracy of these series and of ΔT forecasts
  for future years. The 2072-12-09 case (4 seconds before midnight) is right by
  luck, not by precision.
- ΔT before 1900 is held at its 1900 value. Dates before 1900 still convert,
  with less checking.
