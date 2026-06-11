class_name Debug
extends Object

enum LogFormat {
    TRACE,
    DEBUG,
    INFO,
    WARN,
    ERROR,
    FATAL,
}

static func map_log_format(format: LogFormat, logstring: String) -> String:
    var default = "%s" % logstring

    match (format):
        LogFormat.TRACE:
            return "[color=#ccc]%s[color=#fff]" % logstring
        LogFormat.DEBUG:
            return "[color=YELLOW]%s[color=#fff]" % logstring
        LogFormat.INFO:
            return default
        LogFormat.WARN:
            return "[color=ORANGE]%s[color=#fff]" % logstring
        LogFormat.ERROR:
            return "[color=CRIMSON]%s[color=#fff]" % logstring
        LogFormat.FATAL:
            return "[color=RED]%s[color=#fff]" % logstring
        _:
            return default

static func debug(message: String) -> void:
    Debug.trace(message, LogFormat.DEBUG)

static func info(message: String) -> void:
    Debug.trace(message, LogFormat.INFO)

static func warn(message: String) -> void:
    Debug.trace(message, LogFormat.WARN)

static func error(message: String) -> void:
    Debug.trace(message, LogFormat.ERROR)

static func fatal(message: String) -> void:
    Debug.trace(message, LogFormat.FATAL)

static func trace(message: String, format: LogFormat = LogFormat.TRACE) -> void:
    var ts = timestamp()

    var stack = get_stack()
    var context = stack[1]
    if format != LogFormat.TRACE:
        context = stack[2]

    var source = context["source"].split("/")[-1]
    var function = context["function"]
    var line: int = context["line"]

    # var time_column = "%s" % ts
    # var context_content = "----%s:%s" % [source, line]
    # var context_column = "%-22s" % context_content
    # var msg = time_column + context_column + " | "
    var msg = "%s----%s:%s | %s | %s" % [ts, source, line, function, message]
    print_rich(map_log_format(format, msg))

static func timestamp() -> String:
    var ts = Time.get_ticks_msec()
    var hours = floor(float(ts) / 3600000)
    ts %= 3600000
    var minutes = floor(float(ts) / 60000)
    ts %= 60000
    var seconds = floor(float(ts) / 1000)
    var milliseconds = round(ts % 1000)
    return "%02d:%02d:%02d.%02d" % [hours, minutes, seconds, milliseconds]
