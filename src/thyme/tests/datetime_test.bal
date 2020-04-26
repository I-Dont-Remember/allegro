import ballerina/io;
import ballerina/test;
import ballerina/math;
import ballerina/time;
import ballerina/lang.'int;
import ballerina/lang.'float;

final string SETUP_FAILED_MSG = "Failed setting up for test, error: %s";

// it seems silly we have to have a module global variable just to setup
// stuff for tests, there should be some sort of context to pass between
time:Time randomTime = {time: 0, zone:{id:""}};
Duration randomDuration = new;

function setRandomTime() {
    time:Time|error rand = getRandomTime();
    if (rand is error) {
        panic error("failed getting random time for test");
    } else {
        randomTime = rand;
    }
}

function setRandomDuration() {
    Duration|error d = getRandomDuration();
    if (d is error) {
        panic error("failed getting random duration for test");
    } else {
        randomDuration = d;
    }
}

function getRandomDuration() returns Duration|error {
    // random positive integers
    Duration d = new Duration();
    d.millisecond = check math:randomInRange(0, 2);
    // newDuration.seconds = unitOptions.get("seconds");
    // newDuration.minutes = unitOptions.get("minutes");
    // newDuration.hours = unitOptions.get("hours");
    // newDuration.days = unitOptions.get("days");
    // newDuration.weeks = unitOptions.get("weeks");
    // newDuration.months = unitOptions.get("months");
    // newDuration.years = nitOptions.get("years");u
    return d;
}

function getRandomTime() returns time:Time|error {
    // TODO: make this random so it's not a sucky tester
    string tz = "America/Indiana/Knox"; 
    time:Time timeCreated = check time:createTime(2017, 3, 28, 23, 42, 45,
        554, tz);
    return timeCreated;
}

# TODO: all these tests are probably low quality til we get a better direction
@test:Config {}
function testDurationGivenMap() {
    map<int> args = {
        millisecond: 8,
        second: 1,
        minute: 2,
        hour: 3,
        day: 4,
        week: 5,
        month: 6,
        year: 7
    };
    Duration d = duration(args);
    // TODO: super brittle, how can we fetch attribute by name with variable?
    test:assertEquals(d.second, args.get("second"), "second");
    test:assertEquals(d.minute, args.get("minute"), "minute");
    test:assertEquals(d.hour, args.get("hour"), "hour");
    test:assertEquals(d.day, args.get("day"), "day");
    test:assertEquals(d.week, args.get("week"), "week");
    test:assertEquals(d.month, args.get("month"), "month");
    test:assertEquals(d.year, args.get("year"), "year");
    //.. and so on
}

// @test:Config {}
// function testAdd() {
//     // random duration
//     Duration|error randomDuration = getRandomDuration();
//     time:Time|error randomTime = getRandomTime();
//     if (randomDuration is error || randomTime is error) {
//         panic error("failed getting random data for test");
//     }
// }

// @test:Config {}
// function testSubtract() {
//     // random duration
// }

function getRandomTimestamp(string format = "int") returns any|error {
    // Jan 1st, 3000 12am
    int max = 32503680000;
    int seconds = check math:randomInRange(0, max);
    float millisecond = math:random();
    float fullTimestamp = seconds + millisecond;

    if (format == "string") {
        // TODO: is there no function to get a regular string from int?
        // only found hex conversion so far
        return "32503680000";
    } else if (format == "float") {
        return fullTimestamp;
    } else {
        return seconds;
    }
}

@test:Config {}
function testFromTimestampStringInt() {
    // TODO: there seems like there's a much less messy way to do error handling for this
    // maybe in the beforetest fixture?
    any|error randomTs = getRandomTimestamp(format="string");
    // TODO: brittle test
    int|error value = 'int:fromString("32503680000");
    if (randomTs is string && value is int) {
        int millisecond = value*1000;
        time:Time|error t =  fromTimestamp(randomTs);
        if (t is error) {
            test:assertFail(io:sprintf(SETUP_FAILED_MSG, t.reason()));
        } else {
            test:assertEquals(t.time, millisecond, "millisecond should match");
        }
    } else if (randomTs is error) {
            test:assertFail(io:sprintf(SETUP_FAILED_MSG, randomTs.reason()));            
    } else if (value is error) {
            test:assertFail(io:sprintf(SETUP_FAILED_MSG, value.reason()));            
    }
}

