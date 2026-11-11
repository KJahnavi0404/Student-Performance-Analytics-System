# Student Performance Analytics System

B.Tech Puja Vacation Project: MySQL (Part A) + Python/Pandas/NumPy/Matplotlib (Part B).

## Files
| File | Purpose |
|---|---|
| project.sql | Schema, sample data, stored functions, JOIN queries, constraint tests |
| departments.csv, students.csv, subjects.csv, marks.csv | Data exported from MySQL |
| main.py | Menu-driven program (loading, analysis, charts, report export) |
| attendance.csv | BONUS: attendance data (5th table `attendance` in SQL) |
| charts/ | 4 required PNG charts (+ `charts/bonus/` with 2 extra charts) |
| student_report.csv | Exported student report |
| Report.pdf | Project report |

## How to run
1. **MySQL part:** `mysql -u root -p < project.sql` (MySQL 8.0.16+).
2. **Export CSVs:** in Workbench run `SELECT * FROM <table>;` then Result Grid -> Export. Save with the same file names next to `main.py`.
3. **Python part:**
   ```
   pip install pandas numpy matplotlib
   python main.py          # menu program
   python main.py --all    # creates all charts + student_report.csv directly
   ```

## Notes
- Python never connects to MySQL; data moves through CSV files.
- Pass mark = 40. A student FAILs if any subject is below 40.
- Grades: A+ >=90, A >=80, B+ >=70, B >=60, C >=50, D >=40, else F.

## Bonus features (up to +10 marks)
- `attendance` table/CSV and attendance-vs-marks correlation using `np.corrcoef` (menu option 4, scatter chart with trend line)
- At-risk students (below 50% or any failed subject): menu option 4
- Semester-wise progress line chart: `charts/bonus/6_semester_progress_line.png`
