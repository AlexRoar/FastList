//
//  simple.swift
//  FastList
//
//  Created by  Alex Dremov on 21.05.2021.
//

import Foundation

let list = FastList<Int>()

for i in 0...5 {
    list.append(value: i * i)
}

let hundredId = list.append(value: 100) // access id to 100

try! list.set(physic: hundredId, value: 101) // O(1) always

for i in 0...5 {
    list.appendFront(value: i * i * i) // breaks optimization
}

print(list)
for i in list {
    print(i!)
}

for i in 0..<list.count {
    print(list[i]!) // O(n) subscript
}

list.optimize()
print(list) // the same list, optimized representation

for i in 0..<list.count {
    print(list[i]!) // O(1) subscript
}

while(!list.isEmpty) {
    try! list.remove(logic: 0)
}

print(list)
