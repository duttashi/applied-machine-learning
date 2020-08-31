# -*- coding: utf-8 -*-
"""
Created on Thu Jul  2 13:39:14 2020

@author: Ashish
Objective: accept two numbers and yield their sum of squares
Hint: input should be cast to integer. Use built is square()
"""

def get_user_input():
    num = int(input("Enter a number: "))
    return num

# define function
def sum_of_squares(num1,num2):
    return num1*num1 + num2*num2

num1 = get_user_input()
num2 = get_user_input()
resp = input("Press a to get the sum of squares\n Press b to exit: ")

if (resp == "a" or resp == "A"):
    result = sum_of_squares(num1, num2)
    print("The sum of squares for number ",num1, " and number ", num2, " is ",result)
    ans = input("\n Do you want to continue (y/n): ")
    while(ans!='n'):
        num1 = get_user_input()
        num2 = get_user_input
        #resp = input("Press a to get the sum of squares\n Press b to exit: ")

        result = sum_of_squares(num1,num2)
        print("The sum of squares for number ",num1, " and number ", num2, " is ",result)
        ans = input("\n Do you want to continue (y/n): ")
else:
    print("Good bye")
    exit()



