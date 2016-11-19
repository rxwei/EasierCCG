/// Core.swift
/// EasierCCG
///
/// Created by Richard Wei on 9/14/16.
///

/// Combinatory categorial grammar

public enum Primitive {
    case sentence(SentenceFeature), noun, preposition, verb
    case nounPhrase, prepositionalPhrase, verbPhrase
}

extension Primitive : Equatable {
    public static func ==(lhs: Primitive, rhs: Primitive) -> Bool {
        switch (lhs, rhs) {
        case let (.sentence(x), .sentence(y)):
            return x == y
        default:
            return lhs == rhs
        }
    }

}

public enum Category {

    public enum Direction {
        case forward, backward
        
        var inverse: Direction {
            return self == .forward ? .backward : .forward
        }
    }
    
    public enum Feature {
        case applicationOnly, orderPreserving, permutationLimiting, permissive, variable
        
        static let harmonic: Set<Feature> = [.permissive, .orderPreserving]
        
        func isCompatible(with other: Feature) -> Bool {
            return Feature.harmonic.contains(other)
        }
    }
    case atom(Primitive)
    case variable
    indirect case functor(Category, Direction, Category)
    
}

extension Category : Equatable {
    
    public static func ==(lhs: Category, rhs: Category) -> Bool {
        switch (lhs, rhs) {
        case let (.atom(x), .atom(y)):
            return x == y
        case let (.functor(xRes, xDir, xArg), .functor(yRes, yDir, yArg)):
            return xRes == yRes && xDir == yDir && xArg == yArg
        default:
            return false
        }
    }
    
}

/// MARK: - Property predicates
public extension Category {

    public var containsVariable: Bool {
        switch self {
        case .atom(_): return false
        case .variable: return true
        case let .functor(retCat, _, argCat):
            return retCat.containsVariable || argCat.containsVariable
        }
    }

    public func replacingVariables(with target: Category) -> Category {
        switch self {
        case .atom(_): return self
        case .variable: return target
        case let .functor(retCat, dir, argCat):
            return .functor(retCat.replacingVariables(with: target),
                            dir,
                            argCat.replacingVariables(with: target))
        }
    }

}

private protocol Composable {
    func compose(with other: Self) -> Self?
}

private protocol Applicative {
    func apply(to other: Self) -> Self?
}

/// MARK: - Compositionality
extension Category : Composable {
    
    func compose(with other: Category) -> Category? {
        switch (self, other) {
        // X/Y Y/Z -> X/Z
        case let (.functor(x, .forward,  y), .functor(yy, .forward,  z))
            where y == yy :
            return .functor(x, .forward, z)
        // X\Y Y\Z -> X\Z
        case let (.functor(yy, .backward,  z), .functor(x, .backward,  y))
            where y == yy :
            return .functor(x, .backward,  z)
        // X/Y Y\Z -> X\Z
        case let (.functor(x, .forward,  y),
                  .functor(yy, .backward,  z))
            where y == yy:
            return .functor(x, .backward,  z)
        // X/Y Y\Z -> X\Z
        case let (.functor(yy, .forward, z),
                  .functor(x, .backward, y))
            where y == yy:
            return .functor(x, .forward,  z)
        default:
            return nil
        }
    }
    
}

/// MARK: - Applicativity
extension Category : Applicative {
    
    public func apply(to other: Category) -> Category? {
        switch (self, other) {
        case let (.functor(x, .forward,  y), arg) where arg == y,
             let (.functor(x, .backward, y), arg) where arg == y:
            return x
        case let (.functor(.functor(.variable,
                                    .backward,
                                    .variable),
                           .forward,
                           .variable), arg)
            where !arg.containsVariable:
            return .functor(arg, .backward,  arg)
        default:
            return nil
        }
    }
    
}

/// MARK: - Type Raising
extension Category {
    
    func raised(_ direction: Direction) -> Category {
        return .functor(.variable,
                        direction,
                        .functor(.variable, direction.inverse,  self))
    }

    func bareNounRaising() -> Category? {
        switch self {
        case .atom(.noun):
            return .atom(.nounPhrase)
        default:
            return .none
        }
    }

