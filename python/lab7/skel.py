#!/bin/python3

"""
    program name: skel.py
    program purpose: create a skeleton program to manage a database
    author: jacob p, 041156249, 013
    date and version: 2025-11-09, version: 1.0
    completion time: ~1-2 hours
"""

# imports
import sqlite3

# constants
DB_NAME = "library.db"


# functions
def show_menu():
    # display menu options
    print("1. display all books by title")
    print("2. display all members by last name")
    print("Q. quit")


def get_menu_option():
    # get menu option
    return input("select option: ").strip().upper()


def get_attribute_value(prompt):
    # prompt user for an attr value
    return input(prompt).strip()


# database connections, followed by cursor setup
connection = sqlite3.connect(DB_NAME)
cursor = connection.cursor()

# main program skeleton
option = ''
while option != 'Q':
    show_menu()
    option = get_menu_option()
    
    if option == '1':
        print("TODO: display all books")
    elif option == '2':
        last_name = get_attribute_value("enter last name: ")
        print(f"TODO: display members with last name {last_name}")
    elif option == 'Q':
        print("quitting program...")
    else:
        print("invalid option, try again")

# closing of cursor, followed by closing of database connection
cursor.close()
connection.close()