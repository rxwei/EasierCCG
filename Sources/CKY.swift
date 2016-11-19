//
//  CKY.swift
//  EasierCCG
//
//  Created by Chelsea Jiang on 9/23/16.
//
//


protocol LexiconIndexable {
    associatedtype Category
    subscript(_ key: String) -> [Category] { get set }
}

struct Lexicon {
    var entries: [String : [Category]]
}

extension Lexicon : LexiconIndexable {
    subscript(_ key: String) -> [Category] {
        get {
            return entries[key] ?? []
        }
        set {
            entries[key] = newValue
        }
    }


    mutating func addEntry(word: String, category: Category) {
        guard self[word].contains(category) else {
            return
        }
        self[word].append(category)
    }
}

func parse(_ input: [String], withLexicon lexicon: Lexicon) -> [ParseTree] {
    var cats: [[Category]] = input.map{ lexicon[$0] }
    let n: Int = input.count
    var table: [[[ParseTree]]] = Array(repeating: Array(repeating: [],
                                                        count: n+1),
                                       count: n)
    for j in 1...n {
        let leaves: [ParseTree] = cats[j-1].map{ ParseTree.leaf($0) }
        table[j-1][j] = leaves
        if j - 2 >= 0 {
            for i in stride(from: j-2, to: -1, by: -1) {
                for k in i+1 ... j-1 {
                    let left:  [ParseTree] = table[i][k]
                    let right: [ParseTree] = table[k][j]
                    table[i][j].append(contentsOf: ParseTree.combine(left, right))

                }
            }
        }
    }

    return table[0][n]
}
