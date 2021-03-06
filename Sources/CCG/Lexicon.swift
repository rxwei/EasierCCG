//
//  Lexicon.swift
//  EasierCCG
//
//  Created by Richard Wei on 11/19/16.
//
//

public protocol Indexer : Collection {

    typealias Index = Int

    init()

    associatedtype Element : Hashable

    var elements: [Element] { get }

    @discardableResult
    mutating func add(_ element: Element) -> Int

    subscript(element: Element) -> Int? { get }

    subscript(index: Int) -> String { get }

}

public extension Indexer {

    public init<C: Collection>(_ elements: C)
        where C.Iterator.Element == Element
    {
        self.init()
        elements.forEach { self.add($0) }
    }

    public var startIndex: Int {
        return elements.startIndex
    }

    public var endIndex: Int {
        return elements.endIndex
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public func contains(_ element: Element) -> Bool {
        return self[element] != nil
    }

    public func contains(_ index: Int) -> Bool {
        return index >= 0 && index < elements.count
    }

    public subscript(index: Int) -> Element {
        return elements[index]
    }

}

public protocol LexicallyIndexable {
    associatedtype Key : Hashable
    associatedtype Lex
    subscript(key: Key) -> Lex { get set }
}

public struct Lexicon<Key: Hashable, Lex> : LexicallyIndexable {

    public var storage: [Key : Lex]

    public subscript(key: Key) -> Lex? {
        get {
            return storage[key]
        }
        set {
            storage[key] = newValue
        }
    }
    
}
