/// Core.swift
/// EasierCCG
///
/// Created by Richard Wei on 9/14/16.
///

/// This file contains the core data structures and rules for 
/// combinatory categorial grammar
/// (Steedman, et al. http://groups.inf.ed.ac.uk/ccg/)

/// Primitive (atomic) category parameters
///
/// - sentence: S
/// - noun: N
/// - preposition: P
/// - verb: V
/// - nounPhrase: NP
/// - prepositionalPhrase: PP
/// - verbPhrase: VP
public enum Primitive {
    case sentence(SentenceFeature?), noun, preposition, verb
    case nounPhrase, prepositionalPhrase, verbPhrase
}

/// CCG Category
///
/// - atom: atomic category
/// - variable: meta variable category
/// - forwardFunctor: forward functor (/)
/// - backwardFunctor: backward functor (\)
public enum Category {
    case atom(Primitive)
    case variable
    indirect case forwardFunctor(Category, Category)
    indirect case backwardFunctor(Category, Category)

    /// Functor feature
    public enum Feature {
        case applicationOnly, orderPreserving, permutationLimiting, permissive, variable

        /// Determine if self is harmonic for composition
        var isHarmonic: Bool {
            return self == .permissive || self == .orderPreserving
        }
    }

    public enum Direction {
        case forward
        case backward
    }
}

/// MARK: - Property predicates
public extension Category {

    public var direction: Direction? {
        switch self {
        case .backwardFunctor(_, _): return .backward
        case .forwardFunctor(_, _): return .forward
        default: return nil
        }
    }

    /// Determine if self is a type-raised functor
    public var isTypeRaised: Bool {
        switch self {
        case let .forwardFunctor(left, .forwardFunctor(rightLeft, _)),
             let .backwardFunctor(left, .backwardFunctor(rightLeft, _)),
             let .forwardFunctor(left, .backwardFunctor(rightLeft, _)),
             let .backwardFunctor(left, .forwardFunctor(rightLeft, _)):
            return rightLeft == left
        default:
            return false
        }
    }

    /// Determine if self is a functor, either forward or backward
    public var isFunctor: Bool {
        switch self {
        case .forwardFunctor(_, _), .backwardFunctor(_, _): return true
        default: return false
        }
    }

    /// Determine if self is a variable
    public var isVariable: Bool {
        if case .variable = self { return true }
        return false
    }

    /// Determine if self is an atom
    public var isAtom: Bool {
        if case .atom(_) = self { return true }
        return false
    }

    /// Determine if the category contains variable
    /// - complexity: O(n), where n is the number of nodes
    public var containsVariable: Bool {
        switch self {
        case .atom(_): return false
        case .variable: return true
        case let .forwardFunctor(retCat, argCat), let .backwardFunctor(retCat, argCat):
            return retCat.containsVariable || argCat.containsVariable
        }
    }

    public var isNounOrNP: Bool {
        switch self {
        case .atom(.noun), .atom(.nounPhrase): return true
        default: return false
        }
    }

    public var head: Category {
        switch self {
        case .atom(_), .variable: return self
        case .forwardFunctor(let left, _): return left.head
        case .backwardFunctor(let left, _): return left.head
        }
    }

    /// The result of replacing all occurrences of variables with a specific category
    ///
    /// - Parameter replacement: category replacement
    /// - Returns: new category s.t. all variables are replaced by the replacement
    public func replacingVariables(with replacement: Category) -> Category {
        switch self {
        case .atom(_): return self
        case .variable: return replacement
        case let .forwardFunctor(retCat, argCat):
            return .forwardFunctor(
                retCat.replacingVariables(with: replacement),
                argCat.replacingVariables(with: replacement)
            )
        case let .backwardFunctor(retCat, argCat):
            return .backwardFunctor(
                retCat.replacingVariables(with: replacement),
                argCat.replacingVariables(with: replacement)
            )
        }
    }

}

/// MARK: - Compositionality
public extension Category {

    /// The result of category composition of self and other
    ///
    /// - Parameters:
    ///   - other: other category
    ///   - direction: direction of composition (backward/forward)
    /// - Returns: the result of composition
    public func composedForward(with other: Category) -> Category? {
        switch (self, other) {
        // X/Y Y/Z -> X/Z
        case let (.forwardFunctor(x, y), .forwardFunctor(yy, z))
            where y == yy && !x.isNounOrNP:
            return .forwardFunctor(x, z)
        // X\Y Y\Z -> X\Z
        case let (.backwardFunctor(yy, z), .backwardFunctor(x, y))
            where y == yy && !x.isNounOrNP:
            return .backwardFunctor(x, z)
        // X/Y Y\Z -> X\Z
        case let (.forwardFunctor(x, y), .backwardFunctor(yy, z))
                where y == yy && !x.isNounOrNP,
             let (.forwardFunctor(yy, z), .backwardFunctor(x, y))
                where y == yy && !yy.isNounOrNP:
            return .forwardFunctor(x, z)
        default:
            return nil
        }
    }

