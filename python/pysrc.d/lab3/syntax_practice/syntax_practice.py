#!/usr/bin/python3

"""
    Program name: syntax_practice.py
    Program purpose: syntax practice for logical operators and compound expressions
    Author: Jacob P, 041156249, 010
    Date & version: 2025-09-15, version: 1.0
"""

# evaluate the result of logical operators
print("True and False =", True and False)
print("False and False =", False and False)
print("True or False =", True or False)
print("False or False =", False or False)
print("not True =", not True)
print("not True and True =", not True and True)
print("not True and not False =", not True and not False)
print("not (True and False) =", not (True and False))

# evaluate the result of compound expressions
print("10 > 11 and 11 < 12 =", 10 > 11 and 11 < 12)
print("10 < 11 or 11 > 12 =", 10 < 11 or 11 > 12)
print("\"apple\" == \"apple\" or \"apple\" == \"banana\" =", "apple" == "apple" or "apple" == "banana")
print("\"apple\" != \"Apple\" or \"banana\" != \"banana\" =", "apple" != "Apple" or "banana" != "banana")
print("\"apple\" != \"Apple\" and \"apple\" != \"banana\" =", "apple" != "Apple" and "apple" != "banana")
