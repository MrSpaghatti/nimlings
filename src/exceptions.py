"""Custom exceptions for nimlings with helpful error messages."""

class NimlingsError(Exception):
    """Base exception for all nimlings errors."""
    def __init__(self, message: str, fix: str = ""):
        self.message = message
        self.fix = fix
        super().__init__(self.message)
    
    def __str__(self):
        if self.fix:
            return f"{self.message}\n\n💡 How to fix: {self.fix}"
        return self.message


class NimNotFoundError(NimlingsError):
    """Raised when the Nim compiler is not found."""
    def __init__(self):
        super().__init__(
            message="Hard to teach you Nim if you don't have it installed, genius.",
            fix="Install Nim from https://nim-lang.org/install.html or use your package manager (e.g., 'sudo apt install nim' or 'brew install nim')"
        )


class LessonNotFoundError(NimlingsError):
    """Raised when a requested lesson doesn't exist."""
    def __init__(self, lesson_id: str):
        super().__init__(
            message=f"Lesson '{lesson_id}' not found.",
            fix="Run 'python nimlings.py list' to see all available lessons."
        )


class ConfigError(NimlingsError):
    """Raised when there's an issue with configuration files."""
    def __init__(self, filepath: str, reason: str = "corrupted or invalid"):
        super().__init__(
            message=f"Configuration file issue: {filepath} is {reason}.",
            fix=f"Try running 'python nimlings.py reset' to reset your progress, or manually delete '{filepath}'."
        )


class CompilationError(NimlingsError):
    """Raised when Nim code fails to compile."""
    def __init__(self, stderr: str, hint: str = ""):
        message = f"Compilation failed:\n{stderr}"
        fix = hint if hint else "Check the compiler error message above for details."
        super().__init__(message=message, fix=fix)


class ValidationError(NimlingsError):
    """Raised when lesson validation fails."""
    def __init__(self, output: str, expected: str = ""):
        message = f"Your code produced incorrect output:\n{output}"
        fix = f"Expected: {expected}" if expected else "Review the lesson task and try again."
        super().__init__(message=message, fix=fix)
