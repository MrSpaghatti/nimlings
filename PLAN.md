# Plan: Curriculum Expansion — 60 New Lessons

## Goal

Expand the nimlings curriculum from 255 to 315 lessons by:
- **A)** Filling verified stdlib/ecosystem gaps in Levels 2–4 (14 lessons, 5 chapters)
- **B)** Adding a new Level 5: "Mastery" (46 lessons, 11 chapters)

All new lessons must be one-shot compile+run testable. No async servers, SDL2, or arch-specific code that can't run on Linux.

## Approach

**Pipeline-driven generation.** Existing fleet pipeline: planner (Gemini 2.5 Flash) → smith (Qwen3.6-27B local) → validate → fix → inject.

Phase order: write final topic JSON → generate → audit → verify.

---

## Dedup Audit

The initial topic list was cross-referenced against all 255 existing lessons. The following topics were dropped because they are already covered:

| Dropped Topic | Reason |
|--------------|--------|
| Tables deep-dive | 2.9.2 Tables |
| Hash Sets | 2.9.1 Sets |
| CRITBIT Trees | 2.9.4 CRITBIT Trees |
| Shared Tables | 2.9.5 Shared Tables |
| MEMFILES | 4.13.4 Memory-Mapped Files |
| TCP Sockets | 4.10.1 TCP Sockets |
| HTTP Client | 4.10.2 HTTP Client in Depth |
| HTML Parsing | 3.11.4 XML & HTML Parsing |
| Option Type | 1.4.5 Option Type |
| Channels | 2.5.3 Channels |
| Threadpool | 2.5.1-2.5.4 Spawn+FlowVar |
| Atomics | 2.5.7 Atomic Operations |
| Locks | 2.5.6 Thread Safety & Locks |
| Benchmarking | 4.6.1 Benchmarking |
| Profiling | 4.6.2 Profiling |
| inline Pragmas | 4.6.3 inline Pragmas |
| Memory Layout | 4.6.5 Memory Layout Optimizations |
| Nimble Structure | 4.5.1 Nimble Structure |
| nim doc | 4.12.7 nim doc |
| Conditional Compilation | 4.3.2 Target OS Detection |
| Cross-Compilation | 4.3.1/4.3.4 Cross-Compile |

---

## Part A: Fill Ecosystem Gaps (~13 lessons)

### 2.14: Collections Extras (2 lessons) — after 2.13 Type System Depth
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 2.14.1 | Integer Sets (`std/intsets`) | `IntSet`, bit-vector performance, `incl`, `excl`, `contains` |
| 2 | 2.14.2 | Heap Queues (`std/heapqueue`) | `push`, `pop`, priority ordering, `HeapQueue[T]` |

### 3.16: Streams & IO (3 lessons) — after 3.15 Memory Management Models
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 3.16.1 | Streams Module (`std/streams`) | `StringStream`, `FileStream`, `readData`, `writeData`, `setPosition` |
| 2 | 3.16.2 | Temporary Files (`std/tempfiles`) | `createTempFile`, auto-cleanup patterns |
| 3 | 3.16.3 | OS Pipes & Process I/O (`std/osproc`) | `startProcess`, `inputStream`, `outputStream`, `execProcess` |

### 3.17: Parsing & Formats (2 lessons) — after 3.16
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 3.17.1 | CSV Parsing (`std/parsecsv`) | `open`, `readRow`, `close`, custom delimiters, header row |
| 2 | 3.17.2 | SQL Parsing (`std/parsesql`) | Tokenize/parse SQL, extract table names, query types |

### 3.18: Stdlib Utilities (4 lessons) — after 3.17
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 3.18.1 | Monotimes (`std/monotimes`) | `getMonoTime`, `ticks`, `inNanoseconds`, `-` operator |
| 2 | 3.18.2 | Terminal Colors (`std/terminal`) | `styledWriteLine`, `fgColor`, `bgColor`, `resetAttributes` |
| 3 | 3.18.3 | Edit Distance (`std/editdistance`) | `editDistance`, `editDistanceAscii` |
| 4 | 3.18.4 | Word Wrap (`std/wordwrap`) | `wrapWords`, `indent`, alignment |

