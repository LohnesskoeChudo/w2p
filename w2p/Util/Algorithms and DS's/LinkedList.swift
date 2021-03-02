//
//  LinkedList.swift
//  w2p
//
//  Created by vas on 02.03.2021.
//

import Foundation

class LinkedList<T> {
    
    var count: Int = 0
    var head: LinkedListNode<T>?
    var tail: LinkedListNode<T>?
    
    
    init(array: [T]){
        for index in array.indices{
            appendToBack(array[index])
        }
    }
    
    init() {}
    
    func appendToBack(_ data: T){
        if let tail = tail{
            let node = LinkedListNode(data: data, previousNode: tail)
            tail.nextNode = node
            self.tail = node
        } else {
            let node = LinkedListNode(data: data)
            self.head = node
            self.tail = node
        }
        count += 1
    }
    
    func appendToFront(_ data: T){
        if let head = head{
            let node = LinkedListNode(data: data, nextNode: head)
            head.previousNode = node
            self.head = node
        } else {
            let node = LinkedListNode(data: data)
            self.head = node
            self.tail = node
        }
        count += 1
    }
    
    func popFront() -> T?{
        if count == 0 {
            return nil
        } else if count == 1 {
            let data = head!.data
            self.head = nil
            self.tail = nil
            count -= 1
            return data
        } else {
            let data = head!.data
            self.head = head!.nextNode
            self.head!.previousNode = nil
            count -= 1
            return data
        }
    }
    
    func popBack() -> T?{
        if count == 0 {
            return nil
        } else if count == 1 {
            let data = tail!.data
            self.tail = nil
            self.head = nil
            count -= 1
            return data
        } else {
            let data = tail!.data
            self.tail = tail!.previousNode
            self.tail!.nextNode = nil
            count -= 1
            return data
        }
    }
    
    func insertAfter(element: T, data: T) throws where T: Equatable{
        
        if count == 0 { throw LinkedListError.noElements }
        
        let node = LinkedListNode(data: data)
        var currentNode = head
        
        while currentNode != nil {
            if currentNode!.data == element{
                if currentNode!.nextNode == nil {
                    tail!.nextNode = node
                    node.previousNode = tail
                    tail = node
                    
                } else {
                    let nextToCurrentNode = currentNode!.nextNode!
                    node.previousNode = currentNode
                    node.nextNode = nextToCurrentNode
                    currentNode!.nextNode = node
                    nextToCurrentNode.previousNode = node
                }
                count += 1
                return
            }
            currentNode = currentNode?.nextNode
        }
        
        throw LinkedListError.noMatches
    }
    
    func printLL(){
        var currentNode = head
        
        while currentNode != nil {
            print(currentNode?.data, currentNode?.previousNode?.data, currentNode?.nextNode?.data)
            currentNode = currentNode?.nextNode
        }
    }
}

class LinkedListNode<T> {
    
    var data: T
    var nextNode: LinkedListNode<T>?
    var previousNode: LinkedListNode<T>?
    
    init(data: T, nextNode: LinkedListNode<T>? = nil, previousNode: LinkedListNode<T>? = nil) {
        self.data = data
        self.nextNode = nextNode
        self.previousNode = previousNode
    }
}


enum LinkedListError: Error{
    case noElements
    case noMatches
}
