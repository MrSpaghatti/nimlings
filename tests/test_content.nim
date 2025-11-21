
import unittest
import types, content

suite "Content":
  setup:
    initLessons()

  test "Lessons Loaded":
    check modules.len > 0
    var count = 0
    for m in modules:
      count += m.lessons.len
    check count > 0
    echo "Total lessons: ", count

  test "Lesson Fields Integrity":
    for m in modules:
      for l in m.lessons:
        check l.id.len > 0
        check l.name.len > 0
        check l.filename.len > 0
        # Validate proc should be present
        check l.validate != nil
