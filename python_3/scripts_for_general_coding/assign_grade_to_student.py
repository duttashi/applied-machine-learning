# -*- coding: utf-8 -*-
"""
Created on Mon Apr 27 10:06:26 2020

@author: Ashish

Question: Write a Python program to assign grades to students at the
end of the year.
The program must do the following:

Ask for a student number.
Ask for the student’s tutorial mark.
Ask for the student’s test mark.

Calculate whether the student’s average so far is high enough for the student
to be permitted to write the examination. If the average (mean) of the tutorial
and test marks is lower than 40%, the student should automatically get an F
grade, and the program should print the grade and exit without performing the
following steps.

Ask for the student’s examination mark.

Calculate the student’s final mark. The tutorial and test marks should count
for 25% of the final mark each, and the final examination should count
for the remaining 50%.

Calculate and print the student’s grade, according to the following table:

Weighted final score	Final grade
80 <= mark <= 100	A
70 <= mark < 80	B
60 <= mark < 70	C
50 <= mark < 60	D
mark < 50	E
"""

stud_num = input("Enter the student number: ")
stud_tutorial_mark = float(input("Enter student's tutorial mark:"))
stud_test_mark = float(input("Enter student's test mark:"))
if stud_tutorial_mark+stud_test_mark/2 < 40:
    grade = "Fail"
else:
    stud_exam_mark = float(input("Enter student exam mark: "))

final_mark = (stud_tutorial_mark+stud_test_mark+2*stud_exam_mark)/4
if 80 <= final_mark <= 100:
    grade = "A"
elif 70 <= final_mark < 80:
    grade = "B"
elif 60 <= final_mark < 70:
    grade = "C"
elif 50 <= final_mark < 60:
    grade = "D"
else:
    grade = "E"
print("student %s's grade is %s." % (stud_num, grade))
