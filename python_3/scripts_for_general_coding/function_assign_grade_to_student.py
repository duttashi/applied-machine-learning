# -*- coding: utf-8 -*-
"""
Created on Mon Apr 27 11:00:56 2020

@author: Ashish

Use the logic for assigning grade to student defined in
assign_grade_to_student.py script.
Now, create a function for the same

"""


def get_student_details():
    stud_num = input("Enter the student number: ")
    stud_tutorial_mark = float(input("Enter student's tutorial mark:"))
    stud_test_mark = float(input("Enter student's test mark:"))
    return stud_num, stud_test_mark, stud_tutorial_mark


def calculate_grade(sno, test_mark, tut_mark):
    stud_num = sno
    stud_test_mark = test_mark
    stud_tutorial_mark = tut_mark
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
    return stud_num, final_mark, grade


# call the function
get_stud_info = get_student_details()
print(get_stud_info)
snum = get_stud_info[0]
testmarks = get_stud_info[1]
tutmarks = get_stud_info[2]
print(snum, testmarks, tutmarks)
print(calculate_grade(snum, testmarks, tutmarks))
# get_report_card = calculate_grade(snum, testmarks, tutmarks)
# print("student %s's grade is %s." % (stud_num, grade))
# print(get_report_card)
