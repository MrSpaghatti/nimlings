import re

LESSONS = [
    {
        "module": "1: The Basics (\"Why Bother?\")",
        "lessons": [
            {
                "id": "1.1",
                "name": "Intro",
                "concept": (
                    "Alright, let's get this over with. You're here to learn Nim.\n"
                    "It's a compiled, statically typed language that looks like Python but has the performance of C.\n"
                    "This means you get speed, but you also have to actually think about your types.\n"
                    "No more sloppy dynamic-language nonsense."
                ),
                "task": "There's no code to write. Just read the above and internalize it. Press Enter to continue.",
            },
            {
                "id": "1.2",
                "name": "Hello World",
                "concept": (
                    "Your first rite of passage. In Nim, the `echo` procedure prints stuff to the console.\n"
                    "It's simple, clean, and gets the job done. Don't overthink it."
                ),
                "task": "Write a single line of Nim code that prints the string \"Hello, Nim!\".",
                "validation": lambda code, result: result.stdout.strip() == "Hello, Nim!",
                "solution": "echo \"Hello, Nim!\"",
                "hint": "Just `echo` the exact string. With quotes. You can figure this out.",
            },
            {
                "id": "1.3",
                "name": "Compiling & Running",
                "concept": (
                    "Nim is a compiled language. The command `nim c -r your_file.nim` does two things:\n"
                    "1. `c`: Compiles your Nim code into a C executable.\n"
                    "2. `-r` or `--run`: Runs the resulting executable immediately after compiling.\n"
                    "This is the workflow you'll use constantly. Get used to it."
                ),
                "task": "Write a program that prints the number 42.",
                "validation": lambda code, result: result.stdout.strip() == "42",
                "solution": "echo 42",
                "hint": "Same as before. `echo` the number. No quotes this time, genius.",
            },
        ],
    },
    {
        "module": "2: Variables & Data Types (\"Storing Your Junk\")",
        "lessons": [
            {
                "id": "2.1",
                "name": "let vs var",
                "concept": (
                    "Nim has two ways to declare variables: `let` and `var`.\n"
                    "- `let` creates an immutable variable. Once assigned, you can't change it. It's a constant.\n"
                    "- `var` creates a mutable variable. You can change its value whenever you want.\n"
                    "Rule of thumb: Use `let` by default. Mutability is a footgun. Only use `var` when you know you need it."
                ),
                "task": "Declare an immutable string named `name` with the value \"Nim\" and a mutable integer `age` with the value 15. The program shouldn't print anything.",
                "validation": lambda code, result: result.returncode == 0,
                "solution": "let name = \"Nim\"\nvar age = 15",
                "hint": "The syntax is `let name = \"value\"` and `var age = 15`. If it compiles, you did it right.",
            },
            {
                "id": "2.2",
                "name": "Basic Types",
                "concept": (
                    "Nim is statically typed. You can, and often should, declare types explicitly.\n"
                    "The syntax is `var name: type = value`.\n"
                    "Basic types include: `int`, `string`, `float`, `bool`."
                ),
                "task": "Declare four `var` variables, one of each basic type: an `int` named `i`, a `string` named `s`, a `float` named `f`, and a `bool` named `b`. Assign them any valid values. No output needed.",
                "validation": lambda code, result: result.returncode == 0,
                "solution": "var i: int = 1\nvar s: string = \"a\"\nvar f: float = 1.0\nvar b: bool = true",
                "hint": "Example: `var i: int = 10`. Do that for all four types.",
            },
            {
                "id": "2.3",
                "name": "Type Inference",
                "concept": (
                    "Explicitly writing types is good, but sometimes the compiler can figure it out on its own.\n"
                    "When you declare a variable with `let` or `var` and assign a value immediately, Nim infers the type.\n"
                    "`let name = \"Nim\"` is the same as `let name: string = \"Nim\"`.\n"
                    "`var age = 20` is the same as `var age: int = 20`.\n"
                    "It's clean, simple, and you should use it when the type is obvious."
                ),
                "task": "Declare a mutable integer named `counter` with a value of 0 using type inference.",
                "validation": lambda code, result: result.returncode == 0,
                "solution": "var counter = 0",
                "hint": "Just use `var counter = 0`. The compiler knows it's an integer.",
            },
        ],
    },
    {
        "module": "3: Procedures & Control Flow (\"Actually Doing Stuff\")",
        "lessons": [
            {
                "id": "3.1",
                "name": "Procedures (proc)",
                "concept": (
                    "Procedures, or `proc`, are Nim's functions. They take arguments and can return a value.\n"
                    "The syntax is: `proc name(arg1: type, arg2: type): returntype =`\n"
                    "The body of the proc is indented. The return value is the last expression, or you can use `return`."
                ),
                "task": "Write a procedure named `addNumbers` that takes two integers (`a` and `b`) and returns their sum. Then, call it with `5` and `10` and `echo` the result.",
                "validation": lambda code, result: result.stdout.strip() == "15",
                "solution": "proc addNumbers(a: int, b: int): int = a + b\necho addNumbers(5, 10)",
                "hint": "Define the proc first. `proc addNumbers(a: int, b: int): int = a + b`. Then, on a new line, `echo addNumbers(5, 10)`.",
            },
            {
                "id": "3.2",
                "name": "if/else/elif",
                "concept": (
                    "Conditional logic. You've seen this before in other languages. It's not complicated.\n"
                    "`if condition:`\n"
                    "  `...`\n"
                    "`elif other_condition:`\n"
                    "  `...`\n"
                    "`else:`\n"
                    "  `...`"
                ),
                "task": (
                    "Write a procedure `checkSign` that takes an integer.\n"
                    "- If the number is greater than 0, it should `echo` \"Positive\".\n"
                    "- If it's less than 0, it should `echo` \"Negative\".\n"
                    "- Otherwise, it should `echo` \"Zero\".\n"
                    "Call your procedure with the number -5."
                ),
                "validation": lambda code, result: result.stdout.strip() == "Negative",
                "solution": "proc checkSign(num: int) =\n  if num > 0:\n    echo \"Positive\"\n  elif num < 0:\n    echo \"Negative\"\n  else:\n    echo \"Zero\"\ncheckSign(-5)",
                "hint": "Your `if` condition should be `num > 0`, `elif` should be `num < 0`, and `else` handles the rest.",
            },
            {
                "id": "3.3",
                "name": "for Loops",
                "concept": (
                    "Looping. `for i in a..b:` will loop from `a` to `b`, inclusive.\n"
                    "It's a simple, readable way to iterate."
                ),
                "task": "Write a `for` loop that prints the numbers from 1 to 5, each on a new line.",
                "validation": lambda code, result: result.stdout.strip() == "1\n2\n3\n4\n5",
                "solution": "for i in 1..5:\n  echo i",
                "hint": "Use `for num in 1..5:`. Inside the loop, `echo num`.",
            },
        ],
    },
    {
        "module": "4: Complex Data Types (\"More Junk To Store\")",
        "lessons": [
            {
                "id": "4.1",
                "name": "Tuples",
                "concept": (
                    "Tuples are fixed-size, ordered collections of values that can have different types.\n"
                    "They're useful for grouping related data without creating a full-blown object.\n"
                    "Syntax: `let myTuple = (\"some string\", 42)`.\n"
                    "You access their fields by index: `myTuple[0]`, `myTuple[1]`."
                ),
                "task": "Declare a tuple named `person` containing a string \"Alice\" and an integer 30. Then, `echo` both fields, each on a new line.",
                "validation": lambda code, result: result.stdout.strip() == "Alice\n30",
                "solution": "let person = (\"Alice\", 30)\necho person[0]\necho person[1]",
                "hint": "Declare it with `let person = (\"Alice\", 30)`. Then use `echo person[0]` and `echo person[1]`.",
            },
            {
                "id": "4.2",
                "name": "Objects",
                "concept": (
                    "Objects are custom data types that group named fields. They're like structs in other languages.\n"
                    "You define them with the `type` keyword.\n"
                    "type Person = object\n"
                    "  name: string\n"
                    "  age: int"
                ),
                "task": "Define a `Person` object type with a `name` (string) and `age` (int). Create an instance of it, but don't print anything.",
                "validation": lambda code, result: result.returncode == 0,
                "solution": "type Person = object\n  name: string\n  age: int\nlet p = Person(name: \"Bob\", age: 25)",
                "hint": "After defining the type, create an instance: `let p = Person(name: \"Bob\", age: 25)`.",
            },
            {
                "id": "4.3",
                "name": "Sequences",
                "concept": (
                    "Sequences, or `seq`, are dynamic-sized arrays. They're Nim's version of Python's lists or C++'s vectors.\n"
                    "You can add to them, remove from them, and they'll grow as needed.\n"
                    "Syntax: `var numbers = @[10, 20, 30]`."
                ),
                "task": "Create a sequence of integers containing 1, 2, and 3. Use a `for` loop to iterate over it and `echo` each number.",
                "validation": lambda code, result: result.stdout.strip() == "1\n2\n3",
                "solution": "var numbers = @[1, 2, 3]\nfor n in numbers: echo n",
                "hint": "Use `var numbers = @[1, 2, 3]` and then `for n in numbers: echo n`.",
            },
            {
                "id": "4.4",
                "name": "Enums & Case Statements",
                "concept": (
                    "Enumerations (`enum`) are for when you have a variable that can only be one of a few possible values.\n"
                    "They're great for state machines and making your code type-safe.\n"
                    "The `case` statement is like a switch statement, perfect for handling each possible enum value."
                ),
                "task": (
                    "Define an enum `TrafficLight` with values `tlRed`, `tlYellow`, `tlGreen`.\n"
                    "Create a variable of this type and set it to `tlGreen`.\n"
                    "Use a `case` statement to `echo` \"Go\" if the light is green."
                ),
                "validation": lambda code, result: result.stdout.strip() == "Go",
                "solution": "type TrafficLight = enum\n  tlRed, tlYellow, tlGreen\nlet light = tlGreen\ncase light\nof tlGreen:\n  echo \"Go\"\nelse: discard",
                "hint": "Define the enum, then: `let light = tlGreen`. The case statement looks like: `case light\nof tlGreen:\n  echo \"Go\"\nelse: discard`.",
            },
            {
                "id": "4.5",
                "name": "Option Type",
                "concept": (
                    "What happens when a procedure might not be able to return a value? Use the `Option` type.\n"
                    "It's an enum that can be either `Some(value)` or `None`. This forces you to handle the 'no value' case at compile time, avoiding runtime errors.\n"
                    "You need to `import options` to use it."
                ),
                "task": "Import `options`. Write a `proc` that returns `some(42)`. Use `get()` to unwrap the value and `echo` it.",
                "validation": lambda code, result: result.stdout.strip() == "42",
                "solution": "import options\nproc getValue(): Option[int] = some(42)\necho getValue().get()",
                "hint": "Start with `import options`. Your proc should be `proc getValue(): Option[int] = some(42)`. Then call it and use `.get()` to extract the value.",
            },
        ],
    },
    {
        "module": "BOSS FIGHT 1: The RPG Party",
        "lessons": [
            {
                "id": "B1.1",
                "name": "The Gatekeeper",
                "concept": (
                    "Time to put it all together. You're building a simple RPG party system.\n"
                    "You'll need Enums, Objects, Sequences, and Procs.\n"
                    "This is a comprehensive test of Phase 1."
                ),
                "task": (
                    "1. Define an Enum `Class` with values `Warrior`, `Mage`, `Rogue`.\n"
                    "2. Define an Object `Character` with `name` (string), `class` (Class), and `level` (int).\n"
                    "3. Create a sequence of Characters named `party`.\n"
                    "4. Add a Level 10 Warrior named \"Gimli\" and a Level 8 Mage named \"Gandalf\" to the party.\n"
                    "5. Iterate through the party and echo \"[Name] the [Class] is level [Level]\" for each."
                ),
                "validation": lambda code, result: "Gimli the Warrior is level 10" in result.stdout and "Gandalf the Mage is level 8" in result.stdout,
                "solution": "type\n  Class = enum Warrior, Mage, Rogue\n  Character = object\n    name: string\n    class: Class\n    level: int\nvar party: seq[Character]\nparty.add(Character(name: \"Gimli\", class: Warrior, level: 10))\nparty.add(Character(name: \"Gandalf\", class: Mage, level: 8))\nfor c in party:\n  echo c.name, \" the \", c.class, \" is level \", c.level",
                "hint": "Break it down. Enum first. Then Object. Then `var party: seq[Character]`. Then `party.add(...)`. Finally the loop.",
            },
        ],
    },
    {
        "module": "5: Advanced Procedures (\"Reusable Recipes\")",
        "lessons": [
            {
                "id": "5.1",
                "name": "Generics",
                "concept": (
                    "Generics let you write procedures that can work with different types.\n"
                    "Instead of a specific type like `int`, you use a placeholder, like `T`.\n"
                    "Syntax: `proc echoFirst[T](items: seq[T]) =`"
                ),
                "task": "Write a generic procedure `echoFirst` that takes a sequence of any type and echoes the first element. Call it with a sequence of strings `@[ \"a\", \"b\"]`.",
                "validation": lambda code, result: result.stdout.strip() == "a",
                "solution": "proc echoFirst[T](items: seq[T]) = echo items[0]\nechoFirst(@[\"a\", \"b\"])",
                "hint": "Define the proc as `proc echoFirst[T](items: seq[T]) = echo items[0]`. Then call it.",
            },
            {
                "id": "5.2",
                "name": "Method Call Syntax",
                "concept": (
                    "Nim lets you call procedures in two ways: `procName(obj, arg)` or `obj.procName(arg)`.\n"
                    "The second one is called 'method call syntax' and is just syntactic sugar. It makes code look more object-oriented."
                ),
                "task": (
                    "Define a `Person` object and a `proc greet(p: Person)` that echoes \"Hello, \" followed by the person's name.\n"
                    "Create a `Person` instance and call `greet` using method call syntax."
                ),
                "validation": lambda code, result: "Hello, " in result.stdout.strip(),
                "solution": "type Person = object\n  name: string\nproc greet(p: Person) = echo \"Hello, \", p.name\nlet p = Person(name: \"Carly\")\np.greet()",
                "hint": "Define your proc, create a person `let p = Person(name: \"Carly\")`, then call the proc like this: `p.greet()`.",
            },
            {
                "id": "5.3",
                "name": "Iterators",
                "concept": (
                    "An `iterator` is a procedure that can 'yield' a value and be resumed later, making it perfect for custom loops.\n"
                    "They're memory-efficient because they produce values one at a time, instead of all at once."
                ),
                "task": "Write an iterator `countTo(n: int)` that yields numbers from 1 up to `n`. Use it in a `for` loop to `echo` numbers up to 3.",
                "validation": lambda code, result: result.stdout.strip() == "1\n2\n3",
                "solution": "iterator countTo(n: int): int =\n  var i = 1\n  while i <= n:\n    yield i\n    i += 1\nfor i in countTo(3): echo i",
                "hint": "Define it as `iterator countTo(n: int): int = ...`. Inside, use a `var` counter and a `while` loop that `yield`s the value.",
            },
        ],
    },
    {
        "module": "6: Memory Management (\"Not Leaking Everywhere\")",
        "lessons": [
            {
                "id": "6.1",
                "name": "Ref Types",
                "concept": (
                    "Sometimes you need multiple variables to point to the *same* object in memory.\n"
                    "A `ref` type is a reference to an object. When you pass a `ref`, you're not passing a copy, you're passing a pointer to the original.\n"
                    "This is how you get shared, mutable state."
                ),
                "task": (
                    "Define a `Person` object. Create a `ref Person` variable `p1`.\n"
                    "Create a second variable `p2` and assign `p1` to it.\n"
                    "Modify the `name` of the person through `p2`.\n"
                    "Echo the name through `p1` to see that it changed."
                ),
                "validation": lambda code, result: result.stdout.strip() != "John" and len(result.stdout.strip()) > 0,
                "solution": "type Person = ref object\n  name: string\nvar p1 = Person(name: \"John\")\nvar p2 = p1\np2.name = \"Jane\"\necho p1.name",
                "hint": "Use `type Person = ref object; var p1 = Person(name: \"John\"); var p2 = p1; p2.name = \"Jane\"; echo p1.name`",
            },
        ],
    },
    {
        "module": "7: Error Handling & File I/O (\"Things Go Wrong\")",
        "lessons": [
            {
                "id": "7.1",
                "name": "Try/Except",
                "concept": (
                    "When things go wrong, Nim raises exceptions. You can handle them with a `try`/`except` block.\n"
                    "This prevents your program from crashing when something unexpected happens, like accessing a bad array index."
                ),
                "task": "Create a small array. In a `try` block, attempt to access an index that is out of bounds. In the `except IndexDefect` block, `echo` the message \"Bad index!\".",
                "validation": lambda code, result: result.stdout.strip() == "Bad index!",
                "solution": "var a: array[0..2, int]\nlet badIndex = 10\ntry:\n  discard a[badIndex]\nexcept IndexDefect:\n  echo \"Bad index!\"",
                "hint": "The structure is `try:\n  discard a[10]\nexcept IndexDefect:\n  echo \"Bad index!\"`.",
            },
            {
                "id": "7.2",
                "name": "File Reading",
                "concept": (
                    "The `os` module provides functions for interacting with the file system. `readFile` is the simplest way to get the contents of a file as a string."
                ),
                "task": "Import the `os` module. Create a temporary file named `test.txt` with `writeFile(\"test.txt\", \"hello\")`. Then, use `readFile(\"test.txt\")` and `echo` its contents.",
                "validation": lambda code, result: result.stdout.strip() == "hello",
                "solution": "import os\nwriteFile(\"test.txt\", \"hello\")\necho readFile(\"test.txt\")",
                "hint": "Don't forget to `import os`. Use `writeFile` first, then `echo readFile(\"test.txt\")`.",
            },
            {
                "id": "7.3",
                "name": "File Writing",
                "concept": (
                    "Just as `readFile` reads a file, `writeFile` writes a string to a file, overwriting it if it already exists."
                ),
                "task": "Import the `os` module. Use `writeFile` to create a file named `output.txt` with the content \"Hello, Nim!\". Then, read the file back and `echo` its contents.",
                "validation": lambda code, result: result.stdout.strip() == "Hello, Nim!",
                "solution": "import os\nwriteFile(\"output.txt\", \"Hello, Nim!\")\necho readFile(\"output.txt\")",
                "hint": "After you `writeFile`, just add `echo readFile(\"output.txt\")`.",
            },
        ],
    },
    {
        "module": "8: Modules and Packages (\"Using Other People's Code\")",
        "lessons": [
            {
                "id": "8.1",
                "name": "Import",
                "concept": (
                    "You can't fit everything in one file. The `import` statement lets you use code from other files, called modules.\n"
                    "Nim has a rich standard library with modules for math, string handling, OS interaction, and more."
                ),
                "task": "Import the `math` module and `echo` the result of `sqrt(25.0)`.",
                "validation": lambda code, result: result.stdout.strip() == "5.0",
                "solution": "import math\necho sqrt(25.0)",
                "hint": "Start with `import math`. Then `echo sqrt(25.0)`.",
            },
            {
                "id": "8.2",
                "name": "Nimble Intro",
                "concept": (
                    "Nimble is Nim's package manager. It's how you install and manage third-party libraries.\n"
                    "You'll use it for everything from web frameworks to game engines.\n"
                    "This is just a heads-up; you won't be using it in this tutorial."
                ),
                "task": "Just read this and press Enter. Go on.",
            },
            {
                "id": "8.3",
                "name": "Creating Modules",
                "concept": (
                    "Any Nim file can be a module. To expose a `proc` to other files, you mark it with an asterisk (`*`).\n"
                    "This is Nim's way of marking things as 'public' so they can be exported."
                ),
                "task": "Just read this and press Enter. Go on.",
            },
        ],
    },
    {
        "module": "9: Concurrency (\"Doing Two Things at Once\")",
        "lessons": [
            {
                "id": "9.1",
                "name": "Spawn Intro",
                "concept": (
                    "Nim has powerful and easy-to-use concurrency features built into the language.\n"
                    "The `spawn` keyword can run a procedure in a separate thread.\n"
                    "This is a deep topic, so we're just scratching the surface here. The main takeaway is that concurrency in Nim is a first-class citizen."
                ),
                "task": "Just read this and press Enter. You've reached the end for now.",
            },
            {
                "id": "9.2",
                "name": "FlowVar",
                "concept": (
                    "Running a `proc` in another thread is cool, but how do you get a result back?\n"
                    "A `FlowVar[T]` is a special type that acts as a container for a value that will be computed concurrently.\n"
                    "You can `^` to wait for the result and retrieve it."
                ),
                "task": "Import `threadpool`. Write a `proc` that returns `42`. `spawn` it into a `FlowVar[int]` and `echo` the result.",
                "validation": lambda code, result: result.stdout.strip() == "42",
                "solution": "import threadpool\nproc calc(): int = 42\nvar result = spawn calc()\necho ^result",
                "hint": "`import threadpool`. `proc calc(): int = 42`. Then `var result = spawn calc()`. Finally, `echo ^result`.",
            },
        ],
    },
    {
        "module": "10: Metaprogramming (\"Code That Writes Code\")",
        "lessons": [
            {
                "id": "10.1",
                "name": "Templates",
                "concept": (
                    "Metaprogramming is writing code that generates other code. Nim has powerful metaprogramming features, with `template` being the simplest.\n"
                    "A template is like a super-powered macro. It substitutes code at compile time, which can reduce boilerplate and improve performance."
                ),
                "task": "Create a template `shout(msg: string)` that takes a string and echoes it with an exclamation mark. Use it to shout \"Hello\".",
                "validation": lambda code, result: result.stdout.strip() == "Hello!",
                "solution": "template shout(msg: string) = echo msg, \"!\"\nshout(\"Hello\")",
                "hint": "The syntax is `template shout(msg: string) = echo msg, \"!\". Then you can call it like a regular proc: `shout(\"Hello\")`.",
            },
        ],
    },
    {
        "module": "BOSS FIGHT 2: The Generic Logger",
        "lessons": [
            {
                "id": "B2.1",
                "name": "The Architect",
                "concept": (
                    "Phase 2 tested your ability to write reusable and structural code.\n"
                    "Now you must build a generic logging system using Templates and Generics."
                ),
                "task": (
                    "1. Define a template `log(msg)` that echoes \"[LOG]: \" followed by `msg`.\n"
                    "2. Define a Generic proc `process[T](val: T)`.\n"
                    "3. Inside `process`, use `log` to print \"Processing...\" and then echo `val`.\n"
                    "4. Call `process` with the string \"Data\" and the integer `100`."
                ),
                "validation": lambda code, result: "[LOG]: Processing..." in result.stdout and "Data" in result.stdout and "100" in result.stdout,
                "solution": "template log(msg) = echo \"[LOG]: \", msg\nproc process[T](val: T) =\n  log(\"Processing...\")\n  echo val\nprocess(\"Data\")\nprocess(100)",
                "hint": "Template comes first. Then `proc process[T](val: T) = ...`. Call `process` twice.",
            },
        ],
    },
    {
        "module": "11: Asynchronous IO (\"Don't Block the Thread\")",
        "lessons": [
            {
                "id": "11.1",
                "name": "Async/Await",
                "concept": (
                    "Modern applications need to handle many things at once without freezing.\n"
                    "Nim uses `asyncdispatch` for this. You mark a proc with `{.async.}` and it returns a `Future[T]`.\n"
                    "Inside, you use `await` to pause execution until a future completes.\n"
                    "To run an async proc from the main synchronous scope, use `waitFor`."
                ),
                "task": "Import `asyncdispatch`. Create an async proc `tick()` that waits for 100ms (`await sleepAsync(100)`) then echoes \"Tock\". Call it using `waitFor`.",
                "validation": lambda code, result: result.stdout.strip() == "Tock",
                "solution": "import asyncdispatch\nproc tick() {.async.} =\n  await sleepAsync(100)\n  echo \"Tock\"\nwaitFor tick()",
                "hint": "Import `asyncdispatch`. `proc tick() {.async.} = await sleepAsync(100); echo \"Tock\"`. End with `waitFor tick()`.",
            },
        ],
    },
    {
        "module": "12: Macros (\"The Dark Arts\")",
        "lessons": [
            {
                "id": "12.1",
                "name": "The AST",
                "concept": (
                    "Nim code is parsed into an Abstract Syntax Tree (AST) before compilation.\n"
                    "Macros let you manipulate this tree directly.\n"
                    "The `dumpTree:` statement prints the AST of the code inside it. This is how you learn what the tree looks like."
                ),
                "task": "Import `macros`. Use `dumpTree:` to inspect the code `echo 1`. (This will print to the output/compiler logs).",
                "validation": lambda code, result: "StmtList" in result.stdout or "StmtList" in result.stderr,
                "solution": "import macros\ndumpTree:\n  echo 1",
                "hint": "Just wrap the code in `dumpTree:`: `dumpTree:\n  echo 1`.",
            },
        ],
    },
    {
        "module": "13: C Interoperability (\"The Secret Weapon\")",
        "lessons": [
            {
                "id": "13.1",
                "name": "C Types",
                "concept": (
                    "Nim compiles to C, so interacting with C is trivial.\n"
                    "Nim strings are objects with length and capacity. C strings are just pointers (`char*`).\n"
                    "In Nim, C strings are `cstring`. Conversion is automatic in many cases, or explicit via `cstring(myString)`."
                ),
                "task": "Declare a `cstring` variable initialized with \"Hello C\". Echo it.",
                "validation": lambda code, result: result.stdout.strip() == "Hello C",
                "solution": "var s: cstring = \"Hello C\"\necho s",
                "hint": "`var s: cstring = \"Hello C\"`.",
            },
            {
                "id": "13.2",
                "name": "Wrapping C Functions",
                "concept": (
                    "To call a C function, you just tell Nim it exists using the `importc` pragma.\n"
                    "You also usually specify the header file with `header`."
                ),
                "task": "Define a proc `c_puts(s: cstring)` that maps to the C function `puts`. Use `{.importc: \"puts\", header: \"<stdio.h>\"}`. Call it with \"Native call\".",
                "validation": lambda code, result: result.stdout.strip() == "Native call",
                "solution": "proc c_puts(s: cstring) {.importc: \"puts\", header: \"<stdio.h>\"}\nc_puts(\"Native call\")",
                "hint": "The pragma goes after the arguments: `proc c_puts(s: cstring) {.importc: ... .}`.",
            },
        ],
    },
    {
        "module": "14: Testing (\"Trust, but Verify\")",
        "lessons": [
            {
                "id": "14.1",
                "name": "Unittest",
                "concept": (
                    "Nim has a built-in `unittest` module.\n"
                    "You organize tests into a `suite` and individual `test` blocks.\n"
                    "Use `check` to assert conditions. If a check fails, the test fails, but execution continues."
                ),
                "task": "Import `unittest`. Create a `suite \"Math\":` and a `test \"addition\":`. Inside, `check(1 + 1 == 2)`.",
                "validation": lambda code, result: "Math" in result.stdout and "addition" in result.stdout,
                "solution": "import unittest\nsuite \"Math\":\n  test \"addition\":\n    check(1 + 1 == 2)",
                "hint": "`suite \"Name\":` then indent `test \"Name\":` then indent `check(...)`.",
            },
        ],
    },
    {
        "module": "15: JSON (\"The Lingua Franca\")",
        "lessons": [
            {
                "id": "15.1",
                "name": "Creating JSON",
                "concept": (
                    "JSON is everywhere. Nim handles it with the `json` module.\n"
                    "The `%*` macro is the magic wand. It converts complex data structures into a `JsonNode`.\n"
                    "Example: `let j = %* {\"key\": \"value\", \"list\": [1, 2]}`"
                ),
                "task": "Import `json`. Create a JSON object representing a person with `name` \"Neo\" and `chosen` `true`. Echo the resulting `JsonNode`.",
                "validation": lambda code, result: "\"Neo\"" in result.stdout and "true" in result.stdout,
                "solution": "import json\nlet j = %* {\"name\": \"Neo\", \"chosen\": true}\necho j",
                "hint": "Use `import json`. Then `let j = %* ...`. Finally `echo j`.",
            },
            {
                "id": "15.2",
                "name": "Parsing JSON",
                "concept": (
                    "To read JSON strings, use `parseJson(string)`.\n"
                    "You can access fields using `[]` keys or `.` dot syntax if you know the structure.\n"
                    "Values are wrapped in `JsonNode`, so use helper procs like `.getStr`, `.getInt` to extract raw values."
                ),
                "task": "Parse the string `{\"status\": \"ok\", \"code\": 200}`. Extract and echo the \"status\" string.",
                "validation": lambda code, result: result.stdout.strip() == "ok",
                "solution": "import json\nlet data = parseJson(\"{\\\"status\\\": \\\"ok\\\", \\\"code\\\": 200}\")\necho data[\"status\"].getStr",
                "hint": "Parse it into a variable. Then access `[\"status\"]` and call `.getStr` on it.",
            },
            {
                "id": "15.3",
                "name": "Marshalling",
                "concept": (
                    "Manually traversing JSON nodes is tedious. Marshalling lets you convert JSON directly into Nim objects and vice versa.\n"
                    "Use `to(node, Type)` to convert JSON to an object.\n"
                    "Use `%` to convert an object to JSON (if you don't use the `%*` macro)."
                ),
                "task": "Define a `User` object with a `name` string. Parse `{\"name\": \"Trinity\"}` and convert it to a `User` object. Echo the `name` field of the object.",
                "validation": lambda code, result: result.stdout.strip() == "Trinity",
                "solution": "import json\ntype User = object\n  name: string\nlet node = parseJson(\"{\\\"name\\\": \\\"Trinity\\\"}\")\nlet u = node.to(User)\necho u.name",
                "hint": "Define `type User = object ...`. Parse the json. Then `let u = node.to(User)`.",
            },
        ],
    },
    {
        "module": "16: Command Line Parsing (\"Talk to the Shell\")",
        "lessons": [
            {
                "id": "16.1",
                "name": "Raw Arguments",
                "concept": (
                    "The `os` module gives you `paramCount()` and `paramStr(i)`.\n"
                    "It's the raw way to read arguments passed to your program."
                ),
                "task": "Import `os`. Iterate from 1 to `paramCount()` and echo each argument using `paramStr()`.",
                "args": ["arg1", "arg2", "arg3"],
                "validation": lambda code, result: "arg1" in result.stdout and "arg2" in result.stdout and "arg3" in result.stdout,
                "solution": "import os\nfor i in 1..paramCount():\n  echo paramStr(i)",
                "hint": "Loop `for i in 1..paramCount():`. Inside, `echo paramStr(i)`.",
            },
            {
                "id": "16.2",
                "name": "Parseopt",
                "concept": (
                    "For real CLI tools, use `std/parseopt`. It handles flags (`-f`), long options (`--file`), and arguments.\n"
                    "It provides an iterator `getopt()` that yields `kind`, `key`, and `val`."
                ),
                "task": "Import `parseopt`. Use the `getopt()` iterator. If `kind` is `cmdLongOption` and `key` is \"name\", echo the `val`.",
                "args": ["--name:Morpheus"],
                "validation": lambda code, result: result.stdout.strip() == "Morpheus",
                "solution": "import parseopt\nfor kind, key, val in getopt():\n  if kind == cmdLongOption and key == \"name\":\n    echo val",
                "hint": "Loop with `for kind, key, val in getopt():`. Check if `key == \"name\"`.",
            },
        ],
    },
    {
        "module": "17: Useful Utils (\"Batteries Included\")",
        "lessons": [
            {
                "id": "17.1",
                "name": "Base64",
                "concept": (
                    "Nim's standard library is huge. Need to encode data? Use `base64`.\n"
                    "It provides `encode` and `decode` procedures."
                ),
                "task": "Import `base64`. Encode the string \"Nim\" and echo the result.",
                "validation": lambda code, result: result.stdout.strip() == "Tmlt",
                "solution": "import base64\necho encode(\"Nim\")",
                "hint": "`import base64`. `echo encode(\"Nim\")`.",
            },
            {
                "id": "17.2",
                "name": "Parsing Configs",
                "concept": (
                    "Need to read an INI file? `parsecfg` has you covered.\n"
                    "It works similarly to `parseopt`, iterating over the file structure."
                ),
                "task": "Import `parsecfg`, `streams`. Create a stream from string \"[Section]\\nkey=val\". Open it with `newConfigParser`. Loop `next(p)` and if the event kind is `cfgKeyValuePair`, echo the key.",
                "validation": lambda code, result: "key" in result.stdout,
                "solution": "import parsecfg, streams\nvar p: CfgParser\nlet s = newStringStream(\"[Section]\\nkey=val\")\nopen(p, s, \"test.ini\")\nwhile true:\n  var e = next(p)\n  if e.kind == cfgEof: break\n  if e.kind == cfgKeyValuePair: echo e.key",
                "hint": "Check `e.kind`. Only access `e.key` if it's a key-value pair.",
            },
        ],
    },
    {
        "module": "18: Build Modes (\"Speed vs Safety\")",
        "lessons": [
            {
                "id": "18.1",
                "name": "Release Mode",
                "concept": (
                    "By default, Nim compiles in debug mode (slow, safe, stack traces).\n"
                    "Passing `-d:release` turns on optimizations and turns off some runtime checks.\n"
                    "You can check for this in code using `when defined(release):`."
                ),
                "task": "Write a program that echoes \"Fast\" if `defined(release)` is true, and \"Slow\" otherwise. (Note: This tutor runs in debug mode, so expect \"Slow\").",
                "validation": lambda code, result: result.stdout.strip() == "Slow",
                "solution": "if defined(release):\n  echo \"Fast\"\nelse:\n  echo \"Slow\"",
                "hint": "Use `if defined(release): ... else: ...`.",
            },
        ],
    },
    {
        "module": "BOSS FIGHT 3: The Async Service",
        "lessons": [
            {
                "id": "B3.1",
                "name": "The Professional",
                "concept": (
                    "You have reached the end. This is the final test.\n"
                    "You must build a simulated async microservice that handles JSON data.\n"
                    "Combine `json`, `asyncdispatch`, and your wits."
                ),
                "task": (
                    "1. Import `json` and `asyncdispatch`.\n"
                    "2. Define an async proc `worker(data: JsonNode)`.\n"
                    "3. Inside, `await sleepAsync(10)` and then echo \"Processed: \" & data[\"id\"].getInt.\n"
                    "4. Create a JSON array `jobs` with 3 objects: `[{\"id\": 1}, {\"id\": 2}, {\"id\": 3}]`.\n"
                    "5. Iterate over `jobs` and call `waitFor worker(item)` for each one."
                ),
                "validation": lambda code, result: "Processed: 1" in result.stdout and "Processed: 3" in result.stdout,
                "solution": "import json, asyncdispatch\nproc worker(data: JsonNode) {.async.} =\n  await sleepAsync(10)\n  echo \"Processed: \", data[\"id\"].getInt\nlet jobs = %* [{\"id\": 1}, {\"id\": 2}, {\"id\": 3}]\nfor job in jobs:\n  waitFor worker(job)",
                "hint": "Define `worker` with `{.async.}`. Use `%*` for the JSON array. Loop and `waitFor`.",
            },
        ],
    },
    {
        "module": "19: Project Structure (\"Organizing Your Mess\")",
        "lessons": [
            {
                "id": "19.1",
                "name": "Directory Layout",
                "concept": (
                    "Real projects aren't just one file. You need structure.\n"
                    "Standard Nim layout:\n"
                    "- `src/`: Source code\n"
                    "- `tests/`: Tests\n"
                    "- `myproject.nimble`: Package info\n"
                    "In this lesson, you'll create a `src/main.nim` that imports a `utils.nim`."
                ),
                "task": (
                    "You are writing `src/main.nim`.\n"
                    "1. Import `utils`.\n"
                    "2. Call `utils.greet(\"World\")`.\n"
                    "The `utils.nim` file is already created for you in `src/`."
                ),
                "filename": "src/main.nim",
                "files": {
                    "src/utils.nim": "proc greet*(name: string) = echo \"Hello, \", name"
                },
                "validation": lambda code, result: "Hello, World" in result.stdout,
                "solution": "import utils\ngreet(\"World\")",
                "hint": "Just `import utils` and call `greet(\"World\")`. The file is in the same folder (`src`), so it works.",
            },
            {
                "id": "19.2",
                "name": "Importing from Parent",
                "concept": (
                    "Sometimes you need to import a file from a parent directory.\n"
                    "You can use relative paths like `../utils`."
                ),
                "task": (
                    "You are writing `tests/test1.nim`.\n"
                    "1. Import `utils` from the `src` directory (which is `../src/utils`).\n"
                    "2. Call `greet(\"Tester\")`."
                ),
                "filename": "tests/test1.nim",
                "files": {
                    "src/utils.nim": "proc greet*(name: string) = echo \"Hello, \", name",
                    "tests/placeholder": ""
                },
                "validation": lambda code, result: "Hello, Tester" in result.stdout,
                "solution": "import ../src/utils\ngreet(\"Tester\")",
                "hint": "Use `import ../src/utils`.",
            },
        ],
    },
    {
        "module": "20: Web Development (\"The World Wide Web\")",
        "lessons": [
            {
                "id": "20.1",
                "name": "Async HTTP Server",
                "concept": (
                    "Nim's standard library includes `asynchttpserver`.\n"
                    "It's a basic, non-blocking HTTP server.\n"
                    "You define a callback proc that handles requests and sends responses."
                ),
                "task": (
                    "1. Import `asynchttpserver`, `asyncdispatch`.\n"
                    "2. Create a server instance `var server = newAsyncHttpServer()`.\n"
                    "3. Define a proc `cb(req: Request) {.async.}` that calls `await req.respond(Http200, \"Hello Web\")`.\n"
                    "4. Call `waitFor server.serve(Port(8080), cb)`."
                ),
                "validation": lambda code, result: "serve" in code and "respond" in code,
                "solution": "import asynchttpserver, asyncdispatch\nvar server = newAsyncHttpServer()\nproc cb(req: Request) {.async.} =\n  await req.respond(Http200, \"Hello Web\")\nasyncCheck server.serve(Port(0), cb)\npoll()",
                "hint": "Follow the steps exactly. `waitFor server.serve(Port(8080), cb)`.",
            },
        ],
    },
    {
        "module": "21: JS Backend (\"Nim in the Browser\")",
        "lessons": [
            {
                "id": "21.1",
                "name": "Compiling to JS",
                "concept": (
                    "Nim can compile to JavaScript! This lets you share code between frontend and backend.\n"
                    "Use `nim js` to compile.\n"
                    "The `dom` module gives you access to the browser DOM."
                ),
                "task": (
                    "Write a program that echoes \"Hello JS\".\n"
                    "This will be compiled with `nim js` and run with `node`."
                ),
                "cmd": "js",
                "validation": lambda code, result: result.stdout.strip() == "Hello JS",
                "solution": "echo \"Hello JS\"",
                "hint": "Just `echo \"Hello JS\"`. The tutor handles the `nim js` part.",
            },
        ],
    },
    {
        "module": "22: Testing Frameworks (\"Trust No One\")",
        "lessons": [
            {
                "id": "22.1",
                "name": "Writing a Test Suite",
                "concept": (
                    "You've seen `unittest` before, but let's get serious.\n"
                    "A proper test suite has setup, teardown, and multiple test cases.\n"
                    "Use `setup:` and `teardown:` blocks inside a `suite`."
                ),
                "task": (
                    "Create a `suite \"Database\":`.\n"
                    "Define a variable `dbConnected` (bool).\n"
                    "In `setup:`, set `dbConnected = true`.\n"
                    "In `teardown:`, set `dbConnected = false`.\n"
                    "Write a `test \"connection\":` that checks `dbConnected == true`."
                ),
                "validation": lambda code, result: "Database" in result.stdout and "connection" in result.stdout,
                "solution": "import unittest\nsuite \"Database\":\n  var dbConnected = false\n  setup:\n    dbConnected = true\n  teardown:\n    dbConnected = false\n  test \"connection\":\n    check dbConnected == true",
                "hint": "Structure: `suite ... setup: ... teardown: ... test ...`.",
            },
            {
                "id": "22.2",
                "name": "Mocking",
                "concept": (
                    "Nim doesn't have a built-in mocking library, but you can use `proc` variables or templates to inject dependencies.\n"
                    "This is called 'Dependency Injection'."
                ),
                "task": (
                    "1. Define a type `Sender = proc(msg: string)`.\n"
                    "2. Define a proc `notify(s: Sender, msg: string)` that calls `s(msg)`.\n"
                    "3. Create a mock sender that echoes \"MOCK: \" & msg.\n"
                    "4. Call `notify` with your mock and the message \"Alert\"."
                ),
                "validation": lambda code, result: result.stdout.strip() == "MOCK: Alert",
                "solution": "type Sender = proc(msg: string)\nproc notify(s: Sender, msg: string) = s(msg)\nproc mockSender(msg: string) = echo \"MOCK: \", msg\nnotify(mockSender, \"Alert\")",
                "hint": "Define the proc type, then the notifier. Pass `mockSender` as the first argument to `notify`.",
            },
        ],
    },
    {
        "module": "23: Tooling (\"The Ecosystem\")",
        "lessons": [
            {
                "id": "23.1",
                "name": "Nimble Structure",
                "concept": (
                    "A `.nimble` file describes your package.\n"
                    "It uses a specific Nim-based DSL.\n"
                    "Required fields: `version`, `author`, `description`, `license`."
                ),
                "task": (
                    "Create a file `myproject.nimble`.\n"
                    "Set `version` to \"0.1.0\", `author` to \"Me\", `description` to \"Test\", `license` to \"MIT\".\n"
                    "This is a Project Mode lesson, so just write the content of the nimble file."
                ),
                "filename": "myproject.nimble",
                "skip_run": True,
                "validation": lambda code, result: "version" in code and "author" in code,
                "solution": "version = \"0.1.0\"\nauthor = \"Me\"\ndescription = \"Test\"\nlicense = \"MIT\"",
                "hint": "Just assign the variables: `version = \"0.1.0\"` etc.",
            },
            {
                "id": "23.2",
                "name": "Code Style",
                "concept": (
                    "Professional code must be readable.\n"
                    "Nim comes with `nimpretty`, a code formatter.\n"
                    "In this lesson, the engine will check your style!\n"
                    "Write a messy proc `proc  ugly(  x : int )= echo x` and see if you get a warning."
                ),
                "task": (
                    "Write a properly formatted proc `clean(x: int) = echo x`.\n"
                    "If you write it messily, you'll pass the logic check but get a style warning."
                ),
                "validation": lambda code, result: result.returncode == 0,
                "solution": "proc clean(x: int) = echo x",
                "hint": "Write `proc clean(x: int) = echo x` exactly like that.",
            },
        ],
    },
    {
        "module": "24: Performance (\"Need for Speed\")",
        "lessons": [
            {
                "id": "24.1",
                "name": "Benchmarking",
                "concept": (
                    "To make code fast, you must measure it.\n"
                    "The `std/times` module provides `cpuTime()`.\n"
                    "Measure time before and after a block of code to see how long it takes."
                ),
                "task": (
                    "Import `times`.\n"
                    "Get `let t0 = cpuTime()`.\n"
                    "Run a loop `for i in 1..1_000_000: discard`.\n"
                    "Echo `cpuTime() - t0`."
                ),
                "validation": lambda code, result: "cpuTime" in code and "1000000" in code.replace("_", ""),
                "solution": "import times\nlet t0 = cpuTime()\nfor i in 1..1_000_000: discard\necho cpuTime() - t0",
                "hint": "Use `cpuTime()` before and after the loop. Subtract to get the duration.",
            },
            {
                "id": "24.2",
                "name": "Profiling",
                "concept": (
                    "Nim has a built-in profiler.\n"
                    "Compile with `--profiler:on --stackTrace:on`.\n"
                    "In code, import `nimprof` to enable it.\n"
                    "This writes a `profile_results.txt` file."
                ),
                "task": (
                    "Import `nimprof`.\n"
                    "Write a slow proc `slow()` that loops 100,000 times.\n"
                    "Call `slow()`."
                ),
                "compiler_args": ["--profiler:on", "--stackTrace:on"],
                "validation": lambda code, result: "nimprof" in code, # Hard to validate profile output in this env
                "solution": "import nimprof\nproc slow() = \n  for i in 1..100_000: discard\nslow()",
                "hint": "Just `import nimprof` and write a loop.",
            },
        ],
    },
    {
        "module": "25: Capstone Project (\"The Web API\")",
        "lessons": [
            {
                "id": "25.1",
                "name": "Project Setup",
                "concept": (
                    "Welcome to the final challenge.\n"
                    "You will build a simple Todo API.\n"
                    "First, let's set up the project structure.\n"
                    "We need a `src/server.nim` and a `src/todo.nim`."
                ),
                "task": (
                    "Create `src/todo.nim`.\n"
                    "Define a `Todo` object with `id: int`, `title: string`, `done: bool`.\n"
                    "Export the type and fields (`*`)."
                ),
                "filename": "src/todo.nim",
                "validation": lambda code, result: "type" in code and "Todo*" in code and "title*" in code,
                "solution": "type Todo* = object\n  id*: int\n  title*: string\n  done*: bool",
                "hint": "Remember to use `*` to export symbols.",
            },
            {
                "id": "25.2",
                "name": "The Server",
                "concept": (
                    "Now let's build the server in `src/server.nim`.\n"
                    "We'll use `asynchttpserver` and import our `todo` module."
                ),
                "task": (
                    "Import `asynchttpserver`, `asyncdispatch`, `json`, and `todo`.\n"
                    "Create a server that responds with `{\"status\": \"ok\"}` (JSON) to any request.\n"
                    "Use `Port(0)` to avoid conflicts in tests."
                ),
                "filename": "src/server.nim",
                "files": {
                    "src/todo.nim": "type Todo* = object\n  id*: int\n  title*: string\n  done*: bool"
                },
                "validation": lambda code, result: "import" in code and "todo" in code and "%*" in code,
                "solution": "import asynchttpserver, asyncdispatch, json, todo\nvar server = newAsyncHttpServer()\nproc cb(req: Request) {.async.} =\n  await req.respond(Http200, $(%*{\"status\": \"ok\"}))\nasyncCheck server.serve(Port(0), cb)\npoll()",
                "hint": "Use `%*` for JSON construction. Don't forget to import `todo`.",
            },
        ],
    },
]