@test:Config {}
function testFromTimestampStringFloat() {
    // TODO: there seems like there's a much less messy way to do error handling for this
    // maybe in the beforetest fixture?
    any|error randomTs = getRandomTimestamp(format="string");
    // TODO: brittle test
    float|error value = 'float:fromString("32503680000.12345");
    if (randomTs is string && value is float) {
        // even if float extends farther, those values get lost because they can't be captured in milliseconds for time:Time
        int millisecond = <int> value*1000;
        time:Time|error t =  fromTimestamp(randomTs);
        if (t is error) {
            test:assertFail(io:sprintf(SETUP_FAILED_MSG, t.reason()));
        } else {
            test:assertEquals(t.time, millisecond, "millisecond should match");
        }
    } else if (randomTs is error) {
            test:assertFail(io:sprintf(SETUP_FAILED_MSG, randomTs.reason()));            
    } else if (value is error) {
            test:assertFail(io:sprintf(SETUP_FAILED_MSG, value.reason()));            
    }
}

@test:Config {}
function testFromTimestampInt() {
    any|error randomTs = getRandomTimestamp(format="int");
    int millisecond = <int> randomTs*1000;
    if (randomTs is error) {
        test:assertFail(io:sprintf(SETUP_FAILED_MSG, randomTs.reason()));
    } else {
        time:Time|error t =  fromTimestamp(randomTs);
        if (t is error) {
            test:assertFail(io:sprintf(SETUP_FAILED_MSG, t.reason()));
        } else {
            test:assertEquals(t.time, millisecond, "millisecond should match");
        }
    }
}

@test:Config {}
function testFromTimestampFloat() {
    any|error randomTs = getRandomTimestamp(format="float");
    int millisecond = <int> randomTs*1000;
    if (randomTs is error) {
        test:assertFail(io:sprintf(SETUP_FAILED_MSG, randomTs.reason()));
    } else {
        time:Time|error t =  fromTimestamp(randomTs);
        if (t is error) {
            test:assertFail(io:sprintf(SETUP_FAILED_MSG, t.reason()));
        } else {
            test:assertEquals(t.time, millisecond, "millisecond should match");
        }
    }
}

@test:Config {
    before: "setRandomTime"
}
function testSet() { 
    string attr = "year";
    int value = 2050;
    time:Time|error updated = set(randomTime, attr, value);
    if (updated is error) {
        
    } else {
        int year = time:getYear(updated);
        test:assertEquals(year, value, "Year should be set to new value");
    }
}

@test:Config {
    before: "setRandomTime"
}
function testSetErrorsGivenInvalidKey() { 
    string attr = "i'm on a boat";
    int value = 2050;
    time:Time|error updated = set(randomTime, attr, value);
    test:assertTrue(updated is error, "should get error with invalid unit: " + attr);
}


@test:Config {
    before: "setRandomTime"
}
function testSetFromMap() {
    string attr = "year";
    int value = 2050;
    map<any> args = {
        year: 2050,
        zoneId: "America/Indiana/Vevay"
    };
    time:Time|error updated = setFromMap(randomTime, args);
    if (updated is error) {
        panic updated;
    } else {
        test:assertEquals(time:getYear(updated), args["year"], "Year should be set to new value");
        test:assertEquals(updated.zone.id, args["zoneId"], "Year should be set to new value");
    }
}

// stopgap, dataProvider is less useful if we can't pass tuples or any[]
function toMillisDataProvider() returns (string[][]) {
    // unit, value, expected
    return [
        ["millisecond", "1", "1"],
        ["second", "1", "1000"],
        ["minute", "1", "60000"],
        ["hour", "1", "3600000"],
        ["day", "1", "86400000"],
        ["week", "1", "604800000"],
        ["month", "1", "2629800000"],
        ["year", "1", "31557600000"]
    ];
}

@test:Config {
    dataProvider: "toMillisDataProvider"
}
function testToMillis(string unit, string valueStr, string expectedStr) {
    int|error value = 'int:fromString(valueStr);
    int|error expected = 'int:fromString(expectedStr);
    
    if (value is error || expected is error) {
        test:assertFail(io:sprintf("One of these failed: %s - %s", value, expected));
    } else {
        int|error answer = toMillis(unit, value);
        test:assertEquals(answer, expected, io:sprintf("unit failure - %s", unit));
    }
}

@test:Config{}
function testToMillisInvalidUnitReturnsError() {
    // TODO: brittle test
    string unit = "house";
    int value = 0;
    int|error answer = toMillis(unit, value);
    test:assertTrue(answer is error, "should get error with invalid unit: " + unit);
}

