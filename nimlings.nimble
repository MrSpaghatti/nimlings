# Package

version       = "2.1.10"
author        = "Nimlings Team"
description   = "A purely Nim-based learning path for Nim"
license       = "MIT"
srcDir        = "src"
bin           = @["nimlings"]


# Dependencies

requires "nim >= 1.6.0"
requires "results"
requires "db_connector"

# Dev note: running `nimble install <pkg>` (any package, not just the ones
# above) from *this* directory has been observed to also build and register
# this repo itself as an installed package under ~/.nimble/pkgs2/, which then
# shadows the local `src/` sources on the next `nim c` and breaks the build
# with confusing duplicate-type errors. If that happens, `nimble uninstall
# nimlings` clears it. To avoid it, install dependencies from outside the
# repo root (or a scratch dir) rather than from here.

# Tasks

task generate_content, "Generates content.nim from lessons.json":
  # Run the generator script using the nim interpreter directly
  # This avoids compiling an intermediate binary and handles platform differences
  exec "nim c -r tools/generator.nim"

before build:
  generateContentTask()
