#!/bin/python3

"""
    program name: display_menu.py
    program purpose: create and call a function: one argument and a return value
    author: jacob p, student-id, section-id
    date and version: 2025-10-05, version: 1.0
    completion time: ...
"""

# define functions
def show_menu():
    print("menu item1")
    print("menu item2")
    print("menu item3")
    print("menu item4")
    # ...
    return

def get_menu_choice(prompt):
    choice = input(prompt)
    return choice

# call the functions
show_menu()
menu_choice = get_menu_choice("select a menu option: ")
print(f"you selected: {menu_choice}")
