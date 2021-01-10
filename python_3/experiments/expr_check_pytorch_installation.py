# -*- coding: utf-8 -*-
"""
Created on Mon Dec 28 12:18:40 2020

@author: Ashish
"""

from __future__ import print_function
import torch

x = torch.empty(5, 3)
print(x)

if torch.cuda.is_available():
    device = torch.device("cuda")          # a CUDA device object
    y = torch.ones_like(x, device=device)  # directly create a tensor on GPU
    x = x.to(device)                       # or just use strings ``.to("cuda")``
    z = x + y
    print(z)
    print(z.to("cpu", torch.double))
else:
    print("torch cuda not available")