    /// The result of category composition of self and other
    ///
    /// - Parameters:
    ///   - other: other category
    ///   - direction: direction of composition (backward/forward)
    /// - Returns: the result of composition
    public func composedBackward(with other: Category) -> Category? {
        switch (other, self) {
        // X/Y Y/Z -> X/Z
        case let (.forwardFunctor(x, y), .forwardFunctor(yy, z))
            where y == yy && !x.isNounOrNP:
            return .forwardFunctor(x, z)
        // X\Y Y\Z -> X\Z
        case let (.backwardFunctor(yy, z), .backwardFunctor(x, y))
            where y == yy && !yy.isNounOrNP:
            return .backwardFunctor(x, z)
        // X/Y Y\Z -> X\Z
        case let (.forwardFunctor(x, y), .backwardFunctor(yy, z))
                where y == yy && !x.isNounOrNP,
             let (.forwardFunctor(yy, z), .backwardFunctor(x, y))
                where y == yy && !yy.isNounOrNP:
            return .forwardFunctor(x, z)
        default:
            return nil
        }
    }

}

/// MARK: - Applicativity
public extension Category {

    /// The result of function application of self and other
    ///
    /// - Parameters:
    ///   - other: other category
    ///   - direction: direction of application (backward/forward)
    /// - Returns: the result of application
    public func appliedForward(to other: Category) -> Category? {
        switch self {
        case .forwardFunctor(let x, .variable):
            return x.replacingVariables(with: other)
        case .forwardFunctor(let x, other) where !other.containsVariable:
            return x
        default:
            return nil
        }
    }

    /// The result of function application of self and other
    ///
    /// - Parameters:
    ///   - other: other category
    ///   - direction: direction of application (backward/forward)
    /// - Returns: the result of application
    public func appliedBackward(to other: Category) -> Category? {
        switch self {
        case .backwardFunctor(let x, .variable):
            return x.replacingVariables(with: other)
        case .backwardFunctor(let x, other) where !other.containsVariable:
            return x
        default:
            return nil
        }
    }
    
}

/// MARK: - Type Raising
public extension Category {

    /// The result of type raising of self against a meta variable:
    /// self => X / (X \ self)
    ///
    /// - Parameter direction: direction of type-raising
    /// - Returns: the result of type-raising
    public func raisedForward() -> Category {
        return .forwardFunctor(.variable, .backwardFunctor(.variable, self))
    }

    /// The result of type raising of self against a meta variable:
    /// self => X \ (X / self)
    ///
    /// - Parameter direction: direction of type-raising
    /// - Returns: the result of type-raising
    public func raisedBackward() -> Category {
        return .backwardFunctor(.variable, .forwardFunctor(.variable, self))
    }
    

    /// The result of type raising of self against a neighbor
    ///
    /// - Parameter direction: direction of type-raising
    /// - Parameter neighbor: neighbor to raise against
    /// - Returns: the resukt of type-raising
    public func raisedForward(against neighbor: Category) -> Category {
        return raisedForward().replacingVariables(with: neighbor)
    }

    /// The result of forward type raising of self against a neighbor
    ///
    /// - Parameter direction: direction of type-raising
    /// - Parameter neighbor: neighbor to raise against
    /// - Precondition: Self is an atom, and neighbor is a corresponding functor
    /// - Returns: the resukt of type-raising
    public func raisedBackward(against neighbor: Category) -> Category {
        return raisedBackward().replacingVariables(with: neighbor)
    }
    
}

extension Category : Equatable {
    /// Determine if the two categories are identical
    public static func ==(lhs: Category, rhs: Category) -> Bool {
        switch (lhs, rhs) {
        case let (.atom(x), .atom(y)):
            return x == y
        case let (.forwardFunctor(xRes, xArg), .forwardFunctor(yRes, yArg)),
             let (.backwardFunctor(xRes, xArg), .backwardFunctor(yRes, yArg)):
            return xRes == yRes && xArg == yArg
        default:
            return false
        }
    }
}

extension Primitive : Equatable {
    public static func ==(lhs: Primitive, rhs: Primitive) -> Bool {
        switch (lhs, rhs) {
        case let (.sentence(x), .sentence(y)) where x == y:
            return true
        case (.noun, .noun),
             (.preposition, .preposition),
             (.verb, .verb),
             (.nounPhrase, .nounPhrase),
             (.prepositionalPhrase, .prepositionalPhrase),
             (.verbPhrase, .verbPhrase):
            return true
        default:
            return false
        }
    }
}

/// Sentence feature
public enum SentenceFeature {

    /// Clausal features
    case declarativeSentence
    case whQuestion
    case yesNoQuestion
    case embeddedQuestion
    case embeddedSentence
    case subjunctiveEmbeddedSentence
    case subjunctiveSentence
    case fragment
    case forClause
    case interjection
    case ellipticalInversion

    /// Lexical features
    case adjective
    case bareInfinitive
    case toInfinitive
    case passivePastParticiple
    case activePastParticiple
    case presentParticiple
}
