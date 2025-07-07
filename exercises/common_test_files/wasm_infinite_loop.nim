# This program is designed to consume a lot of fuel in WASM.
# It runs a loop for a very large number of iterations.

proc main() =
  echo "Starting long loop..."
  var counter = 0
  # A very large number of iterations.
  # Adjust if it finishes too quickly or takes too long for fuel exhaustion.
  # For typical fuel limits (e.g., 10M-100M), this should be enough.
  # With a simple counter increment, 100_000_000 iterations might be needed.
  # Let's try a smaller number first for testing, then increase if needed.
  # This loop might not be "infinite" but should be long enough to hit a reasonable fuel limit.
  for i in 0 ..< 500_000_000: # 500 million iterations
    counter += 1
  echo "Loop finished. Counter: ", counter # Should not be reached if fuel runs out

main()
