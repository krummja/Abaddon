from dataclasses import dataclass
import math
from typing import NamedTuple, cast
import pendulum as pdl
import devtools as dev
from astropy.time import Time

DELTA_T = 32.184
UNIX_SECONDS_PER_DAY = 86_400

## 400 years + 1
GREGORIAN_CALENDAR_CYCLE_DAYS = 146_097

## 100 years
DAYS_PER_ERA = 36_524

## 4 years
DAYS_PER_QUADRENNIAL = 1_460

## 400 years
DAYS_PER_CYCLE = DAYS_PER_ERA * 4


def calculate_tcb(date: pdl.DateTime) -> float:
    unix_ts = date.timestamp()
    tcb_offset = 220924832.184
    lb = 1.550519768e-08
    t_diff = unix_ts - tcb_offset
    return unix_ts + 32.184 + (t_diff * lb)


class KeplerElement(NamedTuple):
    value: float
    value_per_century: float

    def compute_eph(self, t) -> float:
        return 0.0


@dataclass
class KeplerBody:
    name: str
    semi_major_axis: KeplerElement
    eccentricity: KeplerElement
    inclination: KeplerElement
    mean_longitude: KeplerElement
    longitude_of_perihelion: KeplerElement
    longitude_of_ascending_node: KeplerElement


EARTH = KeplerBody(
    name="Earth",
    semi_major_axis=KeplerElement(1.00000261, 0.00000562),
    eccentricity=KeplerElement(0.01671123, -0.00004392),
    inclination=KeplerElement(-0.00001531, -0.01294668),
    mean_longitude=KeplerElement(100.46457166, 35999.37244981),
    longitude_of_perihelion=KeplerElement(102.93768193, 0.32327364),
    longitude_of_ascending_node=KeplerElement(0.0, 0.0),
)


if __name__ == "__main__":
    now = pdl.DateTime(year=2026, month=6, day=4)
    unix_ts = now.timestamp()
    _start = pdl.DateTime(year=2000, month=3, day=1)

    days_since_1970 = math.floor(unix_ts / float(UNIX_SECONDS_PER_DAY))
    start = days_since_1970 - 11_017

    era = start // GREGORIAN_CALENDAR_CYCLE_DAYS
    day_of_era = start % GREGORIAN_CALENDAR_CYCLE_DAYS

    year_of_era = (
        day_of_era
        - day_of_era // DAYS_PER_QUADRENNIAL
        + day_of_era // DAYS_PER_ERA
        - day_of_era // DAYS_PER_CYCLE
    ) // 365

    year = year_of_era + era * 400 + 2000

    # Treating Mar 1 as "start of year"
    day_of_year = day_of_era - (
        365 * year_of_era + year_of_era // 4 - year_of_era // 100
    )

    month_shifted = (5 * day_of_year + 2) // 153
    day = day_of_year - (153 * month_shifted + 2) // 5 + 1

    if month_shifted < 10:
        month = month_shifted + 3
    else:
        month = month_shifted - 9
        year += 1

    dev.debug([year, month, day])
