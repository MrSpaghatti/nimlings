# Description: Learn to work with dates and times using the `times` module.
# Hint: `import times`. `getTime()` gets the current time as a `DateTime` object.
# `DateTime` objects have fields like `year`, `month`, `day`, `hour`, `minute`, `second`.
# `format(dt, "format_string")` formats a DateTime. E.g., "yyyy-MM-dd HH:mm:ss".
# SandboxPreference: wasm # Basic time operations are often supported by WASI.
# Points: 15

import times

# Task:
# 1. Get the current time (or use a fixed DateTime in testMode for predictability).
# 2. Print the current year, month, and day individually.
# 3. Format the current time (or fixed DateTime) into a string like "YYYY/MM/DD - HH:MM". Print it.
# 4. Format the current time (or fixed DateTime) into a string like "DayOfWeek, Month D, YYYY". Print it.
#    (e.g., "Monday, January 23, 2023") Hint: Format specifiers: `dddd` for DayOfWeek, `MMMM` for Month name.

proc main() =
  var now: DateTime
  when defined(testMode):
    # For predictable output in tests, use a fixed DateTime.
    # Let's use Jan 23, 2023, Monday, 14:30:00
    # weekday needs to be correct for DayOfWeek formatting. Monday is usually wdMon.
    # Months: mJan = 1 .. mDec = 12
    now = initDateTime(2023, mJan, 23, 14, 30, 0, 0, zonedTimezone()) # Timezone might affect some formatting
    # To be fully robust for DayOfWeek, ensure weekday is set if initDateTime doesn't do it reliably for all platforms.
    # However, format often derives it. For this exercise, assume initDateTime is sufficient.
  else:
    now = getTime()

  echo "Current DateTime (internal): ", now # For user to see, not part of ExpectedOutput usually

  # TODO: Task 2 - Print year, month, day
  # echo "Year: ", now.year
  # echo "Month: ", now.month
  # echo "Day: ", now.day
  echo "Year/Month/Day printing not implemented." # Placeholder

  # TODO: Task 3 - Format as "YYYY/MM/DD - HH:MM"
  # let format1 = now.format("yyyy/MM/dd - HH:mm")
  # echo "Formatted (1): ", format1
  echo "Format 1 not implemented." # Placeholder

  # TODO: Task 4 - Format as "DayOfWeek, Month D, YYYY"
  # let format2 = now.format("dddd, MMMM d, yyyy")
  # echo "Formatted (2): ", format2
  echo "Format 2 not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  echo "Running with current time. Output will vary."
  main()

# ExpectedOutput for testMode (based on fixed DateTime): ```
# Year: 2023
# Month: mJan
# Day: 23
# Formatted (1): 2023/01/23 - 14:30
# Formatted (2): Monday, January 23, 2023
# ```
