import std/strutils

var checks = (
  status: false,
  header: false,
  jsonName: false,
  jsonLevel: false
)

let allLines = stdin.readAll().splitLines()

for line in allLines:
  let trimmedLine = line.strip()
  if trimmedLine.startsWith("STATUS:"):
    if trimmedLine == "STATUS: 200 OK":
      checks.status = true
  elif trimmedLine.startsWith("HEADER_CHECK:"):
    if trimmedLine == "HEADER_CHECK: X-Exercise-Id = net_2":
      checks.header = true
  elif trimmedLine.startsWith("JSON_NAME_CHECK:"):
    if trimmedLine == "JSON_NAME_CHECK: name = Nimling":
      checks.jsonName = true
  elif trimmedLine.startsWith("JSON_LEVEL_CHECK:"):
    if trimmedLine == "JSON_LEVEL_CHECK: level = 2":
      checks.jsonLevel = true

var success = true
var errorMessages: seq[string]

if not checks.status:
  success = false
  errorMessages.add("Did not find correct 'STATUS: 200 OK' line.")
if not checks.header:
  success = false
  errorMessages.add("Did not find correct 'HEADER_CHECK: X-Exercise-Id = net_2' line.")
if not checks.jsonName:
  success = false
  errorMessages.add("Did not find correct 'JSON_NAME_CHECK: name = Nimling' line.")
if not checks.jsonLevel:
  success = false
  errorMessages.add("Did not find correct 'JSON_LEVEL_CHECK: level = 2' line.")


if success:
  echo "Validation successful: All checks passed!"
  quit(0)
else:
  echo "Validation failed:"
  for msg in errorMessages:
    echo "- ", msg
  quit(1)
