"""Regenerates reference/jpl_*.csv from NASA JPL's DE440s ephemeris.

Independent check for lib/: new moon instants and the 24 solar-term
crossings (apparent geocentric ecliptic longitude of date, multiples of
15 degrees), 1900-2100, written as local time UTC+7.

  python3 -m venv venv && ./venv/bin/pip install skyfield
  curl -LO https://ssd.jpl.nasa.gov/ftp/eph/planets/bsp/de440s.bsp
  ./venv/bin/python tool/jpl_reference.py de440s.bsp
"""
import sys
import datetime as dt
from skyfield.api import load
from skyfield import almanac
from skyfield.framelib import ecliptic_frame

ts = load.timescale()
eph = load(sys.argv[1])
t0, t1 = ts.utc(1899, 12, 1), ts.utc(2101, 2, 1)
tz = dt.timedelta(hours=7)


def local(t):
    return (t.utc_datetime() + tz).strftime('%Y-%m-%dT%H:%M:%S')


t, y = almanac.find_discrete(t0, t1, almanac.moon_phases(eph))
with open('reference/jpl_new_moons.csv', 'w') as f:
    f.write('new_moon_utc7\n')
    for ti, yi in zip(t, y):
        if yi == 0:
            f.write(local(ti) + '\n')

earth, sun = eph['earth'], eph['sun']


def sector(t):
    _, lon, _ = earth.at(t).observe(sun).apparent().frame_latlon(ecliptic_frame)
    return (lon.degrees // 15).astype(int) % 24


sector.step_days = 5
t, y = almanac.find_discrete(t0, t1, sector)
with open('reference/jpl_solar_terms.csv', 'w') as f:
    f.write('solar_term_index,start_utc7\n')
    for ti, yi in zip(t, y):
        f.write(f'{yi},{local(ti)}\n')
