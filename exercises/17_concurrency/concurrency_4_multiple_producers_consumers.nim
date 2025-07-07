# Description: Explore using channels with multiple producer and multiple consumer threads.
# Hint: `import std/channels`, `import std/threadpool`.
# Multiple producers can `send` to the same channel. Multiple consumers can `recv` from it.
# The channel handles synchronization for sending/receiving.
# Closing the channel is important: typically done by the main thread after all producers have finished,
# or by a coordinating mechanism if producers can finish at different times.
# Consumers' `for msg in ch:` loops will terminate when the channel is closed and empty.
# SandboxPreference: native
# Points: 30

import std/channels
import std/threadpool
import std/times
import std/strutils # For $ and format
import std/os # for cpuCount for dynamic number of consumers

# Task:
# 1. Define a `producer` proc that takes a `Channel[string]`, an `id: int`, and `numMessages: int`.
#    It should send `numMessages` like "P[id]-Msg[j]" to the channel, with a small random delay
#    (e.g., 10-50ms) between sends. Print when it starts and finishes sending.
# 2. Define a `consumer` proc that takes a `Channel[string]` and an `id: int`.
#    It should loop, receiving messages using `for msg in ch:`.
#    For each message, print "C[id] got: [message]" with a small random processing delay (e.g., 20-100ms).
#    Print when it starts and finishes processing all messages from the channel.
# 3. In `main`:
#    a. Create a `Channel[string]`. (Consider if it should be buffered: `newChannel(bufferSize)`). For this, unbuffered is fine.
#    b. Spawn 2 `producer` threads (e.g., P1 sends 3 messages, P2 sends 2 messages). Store their `FlowVar`s.
#    c. Spawn (e.g.) `max(2, cpuCount())` `consumer` threads.
#    d. Wait for both producers to complete using their `FlowVar`s (`^producer1FlowVar`, `^producer2FlowVar`).
#    e. After all producers are done, `close` the channel.
#    f. `sync()` to wait for all consumer threads to finish processing remaining messages and terminate.
#    g. Print "Main: All producers and consumers finished."

# TODO: Step 1 - Define producer proc.
# proc producer(ch: Channel[string], id: int, numMessages: int) = ...

# TODO: Step 2 - Define consumer proc.
# proc consumer(ch: Channel[string], id: int) = ...

proc main() =
  echo "Main: Initializing..."
  # TODO: Step 3a - Create channel
  # var workChannel = newChannel[string]()
  echo "Channel creation not implemented." # Placeholder

  let numProducers = 2
  let numConsumers = max(2, cpuCount()) # At least 2 consumers
  echo fmt"Main: Spawning {numProducers} producers and {numConsumers} consumers."

  # TODO: Step 3b - Spawn producers and store FlowVars
  # var producerFlowVars: seq[FlowVar[void]]
  # producerFlowVars.add(spawn producer(workChannel, 1, 3))
  # producerFlowVars.add(spawn producer(workChannel, 2, 2))
  echo "Producer spawning not implemented." # Placeholder

  # TODO: Step 3c - Spawn consumers
  # for i in 1..numConsumers:
  #   discard spawn consumer(workChannel, i)
  echo "Consumer spawning not implemented." # Placeholder

  # TODO: Step 3d - Wait for all producers
  # for fv in producerFlowVars:
  #   ^fv
  # echo "Main: All producers have finished sending."
  echo "Waiting for producers not implemented." # Placeholder

  # TODO: Step 3e - Close channel
  # workChannel.close()
  # echo "Main: Work channel closed."
  echo "Channel closing not implemented." # Placeholder

  # TODO: Step 3f - sync() for consumers
  # sync()
  echo "Sync for consumers not implemented." # Placeholder

  # TODO: Step 3g - Print completion.
  echo "Main: All producers and consumers finished."


# Do not modify the lines below; they are for testing.
when defined(testMode):
  # In test mode, reduce delays for faster execution if possible,
  # but the core logic should be the same. Random delays make exact output order impossible.
  # The test will rely on a ValidationScript or very flexible ExpectedOutput.
  # For now, ExpectedOutput will show one possible valid output structure.
  # We need to ensure all messages are accounted for.
  main()
else:
  main()

# ExpectedOutput: ```
# Main: Initializing...
# Main: Spawning 2 producers and [N_CPU_OR_2] consumers.
# P1: Starting, will send 3 messages.
# P2: Starting, will send 2 messages.
# C1: Starting to consume.
# C2: Starting to consume.
# (Potentially C3, C4... starting)
# (Interleaved messages from P1, P2 sending and C1, C2... receiving)
# Example:
# P1: Sent P1-Msg1
# C1: got: P1-Msg1
# P2: Sent P2-Msg1
# C2: got: P2-Msg1
# P1: Sent P1-Msg2
# ... etc. ...
# P1: Finished sending.
# P2: Finished sending.
# Main: All producers have finished sending.
# Main: Work channel closed.
# C1: Finished processing.
# C2: Finished processing.
# (Potentially C3, C4... finishing)
# Main: All producers and consumers finished.
# ```
# This output is HIGHLY variable. A ValidationScript is essential.
# The script would count:
# - Correct number of "PX: Starting..." and "PX: Finished sending." (2 each)
# - Correct number of "CX: Starting..." and "CX: Finished processing." (numConsumers each)
# - Total 5 "PX-MsgY" messages being received by consumers (P1 sends 3, P2 sends 2).
# - Correct "Main: ..." messages in rough order.
#
# For this exercise, we will use a ValidationScript.
# ValidationScript: validate_concurrency_4.nims
