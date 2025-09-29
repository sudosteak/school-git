#!/usr/bin/python3

"""
    program name: guess_number.py
    program purpose: guess the number game (read loop with nested decision)
    author: Jacob P, 041156249, 010
    date & version: 2025-09-28, version: 1.0
    completion time: 1 hour
"""

# import the random module to generate a random number
import random

# generate a secret number between 1 and 9
secret = random.randint(1, 9)

# get the first guess from the user
guess = int(input("guess a number between 1 and 9 (or enter 0 to quit): "))

# continue until user guesses correctly or quits
while guess != 0 and guess != secret:
    if guess < secret:
        # give user a hint if their guess is too low
        print("too low!")
    else:
        # give user a hint if their guess is too high
        print("too high!")
    # prompt user for their next guess
    guess = int(input("guess a number between 1 and 9 (or enter 0 to quit): "))

# display appropriate message based on how the loop ended
if guess == secret:
    print("congratulations! you guessed the correct number!")
elif guess == 0:
    print(f"thanks for playing! the secret number was {secret}.")
