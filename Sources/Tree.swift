//
//  Tree.swift
//  EasierCCG
//
//  Created by Chelsea Jiang on 9/23/16.
//
//


enum Rule {
    case forwardApply
    case backwardApply
    case forwardCompose
    case backwardCompose
    case forwardTypeRaise
    case backwardTypeRaise
    static let binaryRules: [Rule] = [.forwardApply, .backwardApply, .forwardCompose, .backwardCompose]
}


extension Rule : CustomStringConvertible {
    var description: String {
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

indirect enum ParseTree {
    case leaf(Category)
    case raisedLeaf(Category, neighbor: Category)
    case node(ParseTree, ParseTree, Rule)

    var category: Category? {
        switch self {
        case let .leaf(cat):
            return cat
        case let .raisedLeaf(cat, neighbor):
            return cat.raised(toComposeWith: neighbor)
        case let .node(left, right, .forwardApply):
            let leftcat = left.category
            let rightcat = right.category
            return rightcat.flatMap{ leftcat?.apply(to: $0) }
        case let .node(left, right, .backwardApply):
            let leftcat = left.category
            let rightcat = right.category
            return leftcat.flatMap{ rightcat?.apply(to: $0) }
        case let .node(left, right, .forwardCompose):
            let leftcat = left.category
            let rightcat = right.category
            return rightcat.flatMap{ leftcat?.compose(with: $0) }
        case let .node(left, right, .backwardCompose):
            let leftcat = left.category
            let rightcat = right.category
            return leftcat.flatMap{ rightcat?.compose(with: $0) }
        default:
            return nil
        }
    }

    var head: ParseTree {
        switch self {
        case .leaf:
            return self
        case let .node(left, _, .forwardApply):
            return left
        case let .node(_, right, .backwardApply):
            return right
        case let .node(left, _, .forwardCompose):
            return left
        case let .node(_, right, .backwardCompose):
            return right
        default:
            return self
        }
    }

    static func constructParents(fromLeft left: ParseTree, right: ParseTree) -> [ParseTree] {
        if let lcat = left.category, let rcat = right.category {
            var allTrees: [ParseTree] = []
            for r in Rule.binaryRules {
                allTrees.append(.node(left, right, r))
            }
            if let _ = lcat.raised(toComposeWith: rcat) {
                allTrees.append(.node(.raisedLeaf(lcat, neighbor: rcat), right, .forwardCompose))
            }
            return allTrees.filter{ $0.category != nil }
        } else {
            return []
        }
    }

    /// TODO:
    /// add <T instance
    static func constructParent(fromLeft left: ParseTree, right: ParseTree) -> ParseTree? {
        // deterministically return one parse tree
        if let lcat = left.category, let rcat = right.category {
            var allTrees: [ParseTree] = []
            for r in Rule.binaryRules {
                allTrees.append(.node(left, right, r))
            }
            let out = allTrees.filter{ $0.category != nil }
            if out.isEmpty {
                // only perform type-raise when all other rules don't apply
                if let _ = lcat.raised(toComposeWith: rcat) {
                    let forwardRaised: ParseTree = .node(.raisedLeaf(lcat, neighbor: rcat), right, .forwardCompose)
                    return .node(forwardRaised, right, .forwardCompose)
                } else {  }
            } else {
                if out.count == 1 {
                    return out[0]
                } else { }
            }
        } else { }

        return nil
    }

    static func combine(_ left: [ParseTree], _ right: [ParseTree]) -> [ParseTree] {
        var ret: [ParseTree] = []
        for l in left {
            for r in right {
                ret.append(contentsOf: constructParents(fromLeft: l, right: r))
            }
        }
        return ret
    }
}

extension ParseTree : CustomStringConvertible {
    var description: String {
        switch self {
        case let .leaf(cat):
            return cat.description
        case let .raisedLeaf(cat, neighbor):
            return cat.description + Rule.forwardTypeRaise.description + (cat.raised(toComposeWith: neighbor)?.description)!
        case let .node(left, right, rule):
            return "(" + left.description + ";" + right.description + "" + "--\(rule.description)" + self.category!.description + ")"
        }
    }
}
