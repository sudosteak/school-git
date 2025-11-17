#!/usr/bin/python3

"""
    Program name: compare_numbers.py
    Program purpose: syntax practice for Conditional expression & three-way decision with if-elif-else
    Author: Jacob P, 041156249, 010
    Date & version: 2025-09-15, version: 1.0
"""

# prompt the user for two numbers using the input function and store them in variables
num1 = float(input("Enter the first number: "))
num2 = float(input("Enter the second number: "))

# compare the two numbers using comparison operators and display the result of the comparison
if num1 > num2:
    print(num1)
elif num1 < num2:
    print(num2)
else:
    print(f"{num1} is equal to {num2}")