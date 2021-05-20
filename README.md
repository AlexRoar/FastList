# FastList

Fast low-level linked list

**Confroms to `CustomStringConvertible`, `Collection`, and `Sequence` protocols**

## Algo & Features

- All nodes are stored in uniform memory chunk and link each-other by indices. Therefore, list is easily copyable and cache-friendly.
- All insert operations provide physical id. That is, all elements can **be accesed in O(1)** by their ids (physic index). 
- If there were no insert middle / insert front operations, then subscript and getting by logical index **in O(1)**
- If data was modified not in the end, then structure operates like usual linked list: subscript and getting by logical index **in O(n)**
- Data can be re-structured so that it is optimized again and accesses are **in O(1)** again.

| Operation              	| Optimized 	| Non-optimized 	| Breaks optimisation 	|
|------------------------	|-----------	|---------------	|---------------------	|
| Push front             	| O(1)      	| O(1)          	| Yes                 	|
| Push back              	| O(1)      	| O(1)          	| No                  	|
| First insert           	| O(1)      	| O(n)          	| Yes                 	|
| Numerous inserts       	| O(n)      	| O(n)          	| Yes                 	|
| Pop back               	| O(1)      	| O(1)          	| No                  	|
| Pop front              	| O(1)      	| O(1)          	| Yes                 	|
| First remove at index  	| O(1)      	| O(n)          	| Yes                 	|
| Numerous removes       	| O(n)      	| O(n)          	| Yes                 	|
| Next element iteration 	| O(1)      	| O(1)          	| No                  	|
| Optimization           	| O(1)      	| O(n)          	| No                  	|

## Speed

If you make a lot of non-linear insertions/deletions, defenitely consider using this list.

Here are the results of tests included in the package:
```
(comparing to Array)
Remove speed difference: 35%
Remove random speed difference: 40%
Insert front speed difference: 16%
```
