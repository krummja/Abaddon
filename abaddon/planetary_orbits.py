from dataclasses import dataclass
from typing import NamedTuple, cast
from astropy.time import Time, TimeDelta
from astropy.time.formats import erfa, TimeFromEpoch

import devtools as dev


DELTA_T = 32.184


class TimeUnixLeap(TimeFromEpoch):
    """
    Seconds from 1970-01-01 00:00:00 TAI. Similar to Unix time
    but this includes leap seconds.
    """

    name: str = "unix_leap"
    unit: float = 1.0 / erfa.DAYSEC
    epoch_val: str = "1970-01-01 00:00:00"
    epoch_val2: str | None = None
    epoch_scale: str = "tai"
    epoch_format: str = "iso"


class KeplerElement(NamedTuple):
    value: float
    value_per_century: float

    def compute_eph(self, t: Time) -> float:
        TAI: Time = cast(Time, t.unix_leap)
        TDB: Time = TAI + DELTA_T
        TEPH = (cast(TimeDelta, TDB - 2451545.0)) / 36525
        return self.value + self.value_per_century * TEPH


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
    t = Time.now()
    sma = EARTH.semi_major_axis.compute_eph(t)
    ecc = EARTH.eccentricity.compute_eph(t)
    incl = EARTH.inclination.compute_eph(t)
    mean_long = EARTH.mean_longitude.compute_eph(t)
    lop = EARTH.longitude_of_perihelion.compute_eph(t)
    loan = EARTH.longitude_of_ascending_node.compute_eph(t)
