# Lab 7: Develop a relational database design

## Overview

### Objective

Explore the steps in database design: develop the relational database design based on a conceptual
ERD to set up a relational database: set up all relations, relation attributes, and attribute constraints
(primary key/foreign key).

### Outcomes

- Develop the logical design for a relational database to satisfy business requirements.

### Knowledge expected

- To interpret a conceptual ERD.
- To set up relations and attributes.
- To set up a primary key.
- To determine relationships and relationship cardinality.
- To set up foreign keys.

### Submission instructions

- READ ALL THE WORDS
- You must follow ALL submission instructions: Submission instructions are explained in the "Lab 7
submission details" document, posted on BrightSpace. ANY submission instructions below NOT
followed result in a grade of zero.
Note: This includes extra functionality that has not been requested, unless approved.

- You are expected to complete all exercises, even those not are not required to be submitted.

---

## Section A – Conceptual design

### Business specifications

**Entities and characteristics:**

- **Books**: ISBN, title, maximum number of days to borrow
- **Book copies**: date acquired
- **Members**: first name, last name, phone number

**Business process details (business rules):**

- A book has one or more copies.
- A library member may borrow any number of books.
- The library needs to maintain a history of all book loans to assess inventory for upgrades: for each loaned book the following information will be maintained: loan date, due date, return date.

### Conceptual design

Below find the conceptual ERD diagram of the library's first business rule: the ERD diagram for the
conceptual design models entities and business processes.

#### Library ERD: Conceptual design

```
Book (1) → has → (M) Book copy
Member (M) → borrows → (M) Book copy
```

Note: The conceptual design lists 3 entities and one many-to-many relationship, which has to be resolved by an intersecting (link) table. Therefore, the total number of relations will be 4.

### Modeling steps

We will follow the modeling steps below to develop the logical design.

**To model relations:**

- Create a relation for each entity in the conceptual ERD.
- Describe each relation with attributes.
- Select the primary key for each relation.

**To model relationships:**

- Identify all relationships between relations and determine relationship cardinality (one-one, one-many, many-many).
- Resolve many-to-many relationships with an additional intersecting relation.
- Identify all foreign keys.

---

## Section B – Model relations

### Exercise #1: Create relations and corresponding attributes.

Complete the table below:

- For each entity in the conceptual ERD, name the relation, respecting naming convention.
- For each characteristic, name the attribute, respecting naming convention.

Note: The naming of relations and attributes has to follow the naming convention: singular, lower case, words_separated_by_underscore.

| Entity | Characteristics | Relation | Attributes |
|--------|----------------|----------|------------|
| Book | • ISBN<br>• Title<br>• Days to loan | book<br>*Alternatives:* book_info, publication, etc. | • isbn<br>• title<br>• rental_days |
| Book copy | • Date acquired | | |
| Member | • First name<br>• Last name<br>• Phone number | | |

---

### Exercise #2: Select or create the primary key for each relation.

The primary key is the distinguishing attribute of a relation. It is used to uniquely identify each 'relation instance', AKA 'tuple' AKA 'record'.

**Example of natural primary key:** The ISBN is an attribute that uniquely identifies each published book. As such, it is a good candidate for a primary key.

**Example of surrogate primary key:** A member's attribute may be first name, last name and email. Neither of these attributes identifies a member uniquely and unambiguously. Therefore, we create an additional attribute that functions as a primary key.

Note: By convention, this attribute is a unique integer number and the attribute name is id or `<relation>_id` (example: member_id).

Complete the table below: Select a primary key for each relation.

| Relation | Primary key attribute | Key type (surrogate, natural) |
|----------|----------------------|-------------------------------|
| book | isbn | natural |
| | | |
| | | |

| Entity | | |
|--------|--------|--------|
| Book | | |
| Book copy | | |
| Member | | |

---

## Section C – Model relationships

### Exercise #3: Identify business processes and set up corresponding relationships with their cardinalities.

Based on the business processes depicted in the conceptual ERD, the following relationships have been identified:

- A book has a publisher.
- A book has copies.
- A member borrows books.

We have to determine how many entity instances can participate in the relationship. The table below lists the maximum number of entities that can participate in the relationship. This is referred to as the relationship's cardinality.

Complete the table below: Note the cardinality for each relationship using the following notation:

- **1-M**: to identify a one-to-many relationship
- **M-M**: to identify a many-to-many relationship

| Relationship | Cardinality description | Cardinality |
|--------------|------------------------|-------------|
| A book has a copy. | One book may have many copies.<br>One copy is associated with exactly one book. | |
| A member borrows a book. | One member may borrow many book copies.<br>One book copy may be borrowed multiple times; in other words: one book copy may be borrowed by many members. | |

---

### Exercise #4: Resolve many-to-many relationships.

A many-to-many relationship is resolved by adding an 'intersecting' (AKA link AKA associative) relation.

Note: The intersecting relation creates two one-to-many relationships, where the intersecting relation represents the 'many' side and the so-called parent relations represent the 'one' side.

To resolve the many-to-many relationship between members and book copies (see conceptual ERD):

- Create an additional relation for book loans.
- Add the attributes that the library wants to maintain for each loan: loan date, due date (a derived attribute), return date.

**Note on derived attribute:**

- An attribute that can be determined from existing data is called a derived attribute. The database computes its value when requested; it does not store the value: this prevents data inconsistencies.
- The value for the attribute "due date" can be calculated using existing data: loan date + rental days = due date.

- Create a primary key attribute for the intersecting relation.

Complete the table below: Name the relation and the attributes for the new entity book loan, and identify the primary key.

| Relation | Attributes | Primary key attribute | Key type (surrogate, natural) |
|----------|------------|----------------------|-------------------------------|
| | | | |

---

### Exercise #5: Identify all foreign keys.

The purpose of a foreign key is to link two relations to reflect the relationship between them. A foreign key is an attribute in one participating relation that 'references' the primary key of the parent relation.

**Example:** 'A book may have many copies.'

- This relationship is modeled as a 1-M relationship.
  - One book may have many copies.
  - One copy represents exactly one book.

- To model the relationship we use the primary key of the 'one' side, which is the book table, and replicate it as an additional attribute in the 'many' side, which is the book copy table. The replicated attribute is called the foreign key.

Complete the table below: Identify all foreign keys for each relation where applicable.

| Relation | Primary key | Foreign key(s): identify parent table |
|----------|-------------|---------------------------------------|
| book | isbn | n/a |
| | | |
| | | |
| | | |

| Entity | | |
|--------|--------|--------|
| Book | | |
| Book copy | | |
| Member | | |
| Loan | | |

---

### Logical design summary table

| Entity | Relation name | Attribute names:<br>- identify PK<br>- identify FK |
|--------|---------------|-----------------------------------------------------|
| Book | book | PK: isbn<br>• title<br>• rental_days |
| Book copy | | PK:<br>FK:<br>• |
| Member | | PK:<br>• <br>• <br>• |
| Book loan | | PK:<br>FK:<br>FK:<br>• <br>• <br>• due_date (derived) |

---

## Next steps (subsequent labs)

- **Logical ERD:** The logical ERD is a diagrammatic representation of the logical design: for each relation it lists all attributes and identifies the primary and foreign keys.

- **Physical ERD:** Once the logical ERD is complete, we proceed to the physical design phase, which provides the template for the implementation of the database in an RDBMS.
