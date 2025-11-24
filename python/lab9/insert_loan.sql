INSERT INTO loan (copy_id, member_id, loan_date, return_date) VALUES
(1, (SELECT member_id FROM member WHERE last_name = 'Digest'), '2024-01-01', '2024-01-10'),
(2, (SELECT member_id FROM member WHERE last_name = 'Chapter'), '2024-01-05', '2024-01-12'),
(3, (SELECT member_id FROM member WHERE last_name = 'Footnote'), '2024-02-01', '2024-02-15'),
(4, (SELECT member_id FROM member WHERE last_name = 'Reader'), '2024-02-10', '2024-02-20'),
(5, (SELECT member_id FROM member WHERE last_name = 'Tome'), '2024-03-01', '2024-03-05'),
(6, (SELECT member_id FROM member WHERE last_name = 'Journal'), '2024-03-10', '2024-03-24'),
(7, (SELECT member_id FROM member WHERE last_name = 'Digest'), '2025-11-20', NULL),
(8, (SELECT member_id FROM member WHERE last_name = 'Chapter'), '2025-11-21', NULL),
(9, (SELECT member_id FROM member WHERE last_name = 'Footnote'), '2025-11-22', NULL),
(10, (SELECT member_id FROM member WHERE last_name = 'Reader'), '2025-11-23', NULL),
(1, (SELECT member_id FROM member WHERE last_name = 'Tome'), '2025-10-01', NULL),
(2, (SELECT member_id FROM member WHERE last_name = 'Journal'), '2025-10-15', NULL);