### 4.21: Networking Extras (3 lessons) — after 4.18 Nim Design Patterns
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 4.21.1 | Select & Poll (`std/selectors`) | `Selector`, `registerHandle`, `select`, non-blocking I/O |
| 2 | 4.21.2 | Cookies (`std/cookies`) | `parseCookies`, `setCookie`, `getCookie`, `Cookie` type |
| 3 | 4.21.3 | SMTP (`std/smtp`) | `sendMail`, `createMessage`, attachments |

---

## Part B: Level 5 — "Mastery" (~42 lessons)

### 5.1: HTTP & Web Services (6 lessons)
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 5.1.1 | Async HTTP Client | `newAsyncHttpClient`, `get`, `post`, error handling, timeouts |
| 2 | 5.1.2 | URL Encoding (`std/uri`) | `encodeUrl`, `decodeUrl`, `parseUri`, query construction |
| 3 | 5.1.3 | JSON REST Client | Typed GET/POST with `json` + `httpclient`, parse responses |
| 4 | 5.1.4 | Simple HTTP Server | `asynchttpserver` one-shot handler, respond, exit |
| 5 | 5.1.5 | Middleware Pattern | Chainable request processors, logging, auth middleware |
| 6 | 5.1.6 | REST API Client Library | Build a typed HTTP client wrapper with error handling |

### 5.2: Database & SQL (5 lessons)
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 5.2.1 | SQLite Basics (`db_sqlite`) | `open`, `exec`, CREATE TABLE, INSERT, SELECT |
| 2 | 5.2.2 | SQLite Queries & Iteration | `getValue`, `getRow`, `getAllRows`, `fastRows` iterator |
| 3 | 5.2.3 | Prepared Statements | `prepare`, bind params, SQL injection prevention |
| 4 | 5.2.4 | Migration Runner | Versioned schema migrations, `user_version` pragma |
| 5 | 5.2.5 | Object-Relational Mapping | Objects ↔ Rows, `db_common`, type conversion helpers |

### 5.3: Advanced Concurrency (3 lessons)
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 5.3.1 | Weave — Parallel For | `parallelFor`, `init(Weave)`, `exit(Weave)`, thread-safe |
| 2 | 5.3.2 | Malebolgia — Task Dataflow | `spawn`, `awaitAll`, dataflow graphs |
| 3 | 5.3.3 | Race Detection | `--threadAnalysis:on`, `{.thread.}`, `{.gcsafe.}`, debugging |

### 5.4: Performance Deep-Dive (3 lessons)
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 5.4.1 | LTO & Link-Time Optimization | `-d:lto`, `--passC:-flto`, dead code elimination |
| 2 | 5.4.2 | Compile-Time Computation | `static[int]`, `when`, `const`, shifting work to CT |
| 3 | 5.4.3 | SIMD (`std/simd`) | `simdSum`, `simdMin`, `simdMax`, 128/256-bit vectors |

### 5.5: Library Design (3 lessons)
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 5.5.1 | API Design Principles | Naming conventions, parameter order, default values |
| 2 | 5.5.2 | Semver & Breaking Changes | Semantic versioning, deprecation pragmas, migration guides |
| 3 | 5.5.3 | Publishing Workflow | `nimble publish`, git tags, changelog, README conventions |

### 5.6: Scientific Nim (5 lessons)
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 5.6.1 | Arraymancer Basics | Tensors, indexing, `zeros`, `ones`, `randomTensor` |
| 2 | 5.6.2 | Linear Algebra | Matrix multiply, eigenvectors, SVD |
| 3 | 5.6.3 | Statistics Deep-Dive | Distributions, correlation, `runningMean`, hypothesis tests |
| 4 | 5.6.4 | Data Pipeline | CSV → transform → aggregate → output |
| 5 | 5.6.5 | Numerical Computing | `gamma`, `erf`, `binomial`, `frexp`, `log` variants |

### 5.7: Systems Programming (5 lessons)
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 5.7.1 | Process Control | `startProcess`, `waitForExit`, `running`, `terminate` |
| 2 | 5.7.2 | Signal Handling (`std/signals`) | `SIGINT`, `SIGTERM`, `SIGUSR1`, custom handlers |
| 3 | 5.7.3 | Shared Memory (`std/shm`) | `createSharedMem`, `mapSharedMem`, cross-process sharing |
| 4 | 5.7.4 | Daemonizing | `fork`, `setsid`, `chdir`, fd redirection |
| 5 | 5.7.5 | ELF/PE Introspection | Read binary headers, magic bytes, section parsing |

