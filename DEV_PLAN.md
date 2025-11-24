# Nimlings Development Plan

## Branch Analysis

**Comparison:** `main` vs `origin/project-runner-1`

The `project-runner-1` branch introduces significant architectural changes to support multi-file project lessons, alongside new educational content.

### Key Differences
1.  **Engine Capabilities (`src/engine.nim`)**:
    *   **Project Mode**: Added support for `lessonType: "project"`. These lessons are executed via `nimble test` instead of `nim c -r`.
    *   **Dependency Checks**: Added runtime checks for `nim` and `nimble` binaries.
    *   **Output Handling**: Refactored `runWithTimeout` to read process output after termination/completion rather than incrementally, likely to avoid blocking issues on some platforms.

2.  **Data Structures (`src/types.nim`)**:
    *   Extended `Lesson` object to include `lessonType` field.

3.  **Tooling (`tools/generator.nim`)**:
    *   Updated the lesson code generator to parse and serialize the new `lessonType` field.

4.  **Content (`src/lessons.json`)**:
    *   **Module 26**: Macros II ("Writing Your Own Language") - Introduction to DSLs and typed macros.
    *   **Boss Fight 4**: The MiniTest Framework - A project-based lesson requiring the implementation of a testing framework (utilizes the new Project Mode).
    *   **Module 27**: Concurrency Deep Dive - Introduction to Channels.

## Development Plan

### Phase 1: Integration & Stabilization (Immediate)
*   **Merge**: Merge `origin/project-runner-1` into `main` to consolidate the project runner features and new lessons.
*   **Verification**:
    *   Test standard single-file lessons to ensure no regression in `runWithTimeout`.
    *   Test the new "Boss Fight 4" to verify `nimble test` execution flow.
    *   Verify concurrency lessons (Module 27) function correctly with the thread handling.
*   **Refinement**:
    *   Review the output capturing strategy in `engine.nim`. Reading only after process exit might hide output from processes that hang or crash without flushing buffers.

### Phase 2: JS Target Support
The codebase contains TODOs for a JavaScript runner (`cmd: "js"`).
*   **Goal**: Enable lessons that compile to JS and run via Node.js.
*   **Tasks**:
    *   Implement detection for `node` binary.
    *   Update `engine.nim` to handle the `js` command: Compile with `nim js`, then execute with `node`.

### Phase 3: UX & TUI Improvements
*   **Progress Tracking**: Persist user progress (completed lessons) locally.
*   **Interactive TUI**: Enhance the CLI to be more interactive (e.g., a menu to select lessons, distinct "success/fail" screens).
*   **Better Diffing**: Show a diff of expected vs. actual output for failed lessons.

## Brainstorming & Future Implementations

*   **Sandboxing**: Currently, code runs on the host system. For security and stability (especially with "rm -rf" or infinite loops in threads), consider containerization (Docker) or stricter process isolation if this evolves into a web service or public bot.
*   **Hint System 2.0**: Interactive "Reveal Hint" option instead of showing it automatically or statically.
*   **Content Expansion**:
    *   **Networking**: Async/Await, HTTP client/server.
    *   **FFI**: C bindings (might be hard to test safely).
    *   **Metaprogramming**: Deep dive into AST manipulation.
*   **Web Frontend**: Port the runner to a web assembly (Wasm) version of Nim to run entirely in the browser (Nim playground style).
