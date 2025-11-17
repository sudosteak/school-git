#!/usr/bin/python3

"""
    Program name: match_colour.py
    Program purpose: syntax practice for Conditional expression & two-way decision with if-else
    Author: Jacob P, 041156249, 010
    Date & version: 2025-09-15, version: 1.0
"""

# prompt user for a colour and store input in colour variable
colour = input("what colour is the algonquin college logo? ").lower()

# check if the colour matches "green"
if colour == "green":
    print(f"correct, the colour of the algonquin college logo is {colour}!\nexiting program...")
else:
    print(f"incorrect, the colour of the algonquin college logo is green, not {colour}.\nexiting program...")