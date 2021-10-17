# -*- coding: utf-8 -*-
"""
Created on Sat Oct 16 10:13:39 2021
Objectve: To read multiple pdf files from given directory 
@author: Ashish
"""

import fitz
from os import listdir
import fnmatch


# doc_pdf = fitz.open("../../data/pdf/mycv.pdf")
# print("\nPage count: ", doc_pdf.page_count)
# print("\n Metadata:\n", doc_pdf.metadata)
# print(doc_pdf.get_toc())

# text = ""
# for page in doc_pdf:
#     text += page.getText()

# print(text)

## Reading multiple pdf files from directory
dataPath = "C:/Users/Ashoo/Documents/playground_R/applied-machine-learning/data/PDFS"
text = ""

for file in listdir(dataPath):
    # print(file)
    # doc = fitz.open(filetype="*.pdf")
    # print(doc)
    if fnmatch.fnmatch(file, '*.pdf'):
        doc = fitz.open(filetype="*.pdf")
        print(doc.get_toc())
        for page in doc:
            # print(page)
            text += page.get_page_text(1)
            print(text)
        # text += doc.getText()
    #     for pdfile in range(len(file)):
    #         doc = fitz.open(pdfile)
    #         text += doc.getText()
        # document = join('PDFS', file)
        # print(document)
        # doc = fitz.open(file)
        # print(doc)
    #     # doc = fitz.open(document)
    #     # text += doc.getText()



# dataPath = "C:/Users/Ashoo/Documents/playground_R/applied-machine-learning/python_3/data/pdf"
# filelist = [f for f in listdir(dataPath) if isfile(join(dataPath,f))]
# print(filelist)



# for k in range(1,10):
#     obj = fitz.open()

# for f in listdir(dataPath):
#     if isfile(join(dataPath. f)):
#         doc = fitz.open(myfile)
#         text += doc.getText()
        


# for myfile in filelist:
#     doc = fitz.open(myfile)
#     text += doc.getText()

# for myfile in filelst:
#     fpath = join(dataPath,myfile)
#     print(fpath)
    
#     with fitz.open(myfile):
#         text += myfile.getText()
#         pass
    
    # with open(fpath, 'rb') as fh:
    #     while True:
    #         doc = fitz.open(fh)
            
    #         pass
    
# list of files
# filelist = [f for f in listdir(dataPath) if isfile(join(dataPath,f))]
# print(filelist)
# # read list of files
# for myfile in filelist:
#     print(myfile)
    
#     doc = fitz.open(myfile)
#     # print("\n inside file list: ", myfile)
#     # try:
#     #     mydoc = fitz.open(myfile)
#     #     # print(mydoc)
#     #     text += mydoc.getText()
        
#     # except RuntimeError as err:
#     #     print(err)

# # print(text)

