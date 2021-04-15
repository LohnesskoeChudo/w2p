//
//  Combinations.swift
//  w2p
//
//  Created by vas on 20.03.2021.
//

import Foundation

// combinations(sequense: [1,2,3,4], k:3) -> [[1,2,3], [1,2,4], [1,3,4], [2,3,4]]
func combinations<T>(collection: T, k: Int) -> [[T.Element]]? where T: RandomAccessCollection, T.Index == Int {
    var result = [[T.Element]]()
    let n = collection.count
    if k > n {
        return nil
    }
    var indeces = (0..<k).map{$0}
    result.append(indeces.map{collection[$0]})
    outerLoop: while true {
        for q in (0..<k).reversed() {
            if indeces[q] != q + n - k{
                indeces[q] += 1
                for j in (q+1)..<k {
                    indeces[j] = indeces[j-1] + 1
                }
                result.append(indeces.map{collection[$0]})
                continue outerLoop
            }
        }
        return result
    }
}
