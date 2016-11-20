//
//  PriorityQueue.swift
//  EasierCCG
//
//  Created by Chelsea Jiang on 11/19/16.
//
//

struct PriorityQueue<T: Comparable> {

    private var elements: [T]

    private var root: Int {
        return 0
    }

    /// Find the left child of the element at the index
    ///
    /// - Parameter index: index of the element
    /// - Returns: the index of the left child, or nil if the element is a leaf node
    private func leftChild(of index: Int) -> Int? {
        return 2 * (index+1) - 1 < elements.endIndex ? 2 * (index+1) - 1 : nil
    }

    /// Find the right child of the element at the index
    ///
    /// - Parameter index: index of the element
    /// - Returns: the index of the right child, or nil if the right child does not exist
    private func rightChild(of index: Int) -> Int? {
        return 2 * (index+1) < elements.endIndex ? 2 * (index+1) : nil
    }

    /// Find the index of the parent of the element at the index
    ///
    /// - Parameter index: index of the element
    /// - Returns: the index of the parent, or nil if it is the root
    private func parent(of index: Int) -> Int? {
        if index % 2 == 0 {
            return index / 2 >= 0 ? index / 2 : nil
        }
        return index / 2 - 1 >= 0 ? index / 2: nil
    }

    private func isParent(_ index: Int) -> Bool {
        return (2 * (index+1) - 1) < elements.endIndex
    }

    private func maxPriorityChild(of index: Int) -> Int? {
        // if index only has the left child
        guard let rightChild = self.rightChild(of: index), let leftChild  = self.leftChild(of: index)
            else { return nil }
        if rightChild >= elements.count {
            return leftChild
        }
        return elements[leftChild] < elements[rightChild] ? leftChild : rightChild
    }

    // O(logn)
    private mutating func heapifyDown(at index: Int) {
        if isParent(index) {
            guard let maxChild = maxPriorityChild(of: index)
                else { return }
            if (elements[maxChild] < elements[index]) {
                swap(&elements[maxChild], &elements[index])
            }
            heapifyDown(at: maxChild)
        }
    }

    // O(logn)
    private mutating func heapifyUp(at index: Int) {
        if index == self.root {
            return
        }
        guard let parent = self.parent(of: index)
            else { return }
        if (elements[index] < elements[parent]) {
            swap(&elements[index], &elements[parent])
        }
        heapifyUp(at: parent)
    }

    /// Initialize the priority queue
    ///
    /// - Parameter elements: an array of elements that constitute the priority queue
    init(elements: [T]) {
        self.elements = elements
        /// Build heap
        for i in elements.indices.lazy.reversed() {
            heapifyDown(at: i)
        }
    }

    /// The minimum element in the queue
    ///
    /// - Returns: the minimum element
    func min() -> T {
        return elements[self.root]
    }

    /// Remove the minimum element
    ///
    /// - Returns: the minimum element
    mutating func removeMin() -> T {
        let min: T = self.min()
        elements[self.root] = elements[elements.endIndex - 1]
        heapifyDown(at: self.root)
        elements.removeLast()
        return min
    }

    /// Insert an element into the queue
    ///
    /// - Parameter newElement: insert an element into the queue and heapify
    mutating func insert(newElement: T) {
        elements.append(newElement)
        heapifyUp(at: elements.endIndex-1)
    }

    /// Determine whether the queue is empty
    var isEmpty: Bool {
        return elements.isEmpty
    }

    /// The number of elements in the queue
    var count: Int {
        return elements.count
    }
    
}
