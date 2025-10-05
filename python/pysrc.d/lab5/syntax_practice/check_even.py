#!/bin/python3

"""
    program name: check_even.py
    program purpose: create and call a function: one argument and a return value of true/false
    author: jacob p, student-id, section-id
    date and version: 2025-10-05, version: 1.0
    completion time: ...
"""

def is_even(num):
    return num % 2 == 0

number = int(input("enter a number: "))
if is_even(number) == True:
    print("even")
elif is_even(number) == False:
    print("odd")
