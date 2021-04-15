//
//  FIFO.swift
//  w2p
//
//  Created by vas on 02.03.2021.
//

import Foundation

class FifoQueue<T> {
    var queue: LinkedList<T>
    
    init(array: [T]){
        self.queue = LinkedList(array: array)
    }

    init() {
        self.queue = LinkedList()
    }
    
    
    
    func pop() -> T?{
        queue.popFront()
    }
    
    func push(element: T){
        queue.appendToBack(element)
    }
    
    func push(array: [T]){
        for item in array{
            push(element: item)
        }
    }
    
    func pop(numOfElements: Int) -> [T]{
        let numOfElements = min(self.count, numOfElements)
        var result = [T]()
        for _ in 0..<numOfElements {
            if let item = pop() {
                result.append(item)
            } else {
                break
            }
        }
        return result
    }
    
    func clear(){
        self.queue = LinkedList()
    }
    
    var count: Int {
        queue.count
    }
    
    var isEmpty: Bool {
        count == 0
    }
}
