# Package

version       = "2.0.0"
author        = "Nimlings Team"
description   = "A purely Nim-based learning path for Nim"
license       = "MIT"
srcDir        = "src"
bin           = @["nimlings"]


# Dependencies

requires "nim >= 1.6.0"
requires "illwill >= 0.3.0"

# Tasks

task build_generator, "Builds the content generator tool":
  exec "nim c -o:tools/generator tools/generator.nim"

task generate_content, "Generates content.nim from lessons.json":
  build_generatorTask()
  exec "./tools/generator > src/content.nim"

before build:
  generate_contentTask()
