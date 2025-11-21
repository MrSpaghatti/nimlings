# Comparison: Nim Rewrite vs Python Original

## Executive Summary
The codebase has undergone a complete transformation from a **Python-based prototype** to a **native Nim application**. This shift aligns the tool with its subject matter ("Dogfooding") and introduces significant architectural and functional improvements, particularly in workflow and performance.

## 1. Architecture & Language

| Feature | Python Version (Main) | Nim Version (Current) |
| :--- | :--- | :--- |
| **Language** | Python 3.8+ | Nim 1.6.14+ |
| **Dependencies** | `curses` (Unix only), standard lib | `illwill` (Cross-platform TUI), `std/osproc`, `std/threadpool` |
| **Distribution** | Script (`python nimlings.py`) | Native Binary (`./src/nimlings`) |
| **Type Safety** | Dynamic (with some hints) | Statically Typed |
| **Content Storage** | Hardcoded Python Dicts (`src/lessons.py`) | Generated Nim Code (`src/content.nim`) from JSON |

**Impact**: The Nim version is a single, self-contained binary. It is faster, type-safe, and serves as a reference implementation for learners.

## 2. Core Features

### Text Editor
*   **Python Version**: Included a custom, built-in Vim-like text editor written in Curses.
    *   *Pros*: Zero setup for user.
    *   *Cons*: Limited functionality, buggy, "reinventing the wheel", no syntax highlighting.
*   **Nim Version**: **Bring Your Own Editor (BYOE)**.
    *   *Pros*: Users use their preferred tools (VS Code, Vim, Neovim, etc.) with full features (LSP, highlighting).
    *   *Cons*: Requires minimal setup (`$EDITOR` env var).

### Execution Model
*   **Python Version**: **Synchronous/Blocking**.
    *   When you ran code, the UI froze until execution completed.
    *   Code was written to temporary files hidden from the user.
*   **Nim Version**: **Asynchronous/Watch Mode**.
    *   **Auto-Check**: The tool watches the file on disk. When you save in your external editor, it automatically runs checks.
    *   **Non-Blocking**: Compilation happens on a background thread (`spawn`), keeping the TUI responsive.
    *   **Persistence**: Files are scaffolded to a real `exercises/` directory, allowing users to inspect/keep their work.

## 3. Progress & Curriculum

*   **Curriculum**: Identical. All 25 modules and 50+ lessons have been ported 1:1.
*   **Progress Tracking**: Both versions track completed lesson IDs. The storage format is compatible (JSON), but the location/structure is handled by `src/models.nim` now.

## 4. Code Structure Changes

| Python File | Nim Equivalent | Role |
| :--- | :--- | :--- |
| `nimlings.py` | `src/nimlings.nim` | CLI Entry Point |
| `src/tui.py` | `src/tui.nim` | UI Logic (illwill vs curses) |
| `src/engine.py` | `src/engine.nim` | Compilation & Validation |
| `src/lessons.py` | `src/content.nim` | Lesson Data (Generated) |
| N/A | `tools/generate_content.py` | Dev tool to compile lessons |

## 5. User Experience Differences

*   **Old Flow**: Open App -> Navigate -> Internal Edit -> Press 'r' -> Wait -> Result.
*   **New Flow**: Open App -> Select Lesson -> Press 'e' (Opens VSCode/Vim) -> Edit & Save -> App automatically updates with result.

## Conclusion
The Nim rewrite is a more robust, professional-grade tool. By removing the internal editor and adding file watching, it fits better into a real developer's workflow while proving the capabilities of the Nim language itself.
