#!/usr/bin/python3

"""
    Program name: select_operator.py
    Program purpose: exercise for Conditional expression & multi-branch decision with if-elif[-elif]-else, Decision: Execute an operation based on user selection
    Author: Jacob P, 041156249, 010
    Date & version: 2025-09-15, version: 1.0
    Completion time: ~10 minutes
"""

# prompt for user input
operator = input("enter one of the following operators (+, -, *, /): ")

if operator == "+":
    # addition
    print("addition")
elif operator == "-":
    # subtraction
    print("subtraction")
elif operator == "*":
    # multiplication
    print("multiplication")
elif operator == "/":
    # division
    print("division")
else:
    # invalid operator
    print("invalid operator")

# close the program
print("thank you for using this program\nprogram ending...")