
import unittest
import types, content

suite "Content":
  setup:
    initLessons()

  test "Lessons Loaded":
    check levels.len > 0
    var count = 0
    for lv in levels:
      for ch in lv.chapters:
        count += ch.lessons.len
    check count > 0
    echo "Total lessons: ", count

  test "Lesson Fields Integrity":
    for lv in levels:
      for ch in lv.chapters:
        for l in ch.lessons:
          check l.id.len > 0
          check l.name.len > 0
          check l.filename.len > 0
          # Validate proc should be present
          check l.validate != nil
          check l.conceptText.len > 0
          check l.task.len > 0
          # skip_run lessons (conceptual/intro) may omit solution and hint
          if not l.skipRun:
            check l.solution.len > 0
            check l.hint.len > 0
          check l.difficulty.len > 0
