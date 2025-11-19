import nimprof
proc slow() =
  for i in 1..100_000: discard
slow()
