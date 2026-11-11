-- =====================================================================
-- Student Performance Analytics System  |  project.sql  (Part A)

-- =====================================================================

DROP DATABASE IF EXISTS student_analytics;
CREATE DATABASE student_analytics;
USE student_analytics;

-- ---------------------------------------------------------------------
-- DAY 1 : TABLES AND CONSTRAINTS
-- ---------------------------------------------------------------------
CREATE TABLE departments (
    dept_id     INT AUTO_INCREMENT PRIMARY KEY,                -- PRIMARY KEY
    dept_name   VARCHAR(50) NOT NULL UNIQUE,                   -- NOT NULL + UNIQUE
    hod_name    VARCHAR(50) NOT NULL
);

CREATE TABLE students (
    student_id    INT AUTO_INCREMENT PRIMARY KEY,
    student_name  VARCHAR(60) NOT NULL,
    email         VARCHAR(80) NOT NULL UNIQUE,                 -- e-mail must be unique
    dept_id       INT NOT NULL,
    semester      TINYINT NOT NULL DEFAULT 1,                  -- DEFAULT
    CONSTRAINT chk_semester CHECK (semester BETWEEN 1 AND 8),  -- CHECK
    CONSTRAINT fk_student_dept FOREIGN KEY (dept_id)           -- FOREIGN KEY
        REFERENCES departments(dept_id)
);

CREATE TABLE subjects (
    subject_id    INT AUTO_INCREMENT PRIMARY KEY,
    subject_name  VARCHAR(60) NOT NULL UNIQUE,
    credits       TINYINT NOT NULL DEFAULT 4
);

