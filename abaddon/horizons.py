from enum import StrEnum
from pathlib import Path
from astroquery.jplhorizons.core import Table
from astroquery.jplhorizons import Horizons

import pendulum as pdl
import polars as pl
import devtools as dev


HERE = Path(__file__)
SCRIPT_DIR = HERE.parent
PROJECT_DIR = SCRIPT_DIR.parent
GAME_DATA_DIR = Path(PROJECT_DIR, "data")


class Selection(StrEnum):
    SSB = "ssb"
    SUN = "sun"
    MERCURY_BARY = "1"
    VENUS_BARY = "2"
    EARTH_MOON_BARY = "3"
    MARS_BARY = "4"
    JUPITER_BARY = "5"
    SATURN_BARY = "6"
    URANUS_BARY = "7"
    NEPTUNE_BARY = "8"
    MERCURY = "199"
    VENUS = "299"
    EARTH = "399"
    MARS = "499"
    JUPITER = "599"
    SATURN = "699"
    URANUS = "799"
    NEPTUNE = "899"


class StepUnit(StrEnum):
    DAY = "d"
    MONTH = "m"
    YEAR = "y"


def select_object_elements(
    *,
    selection: Selection,
    start: pdl.DateTime,
    stop: pdl.DateTime,
    step: int = 1,
    step_unit: StepUnit = StepUnit.YEAR,
    reference: Selection = Selection.SSB,
) -> pl.DataFrame:
    """
    targetname      official number, name, designation (string)
    datetime_jd     epoch Julian Date (float, JDTDB)
    datetime_str    epoch Date (str, Calendar Date (TDB))
    e               eccentricity (float, EC)
    q               periapsis distance (float, au, QR)
    incl            inclination (float, deg, IN)
    Omega           longitude of Asc. Node (float, deg, OM)
    w               argument of the perifocus (float, deg, W)
    Tp_jd           time of periapsis (float, Julian Date, Tp)
    n               mean motion (float, deg/d, N)
    M               mean anomaly (float, deg, MA)
    nu              true anomaly (float, deg, TA)
    a               semi-major axis (float, au, A)
    Q               apoapsis distance (float, au, AD)
    P               orbital period (float, (Earth) d, PR)

    If the target is a comet, the table will additionally include:

    H               absolute magnitude in V band (float, mag)
    G               photometric slope parameter (float)
    M1              comet total abs mag (float, mag, M1)
    M2              comet nuclear abs mag (float, mag, M2)
    k1              total mag scaling factor (float, k1)
    k2              nuclear mag scaling factor (float, k2)
    phasecoeff      comet phase coeff (float, mag/deg, PHCOFF)
    """
    obj = Horizons(
        id=selection,
        location=reference,
        epochs={
            "start": start.to_datetime_string(),
            "stop": stop.to_datetime_string(),
            "step": str(step) + str(step_unit),
        },
    )

    table = obj.elements()  # pyright: ignore[reportAttributeAccessIssue]
    elements = {key: value for key, value in table.items()}
    return pl.DataFrame(elements)


def main() -> None:
    selection = Selection.NEPTUNE
    start = pdl.DateTime(2000, 1, 1)
    stop = pdl.DateTime(2026, 1, 1)
    step = 1
    unit = StepUnit.YEAR

    dev.debug(
        {
            "selection": selection,
            "start": start.format("YYYYMMDD"),
            "stop": stop.format("YYYYMMDD"),
            "step": step,
            "unit": unit,
        }
    )

    df = select_object_elements(
        selection=selection,
        start=start,
        stop=stop,
        step=step,
        step_unit=unit,
    )

    print(df)

    file_name = f"{selection}_{start.format('YYYYMMDD')}_{stop.format('YYYYMMDD')}_{step}{unit}.json"
    df.write_json(Path(GAME_DATA_DIR, file_name))


if __name__ == "__main__":
    main()
