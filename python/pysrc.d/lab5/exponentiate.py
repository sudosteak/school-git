#!/bin/python3

"""
    program name: exponentiate.py
    program purpose: calculate exponentiation with user-defined function(s) without global variables
    author: jacob p, student-id, section-id
    date and version: 2025-10-05, version: 1.0
    completion time: ~30 minutes
"""

# prompt user for a number and convert to integer
def get_integer(prompt):
    return int(input(prompt))

# multiply a number by itself
def square(num):
    return num * num

# multiplies a number by itself twice (cubes it)
def cube(num):
    return num ** 3

# main program
number = get_integer("enter a number (negative to quit): ")

while number >= 0:
    if number == 0:
        print("0")
    elif number == 1:
        print("1")
    else:
        squared = square(number)
        cubed = cube(number)
        print(f"{number} squared is {squared} and cubed is {cubed}")
    
    number = get_integer("enter a number (negative to quit): ")

print("goodbye")