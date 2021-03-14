//
//  Atomic.swift
//  w2p
//
//  Created by vas on 14.03.2021.
//

import Foundation

final class Atomic<A> {
    
    private let queue = DispatchQueue(label: "atomic")
    
    private var _value: A
    
    var value: A {
        get {
            queue.sync { return self._value }
        }
    }
    
    func mutate( block: (inout A) -> Void ){
        
        queue.sync { block(&self._value) }

    }
    
    init(_ value: A) {
        self._value = value
    }
}
