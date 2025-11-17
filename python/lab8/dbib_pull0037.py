#!/bin/python3

"""
    program name: dbib_pull0037.py
    program purpose: create a program to interact with a database
    author: jacob p, 041156249, 013
    date and version: 2025-11-16, version: 1.0
    completion time: ~30 mins
"""

# imports
import psycopg2
import sys

# constants
DB_NAME = input("Enter database name: ")
DB_USER = input("Enter database user: ")

# database connections
try:
    connection=psycopg2.connect(database=DB_NAME, user=DB_USER)
except psycopg2.DatabaseError:
    print("error: connection to database failed")
    sys.exit(1) # early exit with error code 1
print("connected to database")

# create a cursor
cursor = connection.cursor()

# execute a simple query
cursor.execute('\dt')

# fetch and print the results

# close the connection
cursor.close()
connection.close()