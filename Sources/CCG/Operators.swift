//
//  Operators.swift
//  EasierCCG
//
//  Created by Richard Wei on 11/19/16.
//
//

precedencegroup CCGCombinatorPrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator >>> : CCGCombinatorPrecedence
infix operator <<< : CCGCombinatorPrecedence

infix operator *> : CCGCombinatorPrecedence
infix operator <* : CCGCombinatorPrecedence

/// Forward application (>)
public func >>> (lhs: Category?, rhs: Category?) -> Category? {
    return rhs.flatMap { rhs in
        lhs.flatMap { lhs in
            lhs.appliedForward(to: rhs)
        }
    }
}

/// Backward application (<)
public func <<< (lhs: Category?, rhs: Category?) -> Category? {
    return rhs.flatMap { rhs in
        lhs.flatMap { lhs in
            lhs.appliedBackward(to: rhs)
        }
    }
}

/// Forward composition (>B)
public func *> (lhs: Category?, rhs: Category?) -> Category? {
    return rhs.flatMap { rhs in
        lhs.flatMap { lhs in
            lhs.composedForward(with: rhs)
        }
    }
}

/// Backward application (<B)
public func <* (lhs: Category?, rhs: Category?) -> Category? {
    return rhs.flatMap { rhs in
        lhs.flatMap { lhs in
            lhs.composedBackward(with: rhs)
        }
    }
}
