#!/bin/python3

"""
    program name: division.py
    program purpose: create and call a function that divides two numbers entered in calling function and returns the quotient.
    Author: Jacob P, 041156249, 010
    Date & version: 2025-09-23, version: 1.0
"""

# initialize variables
op1 = 0.0
op2 = 0.0
quotient = 0.0

# function to divide two numbers and return the quotient
def divide(op1, op2):
    if op2 != 0:
        return op1 / op2
    else:
        return "undefined"

# prompt user for input
dividend = float(input("enter the dividend: "))
divisor = float(input("enter the divisor: "))

# call the divide function and print the result
quotient = divide(dividend, divisor)
print("result:", quotient)
