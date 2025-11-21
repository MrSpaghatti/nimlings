import json, tables, strutils
import types
var modules*: seq[Module]
proc initLessons*() =
  modules = @[]
  var m_lessons: seq[Lesson]
  m_lessons = @[]
  proc validate_1_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return true
  m_lessons.add(Lesson(
    id: "1.1",
    name: "Intro",
    conceptText: "Alright, let's get this over with. You're here to learn Nim.\nIt's a compiled, statically typed language that looks like Python but has the performance of C.\nThis means you get speed, but you also have to actually think about your types.\nNo more sloppy dynamic-language nonsense.",
    task: "There's no code to write. Just read the above and internalize it. Press Enter to continue.",
    solution: "",
    hint: "",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_1_1
  ))
  proc validate_1_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Hello, Nim!"
  m_lessons.add(Lesson(
    id: "1.2",
    name: "Hello World",
    conceptText: "Your first rite of passage. In Nim, the `echo` procedure prints stuff to the console.\nIt's simple, clean, and gets the job done. Don't overthink it.",
    task: "Write a single line of Nim code that prints the string \"Hello, Nim!\".",
    solution: "echo \"Hello, Nim!\"",
    hint: "Just `echo` the exact string. With quotes. You can figure this out.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_1_2
  ))
  proc validate_1_3(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "42"
  m_lessons.add(Lesson(
    id: "1.3",
    name: "Compiling & Running",
    conceptText: "Nim is a compiled language. The command `nim c -r your_file.nim` does two things:\n1. `c`: Compiles your Nim code into a C executable.\n2. `-r` or `--run`: Runs the resulting executable immediately after compiling.\nThis is the workflow you'll use constantly. Get used to it.",
    task: "Write a program that prints the number 42.",
    solution: "echo 42",
    hint: "Same as before. `echo` the number. No quotes this time, genius.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_1_3
  ))
  modules.add(Module(name: "1: The Basics (\"Why Bother?\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_2_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return exitCode == 0
  m_lessons.add(Lesson(
    id: "2.1",
    name: "let vs var",
    conceptText: "Nim has two ways to declare variables: `let` and `var`.\n- `let` creates an immutable variable. Once assigned, you can't change it. It's a constant.\n- `var` creates a mutable variable. You can change its value whenever you want.\nRule of thumb: Use `let` by default. Mutability is a footgun. Only use `var` when you know you need it.",
    task: "Declare an immutable string named `name` with the value \"Nim\" and a mutable integer `age` with the value 15. The program shouldn't print anything.",
    solution: "let name = \"Nim\"\nvar age = 15",
    hint: "The syntax is `let name = \"value\"` and `var age = 15`. If it compiles, you did it right.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_2_1
  ))
  proc validate_2_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return exitCode == 0
  m_lessons.add(Lesson(
    id: "2.2",
    name: "Basic Types",
    conceptText: "Nim is statically typed. You can, and often should, declare types explicitly.\nThe syntax is `var name: type = value`.\nBasic types include: `int`, `string`, `float`, `bool`.",
    task: "Declare four `var` variables, one of each basic type: an `int` named `i`, a `string` named `s`, a `float` named `f`, and a `bool` named `b`. Assign them any valid values. No output needed.",
    solution: "var i: int = 1\nvar s: string = \"a\"\nvar f: float = 1.0\nvar b: bool = true",
    hint: "Example: `var i: int = 10`. Do that for all four types.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_2_2
  ))
  proc validate_2_3(code: string, output: string, stderr: string, exitCode: int): bool =
    return exitCode == 0
  m_lessons.add(Lesson(
    id: "2.3",
    name: "Type Inference",
    conceptText: "Explicitly writing types is good, but sometimes the compiler can figure it out on its own.\nWhen you declare a variable with `let` or `var` and assign a value immediately, Nim infers the type.\n`let name = \"Nim\"` is the same as `let name: string = \"Nim\"`.\n`var age = 20` is the same as `var age: int = 20`.\nIt's clean, simple, and you should use it when the type is obvious.",
    task: "Declare a mutable integer named `counter` with a value of 0 using type inference.",
    solution: "var counter = 0",
    hint: "Just use `var counter = 0`. The compiler knows it's an integer.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_2_3
  ))
  modules.add(Module(name: "2: Variables & Data Types (\"Storing Your Junk\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_3_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "15"
  m_lessons.add(Lesson(
    id: "3.1",
    name: "Procedures (proc)",
    conceptText: "Procedures, or `proc`, are Nim's functions. They take arguments and can return a value.\nThe syntax is: `proc name(arg1: type, arg2: type): returntype =`\nThe body of the proc is indented. The return value is the last expression, or you can use `return`.",
    task: "Write a procedure named `addNumbers` that takes two integers (`a` and `b`) and returns their sum. Then, call it with `5` and `10` and `echo` the result.",
    solution: "proc addNumbers(a: int, b: int): int = a + b\necho addNumbers(5, 10)",
    hint: "Define the proc first. `proc addNumbers(a: int, b: int): int = a + b`. Then, on a new line, `echo addNumbers(5, 10)`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_3_1
  ))
  proc validate_3_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Negative"
  m_lessons.add(Lesson(
    id: "3.2",
    name: "if/else/elif",
    conceptText: "Conditional logic. You've seen this before in other languages. It's not complicated.\n`if condition:`\n  `...`\n`elif other_condition:`\n  `...`\n`else:`\n  `...`",
    task: "Write a procedure `checkSign` that takes an integer.\n- If the number is greater than 0, it should `echo` \"Positive\".\n- If it's less than 0, it should `echo` \"Negative\".\n- Otherwise, it should `echo` \"Zero\".\nCall your procedure with the number -5.",
    solution: "proc checkSign(num: int) =\n  if num > 0:\n    echo \"Positive\"\n  elif num < 0:\n    echo \"Negative\"\n  else:\n    echo \"Zero\"\ncheckSign(-5)",
    hint: "Your `if` condition should be `num > 0`, `elif` should be `num < 0`, and `else` handles the rest.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_3_2
  ))
  proc validate_3_3(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "1\n2\n3\n4\n5"
  m_lessons.add(Lesson(
    id: "3.3",
    name: "for Loops",
    conceptText: "Looping. `for i in a..b:` will loop from `a` to `b`, inclusive.\nIt's a simple, readable way to iterate.",
    task: "Write a `for` loop that prints the numbers from 1 to 5, each on a new line.",
    solution: "for i in 1..5:\n  echo i",
    hint: "Use `for num in 1..5:`. Inside the loop, `echo num`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_3_3
  ))
  modules.add(Module(name: "3: Procedures & Control Flow (\"Actually Doing Stuff\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_4_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Alice\n30"
  m_lessons.add(Lesson(
    id: "4.1",
    name: "Tuples",
    conceptText: "Tuples are fixed-size, ordered collections of values that can have different types.\nThey're useful for grouping related data without creating a full-blown object.\nSyntax: `let myTuple = (\"some string\", 42)`.\nYou access their fields by index: `myTuple[0]`, `myTuple[1]`.",
    task: "Declare a tuple named `person` containing a string \"Alice\" and an integer 30. Then, `echo` both fields, each on a new line.",
    solution: "let person = (\"Alice\", 30)\necho person[0]\necho person[1]",
    hint: "Declare it with `let person = (\"Alice\", 30)`. Then use `echo person[0]` and `echo person[1]`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_4_1
  ))
  proc validate_4_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return exitCode == 0
  m_lessons.add(Lesson(
    id: "4.2",
    name: "Objects",
    conceptText: "Objects are custom data types that group named fields. They're like structs in other languages.\nYou define them with the `type` keyword.\ntype Person = object\n  name: string\n  age: int",
    task: "Define a `Person` object type with a `name` (string) and `age` (int). Create an instance of it, but don't print anything.",
    solution: "type Person = object\n  name: string\n  age: int\nlet p = Person(name: \"Bob\", age: 25)",
    hint: "After defining the type, create an instance: `let p = Person(name: \"Bob\", age: 25)`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_4_2
  ))
  proc validate_4_3(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "1\n2\n3"
  m_lessons.add(Lesson(
    id: "4.3",
    name: "Sequences",
    conceptText: "Sequences, or `seq`, are dynamic-sized arrays. They're Nim's version of Python's lists or C++'s vectors.\nYou can add to them, remove from them, and they'll grow as needed.\nSyntax: `var numbers = @[10, 20, 30]`.",
    task: "Create a sequence of integers containing 1, 2, and 3. Use a `for` loop to iterate over it and `echo` each number.",
    solution: "var numbers = @[1, 2, 3]\nfor n in numbers: echo n",
    hint: "Use `var numbers = @[1, 2, 3]` and then `for n in numbers: echo n`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_4_3
  ))
  proc validate_4_4(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Go"
  m_lessons.add(Lesson(
    id: "4.4",
    name: "Enums & Case Statements",
    conceptText: "Enumerations (`enum`) are for when you have a variable that can only be one of a few possible values.\nThey're great for state machines and making your code type-safe.\nThe `case` statement is like a switch statement, perfect for handling each possible enum value.",
    task: "Define an enum `TrafficLight` with values `tlRed`, `tlYellow`, `tlGreen`.\nCreate a variable of this type and set it to `tlGreen`.\nUse a `case` statement to `echo` \"Go\" if the light is green.",
    solution: "type TrafficLight = enum\n  tlRed, tlYellow, tlGreen\nlet light = tlGreen\ncase light\nof tlGreen:\n  echo \"Go\"\nelse: discard",
    hint: "Define the enum, then: `let light = tlGreen`. The case statement looks like: `case light\nof tlGreen:\n  echo \"Go\"\nelse: discard`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_4_4
  ))
  proc validate_4_5(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "42"
  m_lessons.add(Lesson(
    id: "4.5",
    name: "Option Type",
    conceptText: "What happens when a procedure might not be able to return a value? Use the `Option` type.\nIt's an enum that can be either `Some(value)` or `None`. This forces you to handle the 'no value' case at compile time, avoiding runtime errors.\nYou need to `import options` to use it.",
    task: "Import `options`. Write a `proc` that returns `some(42)`. Use `get()` to unwrap the value and `echo` it.",
    solution: "import options\nproc getValue(): Option[int] = some(42)\necho getValue().get()",
    hint: "Start with `import options`. Your proc should be `proc getValue(): Option[int] = some(42)`. Then call it and use `.get()` to extract the value.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_4_5
  ))
  modules.add(Module(name: "4: Complex Data Types (\"More Junk To Store\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_B1_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return "Gimli the Warrior is level 10" in output and "Gandalf the Mage is level 8" in output
  m_lessons.add(Lesson(
    id: "B1.1",
    name: "The Gatekeeper",
    conceptText: "Time to put it all together. You're building a simple RPG party system.\nYou'll need Enums, Objects, Sequences, and Procs.\nThis is a comprehensive test of Phase 1.",
    task: "1. Define an Enum `Class` with values `Warrior`, `Mage`, `Rogue`.\n2. Define an Object `Character` with `name` (string), `class` (Class), and `level` (int).\n3. Create a sequence of Characters named `party`.\n4. Add a Level 10 Warrior named \"Gimli\" and a Level 8 Mage named \"Gandalf\" to the party.\n5. Iterate through the party and echo \"[Name] the [Class] is level [Level]\" for each.",
    solution: "type\n  Class = enum Warrior, Mage, Rogue\n  Character = object\n    name: string\n    class: Class\n    level: int\nvar party: seq[Character]\nparty.add(Character(name: \"Gimli\", class: Warrior, level: 10))\nparty.add(Character(name: \"Gandalf\", class: Mage, level: 8))\nfor c in party:\n  echo c.name, \" the \", c.class, \" is level \", c.level",
    hint: "Break it down. Enum first. Then Object. Then `var party: seq[Character]`. Then `party.add(...)`. Finally the loop.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_B1_1
  ))
  modules.add(Module(name: "BOSS FIGHT 1: The RPG Party", lessons: m_lessons))
  m_lessons = @[]
  proc validate_5_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "a"
  m_lessons.add(Lesson(
    id: "5.1",
    name: "Generics",
    conceptText: "Generics let you write procedures that can work with different types.\nInstead of a specific type like `int`, you use a placeholder, like `T`.\nSyntax: `proc echoFirst[T](items: seq[T]) =`",
    task: "Write a generic procedure `echoFirst` that takes a sequence of any type and echoes the first element. Call it with a sequence of strings `@[ \"a\", \"b\"]`.",
    solution: "proc echoFirst[T](items: seq[T]) = echo items[0]\nechoFirst(@[\"a\", \"b\"])",
    hint: "Define the proc as `proc echoFirst[T](items: seq[T]) = echo items[0]`. Then call it.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_5_1
  ))
  proc validate_5_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return "Hello, " in output.strip()
  m_lessons.add(Lesson(
    id: "5.2",
    name: "Method Call Syntax",
    conceptText: "Nim lets you call procedures in two ways: `procName(obj, arg)` or `obj.procName(arg)`.\nThe second one is called 'method call syntax' and is just syntactic sugar. It makes code look more object-oriented.",
    task: "Define a `Person` object and a `proc greet(p: Person)` that echoes \"Hello, \" followed by the person's name.\nCreate a `Person` instance and call `greet` using method call syntax.",
    solution: "type Person = object\n  name: string\nproc greet(p: Person) = echo \"Hello, \", p.name\nlet p = Person(name: \"Carly\")\np.greet()",
    hint: "Define your proc, create a person `let p = Person(name: \"Carly\")`, then call the proc like this: `p.greet()`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_5_2
  ))
  proc validate_5_3(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "1\n2\n3"
  m_lessons.add(Lesson(
    id: "5.3",
    name: "Iterators",
    conceptText: "An `iterator` is a procedure that can 'yield' a value and be resumed later, making it perfect for custom loops.\nThey're memory-efficient because they produce values one at a time, instead of all at once.",
    task: "Write an iterator `countTo(n: int)` that yields numbers from 1 up to `n`. Use it in a `for` loop to `echo` numbers up to 3.",
    solution: "iterator countTo(n: int): int =\n  var i = 1\n  while i <= n:\n    yield i\n    i += 1\nfor i in countTo(3): echo i",
    hint: "Define it as `iterator countTo(n: int): int = ...`. Inside, use a `var` counter and a `while` loop that `yield`s the value.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_5_3
  ))
  modules.add(Module(name: "5: Advanced Procedures (\"Reusable Recipes\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_6_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() != "John" and len(output.strip()) > 0
  m_lessons.add(Lesson(
    id: "6.1",
    name: "Ref Types",
    conceptText: "Sometimes you need multiple variables to point to the *same* object in memory.\nA `ref` type is a reference to an object. When you pass a `ref`, you're not passing a copy, you're passing a pointer to the original.\nThis is how you get shared, mutable state.",
    task: "Define a `Person` object. Create a `ref Person` variable `p1`.\nCreate a second variable `p2` and assign `p1` to it.\nModify the `name` of the person through `p2`.\nEcho the name through `p1` to see that it changed.",
    solution: "type Person = ref object\n  name: string\nvar p1 = Person(name: \"John\")\nvar p2 = p1\np2.name = \"Jane\"\necho p1.name",
    hint: "Use `type Person = ref object; var p1 = Person(name: \"John\"); var p2 = p1; p2.name = \"Jane\"; echo p1.name`",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_6_1
  ))
  modules.add(Module(name: "6: Memory Management (\"Not Leaking Everywhere\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_7_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Bad index!"
  m_lessons.add(Lesson(
    id: "7.1",
    name: "Try/Except",
    conceptText: "When things go wrong, Nim raises exceptions. You can handle them with a `try`/`except` block.\nThis prevents your program from crashing when something unexpected happens, like accessing a bad array index.",
    task: "Create a small array. In a `try` block, attempt to access an index that is out of bounds. In the `except IndexDefect` block, `echo` the message \"Bad index!\".",
    solution: "var a: array[0..2, int]\nlet badIndex = 10\ntry:\n  discard a[badIndex]\nexcept IndexDefect:\n  echo \"Bad index!\"",
    hint: "The structure is `try:\n  discard a[10]\nexcept IndexDefect:\n  echo \"Bad index!\"`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_7_1
  ))
  proc validate_7_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "hello"
  m_lessons.add(Lesson(
    id: "7.2",
    name: "File Reading",
    conceptText: "The `os` module provides functions for interacting with the file system. `readFile` is the simplest way to get the contents of a file as a string.",
    task: "Import the `os` module. Create a temporary file named `test.txt` with `writeFile(\"test.txt\", \"hello\")`. Then, use `readFile(\"test.txt\")` and `echo` its contents.",
    solution: "import os\nwriteFile(\"test.txt\", \"hello\")\necho readFile(\"test.txt\")",
    hint: "Don't forget to `import os`. Use `writeFile` first, then `echo readFile(\"test.txt\")`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_7_2
  ))
  proc validate_7_3(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Hello, Nim!"
  m_lessons.add(Lesson(
    id: "7.3",
    name: "File Writing",
    conceptText: "Just as `readFile` reads a file, `writeFile` writes a string to a file, overwriting it if it already exists.",
    task: "Import the `os` module. Use `writeFile` to create a file named `output.txt` with the content \"Hello, Nim!\". Then, read the file back and `echo` its contents.",
    solution: "import os\nwriteFile(\"output.txt\", \"Hello, Nim!\")\necho readFile(\"output.txt\")",
    hint: "After you `writeFile`, just add `echo readFile(\"output.txt\")`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_7_3
  ))
  modules.add(Module(name: "7: Error Handling & File I/O (\"Things Go Wrong\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_8_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "5.0"
  m_lessons.add(Lesson(
    id: "8.1",
    name: "Import",
    conceptText: "You can't fit everything in one file. The `import` statement lets you use code from other files, called modules.\nNim has a rich standard library with modules for math, string handling, OS interaction, and more.",
    task: "Import the `math` module and `echo` the result of `sqrt(25.0)`.",
    solution: "import math\necho sqrt(25.0)",
    hint: "Start with `import math`. Then `echo sqrt(25.0)`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_8_1
  ))
  proc validate_8_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return true
  m_lessons.add(Lesson(
    id: "8.2",
    name: "Nimble Intro",
    conceptText: "Nimble is Nim's package manager. It's how you install and manage third-party libraries.\nYou'll use it for everything from web frameworks to game engines.\nThis is just a heads-up; you won't be using it in this tutorial.",
    task: "Just read this and press Enter. Go on.",
    solution: "",
    hint: "",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_8_2
  ))
  proc validate_8_3(code: string, output: string, stderr: string, exitCode: int): bool =
    return true
  m_lessons.add(Lesson(
    id: "8.3",
    name: "Creating Modules",
    conceptText: "Any Nim file can be a module. To expose a `proc` to other files, you mark it with an asterisk (`*`).\nThis is Nim's way of marking things as 'public' so they can be exported.",
    task: "Just read this and press Enter. Go on.",
    solution: "",
    hint: "",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_8_3
  ))
  modules.add(Module(name: "8: Modules and Packages (\"Using Other People's Code\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_9_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return true
  m_lessons.add(Lesson(
    id: "9.1",
    name: "Spawn Intro",
    conceptText: "Nim has powerful and easy-to-use concurrency features built into the language.\nThe `spawn` keyword can run a procedure in a separate thread.\nThis is a deep topic, so we're just scratching the surface here. The main takeaway is that concurrency in Nim is a first-class citizen.",
    task: "Just read this and press Enter. You've reached the end for now.",
    solution: "",
    hint: "",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_9_1
  ))
  proc validate_9_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "42"
  m_lessons.add(Lesson(
    id: "9.2",
    name: "FlowVar",
    conceptText: "Running a `proc` in another thread is cool, but how do you get a result back?\nA `FlowVar[T]` is a special type that acts as a container for a value that will be computed concurrently.\nYou can `^` to wait for the result and retrieve it.",
    task: "Import `threadpool`. Write a `proc` that returns `42`. `spawn` it into a `FlowVar[int]` and `echo` the result.",
    solution: "import threadpool\nproc calc(): int = 42\nvar result = spawn calc()\necho ^result",
    hint: "`import threadpool`. `proc calc(): int = 42`. Then `var result = spawn calc()`. Finally, `echo ^result`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_9_2
  ))
  modules.add(Module(name: "9: Concurrency (\"Doing Two Things at Once\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_10_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Hello!"
  m_lessons.add(Lesson(
    id: "10.1",
    name: "Templates",
    conceptText: "Metaprogramming is writing code that generates other code. Nim has powerful metaprogramming features, with `template` being the simplest.\nA template is like a super-powered macro. It substitutes code at compile time, which can reduce boilerplate and improve performance.",
    task: "Create a template `shout(msg: string)` that takes a string and echoes it with an exclamation mark. Use it to shout \"Hello\".",
    solution: "template shout(msg: string) = echo msg, \"!\"\nshout(\"Hello\")",
    hint: "The syntax is `template shout(msg: string) = echo msg, \"!\". Then you can call it like a regular proc: `shout(\"Hello\")`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_10_1
  ))
  modules.add(Module(name: "10: Metaprogramming (\"Code That Writes Code\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_B2_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return "[LOG]: Processing..." in output and "Data" in output and "100" in output
  m_lessons.add(Lesson(
    id: "B2.1",
    name: "The Architect",
    conceptText: "Phase 2 tested your ability to write reusable and structural code.\nNow you must build a generic logging system using Templates and Generics.",
    task: "1. Define a template `log(msg)` that echoes \"[LOG]: \" followed by `msg`.\n2. Define a Generic proc `process[T](val: T)`.\n3. Inside `process`, use `log` to print \"Processing...\" and then echo `val`.\n4. Call `process` with the string \"Data\" and the integer `100`.",
    solution: "template log(msg) = echo \"[LOG]: \", msg\nproc process[T](val: T) =\n  log(\"Processing...\")\n  echo val\nprocess(\"Data\")\nprocess(100)",
    hint: "Template comes first. Then `proc process[T](val: T) = ...`. Call `process` twice.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_B2_1
  ))
  modules.add(Module(name: "BOSS FIGHT 2: The Generic Logger", lessons: m_lessons))
  m_lessons = @[]
  proc validate_11_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Tock"
  m_lessons.add(Lesson(
    id: "11.1",
    name: "Async/Await",
    conceptText: "Modern applications need to handle many things at once without freezing.\nNim uses `asyncdispatch` for this. You mark a proc with `{.async.}` and it returns a `Future[T]`.\nInside, you use `await` to pause execution until a future completes.\nTo run an async proc from the main synchronous scope, use `waitFor`.",
    task: "Import `asyncdispatch`. Create an async proc `tick()` that waits for 100ms (`await sleepAsync(100)`) then echoes \"Tock\". Call it using `waitFor`.",
    solution: "import asyncdispatch\nproc tick() {.async.} =\n  await sleepAsync(100)\n  echo \"Tock\"\nwaitFor tick()",
    hint: "Import `asyncdispatch`. `proc tick() {.async.} = await sleepAsync(100); echo \"Tock\"`. End with `waitFor tick()`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_11_1
  ))
  modules.add(Module(name: "11: Asynchronous IO (\"Don't Block the Thread\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_12_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return "StmtList" in output or "StmtList" in stderr
  m_lessons.add(Lesson(
    id: "12.1",
    name: "The AST",
    conceptText: "Nim code is parsed into an Abstract Syntax Tree (AST) before compilation.\nMacros let you manipulate this tree directly.\nThe `dumpTree:` statement prints the AST of the code inside it. This is how you learn what the tree looks like.",
    task: "Import `macros`. Use `dumpTree:` to inspect the code `echo 1`. (This will print to the output/compiler logs).",
    solution: "import macros\ndumpTree:\n  echo 1",
    hint: "Just wrap the code in `dumpTree:`: `dumpTree:\n  echo 1`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_12_1
  ))
  modules.add(Module(name: "12: Macros (\"The Dark Arts\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_13_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Hello C"
  m_lessons.add(Lesson(
    id: "13.1",
    name: "C Types",
    conceptText: "Nim compiles to C, so interacting with C is trivial.\nNim strings are objects with length and capacity. C strings are just pointers (`char*`).\nIn Nim, C strings are `cstring`. Conversion is automatic in many cases, or explicit via `cstring(myString)`.",
    task: "Declare a `cstring` variable initialized with \"Hello C\". Echo it.",
    solution: "var s: cstring = \"Hello C\"\necho s",
    hint: "`var s: cstring = \"Hello C\"`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_13_1
  ))
  proc validate_13_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Native call"
  m_lessons.add(Lesson(
    id: "13.2",
    name: "Wrapping C Functions",
    conceptText: "To call a C function, you just tell Nim it exists using the `importc` pragma.\nYou also usually specify the header file with `header`.",
    task: "Define a proc `c_puts(s: cstring)` that maps to the C function `puts`. Use `{.importc: \"puts\", header: \"<stdio.h>\"}`. Call it with \"Native call\".",
    solution: "proc c_puts(s: cstring) {.importc: \"puts\", header: \"<stdio.h>\"}\nc_puts(\"Native call\")",
    hint: "The pragma goes after the arguments: `proc c_puts(s: cstring) {.importc: ... .}`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_13_2
  ))
  modules.add(Module(name: "13: C Interoperability (\"The Secret Weapon\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_14_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return "Math" in output and "addition" in output
  m_lessons.add(Lesson(
    id: "14.1",
    name: "Unittest",
    conceptText: "Nim has a built-in `unittest` module.\nYou organize tests into a `suite` and individual `test` blocks.\nUse `check` to assert conditions. If a check fails, the test fails, but execution continues.",
    task: "Import `unittest`. Create a `suite \"Math\":` and a `test \"addition\":`. Inside, `check(1 + 1 == 2)`.",
    solution: "import unittest\nsuite \"Math\":\n  test \"addition\":\n    check(1 + 1 == 2)",
    hint: "`suite \"Name\":` then indent `test \"Name\":` then indent `check(...)`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_14_1
  ))
  modules.add(Module(name: "14: Testing (\"Trust, but Verify\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_15_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return "\"Neo\"" in output and "true" in output
  m_lessons.add(Lesson(
    id: "15.1",
    name: "Creating JSON",
    conceptText: "JSON is everywhere. Nim handles it with the `json` module.\nThe `%*` macro is the magic wand. It converts complex data structures into a `JsonNode`.\nExample: `let j = %* {\"key\": \"value\", \"list\": [1, 2]}`",
    task: "Import `json`. Create a JSON object representing a person with `name` \"Neo\" and `chosen` `true`. Echo the resulting `JsonNode`.",
    solution: "import json\nlet j = %* {\"name\": \"Neo\", \"chosen\": true}\necho j",
    hint: "Use `import json`. Then `let j = %* ...`. Finally `echo j`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_15_1
  ))
  proc validate_15_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "ok"
  m_lessons.add(Lesson(
    id: "15.2",
    name: "Parsing JSON",
    conceptText: "To read JSON strings, use `parseJson(string)`.\nYou can access fields using `[]` keys or `.` dot syntax if you know the structure.\nValues are wrapped in `JsonNode`, so use helper procs like `.getStr`, `.getInt` to extract raw values.",
    task: "Parse the string `{\"status\": \"ok\", \"code\": 200}`. Extract and echo the \"status\" string.",
    solution: "import json\nlet data = parseJson(\"{\\\"status\\\": \\\"ok\\\", \\\"code\\\": 200}\")\necho data[\"status\"].getStr",
    hint: "Parse it into a variable. Then access `[\"status\"]` and call `.getStr` on it.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_15_2
  ))
  proc validate_15_3(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Trinity"
  m_lessons.add(Lesson(
    id: "15.3",
    name: "Marshalling",
    conceptText: "Manually traversing JSON nodes is tedious. Marshalling lets you convert JSON directly into Nim objects and vice versa.\nUse `to(node, Type)` to convert JSON to an object.\nUse `%` to convert an object to JSON (if you don't use the `%*` macro).",
    task: "Define a `User` object with a `name` string. Parse `{\"name\": \"Trinity\"}` and convert it to a `User` object. Echo the `name` field of the object.",
    solution: "import json\ntype User = object\n  name: string\nlet node = parseJson(\"{\\\"name\\\": \\\"Trinity\\\"}\")\nlet u = node.to(User)\necho u.name",
    hint: "Define `type User = object ...`. Parse the json. Then `let u = node.to(User)`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_15_3
  ))
  modules.add(Module(name: "15: JSON (\"The Lingua Franca\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_16_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return "arg1" in output and "arg2" in output and "arg3" in output
  m_lessons.add(Lesson(
    id: "16.1",
    name: "Raw Arguments",
    conceptText: "The `os` module gives you `paramCount()` and `paramStr(i)`.\nIt's the raw way to read arguments passed to your program.",
    task: "Import `os`. Iterate from 1 to `paramCount()` and echo each argument using `paramStr()`.",
    solution: "import os\nfor i in 1..paramCount():\n  echo paramStr(i)",
    hint: "Loop `for i in 1..paramCount():`. Inside, `echo paramStr(i)`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_16_1
  ))
  proc validate_16_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Morpheus"
  m_lessons.add(Lesson(
    id: "16.2",
    name: "Parseopt",
    conceptText: "For real CLI tools, use `std/parseopt`. It handles flags (`-f`), long options (`--file`), and arguments.\nIt provides an iterator `getopt()` that yields `kind`, `key`, and `val`.",
    task: "Import `parseopt`. Use the `getopt()` iterator. If `kind` is `cmdLongOption` and `key` is \"name\", echo the `val`.",
    solution: "import parseopt\nfor kind, key, val in getopt():\n  if kind == cmdLongOption and key == \"name\":\n    echo val",
    hint: "Loop with `for kind, key, val in getopt():`. Check if `key == \"name\"`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_16_2
  ))
  modules.add(Module(name: "16: Command Line Parsing (\"Talk to the Shell\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_17_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Tmlt"
  m_lessons.add(Lesson(
    id: "17.1",
    name: "Base64",
    conceptText: "Nim's standard library is huge. Need to encode data? Use `base64`.\nIt provides `encode` and `decode` procedures.",
    task: "Import `base64`. Encode the string \"Nim\" and echo the result.",
    solution: "import base64\necho encode(\"Nim\")",
    hint: "`import base64`. `echo encode(\"Nim\")`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_17_1
  ))
  proc validate_17_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return "key" in output
  m_lessons.add(Lesson(
    id: "17.2",
    name: "Parsing Configs",
    conceptText: "Need to read an INI file? `parsecfg` has you covered.\nIt works similarly to `parseopt`, iterating over the file structure.",
    task: "Import `parsecfg`, `streams`. Create a stream from string \"[Section]\\nkey=val\". Open it with `newConfigParser`. Loop `next(p)` and if the event kind is `cfgKeyValuePair`, echo the key.",
    solution: "import parsecfg, streams\nvar p: CfgParser\nlet s = newStringStream(\"[Section]\\nkey=val\")\nopen(p, s, \"test.ini\")\nwhile true:\n  var e = next(p)\n  if e.kind == cfgEof: break\n  if e.kind == cfgKeyValuePair: echo e.key",
    hint: "Check `e.kind`. Only access `e.key` if it's a key-value pair.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_17_2
  ))
  modules.add(Module(name: "17: Useful Utils (\"Batteries Included\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_18_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Slow"
  m_lessons.add(Lesson(
    id: "18.1",
    name: "Release Mode",
    conceptText: "By default, Nim compiles in debug mode (slow, safe, stack traces).\nPassing `-d:release` turns on optimizations and turns off some runtime checks.\nYou can check for this in code using `when defined(release):`.",
    task: "Write a program that echoes \"Fast\" if `defined(release)` is true, and \"Slow\" otherwise. (Note: This tutor runs in debug mode, so expect \"Slow\").",
    solution: "if defined(release):\n  echo \"Fast\"\nelse:\n  echo \"Slow\"",
    hint: "Use `if defined(release): ... else: ...`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_18_1
  ))
  modules.add(Module(name: "18: Build Modes (\"Speed vs Safety\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_B3_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return "Processed: 1" in output and "Processed: 3" in output
  m_lessons.add(Lesson(
    id: "B3.1",
    name: "The Professional",
    conceptText: "You have reached the end. This is the final test.\nYou must build a simulated async microservice that handles JSON data.\nCombine `json`, `asyncdispatch`, and your wits.",
    task: "1. Import `json` and `asyncdispatch`.\n2. Define an async proc `worker(data: JsonNode)`.\n3. Inside, `await sleepAsync(10)` and then echo \"Processed: \" & data[\"id\"].getInt.\n4. Create a JSON array `jobs` with 3 objects: `[{\"id\": 1}, {\"id\": 2}, {\"id\": 3}]`.\n5. Iterate over `jobs` and call `waitFor worker(item)` for each one.",
    solution: "import json, asyncdispatch\nproc worker(data: JsonNode) {.async.} =\n  await sleepAsync(10)\n  echo \"Processed: \", data[\"id\"].getInt\nlet jobs = %* [{\"id\": 1}, {\"id\": 2}, {\"id\": 3}]\nfor job in jobs:\n  waitFor worker(job)",
    hint: "Define `worker` with `{.async.}`. Use `%*` for the JSON array. Loop and `waitFor`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_B3_1
  ))
  modules.add(Module(name: "BOSS FIGHT 3: The Async Service", lessons: m_lessons))
  m_lessons = @[]
  proc validate_19_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return "Hello, World" in output
  m_lessons.add(Lesson(
    id: "19.1",
    name: "Directory Layout",
    conceptText: "Real projects aren't just one file. You need structure.\nStandard Nim layout:\n- `src/`: Source code\n- `tests/`: Tests\n- `myproject.nimble`: Package info\nIn this lesson, you'll create a `src/main.nim` that imports a `utils.nim`.",
    task: "You are writing `src/main.nim`.\n1. Import `utils`.\n2. Call `utils.greet(\"World\")`.\nThe `utils.nim` file is already created for you in `src/`.",
    solution: "import utils\ngreet(\"World\")",
    hint: "Just `import utils` and call `greet(\"World\")`. The file is in the same folder (`src`), so it works.",
    filename: "src/main.nim",
    files: {"src/utils.nim": "proc greet*(name: string) = echo \"Hello, \", name"}.toTable,
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_19_1
  ))
  proc validate_19_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return "Hello, Tester" in output
  m_lessons.add(Lesson(
    id: "19.2",
    name: "Importing from Parent",
    conceptText: "Sometimes you need to import a file from a parent directory.\nYou can use relative paths like `../utils`.",
    task: "You are writing `tests/test1.nim`.\n1. Import `utils` from the `src` directory (which is `../src/utils`).\n2. Call `greet(\"Tester\")`.",
    solution: "import ../src/utils\ngreet(\"Tester\")",
    hint: "Use `import ../src/utils`.",
    filename: "tests/test1.nim",
    files: {"src/utils.nim": "proc greet*(name: string) = echo \"Hello, \", name", "tests/placeholder": ""}.toTable,
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_19_2
  ))
  modules.add(Module(name: "19: Project Structure (\"Organizing Your Mess\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_20_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return "serve" in code and "respond" in code
  m_lessons.add(Lesson(
    id: "20.1",
    name: "Async HTTP Server",
    conceptText: "Nim's standard library includes `asynchttpserver`.\nIt's a basic, non-blocking HTTP server.\nYou define a callback proc that handles requests and sends responses.",
    task: "1. Import `asynchttpserver`, `asyncdispatch`.\n2. Create a server instance `var server = newAsyncHttpServer()`.\n3. Define a proc `cb(req: Request) {.async.}` that calls `await req.respond(Http200, \"Hello Web\")`.\n4. Call `waitFor server.serve(Port(8080), cb)`.",
    solution: "import asynchttpserver, asyncdispatch\nvar server = newAsyncHttpServer()\nproc cb(req: Request) {.async.} =\n  await req.respond(Http200, \"Hello Web\")\nasyncCheck server.serve(Port(0), cb)\npoll()",
    hint: "Follow the steps exactly. `waitFor server.serve(Port(8080), cb)`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_20_1
  ))
  modules.add(Module(name: "20: Web Development (\"The World Wide Web\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_21_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "Hello JS"
  m_lessons.add(Lesson(
    id: "21.1",
    name: "Compiling to JS",
    conceptText: "Nim can compile to JavaScript! This lets you share code between frontend and backend.\nUse `nim js` to compile.\nThe `dom` module gives you access to the browser DOM.",
    task: "Write a program that echoes \"Hello JS\".\nThis will be compiled with `nim js` and run with `node`.",
    solution: "echo \"Hello JS\"",
    hint: "Just `echo \"Hello JS\"`. The tutor handles the `nim js` part.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "js",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_21_1
  ))
  modules.add(Module(name: "21: JS Backend (\"Nim in the Browser\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_22_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return "Database" in output and "connection" in output
  m_lessons.add(Lesson(
    id: "22.1",
    name: "Writing a Test Suite",
    conceptText: "You've seen `unittest` before, but let's get serious.\nA proper test suite has setup, teardown, and multiple test cases.\nUse `setup:` and `teardown:` blocks inside a `suite`.",
    task: "Create a `suite \"Database\":`.\nDefine a variable `dbConnected` (bool).\nIn `setup:`, set `dbConnected = true`.\nIn `teardown:`, set `dbConnected = false`.\nWrite a `test \"connection\":` that checks `dbConnected == true`.",
    solution: "import unittest\nsuite \"Database\":\n  var dbConnected = false\n  setup:\n    dbConnected = true\n  teardown:\n    dbConnected = false\n  test \"connection\":\n    check dbConnected == true",
    hint: "Structure: `suite ... setup: ... teardown: ... test ...`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_22_1
  ))
  proc validate_22_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return output.strip() == "MOCK: Alert"
  m_lessons.add(Lesson(
    id: "22.2",
    name: "Mocking",
    conceptText: "Nim doesn't have a built-in mocking library, but you can use `proc` variables or templates to inject dependencies.\nThis is called 'Dependency Injection'.",
    task: "1. Define a type `Sender = proc(msg: string)`.\n2. Define a proc `notify(s: Sender, msg: string)` that calls `s(msg)`.\n3. Create a mock sender that echoes \"MOCK: \" & msg.\n4. Call `notify` with your mock and the message \"Alert\".",
    solution: "type Sender = proc(msg: string)\nproc notify(s: Sender, msg: string) = s(msg)\nproc mockSender(msg: string) = echo \"MOCK: \", msg\nnotify(mockSender, \"Alert\")",
    hint: "Define the proc type, then the notifier. Pass `mockSender` as the first argument to `notify`.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_22_2
  ))
  modules.add(Module(name: "22: Testing Frameworks (\"Trust No One\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_23_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return "version" in code and "author" in code
  m_lessons.add(Lesson(
    id: "23.1",
    name: "Nimble Structure",
    conceptText: "A `.nimble` file describes your package.\nIt uses a specific Nim-based DSL.\nRequired fields: `version`, `author`, `description`, `license`.",
    task: "Create a file `myproject.nimble`.\nSet `version` to \"0.1.0\", `author` to \"Me\", `description` to \"Test\", `license` to \"MIT\".\nThis is a Project Mode lesson, so just write the content of the nimble file.",
    solution: "version = \"0.1.0\"\nauthor = \"Me\"\ndescription = \"Test\"\nlicense = \"MIT\"",
    hint: "Just assign the variables: `version = \"0.1.0\"` etc.",
    filename: "myproject.nimble",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: true,
    validate: validate_23_1
  ))
  proc validate_23_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return exitCode == 0
  m_lessons.add(Lesson(
    id: "23.2",
    name: "Code Style",
    conceptText: "Professional code must be readable.\nNim comes with `nimpretty`, a code formatter.\nIn this lesson, the engine will check your style!\nWrite a messy proc `proc  ugly(  x : int )= echo x` and see if you get a warning.",
    task: "Write a properly formatted proc `clean(x: int) = echo x`.\nIf you write it messily, you'll pass the logic check but get a style warning.",
    solution: "proc clean(x: int) = echo x",
    hint: "Write `proc clean(x: int) = echo x` exactly like that.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_23_2
  ))
  modules.add(Module(name: "23: Tooling (\"The Ecosystem\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_24_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return "cpuTime" in code and "1000000" in code.replace("_", "")
  m_lessons.add(Lesson(
    id: "24.1",
    name: "Benchmarking",
    conceptText: "To make code fast, you must measure it.\nThe `std/times` module provides `cpuTime()`.\nMeasure time before and after a block of code to see how long it takes.",
    task: "Import `times`.\nGet `let t0 = cpuTime()`.\nRun a loop `for i in 1..1_000_000: discard`.\nEcho `cpuTime() - t0`.",
    solution: "import times\nlet t0 = cpuTime()\nfor i in 1..1_000_000: discard\necho cpuTime() - t0",
    hint: "Use `cpuTime()` before and after the loop. Subtract to get the duration.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_24_1
  ))
  proc validate_24_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return "nimprof" in code
  m_lessons.add(Lesson(
    id: "24.2",
    name: "Profiling",
    conceptText: "Nim has a built-in profiler.\nCompile with `--profiler:on --stackTrace:on`.\nIn code, import `nimprof` to enable it.\nThis writes a `profile_results.txt` file.",
    task: "Import `nimprof`.\nWrite a slow proc `slow()` that loops 100,000 times.\nCall `slow()`.",
    solution: "import nimprof\nproc slow() = \n  for i in 1..100_000: discard\nslow()",
    hint: "Just `import nimprof` and write a loop.",
    filename: "solution.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @["--profiler:on", "--stackTrace:on"],
    skipRun: false,
    validate: validate_24_2
  ))
  modules.add(Module(name: "24: Performance (\"Need for Speed\")", lessons: m_lessons))
  m_lessons = @[]
  proc validate_25_1(code: string, output: string, stderr: string, exitCode: int): bool =
    return "type" in code and "Todo*" in code and "title*" in code
  m_lessons.add(Lesson(
    id: "25.1",
    name: "Project Setup",
    conceptText: "Welcome to the final challenge.\nYou will build a simple Todo API.\nFirst, let's set up the project structure.\nWe need a `src/server.nim` and a `src/todo.nim`.",
    task: "Create `src/todo.nim`.\nDefine a `Todo` object with `id: int`, `title: string`, `done: bool`.\nExport the type and fields (`*`).",
    solution: "type Todo* = object\n  id*: int\n  title*: string\n  done*: bool",
    hint: "Remember to use `*` to export symbols.",
    filename: "src/todo.nim",
    files: initTable[string, string](),
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_25_1
  ))
  proc validate_25_2(code: string, output: string, stderr: string, exitCode: int): bool =
    return "import" in code and "todo" in code and "%*" in code
  m_lessons.add(Lesson(
    id: "25.2",
    name: "The Server",
    conceptText: "Now let's build the server in `src/server.nim`.\nWe'll use `asynchttpserver` and import our `todo` module.",
    task: "Import `asynchttpserver`, `asyncdispatch`, `json`, and `todo`.\nCreate a server that responds with `{\"status\": \"ok\"}` (JSON) to any request.\nUse `Port(0)` to avoid conflicts in tests.",
    solution: "import asynchttpserver, asyncdispatch, json, todo\nvar server = newAsyncHttpServer()\nproc cb(req: Request) {.async.} =\n  await req.respond(Http200, $(%*{\"status\": \"ok\"}))\nasyncCheck server.serve(Port(0), cb)\npoll()",
    hint: "Use `%*` for JSON construction. Don't forget to import `todo`.",
    filename: "src/server.nim",
    files: {"src/todo.nim": "type Todo* = object\n  id*: int\n  title*: string\n  done*: bool"}.toTable,
    cmd: "c",
    compilerArgs: @[],
    skipRun: false,
    validate: validate_25_2
  ))
  modules.add(Module(name: "25: Capstone Project (\"The Web API\")", lessons: m_lessons))
