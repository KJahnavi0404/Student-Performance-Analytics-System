"""
Student Performance Analytics System  (Part B)
Works only on CSV files: departments.csv, students.csv, subjects.csv, marks.csv
Run:  python main.py          -> menu program
      python main.py --all    -> generate report CSV + all 4 charts without the menu
"""
import os
import sys

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CHART_DIR = os.path.join(BASE_DIR, "charts")
BONUS_DIR = os.path.join(CHART_DIR, "bonus")
ATTENDANCE_FILE = os.path.join(BASE_DIR, "attendance.csv")
REPORT_FILE = os.path.join(BASE_DIR, "student_report.csv")
PASS_MARK = 40
FILES = {
    "departments": "departments.csv",
    "students": "students.csv",
    "subjects": "subjects.csv",
    "marks": "marks.csv",
}


# ----------------------------------------------------------------------
# DAY 3 : LOADING, MERGING, SAVING
# ----------------------------------------------------------------------
def csv_path(key):
    return os.path.join(BASE_DIR, FILES[key])


def load_raw():
    """Read the four CSV files into a dict of DataFrames."""
    data = {}
    for key in FILES:
        data[key] = pd.read_csv(csv_path(key))
    return data


def merge_all(data):
    """marks + students + departments + subjects (same as SQL query (a))."""
    df = pd.merge(data["marks"], data["students"], on="student_id", how="inner")
    df = pd.merge(df, data["departments"], on="dept_id", how="inner")
    df = pd.merge(df, data["subjects"], on="subject_id", how="inner")
    return df


def load_data():
    """Read and merge the CSV files; returns the merged DataFrame."""
    return merge_all(load_raw())


def save_marks(marks_df):
    """Write the marks table back to marks.csv."""
    marks_df.to_csv(csv_path("marks"), index=False)


def show_overview(data):
    """Day 3: head(), info(), describe() for every file."""
    for name, df in data.items():
        print(f"\n===== {name}.csv =====")
        print(df.head())
        df.info()
        print(df.describe())


# ----------------------------------------------------------------------
# DAY 4 : CLEANING AND ANALYSIS
# ----------------------------------------------------------------------
def clean_data(df):
    """Remove duplicates, convert marks to numbers, fill missing marks with subject mean."""
    df = df.drop_duplicates(subset=["student_id", "subject_id"]).copy()
    df["marks"] = pd.to_numeric(df["marks"], errors="coerce")
    df["marks"] = df.groupby("subject_name")["marks"].transform(lambda s: s.fillna(s.mean()))
    return df


def subject_stats(df):
    """NumPy mean, median and standard deviation for each subject."""
    rows = []
    for subject, grp in df.groupby("subject_name"):
        values = grp["marks"].to_numpy()
        rows.append({
            "subject": subject,
            "mean": round(float(np.mean(values)), 2),
            "median": round(float(np.median(values)), 2),
            "std_dev": round(float(np.std(values)), 2),
        })
    return pd.DataFrame(rows)


def build_report(df):
    """One row per student: subject marks, total, percentage, grade, status, rank."""
    pivot = df.pivot_table(index="student_id", columns="subject_name",
                           values="marks", aggfunc="mean")
    subjects = list(pivot.columns)
    report = pivot.copy()
    report["total"] = pivot.sum(axis=1)
    report["percentage"] = (report["total"] / (len(subjects) * 100) * 100).round(2)

    pct = report["percentage"]
    conditions = [pct >= 90, pct >= 80, pct >= 70, pct >= 60, pct >= 50, pct >= 40]
    grades = ["A+", "A", "B+", "B", "C", "D"]
    report["grade"] = np.select(conditions, grades, default="F")

    report["status"] = np.where((pivot < PASS_MARK).any(axis=1), "FAIL", "PASS")
    report["rank"] = report["percentage"].rank(ascending=False, method="min").astype(int)

    info = df[["student_id", "student_name", "dept_name", "semester"]].drop_duplicates("student_id")
    report = report.reset_index().merge(info, on="student_id")
    cols = ["student_id", "student_name", "dept_name", "semester"] + subjects + \
           ["total", "percentage", "grade", "status", "rank"]
    return report[cols].sort_values("rank").reset_index(drop=True)


def top_students(report, n=5):
    return report.head(n)[["rank", "student_id", "student_name", "dept_name", "percentage", "grade"]]


def pass_fail_count(report):
    return report["status"].value_counts()


def dept_average(df):
    """Department-wise average marks using groupby (compare with SQL query (e))."""
    return df.groupby("dept_name")["marks"].mean().round(2)


def dept_toppers(report):
    idx = report.groupby("dept_name")["percentage"].idxmax()
    return report.loc[idx, ["dept_name", "student_name", "percentage"]]


# ----------------------------------------------------------------------
# BONUS : attendance correlation, at-risk students, semester progress
# ----------------------------------------------------------------------
def load_attendance():
    """Return attendance DataFrame, or None if attendance.csv is missing."""
    try:
        return pd.read_csv(ATTENDANCE_FILE)
    except FileNotFoundError:
        return None