    // NP -> S\(S/NP)
    func NPRaised1() -> Category? {
        switch self {
        case .atom(.nounPhrase):
            return .functor(.atom(.sentence(.none)),
                            .forward,
                            .functor(.atom(.sentence(.none)), .backward,  self))
        default:
            return .none
        }
    }


    // NP -> (S\NP)/((S\NP)/NP)
    func NPRaised2() -> Category? {
        switch self {
        case .atom(.nounPhrase):
            return .functor(.functor(.atom(.sentence(.none)), .backward,  self),
                            .forward,
                            .functor(.functor(.atom(.sentence(.none)), .backward,  self),
                                     .forward,
                                     self))
        default:
            return .none
        }
    }

    // NP -> (S\NP)/((S\NP)/PP)
    func NPRaisedtoPP() -> Category? {
        switch self {
        case .atom(.nounPhrase):
            return .functor(.functor(.atom(.sentence(.none)), .backward,  self),
                            .forward,
                            .functor(.functor(.atom(.sentence(.none)), .backward,  self),
                                     .forward,
                                     .atom(.prepositionalPhrase)))
        default:
            return .none
        }
    }

    func raised(toComposeWith neighbor: Category) -> Category? {
        guard case .atom(_) = self,
            case let .functor(.functor(x, direction, y), _,  _) = neighbor,
            self == y else { return nil }
        return .functor(x, .forward,  .functor(x, direction, y))
    }
    
}

extension Primitive : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .sentence(x):     return "S" + x.description
        case .noun:                return "N"
        case .preposition:         return "P"
        case .verb:                return "V"
        case .nounPhrase:          return "NP"
        case .prepositionalPhrase: return "PP"
        case .verbPhrase:          return "VP"
        }
    }
    
}

extension Category.Direction : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .forward:  return "/"
        case .backward: return "\\"
        }
    }
    
}

extension Category.Feature : CustomStringConvertible {

    public var description: String {
        switch self {
        case .applicationOnly:     return "★" /// Star
        case .orderPreserving:     return "◇" /// Diamond
        case .permutationLimiting: return "×" /// Cross
        case .permissive:          return ""  /// Dot
        case .variable:            return "𝑖" /// Variable
        }
    }

}

extension Category : CustomStringConvertible {

    public var description: String {
        switch self {
        case let .atom(p):
            return p.description
        case .variable:
            return "X"
        case let .functor(result, direction,  argument):
            return "(\(result) \(direction) \(argument))"
        }
    }
    
}

public enum SentenceFeature : String, CustomStringConvertible {
    case none
    case declarativeSentence
    case whQuestion
    case yesNoQuestion
    case embeddedQuestion
    case embeddedSentence
    case subjunctiveEmbeddedSentence
    case subjunctiveSentence
    case fragment
    case forClause           // small clauses headed by for [for X to do sth]
    case interjection
    case ellipticalInversion // -- (as) [does President Bush]
    /// attributive adjectives -- S[adj]\NP
    case adjective
    /// verb phrase features -- S[b]\NP
    case bareInfinitive
    case toInfinitive
    case passivePastParticiple
    case activePastPariticiple
    case presentParticiple

    public var description : String {
        switch self {
        case .none:
            return ""
        case .declarativeSentence:
            return "dcl"
        case .whQuestion:
            return "wq"
        case .yesNoQuestion:
            return "q"
        case .embeddedQuestion:
            return "qem"
        case .embeddedSentence:
            return "em"
        case .subjunctiveEmbeddedSentence:
            return "bem"
        case .subjunctiveSentence:
            return "b"
        case .fragment:
            return "frg"
        case .forClause:
            return "for"
        case .interjection:
            return "intj"
        case .ellipticalInversion:
            return "inv"
        case .adjective:
            return "adj"
        case .bareInfinitive:
            return "b"
        case .toInfinitive:
            return "to"
        case .passivePastParticiple:
            return "pss"
        case .activePastPariticiple:
            return "pt"
        case .presentParticiple:
            return "ng"
        }
    }
}



