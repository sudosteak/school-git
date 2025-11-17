CREATE TABLE loan (
    loan_id serial PRIMARY KEY,
    copy_id int REFERENCES book_copy(copy_id),
    member_id int REFERENCES member(member_id),
    loan_date date NOT NULL,
    return_date date
);
