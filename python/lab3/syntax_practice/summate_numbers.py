#!/usr/bin/python3

"""
    Program name: summate_numbers.py
    Program purpose: syntax practice for Iteration with conditional statement using while loop
    Author: Jacob P, 041156249, 010
    Date & version: 2025-09-15, version: 1.0
"""

# initialize sum with value of 0
sum = 0

# prompt user for a number if user enters 0 program will quit
addend = int(input("Enter a number (0 to quit): "))

# set up conditional expression as part of the while loop
while addend != 0:
    sum += addend
    addend = int(input("Enter a number (0 to quit): "))

# display the final sum
print("The total sum is:", sum)