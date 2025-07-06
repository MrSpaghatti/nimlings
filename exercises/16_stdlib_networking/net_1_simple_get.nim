# Description: Learn to make simple HTTP GET requests using the `httpclient` module.
# Hint: `import httpclient`. `client.getContent(url)` fetches the content of a URL as a string.
# This operation can raise various exceptions (e.g., `HttpRequestError`, `SSL<y_bin_369>Error`),
# so a `try/except` block is recommended in real applications.
# For this exercise, we'll focus on a successful request to a public API.
# NOTE: This exercise will attempt to make a real internet request if not in testMode.
# SandboxPreference: native # Networking is inherently a native/OS-level operation.
# Points: 20

import httpclient
import json # To parse the example JSON response

# Task:
# 1. Define a URL string for a public JSON API endpoint.
#    Example: "https://jsonplaceholder.typicode.com/todos/1" (returns a single todo item as JSON).
# 2. Use `httpclient.getContent()` to fetch the content from this URL.
# 3. Print a success message and the first 50 characters of the response if successful.
# 4. If an error occurs (e.g., `HttpRequestError`), print an error message.
#
# For testMode, we will not make a real HTTP request to avoid test flakiness.
# Instead, we'll simulate a successful response.

proc main() =
  let url = "https://jsonplaceholder.typicode.com/todos/1"
  echo "Attempting to GET content from: ", url

  when defined(testMode):
    # Simulate a successful response for testing to avoid network dependency.
    echo "--- Test Mode: Simulating HTTP GET ---"
    let mockResponse = """{
  "userId": 1,
  "id": 1,
  "title": "delectus aut autem",
  "completed": false
}"""
    echo "Mocked response received (first 50 chars):"
    if mockResponse.len > 50:
      echo mockResponse[0..<50]
    else:
      echo mockResponse

    # Optionally, try to parse the mock JSON to show it's valid
    try:
      let jsonData = parseJson(mockResponse)
      echo "Mocked JSON title: ", jsonData["title"].getStr()
    except JsonParsingError, KeyError:
      echo "Could not parse mock JSON."

  else: # Actual execution path for user
    # TODO: Implement the try/except block for httpclient.getContent() here.
    # try:
    #   let responseBody = newHttpClient().getContent(url)
    #   echo "Response received successfully!"
    #   echo "First 50 characters of response:"
    #   if responseBody.len > 50:
    #     echo responseBody[0..<50]
    #   else:
    #     echo responseBody
    #
    #   # Optional: Try to parse as JSON and print a field
    #   try:
    #     let jsonData = parseJson(responseBody)
    #     echo "Actual JSON title: ", jsonData["title"].getStr()
    #   except JsonParsingError, KeyError:
    #     echo "Response was not valid JSON or 'title' field missing."
    #
    # except HttpRequestError as e:
    #   echo "HTTP Request Error: ", e.msg
    # except CatchableError as e: # Other potential errors like SSL
    #   echo "An error occurred: ", e.msg
    echo "HTTP GET request not implemented for normal run." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  echo "\nNote: Running this exercise will attempt a real internet connection."
  main()

# ExpectedOutput for testMode: ```
# Attempting to GET content from: https://jsonplaceholder.typicode.com/todos/1
# --- Test Mode: Simulating HTTP GET ---
# Mocked response received (first 50 chars):
# {
#   "userId": 1,
#   "id": 1,
#   "title": "delectus aut
# Mocked JSON title: delectus aut autem
# ```
# Note: The "delectus aut " part is exactly 50 chars from the start of the JSON.
# The line break is due to the 50 char cut-off in the middle of "autem". This is fine for the test.
