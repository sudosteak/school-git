#!/usr/bin/env python3
"""
    program name: lab9.py
    program purpose: Library database management
    author: jacob pulleyblank
    date: 2025-11-23
"""

import psycopg2
import sys


def get_db_connection():
    try:
        db_name = input("Enter database name: ")
        db_user = input("Enter database user: ")
        connection = psycopg2.connect(database=db_name, user=db_user)
        return connection
    except psycopg2.DatabaseError as e:
        print(f"Error: connection to database failed: {e}")
        sys.exit(1)

def query_books(cursor):
    """
    Function purpose: display all books, sorted by title
    Query of table(s): book
    Displayed attributes: title, isbn, rental_days
    """
    sql_query = "SELECT title, isbn, rental_days FROM book ORDER BY title ASC"
    try:
        cursor.execute(sql_query)
        print(f"{'Title':<30} {'ISBN':<15} {'Rental Days':<10}")
        print("-" * 60)
        record = cursor.fetchone()
        while record:
            # record is a tuple (title, isbn, rental_days)
            print(f"{record[0]:<30} {record[1]:<15} {record[2]:<10}")
            record = cursor.fetchone()
    except psycopg2.Error as e:
        print(f"Error executing query: {e}")

def query_member_by_lastname(cursor, last_name):
    """
    Function purpose: display member information of a given member
    Query of table(s): member
    Displayed attributes: member id, last name, first name, phone
    """
    sql_query = "SELECT member_id, last_name, first_name, phone FROM member WHERE last_name = %s"
    sql_data = (last_name,)
    try:
        cursor.execute(sql_query, sql_data)
        print(f"{'ID':<5} {'Last Name':<15} {'First Name':<15} {'Phone':<15}")
        print("-" * 55)
        record = cursor.fetchone()
        if not record:
            print("No member found with that last name.")
        while record:
            print(f"{record[0]:<5} {record[1]:<15} {record[2]:<15} {record[3]:<15}")
            record = cursor.fetchone()
    except psycopg2.Error as e:
        print(f"Error executing query: {e}")

def get_attribute_value(prompt):
    return input(prompt).strip()

def show_menu():
    print("\nLibrary Database Menu")
    print("1. Display all books (sorted by title)")
    print("2. Display member by last name")
    print("Q. Quit")

def main():
    connection = get_db_connection()
    cursor = connection.cursor()
    print("Connected to database.")

    option = ''
    while option != 'Q':
        show_menu()
        option = input("Select option: ").strip().upper()

        if option == '1':
            query_books(cursor)
        elif option == '2':
            last_name = get_attribute_value("Enter member last name: ")
            query_member_by_lastname(cursor, last_name)
        elif option == 'Q':
            print("Exiting program.")
        else:
            print("Invalid option. Please try again.")

    cursor.close()
    connection.close()

if __name__ == "__main__":
    main()
