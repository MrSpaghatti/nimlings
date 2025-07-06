# Description: Learn basic asynchronous programming with `async` and `await`.
# Hint: `import std/asyncdispatch`. An `async proc` returns a `Future[T]`.
# Inside an `async proc`, `await` can be used on another `Future` to pause execution
# without blocking the thread, allowing other tasks to run.
# `waitFor` is used in a synchronous main context to run and wait for an async proc to complete.
# `asyncfutures.sleepAsync(milliseconds)` is an async version of sleep.
# SandboxPreference: native # Async I/O often interacts with system event loop.
# Points: 25

import std/asyncdispatch
import std/asyncfutures # For sleepAsync
import std/times

# Task:
# 1. Define an `async proc fetchData(url: string): string` that:
#    a. Prints "Fetching data from [url]..."
#    b. Simulates a network delay using `await sleepAsync(200)` (for 200 milliseconds).
#    c. Returns a string "Data from [url]".
# 2. Define an `async proc processFetchedData()` that will be our main async entry point:
#    a. Call `fetchData` for "url1" and `await` its result. Store it.
#    b. Call `fetchData` for "url2" and `await` its result. Store it.
#    c. Print both results.
# 3. In `main` (synchronous proc), call `waitFor(processFetchedData())`.

# TODO: Step 1 - Define async proc fetchData(url: string): string
# async proc fetchData(url: string): string =
#   echo "Fetching data from ", url, "..."
#   await sleepAsync(200) # Simulate network delay
#   return "Data from " & url

# TODO: Step 2 - Define async proc processFetchedData()
# async proc processFetchedData() =
#   let data1 = await fetchData("url1")
#   let data2 = await fetchData("url2")
#   echo "Received: ", data1
#   echo "Received: ", data2

proc main() =
  echo "Main: Starting async operations..."
  # TODO: Step 3 - Call waitFor(processFetchedData())
  # waitFor(processFetchedData())
  echo "Async operations setup not implemented." # Placeholder

  echo "Main: All async operations complete."


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Main: Starting async operations...
# Fetching data from url1...
# Fetching data from url2...
# Received: Data from url1
# Received: Data from url2
# Main: All async operations complete.
# ```
# Note: With true async operations and depending on the dispatcher, the "Fetching..." lines
# might interleave differently if `fetchData` calls were made without immediate await,
# e.g. `let future1 = fetchData(...)`, `let future2 = fetchData(...)`, then `await future1`, `await future2`.
# But with direct `await fetchData(...)` in sequence as suggested, the "Fetching..." messages
# should appear before their respective data is "received" and processed.
# The given sequential await in `processFetchedData` implies url1 finishes before url2 starts.
