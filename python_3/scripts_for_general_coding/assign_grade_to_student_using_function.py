# -*- coding: utf-8 -*-
"""
Created on Mon Apr 27 11:00:56 2020

@author: Ashish

Use the logic for assigning grade to student defined in
assign_grade_to_student.py script.
The idea is to create a function that will collect student
exam related data from the user like roll number, test mark, exam mark etc.
It will then pass this data as argument into another function.
The other function will pull the data out of the arguments
and use them for further analysis.


"""

# declare a global list to hold the multiple variable passed by the function
student_info_list = []


def get_student_details():
    stud_num = input("Enter the student number: ")
    stud_tutorial_mark = float(input("Enter student's tutorial mark:"))
    stud_test_mark = float(input("Enter student's test mark:"))
    stud_exam_mark = float(input("Enter student exam mark: "))
    # add data to list
    student_info_list.append(stud_num)
    student_info_list.append(stud_tutorial_mark)
    student_info_list.append(stud_test_mark)
    student_info_list.append(stud_exam_mark)
    # return a list of items
    return student_info_list


def calculate_grade(student_info_list):
    stud_num = student_info_list[0]
    stud_test_mark = student_info_list[1]
    stud_tutorial_mark = student_info_list[2]
    stud_exam_mark = student_info_list[3]
    if stud_tutorial_mark+stud_test_mark/2 < 40:
        grade = "Fail"
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
snum, fmark, grade = calculate_grade(get_stud_info)
print("student %s's final mark is %d and grade is %s." % (snum, fmark, grade))
