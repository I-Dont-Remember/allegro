# Module Overview

Thyme is a library to make working with dates & times a bit easier. Inspired by the many great options available in other languages, such as momentjs, arrow, pendulum, and many more.

## TIME_UNIT_OPTIONS / DURATION_UNIT_OPTIONS

In the current implementation, duration matches these except for `zoneId`. In the future, it may switch to duration using suffix `-s` as it sounds a little nicer.

```ballerina
[
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
```
