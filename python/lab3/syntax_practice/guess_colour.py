"""
    Program name: guess_colour.py
    Program purpose: syntax practice for Iteration with conditional statement using while loop
    Author: Jacob P, 041156249, 010
    Date & version: 2025-09-15, version: 1.0
"""

# initialize variable
colour_guess = ""

# prompt user for the colour of algonquin college logo until the user decides to quit ("q" to quit)
colour_guess = input("what is the colour of algonquin college logo? (q to quit): ").lower()

# while the user does not want to quit and the colour entered is not correct reprompt user
while colour_guess != "q" and colour_guess != "green":
    colour_guess = input(f"{colour_guess} is incorrect, please try again. (q to quit): ").lower()

# check if user decided to quit or guessed the correct colour then display appropriate message
if colour_guess == "q":
    print("exiting program...")
else:
    print(f"correct, the algonquin college logo is {colour_guess}.\nexiting program...")