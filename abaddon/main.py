import json
import re
import requests
import polars as pl
import devtools as dev
from pathlib import Path
from textwrap import dedent


HERE = Path(__file__)
SCRIPT_DIR = HERE.parent
ROOT_DIR = SCRIPT_DIR.parent


def query_astorbdb():
    query = dedent("""
    query MinorPlanets($limit: Int = 10) {
        minorplanet(limit: $limit) {
            ast_number
            designameByIdDesignationPrimary {
                str_designame
            }

            orbelements {
                a
                aphelion_dist
                e
                ecc_anomaly
                epoch
                id
                m
                node
                peri
                q
                r
                true_anomaly
                x
                y
                z
            }
        }
    }
    """)

    response = requests.post(
        url="https://astorbdb.lowell.edu/v1/graphql",
        json={
            "query": query,
            "variables": {
                "limit": 5,
            },
        },
    )

    if response.status_code == 200:
        dev.debug(response.json())
    else:
        dev.debug(response.reason)


def parse_physical_data() -> pl.DataFrame:
    """
    Parse data table from:
        https://www.johnstonsarchive.net/astro/solar_system_phys_data.html

    Uses header column withs for offsets, since the table is not formatted in a way that
    makes it easy to parse.
    """
    with open(Path(SCRIPT_DIR, "physical_data.txt"), "r") as datafile:
        lines = datafile.readlines()
        header = lines[0]

        rows = [ln for ln in lines[2:] if ln.strip() and not set(ln.strip()) == {"-"}]
        widths = []

        if result := re.finditer(r"(\s{2,})", header):
            spacings = [match.span() for match in result]
            last_start = 0
            for spacing in spacings:
                widths.append((last_start, spacing[1]))
                last_start = spacing[1]

        cols = [header[a:b].strip() for a, b in widths]
        for i, col in enumerate(cols):
            if col == "err" or col == "src":
                prior = cols[i - 1]
                new_name = f"{prior} {col}"
                cols[i] = new_name

        raw_data = []
        for row in rows:
            raw_data.append([row[a:b].strip() or None for a, b in widths])

        df = pl.DataFrame(raw_data, schema=cols)
        return df


def main():
    pass


if __name__ == "__main__":
    main()
