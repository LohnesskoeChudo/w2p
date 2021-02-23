//
//  Array+Identifiable.swift
//  w2p
//
//  Created by vas on 23.02.2021.
//

import Foundation


extension Set where Element: Identifiable, Element.ID == Int{
    func toIdArrayString() -> String{
        return "[\(self.map{String($0.id)}.joined(separator: ","))]"
    }
}