### 5.8: Linking & Distribution (3 lessons)
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 5.8.1 | Static Linking | `--passL:-static`, `-d:useMalloc`, single-binary deployment |
| 2 | 5.8.2 | Dynamic Loading (`std/dynlib`) | `loadLib`, `symAddr`, plugin architecture |
| 3 | 5.8.3 | Embedding Nim in C | `--app:staticLib`, header generation, calling from C |

### 5.9: Embedded & IoT (4 lessons)
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 5.9.1 | Nim for Arduino | `--cpu:avr`, `--os:standalone`, GPIO, LED blink |
| 2 | 5.9.2 | FreeRTOS with Nim | `--os:freertos`, tasks, queues, timer patterns |
| 3 | 5.9.3 | Low-Memory Patterns | `--gc:none`, `static`, `{.packed.}`, `{.align.}` |
| 4 | 5.9.4 | Hardware I/O | Raw register access, `volatileLoad`, `volatileStore` |

### 5.10: Capstone: Production API (8 lessons)
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 5.10.1 | Project Scaffold | `.nimble`, `config.nims`, `src/` layout, task defs |
| 2 | 5.10.2 | Configuration System | `std/parsecfg`, env vars, CLI flags, precedence |
| 3 | 5.10.3 | REST Handlers | Route dispatch, request parsing, JSON serialization |
| 4 | 5.10.4 | Database Layer | SQLite schema, queries, connection pool, transactions |
| 5 | 5.10.5 | Auth Middleware | JWT creation/validation, bcrypt, auth header parsing |
| 6 | 5.10.6 | Structured Logging | `std/logging`, log levels, file/console handlers |
| 7 | 5.10.7 | Integration Testing | HTTP test client, DB fixtures, assertion helpers |
| 8 | 5.10.8 | Docker Deployment | `nimble build -d:release`, Dockerfile, small image |

### 5.11: Boss: The Mastery Exam (1 lesson)
| # | ID | Name | Focus |
|---|----|------|-------|
| 1 | 5.11.1 | The Mastery Exam | Parse config → query SQLite → serve HTTP → test |

---

## Tasks

### Phase 1: Curriculum Design (this session)
- [x] Audit existing coverage, deduplicate topics
- [x] Write final topic JSON to `~/nimlings-fleet/nim-topics.json` (add Level 5 + gap chapters) — 315 topics, 0 collisions
- [x] Validate IDs: no collisions with existing 255 lesson IDs

### Phase 2: Generation (overnight pipeline)
- [ ] Launch `orchestrator.py --continuous --max-hours 24` for batch generation
- [ ] Monitor smith failures, rerun fixes as needed
- [ ] `nimble generate_content` runs clean after injection

### Phase 3: Verification (follow-up session)
- [ ] `nim c --warnings:on src/nimlings.nim` — clean build
- [ ] `nimble test -y` — all tests pass (adapt prerequisite tests for new structure)
- [ ] `./nimlings test` — all lessons pass (target: ~310/310)
- [ ] Update STATUS.md, CHANGELOG.md (v2.2.0), DEV_PLAN.md, CHANGE_REPORT.md

## Dependencies
- Phase 1 → Phase 2 (curriculum before generation)
- Phase 2 → Phase 3 (lessons before verification)
- Within Phase 1: audit → write final topics → validate

## Risks
- **Medium:** Arraymancer (5.6.1-5.6.2) may not install cleanly — fallback to `std/math` + `stats`
- **Medium:** Embedded (5.9.1-5.9.2) needs cross-compilers — mark `skipRun`, reference-only
- **Medium:** Signal handling (5.7.2) and daemonizing (5.7.4) platform-specific — `skipRun` on non-Linux
- **Medium:** Weave (5.3.1) and Malebolgia (5.3.2) are nimble packages — use `nimble` runner
- **Low:** `db_sqlite` needs `sqlite3` dev headers — universal on Linux, may need `--dynlib` on macOS
- **Low:** Capstone (5.10.x) lessons are complex — some may need `skipRun` or multi-file runner

## Review Status
- [ ] User approved approach
- [ ] User approved topic list
