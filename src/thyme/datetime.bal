import ballerina/io;
import ballerina/lang.'float;
import ballerina/lang.'int;
import ballerina/math;
import ballerina/time;

# Properties used by the underlying time:Time lib
final string[] TIME_UNIT_OPTIONS = [
            "millisecond",
        "second",
        "minute",
        "hour",
        "day",
        "week",
        "month",
        "year",
        "zoneId"
];

# Properties used by the Duration object
# This used to be with suffix s because it sounds nice,
# but it makes it harder to share helper functions like toMillis
# if you have 'day' and 'days' have to be supported everywhere.
# Keeping it simple and forcing them to be same keys as time:Time
final string[] DURATION_UNIT_OPTIONS = [
        "millisecond",
        "second",
        "minute",
        "hour",
        "day",
        "week",
        "month",
        "year"
];

# Represents a mutable chunk of time without particular start or end.
# 
# + values - Stores the map of time unit:value
public type Duration object {
    map<int> values = {};
    int millisecond = 0;
    int second = 0;
    int minute = 0;
    int hour = 0;
    int day = 0;
    int week = 0;
    int month = 0;
    int year = 0;

    # Clone the current status of a `Duration`, since it's mutable.
    # 
    # Example:
    # ```
    # Duration d = someDuration.clone();
    # ```
    # 
    # + return - `Duration`
    public function clone() returns Duration {
        return self;
    }

    # Get the current value of a single unit type.
    # 
    # Example:
    # ```
    # int|error i = someDuration.get("hour");
    # ```
    # 
    # + unit - A valid unit from `DURATION_UNIT_OPTIONS`
    # + return - An `int`, or an `error` if unknown unit
    public function get(string unit) returns int|error {
        if (self.values.hasKey(unit)) {
            return self.values.get(unit);
        } else {
            return error(io:sprintf("unknown unit %s", unit));
        }
    }

    # Get total value of duration as an `int`.
    # 
    # Example:
    # ```
    # int|error i = someDuration.totalAsInt("minute");
    # ```
    # 
    # + unit - A valid unit from `DURATION_UNIT_OPTIONS`
    # + return - An `int`, or an `error` if unknown unit or conversions inside fail
    public function totalAsInt(string unit) returns int|error {
        // TODO: this name sucks, but can't use in or as except with stupid ' thing
        // is it safer to check from DURATION_UNIT_OPTIONS than keys()?
        if (self.values.hasKey(unit)) {
            int totalMillis = 0;
            // reduce could be cool here, using foreach loop instead cuz i couldn't figure out from docs how to do it
            foreach [string, int] pair in self.values.entries() {
                var [map_unit, value] = pair;
                totalMillis += check toMillis(map_unit, value);
            }
            return <int> fromMillis(unit, totalMillis);
        } else {
            return error(io:sprintf("unknown unit %s", unit));
        }
    }

    # Get total value of duration as a `float`.
    # 
    # Example:
    # ```
    # float|error f = someDuration.totalAsFloat("minute");
    # ```
    # 
    # + unit - A valid unit from `DURATION_UNIT_OPTIONS`
    # + return - A `float`, or an `error` if unknown unit or conversions inside fail
    public function totalAsFloat(string unit) returns float|error {
        // TODO: this name also sucks
        // is it safer to check from DURATION_UNIT_OPTIONS than keys()?
        if (self.values.hasKey(unit)) {
            int totalMillis = 0;
            // reduce could be cool here, using foreach loop instead cuz i couldn't figure out from docs how to do it
            foreach [string, int] pair in self.values.entries() {
                var [map_unit, value] = pair;
                totalMillis += check toMillis(map_unit, value);
            }
            return fromMillis(unit, totalMillis);
        } else {
            return error(io:sprintf("unknown unit %s", unit));
        }
    }
};

# **WIP** To be a wrapper around `time:Time` with simpler access to utility functions
# about that particular instance of time.
# 
# + time - The `time:Time` used internally.
public type Datetime object {    
// TODO: how do we want modification to handle changing the underlying Time object?
// store all properties & time object so we can use it's underlying methods
// IF we modify something, then we update our time attribute?
    public time:Time time = {time:0,zone:{id:""}};

    function __init() {}

    # Clone the current status of a `Datetime`, since it's mutable.
    # 
    # Example:
    # ```
    # Datetime d = someDatetime.clone();
    # ```
    # 
    # + return - `Datetime`
    public function clone() returns Datetime {
        return self;
    }
};

# Update existing keys in a map (given a list of the keys) from a different map's values.
# keys not in options will be ignored.
# 
# + options - Keys available in the map
# + orig_map - Original map as base
# + arg_map -  Map that could contain both valid and invalid keys
# + return - A `map<any>` to make this usable in many situations
function update_values(string[] options, map<any> orig_map, map<any> arg_map) returns map<any> {
// TODO: could be extended to combine options & orig_map, just do orig_map.keys() in here
    map<any> new_map  = {};
    foreach string option in options {
        if (arg_map.hasKey(option)) {
            new_map[option] = arg_map.get(option);
        } else if (orig_map.hasKey(option)) {
            new_map[option] = orig_map.get(option);
        }
    }
    return new_map;
}

