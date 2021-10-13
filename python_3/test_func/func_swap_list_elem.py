# -*- coding: utf-8 -*-
"""
Created on Wed Oct 13 08:45:35 2021
Objective: Given a list in Python and provided the positions of the elements, write a program to swap the two elements in the list.
@author: Ashish
"""

# define function
def swapListElem(mylist, pos1, pos2):
    # mylist[pos1] = mylist[pos2]
    # mylist[pos2] = mylist[pos1]
    mylist[pos1], mylist[pos2] = mylist[pos2], mylist[pos1]
    
    return mylist


# define global vars
mylist = [10,23,45,67,11]
pos1, pos2 = 1,3
print("\nOriginal list: ",mylist)

# invoke the function
new_list = swapListElem(mylist, pos1, pos2)
print("\nSwap Elements: ", new_list) 