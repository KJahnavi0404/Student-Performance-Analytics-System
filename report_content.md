# REPORT TEXT (paste into Word/Google Docs, add screenshots, export as Report.pdf, 3-5 pages)

## 1. Introduction
A college needs to store student marks in an organised database and analyse them. In Part A, a normalized MySQL database (student_analytics) is designed with four tables: departments, students, subjects and marks. In Part B, the data is exported as CSV files and analysed using Pandas and NumPy, visualised using Matplotlib, and wrapped in a menu-driven Python program.
Objectives: design a 3NF database with constraints; write JOIN queries and stored functions; load and merge CSV data with Pandas; compute statistics with NumPy; present results with charts; build a validated mini-application.

## 2. Database Design
[Insert ER diagram: departments 1---M students 1---M marks M---1 subjects]
Tables:
- departments(dept_id PK, dept_name UNIQUE NOT NULL, hod_name NOT NULL)
- students(student_id PK, student_name NOT NULL, email UNIQUE NOT NULL, dept_id FK, semester DEFAULT 1 CHECK 1-8)
- subjects(subject_id PK, subject_name UNIQUE NOT NULL, credits DEFAULT 4)
- marks(mark_id PK, student_id FK, subject_id FK, marks CHECK 0-100, UNIQUE(student_id, subject_id))

Normalization:
1NF: all values are atomic, no repeating groups, every table has a primary key.
2NF: every non-key attribute depends on the whole primary key (single-column keys, so no partial dependency).
3NF: no transitive dependency; department details are only in departments, subject details only in subjects, student details only in students. marks holds just the mark and foreign keys.

## 3. SQL Work
- Constraints used: PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT.
- Data: 4 departments, 6 subjects, 30 students, 180 marks (+ 30 attendance rows for the bonus).
- Queries: (a) 3-table-plus JOIN of marks with student, department, subject; (b) subject-wise AVG/MAX/MIN with GROUP BY; (c) department topper using SUM + RANK() window function; (d) students with marks < 40; (e) department average using LEFT JOIN.
- Functions: get_grade(marks), get_percentage(student_id), get_result(student_id) (bonus).
[Insert screenshots of query outputs]
[Insert constraint-test screenshots, one per error: CHECK marks=150 (Error 3819), duplicate (student,subject) (1062), semester=9 (3819), duplicate e-mail (1062), invalid dept FK (1452), NULL name (1048)]

## 4. Python Work
CSV files used: departments.csv, students.csv, subjects.csv, marks.csv (exported from MySQL).
Code overview (main.py):
- load_raw(), merge_all(), load_data(): read CSVs with pd.read_csv and combine with pd.merge, equivalent to SQL JOIN query (a).
- save_marks(): writes marks back to marks.csv.
- clean_data(): drop_duplicates, pd.to_numeric(errors="coerce"), fill missing marks with subject mean.
- subject_stats(): NumPy mean, median, std per subject.
- build_report(): pivot table, total, percentage, grade (np.select), PASS/FAIL, rank.
- Charts: four functions saving PNG files in charts/.
- Menu: 1 Add/update marks, 2 Student report, 3 Toppers, 4 Analysis, 5 Charts, 6 Export, 0 Exit. Input is validated (numbers only, marks 0-100, IDs must exist) and file errors are caught with try/except.
[Insert screenshots: head()/info()/describe(), merged DataFrame, report table, menu running]

## 5. Results
[Insert charts/1_subject_average_bar.png] Average marks are similar across subjects (about 66-70), with Physics slightly highest.
[Insert charts/2_grade_distribution_pie.png] Most students fall in grades B+ to A; a small share get D or F.
[Insert charts/3_marks_histogram.png] Most marks lie between 60 and 90; the red line at 40 shows the few failing entries on its left. (Check your own chart and adjust the wording.)
[Insert charts/4_department_boxplot.png] Computer Science has the highest median percentage; compare spread between departments. (Check your own chart and adjust.)
Verification: Pandas department averages (Computer Science 70.54, Mechanical 68.83, Electronics 66.44, Civil 65.17) match SQL query (e).

## 5A. Bonus Work
- attendance table (att_id PK, student_id FK UNIQUE, attendance_pct CHECK 0-100) and attendance.csv.
- Correlation between attendance and marks computed with np.corrcoef: r = 0.685 (moderate-to-strong positive: students who attend more score higher). [Insert charts/bonus/5_attendance_vs_marks.png]
- At-risk list (below 50% or any failed subject): 10 students. [Insert menu option 4 screenshot]
- Semester-wise average percentage as a line chart. [Insert charts/bonus/6_semester_progress_line.png]

## 6. Conclusion
Learned: database design and normalization, constraints, JOINs and stored functions, Pandas merge/pivot/groupby, NumPy statistics, Matplotlib charts, input validation.
Problems faced: [write your own, e.g. exporting CSV from Workbench, MySQL function error 1418, Matplotlib label overlap].
Future improvements: connect Python to MySQL directly, add attendance table, semester-wise progress line chart, a GUI or web interface.
