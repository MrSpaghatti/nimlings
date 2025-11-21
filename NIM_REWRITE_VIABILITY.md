# Viability Analysis: Rewriting Nimlings in Nim

## Executive Summary
Rewriting `nimlings` in Nim is **highly viable** and strongly recommended. It aligns with the project's pedagogical goal ("Dogfooding"), simplifies distribution (single binary), and proves the language's capability for CLI/TUI tools.

## Technical Feasibility

### 1. TUI Libraries
Python uses `curses`. Nim has several robust alternatives:
*   **illwill**: A popular, pure Nim TUI library. Very easy to use, cross-platform (supports Windows better than Python's curses).
*   **nim-ncurses**: Direct wrapper around ncurses. Good if we want to port the current logic 1:1.
*   **termui**: Higher-level, experimental.
*   **Recommendation**: **illwill**. It removes the dependency on system ncurses headers and is more "Nim-like".

### 2. Subprocess Management (Engine)
The current `src/engine.py` uses `subprocess`.
Nim's standard library `std/osproc` provides `execProcess`, `startProcess`, and `waitForExit`.
*   **Capability**: Fully equivalent.
*   **Benefit**: Nim's `osproc` is strongly typed and handles platform differences well.

### 3. JSON & Configuration
Python uses `json`.
Nim uses `std/json`.
*   **Capability**: Fully equivalent.
*   **Caveat**: Nim's JSON handling is more verbose (static typing) but safer. We would define `Lesson` types explicitly using `json.to(Lesson)`.

### 4. File I/O
Python uses `pathlib`.
Nim uses `std/os` and `std/paths` (in newer Nim versions).
*   **Capability**: Fully equivalent.

## Pros & Cons

### Pros
1.  **Pedagogical Value**: Users are learning Nim; the tool itself being written in Nim is a huge confidence booster and reference. "Read the source" becomes a valid lesson.
2.  **Performance**: Startup time and processing will be faster (though Python is acceptable for this scale).
3.  **Distribution**: A single compiled binary is easier to distribute than a Python script + `requirements.txt` + ensuring Python version compatibility.
4.  **Type Safety**: Refactoring the monolithic `lessons.py` will be safer with Nim's compiler checking types.

### Cons
1.  **Development Velocity**: Iterating on a compiled language is slightly slower than an interpreted script (compile-run cycle vs run).
2.  **Library Maturity**: Python's ecosystem is vast. Nim's is smaller. However, for a TUI + Exec tool, Nim has "batteries included".
3.  **Porting Effort**: It's a complete rewrite, not a refactor. Logic in `tui.py` (state management, drawing) needs to be translated.

## Roadmap for Rewrite

1.  **Define Data Models**: Create `src/models.nim` defining `Lesson`, `Module`, `Progress`.
2.  **Port Engine**: Create `src/engine.nim` using `osproc` to run `nim c -r ...`.
3.  **Port Content**: Move lessons to a JSON/YAML file (easier to load in Nim than a giant source file) or keep as a code module.
4.  **Build TUI**: Use `illwill` to recreate the UI.
    *   *Note*: `illwill` handles input differently (non-blocking polling), so the event loop will look different.
5.  **Test**: Use `testament` (Nim's testing tool) for the internal tests.

## Conclusion
**Go for it.** The benefits of a single-binary distribution and the educational value of having the tutor written in the target language outweigh the rewrite costs.
