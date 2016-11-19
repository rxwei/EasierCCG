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
    case forwardCrossCompose
    case backwardCrossCompose
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
        case .forwardCrossCompose: return ">Bx"
        case .backwardCrossCompose: return "<Bx"
        case .forwardTypeRaise: return ">T"
        case .backwardTypeRaise: return "<T"
        }
    }
}

public indirect enum SyntaxTree {

    case leaf(Category)
    case node(category: Category, left: SyntaxTree, right: SyntaxTree, rule: Rule)

    public var category: Category {
        switch self {
        case let .leaf(cat), let .node(category: cat, _, _, _):
            return cat
        }
    }

    public var head: SyntaxTree {
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
