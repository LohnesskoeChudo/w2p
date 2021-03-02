//
//  BinarySearch.swift
//  w2p
//
//  Created by vas on 15.02.2021.
//

import Foundation

func customBinarySearch<C>(collection: C, trueProperty: (C.Index) -> Bool, lessThanProperty: (C.Index) -> Bool) -> C.Index? where C: RandomAccessCollection,  C.Index == Int {
    
    let colllectionLength = collection.count
    var index: C.Index = colllectionLength / 2
    var rightBound: C.Index = colllectionLength - 1
    var leftBound: C.Index = 0
    
    while !trueProperty(index){
        if lessThanProperty(index){
            leftBound = index + 1
        } else {
            rightBound = index - 1
        }
        index = (leftBound + rightBound) / 2
    }
    return index
    
}

