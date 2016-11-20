//
//  PriorityQueue.swift
//  EasierCCG
//
//  Created by Chelsea Jiang on 11/19/16.
//
//

struct PriorityQueue<T: Comparable> {

    private var array: [T]

    private var root: Int {
        return 0
    }

    private func leftChild(of index: Int) -> Int? {
        return 2 * (index+1) - 1 < array.endIndex ? 2 * (index+1) - 1 : nil
    }

    private func rightChild(of index: Int) -> Int? {
        return 2 * (index+1) < array.endIndex ? 2 * (index+1) : nil
    }

    private func parent(of index: Int) -> Int? {
        if index % 2 == 0 {
            return index / 2 >= 0 ? index / 2 : nil
        }
        return index / 2 - 1 >= 0 ? index / 2: nil
    }

    private func isParent(_ index: Int) -> Bool {
        return (2 * (index+1) - 1) < array.endIndex
    }

    private func maxPriorityChild(of index: Int) -> Int? {
        // if index only has the left child
        guard let rightChild = self.rightChild(of: index), let leftChild  = self.leftChild(of: index)
            else { return nil }
        if rightChild >= array.count {
            return leftChild
        }
        return array[leftChild] < array[rightChild] ? leftChild : rightChild
    }

    // O(logn)
    private mutating func heapifyDown(at index: Int) {
        if isParent(index) {
            guard let maxChild = maxPriorityChild(of: index)
                else { return }
            if (array[maxChild] < array[index]) {
                swap(&array[maxChild], &array[index])
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
        if (array[index] < array[parent]) {
            swap(&array[index], &array[parent])
        }
        heapifyUp(at: parent)
    }
    

    ///  public functions
    init(elements: [T]) {
        array = elements

        /// build heap
        for i in elements.indices.lazy.reversed() {
            heapifyDown(at: i)
        }
    }

    /// peek
    func min() -> T {
        return array[self.root]
    }

    /// remove the element with lowest priority
    mutating func removeMin() -> T {
        let min: T = self.min()
        array[self.root] = array[array.endIndex - 1]
        heapifyDown(at: self.root)
        array.removeLast()
        return min
    }

    mutating func insert(newElement: T) {
        array.append(newElement)
        heapifyUp(at: array.endIndex-1)
    }

    var isEmpty: Bool {
        return array.isEmpty
    }

    /// minus one because of sentinel
    var size: Int {
        return array.count
    }
    
}
