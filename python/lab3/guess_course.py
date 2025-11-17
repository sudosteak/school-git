#!/usr/bin/python3

"""
    Program name: guess_course.py
    Program purpose: Exercise #2: Iteration: Evaluate user input repeatedly
    Author: Jacob P, 041156249, 010
    Date & version: 2025-09-15, version: 1.0
    Completion time: ~15 minutes
"""

# predefined course code as constant
COURSE_CODE = "cst8245"

# prompt user for the course number and quit option
user_input = input("enter course code (q to quit): ").lower()

# loop until the user guesses correctly or opts to quit
while user_input != "q" and user_input != COURSE_CODE:
    user_input = input(f"{user_input} is incorrect, enter course code (q to quit): ").lower()

# check if the user guessed correctly or chose to quit then respond accordingly
if user_input == COURSE_CODE:
    print(f"{COURSE_CODE} is the correct course code\nprogram ending...")
else:
    print("you chose to quit\nprogram ending...")