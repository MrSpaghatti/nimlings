import difflib

user_code = 'echo "hi"'
formatted = 'echo "hi"\n'

print(f"Different? {user_code != formatted}")

lines1 = user_code.splitlines()
lines2 = formatted.splitlines()

print(f"Lines 1: {lines1}")
print(f"Lines 2: {lines2}")

diff = list(difflib.unified_diff(lines1, lines2, fromfile='Your Code', tofile='Professional Style', lineterm=''))
print(f"Diff len: {len(diff)}")
print("Diff content:")
for line in diff:
    print(line)

print("-" * 20)

lines1_keep = user_code.splitlines(keepends=True)
lines2_keep = formatted.splitlines(keepends=True)
print(f"Lines 1 (keep): {lines1_keep}")
print(f"Lines 2 (keep): {lines2_keep}")

diff_keep = list(difflib.unified_diff(lines1_keep, lines2_keep, fromfile='Your Code', tofile='Professional Style'))
print(f"Diff len (keep): {len(diff_keep)}")
print("Diff content (keep):")
for line in diff_keep:
    print(line, end='')
