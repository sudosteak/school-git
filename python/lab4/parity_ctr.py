#!/usr/bin/python3

"""
    program name: parity_ctr.py
    program purpose: exercise #1: odd/even number counter (read loop with nested decision)
    author: Jacob P, 041156249, 010
    date & version: 2025-09-23, version: 2.0
    completion time: 30 minutes
"""

# initialize counters
odd_counter = 0
even_counter = 0

print("odd/even number counter")
print("=" * 25)
print("enter integer numbers to count odd and even values.")

# main loop to get user input until they choose to quit
continue_program = True
while continue_program:
    user_input = input("enter a number (or 'quit' to exit): ").lower()

    # check if user wants to quit
    if user_input == "quit":
        continue_program = False
    else:
        # convert input to integer
        number = int(user_input)

        # check if number is odd or even using modulus operator
        if number % 2 == 1:
            odd_counter += 1
            print(f"{number} is odd")
        elif number % 2 == 0:
            even_counter += 1
            print(f"{number} is even")
        else:
            print("error: invalid number")

# Display results
print("\n" + "=" * 25)
print(f"odd numbers entered: {odd_counter}")
print(f"even numbers entered: {even_counter}")
print(f"total numbers entered: {odd_counter + even_counter}")
print("\nthank you for using the odd/even counter!")
print("=" * 25)
