# Lab #10.1: Form SQL queries

Overview

Objective

The objective of this lab is to form SQL queries to search the database.

Outcomes

  Create SQL queries against one or more tables.
  Use psql output functionality to facilitate data management.

Knowledge expected

  Form SQL queries against one or more tables:

o  Display all records.
o  Display sorted records.
o  Display all records that match a condition.
o  Display all records that match a compound condition.
  To use the psql \w sub-command to save SQL statements to a file.
  To use the psql \g sub-command to save SQL query results to a file.

Submission instructions

  READ ALL THE WORDS
  You must follow ALL submission instructions: Submission instructions are explained in the “Lab
10 submission details” document, posted on BrightSpace. ANY submission instructions below
NOT followed result in a grade of zero.
Note: This includes extra functionality that has not been requested.

  You are expected to complete all exercises, even those not are not required to be submitted.

Background

SQL syntax

  The semicolon at the end of the statement is part of the SQL syntax.
  SQL commands are case-insensitive.

Common syntax failures

  Example of a regular prompt for a superuser: dabase_name=#

  Example of a regular prompt for a non-superuser: dabase_name=>
  Example of prompt indicating a missing closing bracket: dabase_name(#
  Example of prompt indicating a missing closing semi-colon: dabase_name-#
  To cancel a bad command use: \r.

Scenario: Library logical design

Library ERD: Logical design

Note: If there is a
discrepancy between
the logical ERD and the
lab description the ERD
is authoritative.

Note on loan: A separate primary_key
(loan_id) rather than a composite key
of the foreign keys (copy_code +
member_id) enables the database to
store multiple loans of the same book
by the same member.

book

PK

isbn

title

rental_days

member

loan

book_copy

PK

member_id

PK

loan_id

PK

copy_id

FK

isbn

acquisition_date

first_name

last_name

phone

FK

copy_id

FK

member_id

loan_date

return_date

due_date
(derived)

Section A – Form SQL queries on a single table

Note: The query examples and exercises given below may not reflect your data. Adjust where
necessary to achieve successful queries.

Syntax practice #1: Display all records.

  Select all records.

o  Syntax: `SELECT * FROM table;`
o  Example: `SELECT * FROM book;`

  Select specified attributes for all records.

Note: To display only certain attributes, replace the ‘*’ with a comma-separated list of
column names.

o  Syntax: `SELECT column(s) FROM table;`
o  Example:  `SELECT first_name, last_name FROM member;`
o  Exercise: Display the book title and rental days of all records in the book table.

Syntax practice #2: Display all records, sorted.

  Sort all records: ORDER BY

o  Syntax: `SELECT * FROM table ORDER BY column(s) [ASC|DESC];`
o  Example: `SELECT * FROM member ORDER BY last_name ASC, first_name ASC;`

o  Exercise: Display the book title and ISBN number of all books sorted by title in

ascending order.

o  Exercise: Display first and last name of all members sorted by last name in ascending

order.

Syntax practice #3: Display all records that match a condition using comparison operators.

We are selecting all records that match a condition using the WHERE clause.

The following comparison operators are accepted by the WHERE clause: =, !=, <, >, <=, >=

  Select records using the WHERE clause with a comparison operator.

o  Syntax: `SELECT * FROM table WHERE column = value;`
o  Example: `SELECT * FROM book WHERE title = ‘Moby Dick’;`
o  Exercise: Display the first and last name of all member records where the last name

is not ‘Simpson’.

o  Exercise: Display the title and rental days of all books where the number of rental

days is greater than 7 days.

o  Exercise: Select all book copies where the acquisition date is less or equal than 2022-

12-31 (or any other reasonable date).

Syntax practice #4: Select all records that match a condition using alternative match criteria.

 We are selecting all records that match a condition using the WHERE clause with alternative match
criteria.

  BETWEEN AND (equivalent to >= and <=)

o  Example: `SELECT * FROM book_copy WHERE acquisition_date BETWEEN ‘2010-12-31’ AND ‘2020-12-31’;`

  LIKE # Note: resource intensive query

o  Example: `SELECT * FROM member WHERE last_name LIKE ‘Chap%’;`
o  Example: `SELECT * FROM member WHERE last_name LIKE ‘%eade’;`

  IS [NOT] NULL

o  Example: `SELECT * FROM loan WHERE return_date IS NOT NULL;`

  IN

o  Example: `SELECT * FROM member WHERE last_name IN (‘Reader’, ‘Digest’, ‘Noname’);`

Syntax practice #5: Select all records that match a compound condition.

  AND

o  Example: `SELECT * FROM member where last_name = ‘Reader’ AND first_name = ‘Robin’;`

  OR

o  Example: `SELECT * FROM member where last_name = ‘Reader’ OR first_name = ‘Chris’;`

Section B – Save a query to a file

The interactive psql utility has sub-commands to save SQL statements written at the psql
prompt and query results to a file in the current directory.

Syntax practice #6: Save a query.

  Syntax: \w file # saves the last executed SQL command to a file from the query buffer.

Note: To view the query buffer use \p.

  Exercise:

In psql display all books by title only.

o
o  Save the query to a file named book_title.query using the psql sub-

command \w.

o  Verify that the query command has been saved in a text file in your current Linux

directory.

FYI: Save a query result.

To save the query result of a previously executed SQL query to a file use the psql subcommand:
\g file.

Section C – SQL Queries: Join multiple tables

Overview

  There four types of joins: inner join, full join, left join, right join. The most common join type

is the inner join.

  Tables are joined on a common column provided by the primary key in the parent table that

is referenced by the foreign key in the related table.

  The basic join syntax identifies:

o  the attributes to display
o  the tables to join
o  the common field in the table-pairs to join: PK-FK
o  optional clauses: match, sort

Join two tables

Syntax example for joining two tables

```sql
SELECT column(s)
  FROM table1
  JOIN table2 ON table1.pkey = table2.fkey
  [WHERE condition]
  [ORDER BY];
```

Note: Attributes (columns) may include the table name. This must be used when we need to
disambiguate the same column name in different tables.
Example: `SELECT member.last_name, author.last_name`

Syntax practice #7: Join two tables and sort records.

  Request: Display all book copies for all books, sort by title.
  Query:

```sql
SELECT copy_id, title
  FROM book
  JOIN book_copy ON book.isbn = book_copy.isbn
  ORDER BY title;
```

Syntax practice #8: Join two tables and filter result set based on condition.

  Request: Display all book copies for the book ‘Moby Dick’.
  Query:

```sql
SELECT title, copy_id
  FROM book
  JOIN book_copy ON book.isbn = book_copy.isbn
  WHERE title = ‘Moby Dick’;
```

Exercise #9: Join two tables, sort result set.

  Request: Display title and acquisition date of all book copies & sort by book title.

o  Which attributes do you list for display?
o  Which tables do you join?
o  Which column(s) do you use to join the tables?
o  Which optional clause(s) do you include?

Exercise #10: Join two tables and filter result set based on compound condition.

  Request: Display loan date, return date and copy id for all loans (past & current) by the

member “Chris Chapter”.

o  Which attributes do you list for display?
o  Which tables do you join?
o  Which column(s) do you use to join the tables?
o  Which conditions are used in the matching clause?

Note: Display a minimum of two records (add more records where necessary).

Join tables with intersecting table

Syntax example for joining three tables that represent a many-to-many relationship

```sql
SELECT table1.column, table2.column
  FROM table1
  JOIN linktable ON table1.primarykey = linktable.foreignkey
  JOIN table2    ON table2.primarykey = linktable.foreignkey
```

Syntax practice #11: Join three tables that include an intersecting table, filter and sort result set.

  Request: Display all book copies borrowed by the member “Robin Reader” (past & current).

o  List attributes to display: [member.]first_name, [member.]last_name,

[book_copy.]isbn, [loan.]loan_date, [loan.]return_date
Note: Data in brackets are optional but it helps to identify the tables that have to be
included in the join.

o  List tables to join: member, book_copy, loan
o
Identify the column(s) to join the tables:
  member & loan: member_id
  book_copy & loan: copy_id

o  Specify required clause(s): compound matching clause to filter for the member

“Robin Reader”

Note: Display a minimum of two records (add more records where necessary).

  Query:

```sql
SELECT first_name, last_name, isbn, loan_date, return_date
  FROM book_copy
  JOIN loan   ON book_copy.copy_id = loan.copy_id
  JOIN member ON member.member_id  = loan.member_id
  WHERE last_name = ‘Reader’ AND first_name = ‘Robin’;
```

Note: The table in the query order can be reversed, starting with the member table.

Join multiple tables

Syntax practice #12: Join three tables & sort result set.

  Request: Display all book loans (current & past) and sort by title.

o  List attributes to display: title, loan_date, return_date

o  List tables to join: ______________________________________
o

Identify the column(s) to join the tables:

  _______________________________________________
  _______________________________________________
o  Specify required clause(s): _______________________________

  Query:

```sql
SELECT title, loan_date, return_date
  FROM book
  JOIN book_copy ON book.isbn         = book_copy.isbn
  JOIN loan      ON book_copy.copy_id = loan.copy_id
  ORDER BY title;
```

Syntax practice #13: Join three tables with derived attribute.

  Request: Display due dates for all book loans (current & past).

o  List attributes to display: title, loan_date, due_date (derived from loan_date and

rental_days)

o  List tables to join: book, book_copy, loan
o
Identify the column(s) to join the tables:

  book, book_copy: isbn
  book_copy, loan: copy_id

  Query:

```sql
SELECT title, loan_date, loan_date + rental_days AS due_date
  FROM book
  JOIN book_copy ON book.isbn         = book_copy.isbn
  JOIN loan      ON book_copy.copy_id = loan.copy_id;
```

Exercise #14: Join more than three tables & sort result set.

  Request: Display all book loans (past & current) of all members and sort by last name.

o  List attributes to display: last_name, title, loan_date, return_date
o  List tables to join: ________________________________________________
o

Identify the column(s) to join the tables:

  _________________________________________________________
  _________________________________________________________
  _________________________________________________________
o  Specify required clause(s): _________________________________________