# Create an int map using a list of valid keys and an unknown map of arguments.
# 
# + arg_map - Map that could contain both valid and invalid keys
# + return - A `map<int>`
function collect_int_values(string[] options, map<int> arg_map) returns map<int> {
    map<int> new_map  = {};
    foreach string option in options {
        if (arg_map.hasKey(option)) {
            new_map[option] = arg_map.get(option);
        } else {
            new_map[option] = 0;
        }
    }
    return new_map;
}

// #############################
// Public module functions follow
// ##############################

# Convert from a unit to milliseconds.
#
# Example:
# ```
# int|error millis = toMillis("year", 2.5);
# ```
#  
# + unit - A valid unit from `TIME_UNIT_OPTIONS`
# + value - An integer of the current unit's value
# + return - `int` if a valid unit, else an `error`
public function toMillis(string unit, int value) returns int|error {
    if (unit == "millisecond") {
        // cheeky then, aren't ya?
        return value;
    } 
    
    int second = value*1000;
    if (unit == "second") {
        return second;
    }

    int minute = 60*second;
    if (unit == "minute") {
        return minute;
    }
    
    int hour = 60*minute;
    if (unit == "hour") {
        return hour;
    }

    int day = 24*hour;
    if (unit == "day") {
        return day;
    }

    int week = 7*day;
    if (unit == "week") {
        return week;
    }

    // according to duckduckgo converter
    float month = 30.4375*day;
    if (unit == "month") {
        return <int> month;
    }

    // according to duckduckgo converter
    float year = 365.25*day;
    if (unit == "year") {
        return <int> year;
    }

    return error(io:sprintf("%s is an unknown unit to convert from", unit));
}

# Convert from milliseconds to a unit.
# 
# Example:
# ```
# float|error years = fromMillis("year", 5000000);
# ```
# 
# + unit - A valid unit from `TIME_UNIT_OPTIONS`
# + milliseconds - Current number of milliseconds
# + return - `float` if given a valid unit, else an `error`
public function fromMillis(string unit, int milliseconds) returns float|error {
    if (unit == "millisecond") {
        // cheeky then, aren't ya?
        return <float> milliseconds;
    } 
    
    float second = milliseconds/1000.0;
    if (unit == "second") {
        return second;
    }

    float minute = second/60;
    if (unit == "minute") {
        return minute;
    }
    
    float hour = minute/60;
    if (unit == "hour") {
        return hour;
    }

    float day = hour/24;
    if (unit == "day") {
        return day;
    }

    float week = day/7;
    if (unit == "week") {
        return week;
    }

    // according to duckduckgo converter
    float month = day/30.4375;
    if (unit == "month") {
        return month;
    }

    // according to duckduckgo converter
    float year = day/365.25;
    if (unit == "year") {
        return year;
    }

    return error(io:sprintf("%s is an unknown unit to convert from", unit));
}

# A simple wrapper to get a new Datetime object from `time:currentTime`.
# 
# + return - `Datetime`
public function now() returns Datetime {
    // TODO: implement
    time:Time now = time:currentTime();
    return new Datetime();
}

# Create `time:Time` from a unix timestamp.
# 
# Examples:
# ```ballerina
# time:Time t = fromTimestamp("1587869442");
# time:Time t = fromTimestamp("1587869442.345678");
# time:Time t = fromTimestamp(1587869442);
# time:Time t = fromTimestamp(1587869442.345678);
# ```
# 
# + timestamp - Unix timestamp of any flavor: `int`, `float`, 
#               or a string that parses to either `int` or `float`.
# + return - A `time:Time` with zone UTC
public function fromTimestamp(any timestamp) returns time:Time|error {
    // current understanding of timestamp:
    // seconds from unix epoch, if a decimal value those are the milliseconds
    // time:Time stores as milliseconds so have to convert
    // TODO: there is definitely a cleaner way to do this
    int milliseconds = 0;
    if (timestamp is string) {
        int tsInt = check 'int:fromString(timestamp);
        float tsFloat = check 'float:fromString(timestamp);
        if (<float>tsInt == tsFloat) {
            // float must be at .00 like an int
            milliseconds = tsInt*1000;
        } else {
            // float has decimal values
            milliseconds = <int> tsFloat*1000;
        }
    } else if (timestamp is float) {
        milliseconds = <int> timestamp*1000;
    } else if (timestamp is int) {
        milliseconds = timestamp*1000;
    } else {
        return error("Incompatible type of timestamp to parse");
    }

    time:Time newTime = {
        time: milliseconds,
        zone: {
            id: "UTC"
        }
    };

    return newTime;
}