def attendance_correlation(report):
    """Correlation between attendance % and marks % using np.corrcoef."""
    att = load_attendance()
    if att is None:
        return None, None
    merged = pd.merge(report, att, on="student_id")
    r = np.corrcoef(merged["attendance_pct"], merged["percentage"])[0, 1]
    return float(r), merged


def at_risk_students(report):
    """Below 50% or failed in any subject."""
    risk = report[(report["percentage"] < 50) | (report["status"] == "FAIL")]
    return risk[["student_id", "student_name", "dept_name", "percentage", "status"]]


def semester_progress(report):
    return report.groupby("semester")["percentage"].mean().round(2)


# ----------------------------------------------------------------------
# DAY 5 : CHARTS  (each one saved as PNG)
# ----------------------------------------------------------------------
def finish_chart(fig, filename, show, folder=None):
    folder = folder or CHART_DIR
    os.makedirs(folder, exist_ok=True)
    path = os.path.join(folder, filename)
    fig.tight_layout()
    fig.savefig(path, dpi=150)
    print("Saved:", path)
    if show:
        plt.show()
    plt.close(fig)


def chart_subject_avg(df, show=False):
    avg = df.groupby("subject_name")["marks"].mean().round(2)
    fig, ax = plt.subplots(figsize=(9, 5))
    bars = ax.bar(avg.index, avg.values, color="steelblue")
    ax.bar_label(bars, fmt="%.1f")
    ax.set_title("Average Marks per Subject")
    ax.set_xlabel("Subject")
    ax.set_ylabel("Average Marks")
    ax.set_ylim(0, 100)
    plt.setp(ax.get_xticklabels(), rotation=20, ha="right")
    finish_chart(fig, "1_subject_average_bar.png", show)


def chart_grade_pie(report, show=False):
    counts = report["grade"].value_counts()
    fig, ax = plt.subplots(figsize=(6, 6))
    ax.pie(counts.values, labels=counts.index, autopct="%1.1f%%", startangle=90)
    ax.set_title("Grade Distribution")
    finish_chart(fig, "2_grade_distribution_pie.png", show)


def chart_marks_hist(df, show=False):
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.hist(df["marks"], bins=10, range=(0, 100), color="seagreen", edgecolor="black")
    ax.axvline(PASS_MARK, color="red", linestyle="--", label=f"Pass mark = {PASS_MARK}")
    ax.set_title("Distribution of All Marks")
    ax.set_xlabel("Marks")
    ax.set_ylabel("Number of Entries")
    ax.legend()
    finish_chart(fig, "3_marks_histogram.png", show)


def chart_dept_box(report, show=False):
    groups = report.groupby("dept_name")["percentage"]
    names = list(groups.groups.keys())
    values = [groups.get_group(n).values for n in names]
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.boxplot(values)
    ax.set_xticklabels(names)
    ax.set_title("Percentage by Department")
    ax.set_xlabel("Department")
    ax.set_ylabel("Percentage")
    finish_chart(fig, "4_department_boxplot.png", show)


def chart_attendance_scatter(report, show=False):
    r, merged = attendance_correlation(report)
    if merged is None:
        print("attendance.csv not found - skipping attendance chart.")
        return
    x, y = merged["attendance_pct"].to_numpy(), merged["percentage"].to_numpy()
    slope, intercept = np.polyfit(x, y, 1)
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.scatter(x, y, color="darkorange")
    ax.plot(np.sort(x), slope * np.sort(x) + intercept, color="black", label=f"Trend (r = {r:.2f})")
    ax.set_title("Attendance vs Marks")
    ax.set_xlabel("Attendance %")
    ax.set_ylabel("Percentage")
    ax.legend()
    finish_chart(fig, "5_attendance_vs_marks.png", show, BONUS_DIR)


def chart_semester_line(report, show=False):
    prog = semester_progress(report)
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(prog.index, prog.values, marker="o", color="purple")
    for x, y in zip(prog.index, prog.values):
        ax.annotate(f"{y:.1f}", (x, y), textcoords="offset points", xytext=(0, 8), ha="center")
    ax.set_title("Average Percentage by Semester")
    ax.set_xlabel("Semester")
    ax.set_ylabel("Average Percentage")
    ax.set_xticks(list(prog.index))
    finish_chart(fig, "6_semester_progress_line.png", show, BONUS_DIR)


def make_all_charts(df, report, show=False):
    chart_subject_avg(df, show)
    chart_grade_pie(report, show)
    chart_marks_hist(df, show)
    chart_dept_box(report, show)
    chart_attendance_scatter(report, show)   # bonus
    chart_semester_line(report, show)        # bonus


