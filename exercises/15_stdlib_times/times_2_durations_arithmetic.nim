# Description: Work with time durations and perform time arithmetic.
# Hint: `import times`. `Duration` objects can be created with helpers like `5.minutes`, `30.seconds`, `2.hours`.
# You can add or subtract Durations from DateTime objects.
# `initDuration(days=d, hours=h, minutes=m, seconds=s)` also creates Durations.
# SandboxPreference: wasm
# Points: 15

import times

# Task:
# 1. Create a fixed `DateTime` instance representing "2023-10-26 10:00:00".
# 2. Create a `Duration` of 2 hours and 30 minutes.
# 3. Add this duration to the fixed DateTime and print the resulting DateTime (formatted as "yyyy-MM-dd HH:mm:ss").
# 4. Create another `Duration` of 90 seconds.
# 5. Subtract this 90-second duration from the original fixed DateTime and print the result (same format).
# 6. Calculate the difference between the future time (from step 3) and past time (from step 5). Print this duration in seconds.

proc main() =
  # TODO: Step 1 - Create a fixed DateTime for 2023-10-26 10:00:00
  # let startTime = initDateTime(2023, mOct, 26, 10, 0, 0, 0, zonedTimezone())
  # echo "Start time: ", startTime.format("yyyy-MM-dd HH:mm:ss")
  var startTime: DateTime # Placeholder
  echo "Start time creation not implemented." # Placeholder

  # TODO: Step 2 - Create a Duration of 2 hours and 30 minutes
  # let duration1 = 2.hours + 30.minutes # Or initDuration(hours=2, minutes=30)
  var duration1: Duration # Placeholder
  echo "Duration1 creation not implemented." # Placeholder

  # TODO: Step 3 - Add duration1 to startTime and print
  # let futureTime = startTime + duration1
  # echo "Future time: ", futureTime.format("yyyy-MM-dd HH:mm:ss")
  var futureTime: DateTime # Placeholder
  echo "Future time calculation not implemented." # Placeholder

  # TODO: Step 4 - Create a Duration of 90 seconds
  # let duration2 = 90.seconds
  var duration2: Duration # Placeholder
  echo "Duration2 creation not implemented." # Placeholder

  # TODO: Step 5 - Subtract duration2 from startTime and print
  # let pastTime = startTime - duration2
  # echo "Past time: ", pastTime.format("yyyy-MM-dd HH:mm:ss")
  var pastTime: DateTime # Placeholder
  echo "Past time calculation not implemented." # Placeholder

  # TODO: Step 6 - Calculate difference between futureTime and pastTime
  # if futureTime != nil and pastTime != nil: # Check if they were calculated
  #   let diffDuration = futureTime - pastTime
  #   echo "Difference (future - past) in seconds: ", diffDuration.inSeconds
  echo "Difference calculation not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Start time: 2023-10-26 10:00:00
# Future time: 2023-10-26 12:30:00
# Past time: 2023-10-26 09:58:30
# Difference (future - past) in seconds: 9090
# ```
