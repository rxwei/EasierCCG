//
//  Tree.swift
//  EasierCCG
//
//  Created by Chelsea Jiang on 9/23/16.
//
//

public enum Rule {
    case forwardApply
    case backwardApply
    case forwardCompose
    case backwardCompose
    case forwardTypeRaise
    case backwardTypeRaise
}

extension Rule : CustomStringConvertible {
    public var description: String {
        switch self {
        case .forwardApply:
            return ">"
        case .backwardApply:
            return "<"
        case .forwardCompose:
            return ">B"
        case .backwardCompose:
            return "<B"
        case .forwardTypeRaise:
            return ">T"
        case .backwardTypeRaise:
            return "<T"
        }
    }
}

public indirect enum ParseTree {
    case leaf(Category)
    case raisedLeaf(Category, neighbor: Category)
    case node(ParseTree, ParseTree, Rule)
    
    public var category: Category? {
        switch self {
        case let .leaf(cat):
            return cat
        case let .raisedLeaf(cat, neighbor):
            return cat.raisedForward(against: neighbor)
        case let .node(left, right, .forwardApply):
            let leftcat = left.category
            let rightcat = right.category
            return rightcat.flatMap { leftcat?.appliedBackward(to: $0) }
        case let .node(left, right, .backwardApply):
            let leftcat = left.category
            let rightcat = right.category
            return leftcat.flatMap { rightcat?.appliedBackward(to: $0) }
        case let .node(left, right, .forwardCompose):
            let leftcat = left.category
            let rightcat = right.category
            return rightcat.flatMap { leftcat?.composedForward(with: $0) }
        case let .node(left, right, .backwardCompose):
            let leftcat = left.category
            let rightcat = right.category
            return leftcat.flatMap { rightcat?.composedBackward(with: $0) }
        default:
            return nil
        }
    }

    public var head: ParseTree {
        switch self {
        case let .node(left, _, .forwardApply),
             let .node(left, _, .forwardCompose):
            return left
        case let .node(_, right, .backwardApply),
             let .node(_, right, .backwardCompose):
            return right
        default:
            return self
        }
    }

    private static let binaryRules: [Rule] = [
        .forwardApply, .backwardApply, .forwardCompose, .backwardCompose
    ]
    
    private static func parentTrees(left: ParseTree, right: ParseTree) -> [ParseTree] {
        guard let lcat = left.category, let rcat = right.category else { return [] }
        
        var allTrees = binaryRules.map { ParseTree.node(left, right, $0) }
        
        if let _ = lcat.raisedForward(against: rcat) {
            allTrees.append(.node(.raisedLeaf(lcat, neighbor: rcat), right, .forwardCompose))
        }
        
        return allTrees.filter { $0.category != nil }
    }

    private static func combining(left: [ParseTree], right: [ParseTree]) -> [ParseTree] {
        return left.flatMap { l in
            right.flatMap { r in
                parentTrees(left: l, right: r)
            }
        }
    }
}

extension ParseTree : CustomStringConvertible {
    public var description: String {
        switch self {
        case let .leaf(cat):
            return cat.description
        case let .raisedLeaf(cat, neighbor):
            return cat.description + Rule.forwardTypeRaise.description
                + (cat.raisedForward(against: neighbor)?.description ?? "")
        case let .node(left, right, rule):
            return "(" + left.description + ";" + right.description + "" + "--\(rule.description)" + self.category!.description + ")"
        }
    }
}
