# -*- coding: utf-8 -*-
"""
Created on Tue Apr 14 11:33:30 2020

@author: Ashish

Objective: To extract multiple excel sheets into a pandas dataframe
"""
# load required library
import pandas as pd

EXCEL_DATA = pd.ExcelFile('../data/sample_data.xlsx')
# print all sheets in the excel file
print(EXCEL_DATA.sheet_names)

# read a specific excel sheet data to a pandas object
excelsheet_data = pd.read_excel(EXCEL_DATA,"Sheet1")
#print(single_excelsheet_data.head)


# read multiple excel sheets to a pandas object
# Option 1: Easy
# Read all sheets and store in a dictionary
all_sheets={}
for sheet_name in EXCEL_DATA.sheet_names:
    all_sheets[sheet_name] = EXCEL_DATA.parse()
#print(all_sheets)

# Option 2: Difficult 
# multiple_excelsheet_data = {sheet_name: EXCEL_DATA.parse(sheet_name) for sheet_name in EXCEL_DATA.sheet_names}
# print(multiple_excelsheet_data)

# Read data from specific rows 
# reference: https://stackoverflow.com/questions/49876077/pandas-reading-excel-file-starting-from-the-row-below-that-with-a-specific-valu
## Step 1: Find the location of the starting column 
for row in range(excelsheet_data.shape[0]):
    for col in range(excelsheet_data.shape[1]):
        if excelsheet_data.iat[row, col]=='S.No.':
            row_start = row
            #print(row_start)
            break

# Step 2: after having row_start you can use subframe of pandas
excelsheet_data_required = excelsheet_data.loc[row_start+1:]
print(excelsheet_data_required)
    



