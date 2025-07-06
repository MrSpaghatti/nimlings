# Description: Practice converters with more involved logic or differing field names.
# Hint: Converters are just special procs; they can contain any necessary logic.
# Ensure the return type of the converter matches the target type.
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define an object type `UserDetails` with fields:
#    - `userID: int`
#    - `username: string`
#    - `email: string`
# 2. Define an object type `UserProfile` with fields:
#    - `profileId: string` (e.g., "user-[userID]")
#    - `displayName: string` (e.g., "@[username]")
#    - `contactEmail: string`
# 3. Define a `converter toUserProfile(details: UserDetails): UserProfile`.
#    This converter should:
#    - Create `profileId` by prefixing "user-" to `details.userID`.
#    - Create `displayName` by prefixing "@" to `details.username`.
#    - Copy `details.email` to `contactEmail`.
# 4. In `main`:
#    a. Create an instance of `UserDetails`.
#    b. Convert it to a `UserProfile` using your converter.
#    c. Print the fields of the resulting `UserProfile`.

# TODO: Step 1 - Define UserDetails object type.

# TODO: Step 2 - Define UserProfile object type.

# TODO: Step 3 - Define the converter toUserProfile.

proc main() =
  # TODO: Step 4a - Create UserDetails instance.
  # let user = UserDetails(userID: 123, username: "NimFan", email: "fan@example.com")
  echo "UserDetails creation not implemented." # Placeholder

  # TODO: Step 4b - Convert to UserProfile.
  # let profile = toUserProfile(user)
  echo "Conversion to UserProfile not implemented." # Placeholder

  # TODO: Step 4c - Print UserProfile fields.
  # echo "Profile ID: ", profile.profileId
  # echo "Display Name: ", profile.displayName
  # echo "Contact Email: ", profile.contactEmail
  echo "UserProfile printing not implemented." # Placeholder


# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Profile ID: user-123
# Display Name: @NimFan
# Contact Email: fan@example.com
# ```
