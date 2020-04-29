# Thyme

Thyme aims to work in harmony with the stdlib `time` module while enhancing the experience for
developers, so they can concentrate on building their widget.  Inspired by the great options available in other languages; such as Momentjs, Arrow, Pendulum, and others.

Documentation: [i-dont-remember.github.io/thyme/](https://i-dont-remember.github.io/thyme/).

**Note**: _Until it has reached version 1.0, there will be breaking changes as I figure out improvements and what direction to take it. If you are interested in using the module and worried about things breaking, please reach out so I know and can adjust, otherwise I will rampage through this codebase with no regard._

## Usage

See examples provided in the docs linked above.

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

## Contributions

Issues and PRs are more than welcome! Feel free to reach out if you have any questions.

## Misc

A neat piece of time info, according to [unixtimestamp.com](https://www.unixtimestamp.com/):
>What happens on January 19, 2038? On this date the Unix Time Stamp will
>cease to work due to a 32-bit overflow. Before this moment millions of
>applications will need to either adopt a new convention for time stamps
>or be migrated to 64-bit systems which will buy the time stamp a "bit" more time.
