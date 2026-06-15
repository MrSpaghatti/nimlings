import json, os, sets, times, strutils

type
  DailyRecord* = object
    lastLessonDate*: string   # YYYY-MM-DD
    streak*: int
    longestStreak*: int
    lessonsToday*: int

const
  ConfigDir = getHomeDir() / ".config" / "nimlings"
  ProgressFile = ConfigDir / "progress.json"
  DailyFile = ConfigDir / "daily.json"

proc ensureConfigDir*() =
  createDir(ConfigDir)

# ── Lesson Progress ─────────────────────────────────────────────────

proc loadProgress*(): HashSet[string] =
  result = initHashSet[string]()
  if not fileExists(ProgressFile):
    return
  try:
    let data = parseJson(readFile(ProgressFile))
    for item in data.getElems():
      result.incl(item.getStr())
  except:
    stderr.writeLine("[nimlings] Warning: Could not load progress file, starting fresh")

proc saveProgress*(completed: HashSet[string]) =
  ensureConfigDir()
  let jsonNode = newJArray()
  for item in completed:
    jsonNode.add(newJString(item))
  writeFile(ProgressFile, $jsonNode)

# ── Daily Streak ────────────────────────────────────────────────────

proc today*(): string =
  let now = now()
  result = $now.year & "-" & align($(now.month.ord), 2, '0') & "-" & align($(now.monthday), 2, '0')

proc loadDaily*(): DailyRecord =
  if not fileExists(DailyFile):
    return DailyRecord()
  try:
    let data = parseJson(readFile(DailyFile))
    result = DailyRecord(
      lastLessonDate: data{"lastLessonDate"}.getStr(""),
      streak: data{"streak"}.getInt(0),
      longestStreak: data{"longestStreak"}.getInt(0),
      lessonsToday: data{"lessonsToday"}.getInt(0)
    )
  except:
    stderr.writeLine("[nimlings] Warning: Could not load daily streak file, starting fresh")
    result = DailyRecord()

proc saveDaily*(record: DailyRecord) =
  ensureConfigDir()
  let jsonNode = %*{
    "lastLessonDate": record.lastLessonDate,
    "streak": record.streak,
    "longestStreak": record.longestStreak,
    "lessonsToday": record.lessonsToday
  }
  writeFile(DailyFile, $jsonNode)

proc updateStreak*(daily: DailyRecord, todayDate: string): DailyRecord =
  ## Pure function: compute updated streak given current record and today's date.
  ## Does not touch filesystem or system clock.
  result = daily

  if result.lastLessonDate == todayDate:
    # Already did a lesson today — just increment count
    result.lessonsToday += 1
  elif result.lastLessonDate == "":
    # First lesson ever
    result.streak = 1
    result.longestStreak = 1
    result.lessonsToday = 1
    result.lastLessonDate = todayDate
  else:
    # Check if yesterday or gap
    let lastDate = result.lastLessonDate
    if lastDate < todayDate:
      try:
        let last = lastDate.split("-")
        let parts = todayDate.split("-")
        let lastDay = parseInt(last[2])
        let lastMonth = parseInt(last[1])
        let lastYear = parseInt(last[0])
        let todayDay = parseInt(parts[2])
        let todayMonth = parseInt(parts[1])
        let todayYear = parseInt(parts[0])

        var isConsecutive = false
        if lastYear == todayYear and lastMonth == todayMonth and todayDay - lastDay == 1:
          isConsecutive = true
        elif lastYear == todayYear and lastMonth == todayMonth - 1:
          let daysInLastMonth = case lastMonth
            of 1, 3, 5, 7, 8, 10, 12: 31
            of 4, 6, 9, 11: 30
            of 2: (if lastYear mod 4 == 0 and (lastYear mod 100 != 0 or lastYear mod 400 == 0): 29 else: 28)
            else: 30
          if todayDay == 1 and lastDay == daysInLastMonth:
            isConsecutive = true
        elif lastYear == todayYear - 1 and lastMonth == 12 and todayMonth == 1 and lastDay == 31 and todayDay == 1:
          isConsecutive = true

        if isConsecutive:
          result.streak += 1
        else:
          result.streak = 1

        if result.streak > result.longestStreak:
          result.longestStreak = result.streak
      except:
        result.streak = 1

    result.lessonsToday = 1
    result.lastLessonDate = todayDate

proc recordLessonCompletion*() =
  ## Call this when a lesson is completed. Updates streak.
  let daily = loadDaily()
  let updated = updateStreak(daily, today())
  saveDaily(updated)


