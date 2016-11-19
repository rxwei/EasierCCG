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
        case .forwardApply: return ">"
        case .backwardApply: return "<"
        case .forwardCompose: return ">B"
        case .backwardCompose: return "<B"
        case .forwardTypeRaise: return ">T"
        case .backwardTypeRaise: return "<T"
        }
    }
}

public indirect enum ParseTree {

    case leaf(Category)
    case node(category: Category, left: ParseTree, right: ParseTree, rule: Rule)

    public var category: Category {
        switch self {
        case let .leaf(cat), let .node(category: cat, _, _, _):
            return cat
        }
    }

    public var head: ParseTree {
        switch self {
        case let .node(_, left, _, .forwardApply),
             let .node(_, left, _, .forwardCompose):
            return left
        case let .node(_, _, right, .backwardApply),
             let .node(_, _, right, .backwardCompose):
            return right
        default:
            return self
        }
    }

}