# ----------------------------------------------------------------------
# INPUT HELPERS (validation)
# ----------------------------------------------------------------------
def ask_number(prompt, low, high, cast=int):
    """Keep asking until a valid number in [low, high] is typed."""
    while True:
        text = input(prompt).strip()
        try:
            value = cast(text)
        except ValueError:
            print("  Please enter a number only.")
            continue
        if low <= value <= high:
            return value
        print(f"  Value must be between {low} and {high}.")


def ask_existing_id(prompt, valid_ids):
    while True:
        value = ask_number(prompt, 1, 10**9)
        if value in valid_ids:
            return value
        print("  That ID does not exist. Valid IDs:", sorted(valid_ids)[:10], "...")


# ----------------------------------------------------------------------
# MENU ACTIONS
# ----------------------------------------------------------------------
def add_update_marks():
    data = load_raw()
    students, subjects, marks = data["students"], data["subjects"], data["marks"]
    print(subjects[["subject_id", "subject_name"]].to_string(index=False))
    sid = ask_existing_id("Student ID: ", set(students["student_id"]))
    sub = ask_existing_id("Subject ID: ", set(subjects["subject_id"]))
    value = ask_number("Marks (0-100): ", 0, 100, cast=float)

    mask = (marks["student_id"] == sid) & (marks["subject_id"] == sub)
    if mask.any():
        marks.loc[mask, "marks"] = value
        print("Existing entry updated.")
    else:
        new_id = int(marks["mark_id"].max()) + 1
        marks.loc[len(marks)] = [new_id, sid, sub, value]
        print("New entry added.")
    save_marks(marks)


def view_student_report():
    report = build_report(clean_data(load_data()))
    sid = ask_existing_id("Student ID: ", set(report["student_id"]))
    row = report[report["student_id"] == sid].iloc[0]
    print(f"\nStudent : {row['student_name']} ({row['dept_name']}, Sem {row['semester']})")
    skip = {"student_id", "student_name", "dept_name", "semester", "total",
            "percentage", "grade", "status", "rank"}
    for col in report.columns:
        if col not in skip:
            print(f"  {col:<22}: {row[col]:.0f}")
    print(f"Total {row['total']:.0f} | {row['percentage']}% | Grade {row['grade']} "
          f"| {row['status']} | Rank {row['rank']}")


def show_toppers():
    report = build_report(clean_data(load_data()))
    print("\nTOP 5 STUDENTS")
    print(top_students(report).to_string(index=False))
    print("\nDEPARTMENT TOPPERS")
    print(dept_toppers(report).to_string(index=False))


def show_analysis():
    df = clean_data(load_data())
    report = build_report(df)
    print("\nSUBJECT STATISTICS (NumPy)")
    print(subject_stats(df).to_string(index=False))
    print("\nPASS / FAIL COUNT")
    print(pass_fail_count(report).to_string())
    print("\nDEPARTMENT-WISE AVERAGE")
    print(dept_average(df).to_string())
    print("\nAT-RISK STUDENTS (below 50% or any failed subject)")
    print(at_risk_students(report).to_string(index=False))
    r, _ = attendance_correlation(report)
    if r is not None:
        print(f"\nATTENDANCE vs MARKS correlation (np.corrcoef): {r:.3f}")
    print("\nSEMESTER-WISE AVERAGE PERCENTAGE")
    print(semester_progress(report).to_string())


def show_charts():
    df = clean_data(load_data())
    make_all_charts(df, build_report(df), show=True)


def export_report():
    report = build_report(clean_data(load_data()))
    report.to_csv(REPORT_FILE, index=False)
    print("Report exported to", REPORT_FILE)


MENU = """
===== STUDENT PERFORMANCE ANALYTICS =====
1) Add / update marks
2) View student report
3) Show topper list
4) Show analysis
5) Show charts
6) Export report to CSV
0) Exit
"""
ACTIONS = {
    1: add_update_marks,
    2: view_student_report,
    3: show_toppers,
    4: show_analysis,
    5: show_charts,
    6: export_report,
}


def main():
    while True:
        print(MENU)
        choice = ask_number("Enter choice: ", 0, 6)
        if choice == 0:
            print("Goodbye!")
            break
        try:
            ACTIONS[choice]()
        except FileNotFoundError as err:
            print("File not found:", err.filename, "- keep the CSV files next to main.py.")
        except PermissionError:
            print("Cannot write the file. Close it in Excel and try again.")
        except (KeyError, ValueError, pd.errors.EmptyDataError) as err:
            print("Data problem in the CSV files:", err)


if __name__ == "__main__":
    if "--all" in sys.argv:
        try:
            data = load_raw()
            show_overview(data)
            merged = clean_data(merge_all(data))
            rep = build_report(merged)
            rep.to_csv(REPORT_FILE, index=False)
            make_all_charts(merged, rep, show=False)
            print("\nSubject stats:\n", subject_stats(merged))
            print("\nDept average:\n", dept_average(merged))
            print("\nPass/Fail:\n", pass_fail_count(rep))
        except FileNotFoundError as e:
            print("File not found:", e.filename)
    else:
        main()
