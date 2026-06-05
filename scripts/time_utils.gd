class_name TimeUtils

const UNIX_SECONDS_PER_DAY = 86_400

## 400 years + 1
const GREGORIAN_CALENDAR_CYCLE_DAYS = 146_097

## 100 years
const DAYS_PER_ERA = 36_524

## 4 years
const DAYS_PER_QUADRENNIAL = 1_460

## 400 years
const DAYS_PER_CYCLE = DAYS_PER_ERA * 4

## Get a dictionary UTC representation of the current date and time
static func GetUTCDict() -> Dictionary:
    return Time.get_datetime_dict_from_system(true)

## Get a Unix epoch timestamp from a dictionary representing a date and time
static func DictToUnixTimestamp(datetime: Dictionary) -> int:
    return Time.get_unix_time_from_datetime_dict(datetime)

## Extract the time of day from the Unix epoch. Returns [hour, minute, second] format.
static func UnixTimeToUTC(timestamp: int) -> Array[int]:
    var seconds_left = timestamp % UNIX_SECONDS_PER_DAY
    var hour: int = floor(seconds_left / 3600.0)
    var minute: int = floor((seconds_left % 3600) / 60.0)
    var second: int = seconds_left % 60
    return [hour, minute, second]

## Extract the date from the Unix epoch. Returns [year, month, day] format.
static func UnixDateToUTC(timestamp: int) -> Array[int]:
    var days_since_1970 = floor(timestamp / float(UNIX_SECONDS_PER_DAY))

    # There are exactly 11,017 days between Jan 1, 1970 and Mar 1, 2000.
    # We'll use that as our starting point.
    var start = days_since_1970 - 11_017

    var era = floor(start / GREGORIAN_CALENDAR_CYCLE_DAYS)

    var day_of_era = int(start) % GREGORIAN_CALENDAR_CYCLE_DAYS
    if day_of_era < 0:
        day_of_era = day_of_era + GREGORIAN_CALENDAR_CYCLE_DAYS
        era -= 1

    var year_of_era = floor(
        (
            day_of_era
            - floor(day_of_era / DAYS_PER_QUADRENNIAL)  # subtract quadrennial days
            + floor(day_of_era / DAYS_PER_ERA)          # add era days
            - floor(day_of_era / DAYS_PER_CYCLE)        # subtract cycle days
        )
        / 365
    )

    var year = year_of_era + era * 400 + 2000

    var day_of_year = day_of_era - (
        365
        * year_of_era
        + floor(year_of_era / 4)
        - floor(year_of_era / 100)
    )

    var month_shifted = floor((5 * day_of_year + 2) / 153)
    var day = day_of_year - floor((153 * month_shifted + 2) / 5) + 1

    var month = 0

    if month_shifted < 10:
        month = month_shifted + 3
    else:
        month = month_shifted - 9
        year += 1

    return [year, month, day]


static func CompileUnixToUTCDict(timestamp: int) -> Dictionary:
    var date_part = UnixDateToUTC(timestamp)
    var time_part = UnixTimeToUTC(timestamp)
    return {
        "year": date_part[0],
        "month": date_part[1],
        "day": date_part[2],
        "hour": time_part[0],
        "minute": time_part[1],
        "second": time_part[2],
    }
