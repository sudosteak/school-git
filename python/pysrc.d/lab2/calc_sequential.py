#!/usr/bin/python3

"""
    Program name: calc_sequential.py
    Program purpose: Perform sequential calculations
    Author: Jacob P, 041156249, 010
    Date & version: 2025-09-14, version: 1.0
    Completion time: ~1 hour
"""

# Greet the user
user_name = input("What is your name? ")
print("Hello, " + user_name + "!")

# Prompt for user input
first_operand = float(input("Enter the first operand: "))
second_operand = float(input("Enter the second operand: "))

# Perform arithmetic calculations and display result.
sum_result = first_operand + second_operand
difference = first_operand - second_operand

# Display results as both float and integer
print(f"Result of addition as float: {sum_result}, as int: {int(sum_result)}")
print(f"Result of subtraction as float: {difference}, as int: {int(difference)}")

# Close the program
print("Thank you for using the calculator, " + user_name + ". Goodbye!")