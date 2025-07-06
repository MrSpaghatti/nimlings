# Description: Learn basic concurrency using `spawn` to run procedures in parallel threads.
# Hint: `import std/threadpool`. `spawn myProc(arg1, arg2)` executes `myProc` in a separate thread
# from a thread pool. The main thread continues.
# Use `sync()` from `threadpool` (or `waitFor` on the FlowVar returned by `spawn`) to wait for spawned tasks to complete.
# Output order from concurrent tasks is often non-deterministic.
# SandboxPreference: native # Threads are OS-level features.
# Points: 25

import std/threadpool
import std/times # For sleep

# Task:
# 1. Define a procedure `printWithDelay(id: string, delayMillis: int)` that:
#    a. Prints "Task [id]: Starting..."
#    b. Sleeps for `delayMillis` milliseconds (e.g., `times.sleep(delayMillis)`).
#    c. Prints "Task [id]: Finished."
# 2. In `main`:
#    a. Spawn `printWithDelay` three times with different IDs and delays:
#       - Task "A", 300ms
#       - Task "B", 100ms
#       - Task "C", 200ms
#    b. Use `sync()` to wait for all spawned tasks to complete before `main` exits.
#    c. Print "All tasks synchronized." after `sync()`.

# TODO: Step 1 - Define printWithDelay procedure.
# proc printWithDelay(id: string, delayMillis: int) =
#   echo "Task ", id, ": Starting..."
#   sleep(delayMillis)
#   echo "Task ", id, ": Finished."

proc main() =
  echo "Main: Spawning tasks..."

  # TODO: Step 2a - Spawn printWithDelay three times.
  # discard spawn printWithDelay("A", 300) # discard FlowVar if not used for individual waitFor
  # discard spawn printWithDelay("B", 100)
  # discard spawn printWithDelay("C", 200)
  echo "Task spawning not implemented." # Placeholder

  # TODO: Step 2b - Wait for tasks to complete.
  # sync()
  echo "Synchronization (sync) not implemented." # Placeholder

  # TODO: Step 2c - Print completion message.
  echo "All tasks synchronized." # This should print after sync() and after tasks finish.


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Main: Spawning tasks...
# Task B: Starting...
# Task C: Starting...
# Task A: Starting...
# Task B: Finished.
# Task C: Finished.
# Task A: Finished.
# All tasks synchronized.
# ```
# Note: The order of "Starting..." and "Finished..." lines for A, B, C can vary due to concurrency.
# The ExpectedOutput shows one possible valid interleaving. A ValidationScript would be needed
# to robustly check for the presence of all required lines regardless of their exact order for "Starting"
# and "Finished" blocks, but ensuring "All tasks synchronized" is last.
# For this exercise, we'll rely on a common observed order for ExpectedOutput for simplicity.
# The critical part is that all start, all finish, and sync is last.
