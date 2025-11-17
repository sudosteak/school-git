#!/usr/bin/python3

"""
    Program name: show_stars.py
    Program purpose: syntax practice for Iteration with loop control variable using for loop
    Author: Jacob P, 041156249, 010
    Date & version: 2025-09-15, version: 1.0
"""

num_stars = int(input("enter number of stars: "))
for i in range(num_stars):
    print("*", end="")
print()