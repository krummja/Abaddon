from pathlib import Path

import requests
import devtools as dev


HERE = Path(__file__)
SCRIPT_DIR = HERE.parent


def main() -> None:
    URL = "https://ssd.jpl.nasa.gov/api/horizons_file.api"

    with open(Path(SCRIPT_DIR, "horizons_input.txt"), "r") as command_file:
        response = requests.post(
            URL,
            data={"format": "text"},
            files={"input": command_file},
        )
        dev.debug(vars(response))


if __name__ == "__main__":
    main()