# Find the difference between two `time:Time`.
# 
# Example:
# ```
# time:Time now = time:parse("09:40:00", "HH:mm:ss");
# time:Time before = time:parse("09:55:00", "HH:mm:ss");
# Duration d = difference(before, now);
# ```
# 
# + t1 - First `time:Time`
# + t2- Second `time:Time`
# + return - A `Duration` representing the difference in milliseconds, it cannot
#           be negative as a duration is a scalar, the user has to understand
#           the direction it goes in time.
public function difference(time:Time t1, time:Time t2) returns Duration {
    int millisecondsDiff = t2.time - t1.time;
    return duration({
        millisecond: math:absInt(millisecondsDiff)
    });
}

# Create a `Duration` from a map.
# 
# 
# Example:
# ```
# Duration d = duration({seconds: 5, minutes: 10});
# ```
# + args - Map of valid units from `TIME_UNIT_OPTIONS` and desired values.
#          A duration is a scalar, the user has to understand
#          the direction they want it to go in time, so negative values will be converted.
# + return - `Duration`
public function duration(map<int> args) returns Duration {
    map<int> values = collect_int_values(DURATION_UNIT_OPTIONS, args);

    //"Wow my chicken only took -5 minutes to cook!", we can't get time back from doing things,
    // absolute value to prevent negatives.
    foreach [string, int] pair in values.entries() {
        var [map_unit, value] = pair;
        values[map_unit] = math:absInt(value);
    }

    Duration newDuration = new Duration();

    newDuration.values = values;
    newDuration.millisecond = values.get("millisecond");
    newDuration.second = values.get("second");
    newDuration.minute = values.get("minute");
    newDuration.hour = values.get("hour");
    newDuration.day = values.get("day");
    newDuration.week = values.get("week");
    newDuration.month = values.get("month");
    newDuration.year = values.get("year");
    return newDuration;
}

# Easier version of `time:addDuration`.
# 
# Example:
# ```
# time:Time now = time:currentTime();
# Duration minuteRice = duration({minute: 1});
# time:Time doneCooking = add(now, minuteRice);
# ```
# 
# + originalTime - Base `time:Time` you would like to modify
# + d - `Duration`
# + return - A new `time:Time`
public function add(time:Time originalTime, Duration d) returns time:Time {
// time.add(duration), this could be nice taking string instead of just time
// TODO: don't force them to create duration, allow option for us to create inside for user
    return time:addDuration(
        originalTime,
        d.year,
        d.month,
        d.day,
        d.hour,
        d.minute,
        d.second,
        d.millisecond
    );
}

# Easier version of `time:subtractDuration`.
# 
# Example:
# ```
# time:Time now = time:currentTime();
# Duration aLongTimeAgo = duration({day: 5});
# time:Time whenIShouldHaveCleanedRoom = subtract(now, aLongTimeAgo);
# ```
# 
# + originalTime - Base `time:Time` you would like to modify
# + d - `Duration`
# + return - `time:Time`
public function subtract(time:Time originalTime, Duration d) returns time:Time {
    // TODO: don't force them to create duration, allow option for us to create inside for user
    return time:subtractDuration(
        originalTime,
        d.year,
        d.month,
        d.day,
        d.hour,
        d.minute,
        d.second,
        d.millisecond
    );
}

# Update a `time:Time` with a map of the fields to change.
# 
# Example:
# ```
# time:Time updated = setFromMap({
#   year: 2025,
#   hour: 15,
#   zoneId: "America/Indiana/Knox"
# });
# ```
# 
# + t - `time:Time` to modify
# + args - fields to be changed, ignores keys not in `TIME_UNIT_OPTIONS`
# + return - `time:Time` or `error` if `time` library fails
public function setFromMap(time:Time t, map<any> args) returns time:Time|error {
    map<any> currentValues = {
        year: time:getYear(t),
        month: time:getMonth(t),
        day: time:getDay(t),
        hour: time:getHour(t),
        minute: time:getMinute(t),
        second: time:getSecond(t),
        millisecond: time:getMilliSecond(t),
        zoneId: t.zone.id
    };

    map<any> u = update_values(TIME_UNIT_OPTIONS, currentValues, args);

    return time:createTime(
                <int> u["year"],
                <int> u["month"],
                <int> u["day"],
                <int> u["hour"],
                <int> u["minute"],
                <int> u["second"],
                <int> u["millisecond"],
                <string> u["zoneId"]);
}

# Update a `time:Time` attribute **Note:** Not a conversion, just directly changing attributes.
# Don't expect this function to handle converting everything if you change timezone.
# 
# Example:
# ```
# time:Time now = time:currentTime();
# time:Time updated = set(now, "zoneId", "America/Indiana/Knox");
# ```
# 
# + t - `time:Time` to modify
# + attr - Field to be changed, errors if not in TIME_UNIT_OPTIONS
# + value - Value to set the field to
# + return - `time:Time`
public function set(time:Time t, string attr, int value) returns time:Time|error {
    boolean isValid = false;
    TIME_UNIT_OPTIONS.forEach(function (string option) {
        if (attr == option) {
            isValid = true;
        }
    });

    if (!isValid) {
        return error(io:sprintf("%s is not a valid unit", attr));
    } else {
        map<any> args = {};
        args[attr] = value;
        return setFromMap(t, args);
    }
}

