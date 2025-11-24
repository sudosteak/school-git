INSERT INTO book_copy (isbn, acquisition_date) VALUES
((SELECT isbn FROM book WHERE title = '1984'), '2020-12-24'),
((SELECT isbn FROM book WHERE title = '1984'), '2021-01-15'),
((SELECT isbn FROM book WHERE title = 'Emma'), '2020-12-24'),
((SELECT isbn FROM book WHERE title = 'Emma'), '2021-03-21'),
((SELECT isbn FROM book WHERE title = 'Emma'), '2021-03-21'),
((SELECT isbn FROM book WHERE title = 'Moby Dick'), '2021-05-01'),
((SELECT isbn FROM book WHERE title = 'Moby Dick'), '2021-05-01'),
((SELECT isbn FROM book WHERE title = 'Pride and Prejudice'), '2021-06-01'),
((SELECT isbn FROM book WHERE title = 'Hamlet'), '2021-07-01'),
((SELECT isbn FROM book WHERE title = 'The Great Gatsby'), '2021-08-01');
