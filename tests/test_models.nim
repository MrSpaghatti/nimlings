
import unittest, sets, json
import models

suite "Models":

  test "Progress JSON round-trip":
    let s = toHashSet(["1.1", "1.2"])
    let jsonNode = newJArray()
    for item in s:
      jsonNode.add(newJString(item))

    let jsonStr = $jsonNode
    let parsed = parseJson(jsonStr)
    var res = initHashSet[string]()
    for item in parsed.getElems():
      res.incl(item.getStr())

    check "1.1" in res
    check "1.2" in res
    check res.len == 2


  test "updateStreak: first lesson ever":
    let daily = DailyRecord()
    let updated = updateStreak(daily, "2026-06-14")
    check updated.streak == 1
    check updated.longestStreak == 1
    check updated.lessonsToday == 1
    check updated.lastLessonDate == "2026-06-14"

  test "updateStreak: same day increments lessonsToday":
    let daily = DailyRecord(lastLessonDate: "2026-06-14", streak: 3, longestStreak: 5, lessonsToday: 1)
    let updated = updateStreak(daily, "2026-06-14")
    check updated.streak == 3
    check updated.longestStreak == 5
    check updated.lessonsToday == 2
    check updated.lastLessonDate == "2026-06-14"

  test "updateStreak: consecutive day extends streak":
    let daily = DailyRecord(lastLessonDate: "2026-06-13", streak: 3, longestStreak: 5, lessonsToday: 1)
    let updated = updateStreak(daily, "2026-06-14")
    check updated.streak == 4
    check updated.longestStreak == 5
    check updated.lessonsToday == 1
    check updated.lastLessonDate == "2026-06-14"

  test "updateStreak: consecutive day extends longestStreak":
    let daily = DailyRecord(lastLessonDate: "2026-06-13", streak: 5, longestStreak: 5, lessonsToday: 1)
    let updated = updateStreak(daily, "2026-06-14")
    check updated.streak == 6
    check updated.longestStreak == 6
    check updated.lessonsToday == 1
    check updated.lastLessonDate == "2026-06-14"

  test "updateStreak: gap > 1 day resets streak":
    let daily = DailyRecord(lastLessonDate: "2026-06-10", streak: 3, longestStreak: 10, lessonsToday: 1)
    let updated = updateStreak(daily, "2026-06-14")
    check updated.streak == 1
    check updated.longestStreak == 10  # unchanged
    check updated.lessonsToday == 1
    check updated.lastLessonDate == "2026-06-14"

  test "updateStreak: month boundary (Jan 31 → Feb 1)":
    let daily = DailyRecord(lastLessonDate: "2026-01-31", streak: 10, longestStreak: 10, lessonsToday: 1)
    let updated = updateStreak(daily, "2026-02-01")
    check updated.streak == 11
    check updated.longestStreak == 11
    check updated.lastLessonDate == "2026-02-01"

  test "updateStreak: month boundary (Feb 28 non-leap → Mar 1)":
    let daily = DailyRecord(lastLessonDate: "2025-02-28", streak: 5, longestStreak: 5, lessonsToday: 1)
    let updated = updateStreak(daily, "2025-03-01")
    check updated.streak == 6
    check updated.longestStreak == 6

  test "updateStreak: month boundary (Feb 29 leap → Mar 1)":
    let daily = DailyRecord(lastLessonDate: "2024-02-29", streak: 5, longestStreak: 5, lessonsToday: 1)
    let updated = updateStreak(daily, "2024-03-01")
    check updated.streak == 6
    check updated.longestStreak == 6

  test "updateStreak: year boundary (Dec 31 → Jan 1)":
    let daily = DailyRecord(lastLessonDate: "2025-12-31", streak: 30, longestStreak: 30, lessonsToday: 1)
    let updated = updateStreak(daily, "2026-01-01")
    check updated.streak == 31
    check updated.longestStreak == 31
    check updated.lastLessonDate == "2026-01-01"

  test "updateStreak: non-leap Feb 28 followed by Mar 1 (gap of 1 day)":
    let daily = DailyRecord(lastLessonDate: "2025-02-28", streak: 3, longestStreak: 3, lessonsToday: 1)
    let updated = updateStreak(daily, "2025-03-01")
    check updated.streak == 4
    check updated.longestStreak == 4

  test "updateStreak: past date does not increment":
    let daily = DailyRecord(lastLessonDate: "2026-06-15", streak: 5, longestStreak: 10, lessonsToday: 1)
    let updated = updateStreak(daily, "2026-06-14")
    # Past date: lastDate < todayDate is false, streak unchanged
    check updated.streak == 5
    check updated.longestStreak == 10
    check updated.lessonsToday == 1
    check updated.lastLessonDate == "2026-06-14"
