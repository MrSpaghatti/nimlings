
import tables

type
  LessonValidation* = proc(code: string, output: string, stderr: string, exitCode: int): bool

  DocLink* = object
    title*: string
    url*: string
    summary*: string
  Lesson* = object
    id*: string
    name*: string
    conceptText*: string
    task*: string
    solution*: string
    hint*: string
    filename*: string
    files*: Table[string, string]
    docs*: seq[DocLink]
    lessonType*: string
    cmd*: string
    compilerArgs*: seq[string]
    runArgs*: seq[string]
    skipRun*: bool
    difficulty*: string
    prerequisites*: seq[string]
    crossLanguageNotes*: string
    validate*: LessonValidation

  Chapter* = object
    id*: string
    name*: string
    lessons*: seq[Lesson]

  Level* = object
    id*: int
    name*: string
    chapters*: seq[Chapter]

  RunResult* = ref object
    stdout*: string
    stderr*: string   ## Note: always "" — poStdErrToStdOut merges into stdout
    exitCode*: int
