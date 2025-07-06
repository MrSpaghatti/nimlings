# Description: Define methods that modify the state of an object.
# Hint: If a method needs to change the object's fields, the object parameter must be `var`.
# `proc increment(c: var Counter, amount: int) = c.value += amount`
# SandboxPreference: wasm
# Points: 15

# Task:
# 1. Define an object type `BankAccount` with a field `balance: float`.
# 2. Define a method `deposit` that takes a `var BankAccount` and an `amount: float`.
#    It should add the `amount` to the account's `balance`. (Ensure amount is positive).
# 3. Define a method `withdraw` that takes a `var BankAccount` and an `amount: float`.
#    It should subtract the `amount` if `balance >= amount` and `amount > 0`.
#    Return `true` if withdrawal was successful, `false` otherwise.
# 4. Define a method `getBalance` that takes a `BankAccount` and returns its `balance`.
# 5. In `main`, create an account, perform some deposits and withdrawals, and print the balance at each step.

# TODO: Step 1 - Define BankAccount object type.

# TODO: Step 2 - Define deposit method.

# TODO: Step 3 - Define withdraw method.

# TODO: Step 4 - Define getBalance method.

proc main() =
  # TODO: Step 5 - Create account and perform operations.
  # var myAccount = BankAccount(balance: 100.0) # Initial balance
  # echo "Initial balance: ", myAccount.getBalance()
  # myAccount.deposit(50.0)
  # echo "After deposit 50: ", myAccount.getBalance()
  # if myAccount.withdraw(30.0):
  #   echo "Withdrew 30 successfully."
  # echo "After withdraw 30: ", myAccount.getBalance()
  # if not myAccount.withdraw(200.0): # Attempt to overdraw
  #   echo "Failed to withdraw 200 (insufficient funds)."
  # echo "After failed withdraw 200: ", myAccount.getBalance()

  echo "Bank account methods not fully implemented." # Placeholder

# Do not modify the lines below; they are for testing.
when defined(testMode):
  main()
else:
  main()

# ExpectedOutput: ```
# Initial balance: 100.0
# After deposit 50: 150.0
# Withdrew 30 successfully.
# After withdraw 30: 120.0
# Failed to withdraw 200 (insufficient funds).
# After failed withdraw 200: 120.0
# ```
