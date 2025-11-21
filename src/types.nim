
import tables

type
  LessonValidation* = proc(code: string, output: string, stderr: string, exitCode: int): bool

  Lesson* = object
    id*: string
    name*: string
    conceptText*: string
    task*: string
    solution*: string
    hint*: string
    filename*: string
    files*: Table[string, string]
    cmd*: string
    compilerArgs*: seq[string]
    skipRun*: bool
    validate*: LessonValidation

  Module* = object
    name*: string
    lessons*: seq[Lesson]

  RunResult* = ref object
    stdout*: string
    stderr*: string
    exitCode*: int
