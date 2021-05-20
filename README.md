# FastList

Fast low-level linked list

**Confroms to `CustomStringConvertible`, `Collection`, and `Sequence` protocols**

## Algo & Features

- All nodes are stored in uniform memory chunk and link each-other by indices. Therefore, list is easily copyable and cache-friendly.
- All insert operations provide physical id. That is, all elements can **be accesed in O(1)** by their ids (physic index). 
- If there were no insert middle / insert front operations, then subscript and getting by logical index **in O(1)**
- If data was modified not in the end, then structure operates like usual linked list: subscript and getting by logical index **in O(n)**
- Data can be re-structured so that it is optimized again and accesses are **in O(1)** again.

## Speed

If you make a lot of non-linear insertions/deletions, defenitely consider using this list.

Here are the results of tests included in the package:
```
(comparing to Array)
Remove speed difference: 35%
Remove random speed difference: 40%
Insert front speed difference: 16%
```
