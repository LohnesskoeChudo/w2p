//
//  Heap.swift
//  w2p
//
//  Created by vas on 15.03.2021.
//



import Foundation

// BinaryHeap without using arrays

class BinaryHeap<Element, Priority> where Priority: Comparable {
    
    typealias BHNode = BinaryHeapNode<Element, Priority>
    
    private var compare: (_ leftItem: Priority,_ rightItem: Priority) -> Bool
    var isEmpty: Bool { size == 0 }
    
    init(type: HeapKind) {
        switch type {
        case .max:
            compare = { $0 >= $1 }
        case .min:
            compare = { $0 <= $1 }
        }
    }
    
    private(set) var top: BHNode?
    private(set) var size: Int = 0
    
    func insert(node: BHNode) {
        node.leftChild = nil
        node.rightChild = nil
        node.parent = nil
        size += 1

        if top == nil {
            top = node
            return
        }
        
        let nodeToWhichNeedToAttach = findNode(position: size / 2)!
        if nodeToWhichNeedToAttach.leftChild == nil {
            nodeToWhichNeedToAttach.leftChild = node
        } else {
            nodeToWhichNeedToAttach.rightChild = node
        }
        node.parent = nodeToWhichNeedToAttach
        siftUp(node: node)

    }
   
    
    private func siftUp(node: BHNode) {
        while true {
            if let parent = node.parent {
                if compare(node.priority, parent.priority) {
                    node.swapWithParent()
                    if node.parent == nil {
                        self.top = node
                    }
                } else {
                    break
                }
            } else {
                break
            }
        }
    }
    
    private func siftDown(node: BHNode) {
        var topChanged = false
        while true {
            guard let leftChild = node.leftChild else { break }
            if let rightChild = node.rightChild {
                if compare(rightChild.priority, leftChild.priority) {
                    if compare(rightChild.priority, node.priority){
                        rightChild.swapWithParent()
                        if !topChanged {
                            self.top = rightChild
                            topChanged.toggle()
                        }
                        continue
                    } else {
                        break
                    }
                }
            }
                
            if compare(leftChild.priority, node.priority){
                leftChild.swapWithParent()
                if !topChanged {
                    self.top = leftChild
                    topChanged.toggle()
                }
            } else {
                break
            }
        }
    }
    
    private func findNode(position: Int) -> BHNode?{
        
        

        guard var node = top else { return nil }
        if position == 1 { return node }
        
        let path = findPath(for: position)
        
        while !path.isEmpty {
            if let needToGoRight = path.pop() {
                if needToGoRight{
                    if let rightChild = node.rightChild {
                        node = rightChild
                    } else {
                        return nil
                    }
                } else {
                    if let leftChild = node.leftChild {
                        node = leftChild
                    } else {
                        return nil
                    }
                }
            }
        }
        return node
    }
    
    private func findPath(for position: Int) -> LifoQueue<Bool> {
        var position = position
        let stack = LifoQueue<Bool>()
        while position > 1 {
            if position.isEven {
                stack.push(element: false)
            } else {
                stack.push(element: true)
            }
            position = position / 2
        }
        
        return stack
    }
    
    func popTop() -> BHNode? {
        
        if size <= 1 {
            let top = self.top
            self.top = nil
            size = 0
            return top
        }

        if let lastChildNode = findNode(position: size) {
            let topNode = self.top
            let isRightchild = lastChildNode.isRightChild
            if isRightchild == true {
                lastChildNode.parent?.rightChild = nil
            } else if isRightchild == false{
                lastChildNode.parent?.leftChild = nil
            }
            lastChildNode.parent = nil
            
            lastChildNode.leftChild = topNode?.leftChild
            lastChildNode.leftChild?.parent = lastChildNode
            
            lastChildNode.rightChild = topNode?.rightChild
            lastChildNode.rightChild?.parent = lastChildNode
            
            self.top = lastChildNode
            siftDown(node: lastChildNode)
            topNode?.leftChild = nil
            topNode?.rightChild = nil
            
            size -= 1
            return topNode
        }
        
        return nil

    }
    
    func changePriority(of node: BHNode, newPriority: Priority) {
        node.priority = newPriority
        if let parent = node.parent {
            if compare(node.priority, parent.priority) {
                siftUp(node: node)
            } else {
                siftDown(node: node)
            }
        }
    }
}


class BinaryHeapNode<Element, Priority> {
    
    init(data: Element, priority: Priority) {
        self.data = data
        self.priority = priority
    }
    
    var data: Element
    fileprivate(set) var priority: Priority
    var isRightChild: Bool? {
        if let parent = parent {
            return self === parent.rightChild
        } else {
            return nil
        }
    }
    
    fileprivate weak var parent: BinaryHeapNode<Element, Priority>?
    fileprivate var leftChild: BinaryHeapNode<Element, Priority>?
    fileprivate var rightChild: BinaryHeapNode<Element, Priority>?
    
    
    func swapWithParent(){
        
        if parent == nil {return}
        
        let leftChild = self.leftChild
        let rightChild = self.rightChild
        let oldParent = self.parent
        
        let parentIsRightChild = parent?.isRightChild

        if isRightChild == true {
            let parentLeftChild = parent?.leftChild
            self.leftChild = parentLeftChild
            parentLeftChild?.parent = self
            self.rightChild = parent
            
        } else if isRightChild == false {
            let parentRightChild = parent?.rightChild
            self.rightChild = parentRightChild
            parentRightChild?.parent = self
            self.leftChild = parent
        } else {
            return
        }
        
        
        parent = parent?.parent
        
        if parentIsRightChild == true {
            parent?.rightChild = self
        } else if parentIsRightChild == false {
            parent?.leftChild = self
        }
        

        oldParent?.parent = self
        oldParent?.leftChild = leftChild
        oldParent?.rightChild = rightChild
        leftChild?.parent = oldParent
        rightChild?.parent = oldParent

    }
}


enum HeapKind {
    case min
    case max
}

extension Int {
    var isEven: Bool {
        return (self % 2) == 0
    }
}
