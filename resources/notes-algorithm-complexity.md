#### Algorithm development

**Question** The question is about finding the smallest non-negative integer that does not occur in a list. The solution complexity must be linear i.e. `*O(n)*`. This question can be asked in the following two flavors:

***Question style 1:*** 
Suppose that you are given a very long, unsorted list of unsigned 64-bit integers. How would you find the smallest non-negative integer that does not occur in the list?

FOLLOW-UP: Now that the obvious solution by sorting has been proposed, can you do it faster than O(n log n)?

FOLLOW-UP: Your algorithm has to run on a computer with, say, 1GB of memory

CLARIFICATION: The list is in RAM, though it might consume a large amount of it. You are given the size of the list, say N, in advance.

***Question style 2:***
Given an array of unique positive integers, find the smallest possible number to insert into it so that every integer is still unique. The algorithm should be in `O(n)` and the additional space complexity should be constant. Assigning values in the array to other integers is allowed.

For example, for an array `[5, 3, 2, 7]`, output should be `1`. However for `[5, 3, 2, 7, 1]`, the answer should then be `4`.

*Reference: this question was initially asked on SO [1](https://stackoverflow.com/questions/1586858/find-the-smallest-integer-not-in-a-list), [2](https://stackoverflow.com/questions/56526387/insert-a-smallest-possible-positive-integer-into-an-array-of-unique-integers)*



****

- **Solution #1: Pseudo-code:**

If the datastructure can be mutated in place and supports random access then you can do it in O(N) time and O(1) additional space. Just go through the array sequentially and for every index write the value at the index to the index specified by value, recursively placing any value at that location to its place and throwing away values > N. Then go again through the array looking for the spot where value doesn't match the index - that's the smallest value not in the array. This results in at most 3N comparisons and only uses a few values worth of temporary space.

- **Solution #1: Code:**
    
    	# Pass 1, move every value to the position of its value
	    for cursor in range(N):
    	target = array[cursor]
	    while target < N and target != array[target]:
    	new_target = array[target]
    	array[target] = target
	    target = new_target
    
    	# Pass 2, find first location where the index doesn't match the value
    	for cursor in range(N):
    	if array[cursor] != cursor:
    	return cursor
    	return N

- **Solution# 2: Pseudo-code:** 

The array `A` is assumed 1-indexed. We call an active value one that is nonzero and does not exceed  `n`.

Scan the array until you find an active value, let `A[i] = k` (if you can't find one, stop);

While `A[k]` is active,

Move `A[k]` to `k` while clearing `A[k]`;
Continue from `i` until you reach the end of the array.

After this pass, all array entries corresponding to some integer in the array are cleared.

Find the first nonzero entry, and report its index.
E.g.

    [5, 3, 2, 7], clear A[3]
    [5, 3, 0, 7], clear A[2]
    [5, 0, 0, 7], done
The answer is `1`.

E.g.

    [5, 3, 2, 7, 1], clear A[5],
    [5, 3, 2, 7, 0], clear A[1]
    [0, 3, 2, 7, 0], clear A[3],
    [0, 3, 0, 7, 0], clear A[2],
    [0, 0, 0, 7, 0], done
The answer is `4`.

The behavior of the first pass is linear because every number is looked at once (and immediately cleared), and `i` increases regularly.

The second pass is a linear search.

    A= [5, 3, 2, 7, 1]
    N= len(A)
    
    print(A)
    for i in range(N):
    k= A[i]
    while k > 0 and k <= N:
    A[k-1], k = 0, A[k-1] # -1 for 0-based indexing
    print(A)
    
    [5, 3, 2, 7, 1]
    [5, 3, 2, 7, 0]
    [0, 3, 2, 7, 0]
    [0, 3, 2, 7, 0]
    [0, 3, 0, 7, 0]
    [0, 0, 0, 7, 0]
    [0, 0, 0, 7, 0]

- **Solution #2: Code:**

    	print(A)
    	for a in A:
	    	a= abs(a)
    		if a <= N:
    			A[a-1]= - A[a-1] # -1 for 0-based indexing
    		print(A)
    
    	[5, 3, 2, 7, 1]
    	[5, 3, 2, 7, -1]
    	[5, 3, -2, 7, -1]
    	[5, -3, -2, 7, -1]
    	[5, -3, -2, 7, -1]
    	[-5, -3, -2, 7, -1]
