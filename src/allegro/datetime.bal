import ballerina/io;
import ballerina/time;
import ballerina/lang.'int;
import ballerina/lang.'float;
# According to https://www.unixtimestamp.com/:
# "What happens on January 19, 2038? On this date the Unix Time Stamp will 
# cease to work due to a 32-bit overflow. Before this moment millions of 
# applications will need to either adopt a new convention for time stamps 
# or be migrated to 64-bit systems which will buy the time stamp 
# a "bit" more time. 

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

    function clone() returns Duration {
        return self;
    }


    function get(string unit) returns int|error {
        if (self.values.hasKey(unit)) {
            return self.values.get(unit);
        } else {
            return error(io:sprintf("unknown unit %s", unit));
        }
    }

    // TODO: this name sucks, but can't use in or as except with stupid ' thing
    // one func for returning whole values, one for floats
    function totalAsInt(string unit) returns int|error {
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

    // TODO: this name also sucks
    function totalAsFloat(string unit) returns float|error {
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

# TODO: how do we want modification to handle changing the underlying Time object?
# store all properties & time object so we can use it's underlying methods
# IF we modify something, then we update our time attribute?
public type Datetime object {    
    function __init() {}

    function clone() returns Datetime {
        return self;
    }
};

# update existing keys in a map (given a list of the keys) from a different map's values
# + return - map<any>
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

# create a map 
# + return - map<int>
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

########################
# Public module functions
########################

# desc
# + return - int|error
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

#
# + return - Datetime
public function now() returns Datetime {
    // TODO: implement
    time:Time now = time:currentTime();
    return new Datetime();
}

# Create time:Time() from a unix timestamp.
# 
# Example:
# ```ballerina
# time:Time t = fromTimestamp("1587869442")
# ```
# 
# + timestamp - a unix timestamp of any flavor (string, float, int)
# + return - a time:Time with zone UTC
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
        io:println(io:sprintf("float %f mlli %d", timestamp, milliseconds));
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

public function difference(time:Time t1, time:Time t2) returns Duration {
    // we don't need to put this reference, it's just subtraction lol
    // borrowed from https://stackoverflow.com/questions/52145669/subtracting-a-two-time-values-in-ballerina
    // TODO: what happens if this is negative?
    int millisecondsDiff = t2.time - t1.time;
    return duration({
        millisecond: millisecondsDiff
    });
}

# Need a duration object, should be able to pass a string instead
# duration({'seconds': 5, minutes: 10});
# + return - Duration
public function duration(map<int> args) returns Duration {
    map<int> values = collect_int_values(DURATION_UNIT_OPTIONS, args);
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

// TODO: don't force them to create duration, allow option for us to create inside for user
# cleaner version of addDuration
# time.add(duration), this could be nice taking string instead of just time
# + return - time:Time
public function add(time:Time originalTime, Duration d) returns time:Time {
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

// TODO: don't force them to create duration, allow option for us to create inside for user
# cleaner version of subtractDuration
# time.subtract(duration)
# + return - time:Time
public function subtract(time:Time originalTime, Duration d) returns time:Time {
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

# set but given a map
# + return - time:Time
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

    io:println(currentValues);
    map<any> u = update_values(TIME_UNIT_OPTIONS, currentValues, args);

    io:println(u);
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

# desc
# + return - time:Time
public function set(time:Time t, string attr, int value) returns time:Time|error {
    map<any> args = {};
    args[attr] = value;
    return setFromMap(t, args);
}


