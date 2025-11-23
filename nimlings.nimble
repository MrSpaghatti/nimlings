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

task generate_content, "Generates content.nim from lessons.json":
  # Run the generator script using the nim interpreter directly
  # This avoids compiling an intermediate binary and handles platform differences
  exec "nim c -r tools/generator.nim"

before build:
  generateContentTask()
