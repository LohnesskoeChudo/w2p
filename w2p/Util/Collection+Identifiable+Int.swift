//
//  Array+Identifiable.swift
//  w2p
//
//  Created by vas on 23.02.2021.
//

import Foundation


extension Collection where Element: Identifiable, Element.ID == Int{
    func toIdArrayString(firstBracket: String, secondBracket: String) -> String{
        return "\(firstBracket)\(self.map{String($0.id)}.joined(separator: ","))\(secondBracket)"
    }
}

extension Int: Identifiable{
    public var id: Int{
        self
    }
}
