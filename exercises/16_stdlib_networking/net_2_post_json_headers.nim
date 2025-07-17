# Description: Learn to send an HTTP POST request with a JSON body and custom headers using `std/httpclient`, and then parse the JSON response.
# Hint: Use `std/json` to create a `JsonNode` (e.g., `newJObject()`, `%=`). Create an `httpclient` and add to its `.headers` table. Use `client.post()` with the URL and a string-formatted JSON body (`$myJsonNode`). Parse the `resp.body` with `parseJson()` and access the fields (e.g., `respJson["json"]["name"]`) to verify the result. This exercise requires an internet connection.
# Points: 40
# SandboxPreference: native
# ValidationScript: validate_net_2.nims

import std/httpclient
import std/json

const PostURL = "https://httpbin.org/post"

proc main() =
  # TODO: Step 1 - Create a new httpclient instance.
  # var client = newHttpClient()
  echo "HTTP client not implemented." # Placeholder

  # TODO: Step 2 - Add a custom header to the client.
  # The header should be "X-Exercise-ID" with the value "net_2".
  # client.headers["X-Exercise-ID"] = "net_2"
  echo "Custom header not set." # Placeholder

  # TODO: Step 3 - Create a JSON object for the request body.
  # It should have three fields:
  # - "name": "Nimling" (string)
  # - "exercise": "http_post" (string)
  # - "level": 2 (integer)
  # let requestBodyJson = %*{"name": "Nimling", "exercise": "http_post", "level": 2}
  echo "JSON body not created." # Placeholder

  # TODO: Step 4 - Send the POST request.
  # Use `client.post()` with the `PostURL` and the string representation of your JSON object as the body.
  # try:
  #   let resp = client.post(PostURL, body = $requestBodyJson)
  # except Exception as e:
  #   echo "ERROR: ", e.msg
  #   return
  echo "POST request not sent." # Placeholder

  # TODO: Step 5 - Check the response status and parse the response body.
  # 5a. Check if `resp.status` is "200 OK". If not, print an error and exit.
  # 5b. If the status is OK, print it in the format "STATUS: <status_code>"
  # 5c. Parse the `resp.body` into a `JsonNode` called `responseJson`.
  # if resp.status == "200 OK":
  #   echo "STATUS: ", resp.status
  #   let responseJson = parseJson(resp.body)
  # else:
  #   echo "ERROR: Received non-200 status: ", resp.status
  #   return
  echo "Response not processed." # Placeholder

  # TODO: Step 6 - Validate the response and print checks for the validation script.
  # From `responseJson`, extract and print the following in the specified format:
  # 6a. The custom header: `responseJson["headers"]["X-Exercise-Id"]`
  #     Print as: "HEADER_CHECK: X-Exercise-Id = <value>"
  # 6b. The "name" field from the echoed JSON body: `responseJson["json"]["name"]`
  #     Print as: "JSON_NAME_CHECK: name = <value>"
  # 6c. The "level" field from the echoed JSON body: `responseJson["json"]["level"]`
  #     Print as: "JSON_LEVEL_CHECK: level = <value>"
  #
  # Example for one check:
  # let receivedHeader = responseJson["headers"]["X-Exercise-Id"].getStr()
  # echo "HEADER_CHECK: X-Exercise-Id = ", receivedHeader
  echo "Validation checks not printed." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()