CREATE TABLE marks (
    mark_id     INT AUTO_INCREMENT PRIMARY KEY,
    student_id  INT NOT NULL,
    subject_id  INT NOT NULL,
    marks       DECIMAL(5,2) NOT NULL,
    CONSTRAINT chk_marks CHECK (marks BETWEEN 0 AND 100),                 -- marks 0-100
    CONSTRAINT uq_student_subject UNIQUE (student_id, subject_id),        -- one entry per subject
    CONSTRAINT fk_marks_student FOREIGN KEY (student_id) REFERENCES students(student_id),
    CONSTRAINT fk_marks_subject FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- BONUS table: attendance (one row per student)
CREATE TABLE attendance (
    att_id          INT AUTO_INCREMENT PRIMARY KEY,
    student_id      INT NOT NULL UNIQUE,
    attendance_pct  DECIMAL(5,2) NOT NULL,
    CONSTRAINT chk_att CHECK (attendance_pct BETWEEN 0 AND 100),
    CONSTRAINT fk_att_student FOREIGN KEY (student_id) REFERENCES students(student_id)
);

/* NORMALIZATION 
1NF: Every column holds a single atomic value (no lists/repeating groups); each table has a primary key.
2NF: All tables are in 1NF and every non-key column depends on the WHOLE key. marks has a single-column
     key (mark_id), so no partial dependency; the pair (student_id, subject_id) is also kept UNIQUE.
3NF: No transitive dependency. Department name/HOD are stored only in departments (students keeps just
     dept_id); subject name/credits only in subjects. Student name/email only in students.
     Marks stores only the mark value plus foreign keys, so no non-key column depends on another non-key column.
*/

-- ---------------------------------------------------------------------
-- DAY 2 : SAMPLE DATA  (4 departments, 6 subjects, 30 students, 180 marks, + bonus attendance)
-- ---------------------------------------------------------------------
INSERT INTO departments (dept_id, dept_name, hod_name) VALUES
(1,'Computer Science','Dr. A. Sharma'),
(2,'Electronics','Dr. R. Verma'),
(3,'Mechanical','Dr. S. Rao'),
(4,'Civil','Dr. K. Reddy');

INSERT INTO subjects (subject_id, subject_name, credits) VALUES
(1,'Python Programming',4),
(2,'Mathematics',4),
(3,'Database Systems',4),
(4,'Physics',3),
(5,'Data Structures',4),
(6,'English',2);

INSERT INTO students (student_id, student_name, email, dept_id, semester) VALUES
(1,'Aarav Sharma','aarav.sharma@college.edu',1,2),
(2,'Ananya Reddy','ananya.reddy@college.edu',2,1),
(3,'Rohan Verma','rohan.verma@college.edu',3,5),
(4,'Priya Nair','priya.nair@college.edu',4,4),
(5,'Karthik Rao','karthik.rao@college.edu',1,4),
(6,'Sneha Iyer','sneha.iyer@college.edu',2,3),
(7,'Vikram Singh','vikram.singh@college.edu',3,2),
(8,'Divya Patel','divya.patel@college.edu',4,2),
(9,'Arjun Mehta','arjun.mehta@college.edu',1,7),
(10,'Lakshmi Devi','lakshmi.devi@college.edu',2,1),
(11,'Rahul Gupta','rahul.gupta@college.edu',3,1),
(12,'Pooja Kumari','pooja.kumari@college.edu',4,2),
(13,'Sai Teja','sai.teja@college.edu',1,4),
(14,'Meera Joshi','meera.joshi@college.edu',2,4),
(15,'Aditya Kulkarni','aditya.kulkarni@college.edu',3,1),
(16,'Neha Das','neha.das@college.edu',4,4),
(17,'Harsha Vardhan','harsha.vardhan@college.edu',1,7),
(18,'Isha Banerjee','isha.banerjee@college.edu',2,4),
(19,'Manoj Kumar','manoj.kumar@college.edu',3,8),
(20,'Swathi Reddy','swathi.reddy@college.edu',4,5),
(21,'Nikhil Jain','nikhil.jain@college.edu',1,1),
(22,'Kavya Menon','kavya.menon@college.edu',2,3),
(23,'Suresh Babu','suresh.babu@college.edu',3,7),
(24,'Tanvi Shah','tanvi.shah@college.edu',4,6),
(25,'Varun Chowdary','varun.chowdary@college.edu',1,5),
(26,'Ritu Agarwal','ritu.agarwal@college.edu',2,3),
(27,'Deepak Yadav','deepak.yadav@college.edu',3,4),
(28,'Bhavana Rao','bhavana.rao@college.edu',4,6),
(29,'Imran Khan','imran.khan@college.edu',1,2),
(30,'Sowmya Pillai','sowmya.pillai@college.edu',2,2);

INSERT INTO marks (mark_id, student_id, subject_id, marks) VALUES
(1,1,1,67),
(2,1,2,57),
(3,1,3,67),
(4,1,4,29),
(5,1,5,64),
(6,1,6,76),
(7,2,1,91),
(8,2,2,88),
(9,2,3,71),
(10,2,4,70),
(11,2,5,80),
(12,2,6,88),
(13,3,1,87),
(14,3,2,85),
(15,3,3,55),
(16,3,4,92),
(17,3,5,67),
(18,3,6,23),
(19,4,1,78),
(20,4,2,71),
(21,4,3,67),
(22,4,4,86),
(23,4,5,71),
(24,4,6,62),
(25,5,1,86),
(26,5,2,74),
(27,5,3,79),
(28,5,4,74),
(29,5,5,82),
(30,5,6,93),
(31,6,1,63),
(32,6,2,69),
(33,6,3,61),
(34,6,4,58),
(35,6,5,68),
(36,6,6,46),
(37,7,1,67),
(38,7,2,75),
(39,7,3,59),
(40,7,4,64),
(41,7,5,24),
(42,7,6,46),
(43,8,1,65),
(44,8,2,64),
(45,8,3,78),
(46,8,4,80),
(47,8,5,54),
(48,8,6,64),
(49,9,1,61),
(50,9,2,36),
(51,9,3,80),
(52,9,4,63),
(53,9,5,64),
(54,9,6,57),
(55,10,1,51),
(56,10,2,52),
(57,10,3,43),
(58,10,4,37),
(59,10,5,39),
(60,10,6,56),
(61,11,1,62),
(62,11,2,40),
(63,11,3,53),
(64,11,4,59),
(65,11,5,57),
(66,11,6,72),
(67,12,1,35),
(68,12,2,49),
(69,12,3,56),
(70,12,4,62),
(71,12,5,71),
(72,12,6,57),
(73,13,1,39),
(74,13,2,64),
(75,13,3,52),
(76,13,4,73),
(77,13,5,71),
(78,13,6,69),
(79,14,1,61),
(80,14,2,66),
(81,14,3,70),
(82,14,4,77),
(83,14,5,76),
(84,14,6,49),
(85,15,1,53),
(86,15,2,65),
(87,15,3,64),
(88,15,4,75),
(89,15,5,57),
(90,15,6,59),
(91,16,1,72),
(92,16,2,74),
(93,16,3,74),
(94,16,4,59),
(95,16,5,86),
(96,16,6,38),
(97,17,1,88),
(98,17,2,83),
(99,17,3,77),
(100,17,4,66),
(101,17,5,76),
(102,17,6,99),
(103,18,1,63),
(104,18,2,49),
(105,18,3,61),
(106,18,4,54),
(107,18,5,59),
(108,18,6,55),
(109,19,1,71),
(110,19,2,77),
(111,19,3,80),
(112,19,4,88),
(113,19,5,78),
(114,19,6,76),
(115,20,1,67),
(116,20,2,64),
(117,20,3,69),
(118,20,4,68),
(119,20,5,62),
(120,20,6,77),
(121,21,1,76),
(122,21,2,32),
(123,21,3,62),
(124,21,4,75),
(125,21,5,58),
(126,21,6,66),
(127,22,1,76),
(128,22,2,82),
(129,22,3,75),
(130,22,4,72),
(131,22,5,64),
(132,22,6,89),
(133,23,1,86),
(134,23,2,80),
(135,23,3,79),
(136,23,4,80),
(137,23,5,66),
(138,23,6,86),
(139,24,1,67),
(140,24,2,71),
(141,24,3,76),
(142,24,4,81),
(143,24,5,75),
(144,24,6,70),
(145,25,1,58),
(146,25,2,86),
(147,25,3,83),
(148,25,4,74),
(149,25,5,75),
(150,25,6,88),
(151,26,1,30),
(152,26,2,86),
(153,26,3,59),
(154,26,4,79),
(155,26,5,82),
(156,26,6,74),
(157,27,1,78),
(158,27,2,92),
(159,27,3,71),
(160,27,4,75),
(161,27,5,92),
(162,27,6,76),
(163,28,1,45),
(164,28,2,42),
(165,28,3,53),
(166,28,4,57),
(167,28,5,64),
(168,28,6,56),
(169,29,1,79),
(170,29,2,86),
(171,29,3,79),
(172,29,4,86),
(173,29,5,71),
(174,29,6,86),
(175,30,1,74),
(176,30,2,69),
(177,30,3,88),
(178,30,4,80),
(179,30,5,55),
(180,30,6,84);

INSERT INTO attendance (att_id, student_id, attendance_pct) VALUES
(1,1,79.2),
(2,2,99.5),
(3,3,83.1),
(4,4,90.8),
(5,5,89.9),
(6,6,73.9),
(7,7,70.7),
(8,8,89.9),
(9,9,82.1),
(10,10,69.9),
(11,11,91.7),
(12,12,73.3),
(13,13,81.0),
(14,14,83.1),
(15,15,77.4),
(16,16,93.6),
(17,17,99.6),
(18,18,67.8),
(19,19,87.8),
(20,20,84.6),
(21,21,82.0),
(22,22,81.7),
(23,23,79.4),
(24,24,76.8),
(25,25,88.8),
(26,26,82.3),
(27,27,93.2),
(28,28,68.1),
(29,29,85.7),
(30,30,77.4);

-- ---------------------------------------------------------------------
-- STORED FUNCTIONS
-- ---------------------------------------------------------------------


CREATE FUNCTION get_grade(p_marks DECIMAL(5,2))
RETURNS VARCHAR(2)
DETERMINISTIC
BEGIN
    DECLARE g VARCHAR(2);
    IF p_marks >= 90 THEN SET g = 'A+';
    ELSEIF p_marks >= 80 THEN SET g = 'A';
    ELSEIF p_marks >= 70 THEN SET g = 'B+';
    ELSEIF p_marks >= 60 THEN SET g = 'B';
    ELSEIF p_marks >= 50 THEN SET g = 'C';
    ELSEIF p_marks >= 40 THEN SET g = 'D';
    ELSE SET g = 'F';
    END IF;
    RETURN g;
END$$

-- every subject is out of 100, so percentage = average of the student's marks
CREATE FUNCTION get_percentage(p_student_id INT)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE pct DECIMAL(5,2);
    SELECT ROUND(SUM(marks) / (COUNT(*) * 100) * 100, 2) INTO pct
    FROM marks WHERE student_id = p_student_id;
    RETURN pct;
END$$

-- BONUS: FAIL if the student has marks < 40 in at least one subject
CREATE FUNCTION get_result(p_student_id INT)
RETURNS VARCHAR(4)
READS SQL DATA
BEGIN
    DECLARE failed INT;
    SELECT COUNT(*) INTO failed FROM marks WHERE student_id = p_student_id AND marks < 40;
    RETURN IF(failed > 0, 'FAIL', 'PASS');
END$$

DELIMITER ;

-- Test the functions
SELECT get_grade(85) AS grade_85, get_percentage(1) AS pct_student_1, get_result(1) AS result_student_1;
SELECT student_id, student_name, get_percentage(student_id) AS pct,
       get_grade(get_percentage(student_id)) AS grade, get_result(student_id) AS result
FROM students;

-- ---------------------------------------------------------------------
-- JOIN QUERIES
-- ---------------------------------------------------------------------
-- (a) marks with student, department and subject name
SELECT m.mark_id, s.student_name, d.dept_name, sub.subject_name, m.marks
FROM marks m
JOIN students    s   ON m.student_id = s.student_id
JOIN departments d   ON s.dept_id    = d.dept_id
JOIN subjects    sub ON m.subject_id = sub.subject_id
ORDER BY s.student_id, sub.subject_id;

-- (b) subject-wise average, highest and lowest marks
SELECT sub.subject_name,
       ROUND(AVG(m.marks),2) AS avg_marks,
       MAX(m.marks) AS highest,
       MIN(m.marks) AS lowest
FROM marks m
JOIN subjects sub ON m.subject_id = sub.subject_id
GROUP BY sub.subject_id, sub.subject_name;

-- (c) department-wise topper (highest total marks in each department)
WITH totals AS (
    SELECT s.student_id, s.student_name, d.dept_name, SUM(m.marks) AS total_marks,
           RANK() OVER (PARTITION BY d.dept_id ORDER BY SUM(m.marks) DESC) AS rnk
    FROM students s
    JOIN departments d ON s.dept_id = d.dept_id
    JOIN marks m       ON m.student_id = s.student_id
    GROUP BY s.student_id, s.student_name, d.dept_id, d.dept_name
)
SELECT dept_name, student_name, total_marks
FROM totals WHERE rnk = 1;

-- (d) students failing in at least one subject (marks < 40)
SELECT s.student_id, s.student_name, sub.subject_name, m.marks
FROM marks m
JOIN students s    ON m.student_id = s.student_id
JOIN subjects sub  ON m.subject_id = sub.subject_id
WHERE m.marks < 40
ORDER BY s.student_id;

-- (e) department average using LEFT JOIN
SELECT d.dept_name, ROUND(AVG(m.marks),2) AS avg_marks
FROM departments d
LEFT JOIN students s ON s.dept_id = d.dept_id
LEFT JOIN marks m    ON m.student_id = s.student_id
GROUP BY d.dept_id, d.dept_name;

-- ---------------------------------------------------------------------
-- BONUS QUERIES
-- ---------------------------------------------------------------------
-- (f) AT-RISK students: percentage below 50 OR failed in any subject
SELECT s.student_id, s.student_name, get_percentage(s.student_id) AS pct, get_result(s.student_id) AS result
FROM students s
WHERE get_percentage(s.student_id) < 50 OR get_result(s.student_id) = 'FAIL';

-- (g) attendance vs average marks (the correlation itself is calculated in Python with np.corrcoef)
SELECT s.student_name, a.attendance_pct, get_percentage(s.student_id) AS pct
FROM students s JOIN attendance a ON a.student_id = s.student_id
ORDER BY a.attendance_pct DESC;

-- (h) average percentage per semester
SELECT s.semester, ROUND(AVG(m.marks),2) AS avg_marks
FROM students s JOIN marks m ON m.student_id = s.student_id
GROUP BY s.semester ORDER BY s.semester;

-- ---------------------------------------------------------------------
-- CONSTRAINT TESTS : run each line ONE BY ONE, each must FAIL.
-- Screenshot the error message for the report.  (Commented so the script runs cleanly.)
-- ---------------------------------------------------------------------
-- 1. CHECK (marks > 100)          -> Error 3819: Check constraint 'chk_marks' is violated
-- INSERT INTO marks (student_id, subject_id, marks) VALUES (1, 1, 150);
-- 2. UNIQUE (duplicate pair)      -> Error 1062: Duplicate entry '1-1' for key 'marks.uq_student_subject'
-- INSERT INTO marks (student_id, subject_id, marks) VALUES (1, 1, 50);
-- 3. CHECK (semester = 9)         -> Error 3819: Check constraint 'chk_semester' is violated
-- INSERT INTO students (student_name, email, dept_id, semester) VALUES ('Test One', 'test1@college.edu', 1, 9);
-- 4. UNIQUE (duplicate e-mail)    -> Error 1062: Duplicate entry for key 'students.email'
-- INSERT INTO students (student_name, email, dept_id) VALUES ('Test Two', 'aarav.sharma@college.edu', 1);
-- 5. FOREIGN KEY (dept 99)        -> Error 1452: Cannot add or update a child row
-- INSERT INTO students (student_name, email, dept_id) VALUES ('Test Three', 'test3@college.edu', 99);
-- 6. NOT NULL (name is NULL)      -> Error 1048: Column 'student_name' cannot be null
-- INSERT INTO students (student_name, email, dept_id) VALUES (NULL, 'test4@college.edu', 1);
-- 7. CHECK on attendance (110)    -> Error 3819: Check constraint 'chk_att' is violated
-- INSERT INTO attendance (student_id, attendance_pct) VALUES (1, 110);
-- 8. DEFAULT (works!)  semester gets 1 automatically; then delete the test row:
-- INSERT INTO students (student_name, email, dept_id) VALUES ('Test Five', 'test5@college.edu', 1);
-- SELECT student_name, semester FROM students WHERE email = 'test5@college.edu';
-- DELETE FROM students WHERE email = 'test5@college.edu';

-- ---------------------------------------------------------------------
-- DAY 3 : EXPORT TO CSV  (Workbench: run SELECT * FROM table; -> Result Grid -> Export)
-- Needed columns: departments(dept_id,dept_name,hod_name) students(student_id,student_name,email,dept_id,semester)
--                 subjects(subject_id,subject_name,credits) marks(mark_id,student_id,subject_id,marks)
-- ---------------------------------------------------------------------
SELECT * FROM departments;
SELECT * FROM students;
SELECT * FROM subjects;
SELECT * FROM marks;
SELECT * FROM attendance;   -- bonus: columns att_id,student_id,attendance_pct
