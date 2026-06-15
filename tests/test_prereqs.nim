import unittest, tables, sets, strutils
import types, content, engine

suite "Prerequisites":

  var byId = initTable[string, Lesson]()

  setup:
    ## Runs before each test: rebuild the byId lookup table.
    initLessons()
    byId.clear()
    for lv in levels:
      for ch in lv.chapters:
        for l in ch.lessons:
          byId[l.id] = l

  teardown:
    byId.clear()

  test "All lessons have prerequisites except root (1.1.1)":
    for lv in levels:
      for ch in lv.chapters:
        for l in ch.lessons:
          if l.id == "1.1.1":
            check l.prerequisites.len == 0
          else:
            check l.prerequisites.len > 0

  test "All prerequisite IDs reference existing lessons":
    var bad = 0
    for lv in levels:
      for ch in lv.chapters:
        for l in ch.lessons:
          for pre in l.prerequisites:
            if not byId.hasKey(pre):
              echo "  MISSING: ", pre, " (prereq of ", l.id, ")"
              bad += 1
    check bad == 0

  test "Prerequisite graph has no cycles":
    var visited = initHashSet[string]()
    var inStack = initHashSet[string]()

    proc hasCycle(node: string): bool =
      if node in inStack: return true
      if node in visited: return false
      visited.incl(node)
      inStack.incl(node)
      if byId.hasKey(node):
        for pre in byId[node].prerequisites:
          if hasCycle(pre): return true
      inStack.excl(node)
      return false

    for lid in byId.keys():
      check hasCycle(lid) == false

  test "Every lesson is reachable from root (1.1.1)":
    var reachable = initHashSet[string]()
    var stack: seq[string] = @["1.1.1"]
    while stack.len > 0:
      let current = stack.pop()
      if current in reachable: continue
      reachable.incl(current)
      for l in byId.values:
        if current in l.prerequisites:
          stack.add(l.id)

    for lid in byId.keys():
      check lid in reachable

  test "Level 1 is self-contained (no cross-level prereqs)":
    for lv in levels:
      if lv.id == 1:
        for ch in lv.chapters:
          for l in ch.lessons:
            for pre in l.prerequisites:
              check pre.startsWith("1.")

  test "Level gates: Level N intro requires Level N-1 boss":
    check "1.5.1" in byId["2.1.1"].prerequisites
    check "2.7.1" in byId["3.1.1"].prerequisites
    check "3.9.1" in byId["4.1.1"].prerequisites

  test "canSkip gatekeeping":
    var p = initHashSet[string]()

    # Nothing done — only 1.1.1 is accessible
    check canSkip("1.1.1", p) == true
    check canSkip("1.1.2", p) == false
    check canSkip("2.1.1", p) == false

    # Complete Level 1
    for lv in levels:
      if lv.id == 1:
        for ch in lv.chapters:
          for l in ch.lessons:
            p.incl(l.id)

    check canSkip("2.1.1", p) == true
    check canSkip("3.1.1", p) == false

    # Complete Level 2
    for lv in levels:
      if lv.id == 2:
        for ch in lv.chapters:
          for l in ch.lessons:
            p.incl(l.id)

    check canSkip("3.1.1", p) == true
