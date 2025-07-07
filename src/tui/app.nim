# Nimlings TUI Application
# This module will manage the Text User Interface.

import illwill # Tentatively chosen TUI library

proc runTuiApp*() =
  echo "Attempting to initialize TUI..."
  if not illwill.initialize():
    stderr.writeLine "Failed to initialize illwill (TUI library)."
    quit(1)
  defer: illwill.terminate()

  # Clear screen
  illwill.clear()
  illwill.flush() # illwill requires explicit flushes/updates

  # Basic loop structure (conceptual for now)
  var running = true
  while running:
    # Draw basic layout (header, main, footer placeholders)
    let (w, h) = illwill.getTerminalSize()

    # Header
    illwill.setFgColor(Default, bright = true)
    illwill.writeAt(0, 0, "Nimlings TUI - Welcome!")
    illwill.setFgColor(Default) # Reset color

    # Footer
    illwill.writeAt(0, h-1, "Press 'q' to quit.")

    illwill.flush()

    # Event handling
    let event = illwill.pollEvent()
    if event.kind == EventKind.Key:
      case event.key
      of Key.Q, Key.q: # Quit on 'q'
        running = false
      else:
        discard # Ignore other keys for now
    elif event.kind == EventKind.Resize:
      illwill.clear() # Clear on resize to redraw cleanly

    # Small delay to prevent busy-looping if pollEvent is non-blocking or fast
    # illwill.pollEvent() is blocking by default, so this might not be strictly needed
    # but can be good if event polling behavior changes or for lower CPU.
    # However, for responsive UI, relying on pollEvent's blocking is better.
    # sleep(10)

  illwill.clear()
  illwill.flush()
  echo "TUI Exited."
