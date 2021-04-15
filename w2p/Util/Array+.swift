//
//  Array+.swift
//  w2p
//
//  Created by vas on 04.03.2021.
//

import Foundation


extension Array {

    func growingOrderedSubarrays() -> [[Element]] {
        var result = [[Element]]()
        for index in self.indices{
            result.append(Array(self[0..<index+1]))
        }
        return result
    }
}
