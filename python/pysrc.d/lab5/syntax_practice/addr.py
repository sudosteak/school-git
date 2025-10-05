#!/bin/python3

"""
    program name: addr.py
    program purpose: create and call a function: two arguments and a return value
    author: jacob p, student-id, section-id
    date and version: 2025-10-05, version: 1.0
    completion time: ...
"""

def add(num1, num2):
    return num1 + num2

number_1 = int(input("enter a number: "))
number_2 = int(input("enter another number: "))

result = add(number_1, number_1)
print(f"the sum is: {result}")