function fromMillisDataProvider() returns (string[][]) {
    // unit, millisecond, expected
    return [
        ["millisecond", "1", "1"]
        // ["second", "1", "1000"],
        // ["minute", "1", "60000"],
        // ["hour", "1", "3600000"],
        // ["day", "1", "86400000"],
        // ["week", "1", "604800000"],
        // ["month", "1", "2629800000"],
        // ["year", "1", "31557600000"]
    ];
}

@test:Config {
    dataProvider: "fromMillisDataProvider"
}
function testFromMillis(string unit, string msStr, string expectedStr) {
    int|error millisecond = 'int:fromString(msStr);
    float|error expected = 'float:fromString(expectedStr);
    
    if (millisecond is error) {
        test:assertFail(io:sprintf(SETUP_FAILED_MSG, millisecond.reason()));        
    } else if (expected is error) {
        test:assertFail(io:sprintf(SETUP_FAILED_MSG,expected.reason()));
    } else {
        float|error answer = fromMillis(unit, millisecond);
        test:assertEquals(answer, expected, io:sprintf("unit failure - %s", unit));
    }
}


@test:Config{}
function testFromMillisInvalidUnitReturnsError() {
    // TODO: brittle test
    string unit = "House";
    int millisecond = 0;
    float|error answer = fromMillis(unit, millisecond);
    test:assertTrue(answer is error, "should get error with invalid unit: " + unit);
}

function totalAsIntDataProvider() returns (string[][]) {
    // unit, expected
    return [
        ["millisecond", "34882261001"], // 34882261001
        ["second", "34882261"], // 34882261.001
        ["minute", "581371"], // 581371.01668
        ["hour", "9690"], // 9689.5169447
        ["day", "404"], // 403.7298726956
        ["week", "58"], // 57.6756961
        ["month", "13"], // 13.264225797
        ["year",  "1"] // 1.1053521498
    ];
}

@test:Config{
    // before: "setRandomDuration",
    dataProvider: "totalAsIntDataProvider" 
}
function testTotalAsIntSimple(string unit, string expectedStr) {
    // TODO: brittle test
    // don't do random duration for now as it's hard to make a good test, need thought
    Duration simpleDuration = duration({
        millisecond: 1,
        second: 1,
        minute: 1,
        hour: 1,
        day: 1,
        week: 1,
        month: 1,
        year: 1
    });
    int|error expected = 'int:fromString(expectedStr);
    int|error answer = simpleDuration.totalAsInt(unit);
    test:assertEquals(answer, expected, io:sprintf("unit failure - %s", unit));
}

@test:Config{
    before: "setRandomDuration"
}
function testTotalAsIntInvalidUnitReturnsError() {
    // TODO: brittle test
    string unit = "House";
    int|error answer = randomDuration.totalAsInt(unit);
    test:assertTrue(answer is error, "should get error with invalid unit: " + unit);
}

// TODO: lotta stuff here, could this be trimed down and combined with Int version?
function totalAsFloatDataProvider() returns (string[][]) {
    // unit, expected
    return [
        ["millisecond", "34882261001"],
        ["second", "34882261.001"],
        ["minute", "581371.0166833333"],
        ["hour", "9689.516944722222"],
        ["day", "403.72987269675923"],
        ["week", "57.675696099537035"],
        ["month", "13.264225797018783"],
        ["year",  "1.1053521497515653"]
    ];
}

@test:Config{
    // before: "setRandomDuration",
    dataProvider: "totalAsFloatDataProvider" 
}
function testTotalAsFloatSimple(string unit, string expectedStr) {
    // TODO: brittle test
    // don't do random duration for now as it's hard to make a good test, need thought
    Duration simpleDuration = duration({
        millisecond: 1,
        second: 1,
        minute: 1,
        hour: 1,
        day: 1,
        week: 1,
        month: 1,
        year: 1
    });
    float|error expected = 'float:fromString(expectedStr);
    float|error answer = simpleDuration.totalAsFloat(unit);
    test:assertEquals(answer, expected, io:sprintf("unit failure - %s", unit));
}

@test:Config{
    before: "setRandomDuration"
}
function testTotalAsFloatInvalidUnitReturnsError() {
    // TODO: brittle test
    string unit = "House";
    float|error answer = randomDuration.totalAsFloat(unit);
    test:assertTrue(answer is error, "should get error with invalid unit: " + unit);
}