import difflib

user_code = 'echo 42'
formatted = 'echo 42\n'

lines1 = user_code.splitlines(keepends=True)
lines2 = formatted.splitlines(keepends=True)

diff = difflib.unified_diff(lines1, lines2, fromfile='Your Code', tofile='Professional Style')

# Proposed fix:
diff_text = "".join(line.rstrip('\n') + '\n' for line in diff)

print("--- Result ---")
print(diff_text)
print("--- End ---")
