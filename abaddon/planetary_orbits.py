from dataclasses import dataclass
from pathlib import Path
import math
import re
from typing import TypedDict
import devtools as dev


HERE = Path(__file__)
SCRIPT_DIR = HERE.parent


def normalize_angle(value: float) -> float:
    return ((value + 180) % 360) - 180


def rad_to_deg(rad: float) -> float:
    return rad * (180 / math.pi)


@dataclass
class KeplerElements:
    semimajor_axis: float
    eccentricity: float
    inclination: float
    mean_longitude: float
    long_perihelion: float
    long_asc_node: float


@dataclass
class KeplerRates:
    semimajor_axis: float
    eccentricity: float
    inclination: float
    mean_longitude: float
    long_perihelion: float
    long_asc_node: float


@dataclass
class KeplerBody:
    t: float
    elements: KeplerElements
    rates: KeplerRates

    @property
    def semimajor_axis(self) -> float:
        return self.elements.semimajor_axis + (self.rates.semimajor_axis * self.t)

    @property
    def eccentricity(self) -> float:
        return self.elements.eccentricity + (self.rates.eccentricity * self.t)

    @property
    def inclination(self) -> float:
        return self.elements.inclination + (self.rates.inclination * self.t)

    @property
    def mean_longitude(self) -> float:
        raw_value = self.elements.mean_longitude + (self.rates.mean_longitude * self.t)
        return normalize_angle(raw_value)

    @property
    def longitude_of_perihelion(self) -> float:
        return self.elements.long_perihelion + (self.rates.long_perihelion * self.t)

    @property
    def longitude_of_the_ascending_node(self) -> float:
        raw_value = self.elements.long_asc_node + (self.rates.long_asc_node * self.t)
        return raw_value + 180.0


class DateDict(TypedDict):
    year: int
    month: int
    day: int


def calculate_julian_day(date: DateDict) -> float:
    year = date["year"]
    month = date["month"]
    day = date["day"]

    if month in [1, 2]:
        year -= 1
        month += 12

    A = math.floor(year / 100)
    B = math.floor(A / 4)
    C = 2 - A + B
    E = math.floor(365.25 * (year + 4716))
    F = math.floor(30.6001 * (month + 1))
    jdn = C + day + E + F - 1524.5
    return math.ceil(jdn)


def get_jdn_range(dates: list[DateDict]) -> list[tuple[float]]:
    jdn_values = []
    for date in dates:
        jdn_values.append((date["year"], calculate_julian_day(date)))
    return jdn_values


def main() -> None:
    date: DateDict = {
        "year": 2000,
        "month": 1,
        "day": 1,
    }

    JDN = calculate_julian_day(date)

    # Centuries past J2000.0
    T = (JDN - 2451545.0) / 36525

    EarthElements = KeplerElements(
        semimajor_axis=1.00000261,
        eccentricity=0.01671123,
        inclination=-0.0,
        mean_longitude=100.46457166,
        long_perihelion=102.93768193,
        long_asc_node=-5.11260389,
    )

    EarthRates = KeplerRates(
        semimajor_axis=0.00000562,
        eccentricity=-0.00004392,
        inclination=0.0,
        mean_longitude=35999.37244981,
        long_perihelion=0.32327364,
        long_asc_node=-0.24123856,
    )

    Earth = KeplerBody(T, EarthElements, EarthRates)

    print(f"{date['year']}-{date['month']}-{date['day']} (JDN: {JDN}, T: {T})")
    print(f"Semi-major axis:  {round(Earth.semimajor_axis, 4)} au")  # SE: 1 AU
    print(f"Eccentricity:     {round(Earth.eccentricity, 4)} e")  # SE: 0.017
    print(f"Inclination:      {round(Earth.inclination, 4)} deg")  # SE: 0
    print(f"Mean Longitude:   {round(Earth.mean_longitude, 4)} deg")  # SE: 100.466457
    print(
        f"Long. Perihelion: {round(Earth.longitude_of_perihelion, 4)} deg"
    )  # SE: ? 102.937348
    print(
        f"Long. Asc. Node:  {round(Earth.longitude_of_the_ascending_node, 4)} deg"
    )  # Horizons: 241.07 degrees

    # Semi-major axis:  1.0 au          matches
    # Eccentricity:     0.0167          matches
    # Inclination:      0.0 deg         matches
    # Mean Longitude:   -105.9561 deg
    # Long. Perihelion: 103.0296 deg    matches within error tolerance
    # Long. Asc. Node:  174.8188 deg

    #                         2451545               2461928
    # Eccentricity          = 0.0167 e              "
    # Periapsis             = 0.9832 au             "
    # Inclination           = 0.0001 deg            "
    # Long. Asc.            = 140.29 deg            175.37 deg          ???
    # Arg. of Perifocus     = 322.62 deg
    # Mean Motion           = 0.9856 deg/day
    # Mean Anomaly          = 357.54 deg
    # True Anomaly          = 357.46 deg
    # Semi-major Axis       = 0.9999 au
    # Apoapsis              = 1.0166 au

    # 2000-1-1 (JDN: 2451545, T: 0.0)
    # Semi-major axis:      1.0 au          matches
    # Eccentricity:         0.0167 e        matches
    # Inclination:          0.0 deg         matches
    # Mean Longitude:       100.4646 deg    *
    # Long. Perihelion:     102.9377 deg    *
    # Long. Asc. Node:      174.8874 deg    != 140.29


if __name__ == "__main__":
    main()

    dates: list[DateDict] = [
        {
            "year": 1998,
            "month": 1,
            "day": 1,
        },
        {
            "year": 2022,
            "month": 1,
            "day": 1,
        },
        {
            "year": 2023,
            "month": 1,
            "day": 1,
        },
        {
            "year": 2024,
            "month": 1,
            "day": 1,
        },
        {
            "year": 2025,
            "month": 1,
            "day": 1,
        },
        {
            "year": 2026,
            "month": 1,
            "day": 1,
        },
        {
            "year": 2027,
            "month": 1,
            "day": 1,
        },
        {
            "year": 2028,
            "month": 1,
            "day": 1,
        },
    ]

    date_range = get_jdn_range(dates)

    dev.debug(date_range)

    # re_epoch = re.compile(
    #     r"(\d*\.\d*) = (A.D. \d{4}-\w{3}-\d{2} \d{2}:\d{2}:\d{2}\.\d* TDB)"
    # )

    # re_elem = re.compile(r"\s{1}(\w{1,2})\s*=\s*(?:(\d\.\d*E[+|-]\d{2})|(\d\.\d*))")

    # dev.debug(
    #     re_elem.findall(
    #         " A = 1.000001962045544E+00 AD= 1.016672543301838E+00 PR= 3.652574180339008E+02"
    #     )
    # )

    # with open(Path(SCRIPT_DIR, "ephemeris.txt"), "r") as datafile:
    #     lines = datafile.readlines()

    #     for line in lines:
    #         line = line.replace("\n", "")

    #         if ephemeris_info := re_epoch.findall(line):
    #             print(ephemeris_info)

    #         if element_value := re_elem.findall(line):
    #             print(element_value)
