# -*- coding: utf-8 -*-
"""
Created on Sun Jan  3 21:42:35 2021

@author: Ashish
"""

import torch

x = torch.rand(5, 3)
print(x)
print(torch.cuda.is_available())
