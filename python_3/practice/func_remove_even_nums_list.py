# -*- coding: utf-8 -*-
"""
Created on Wed Oct 13 09:39:46 2021
Objective: remove even numbers from a list
@author: Ashish
"""

# n = int(input("Enter a number: "))
# numlst = []

# for i in range(n):
#     numlst.append(i)

# print(numlst)

# for num in numlst:
#     # print(num)
#     if(num % 2 == 0):
#         # numlst.pop(num)
#         # numlst[num]= -1
#         try:
#             #numlst.pop(num)
#             #del numlst[num]
#             numlst.remove(num)
#         except IndexError:
#             print("sorry! cant remove that")
#         # print(numlst[num])
#     else:
#         continue

# print(numlst)
        

def remove_even_number_list():
    inp = int(input("\nWhat number range you want?: "))
    # declare empty list
    numlst = []
    # add numbers in list based on number range taken as input
    for num in range(inp):
        numlst.append(num)
    # main logic
    for num in numlst:
        # check for even number
        if(num % 2 == 0):
            
            # error handling
            try:
                numlst.remove(num)
            except IndexError:
                print("\n Sorry! can't remove that!")
        else:
            continue
    
    return numlst

if __name__ == '__main__':
    mylst = remove_even_number_list()
    print(mylst)