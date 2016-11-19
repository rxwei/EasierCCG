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
    indirect case functor(Category, Direction, Feature, Category)
    
}

extension Category : Equatable {
    
    public static func ==(lhs: Category, rhs: Category) -> Bool {
        switch (lhs, rhs) {
        case let (.atom(x), .atom(y)):
            return x == y
        case let (.functor(xRes, xDir, xFeat, xArg), .functor(yRes, yDir, yFeat, yArg)):
            return xRes == yRes && xDir == yDir && xFeat == yFeat && xArg == yArg
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
        case let .functor(retCat, _, _, argCat):
            return retCat.containsVariable || argCat.containsVariable
        }
    }

    public func replacingVariables(with target: Category) -> Category {
        switch self {
        case .atom(_): return self
        case .variable: return target
        case let .functor(retCat, feat, dir, argCat):
            return .functor(retCat.replacingVariables(with: target),
                            feat,
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
        case let (.functor(x, .forward, f1, y), .functor(yy, .forward, f2, z))
            where y == yy && f1.isCompatible(with: f2):
            return .functor(x, .forward, f2, z)        
        // X\Y Y\Z -> X\Z
        case let (.functor(yy, .backward, f1, z), .functor(x, .backward, f2, y))
            where y == yy && f1.isCompatible(with: f2):
            return .functor(x, .backward, f1, z)
        // X/Y Y\Z -> X\Z
        case let (.functor(x, .forward, .permutationLimiting, y),
                  .functor(yy, .backward, .permutationLimiting, z))
            where y == yy:
            return .functor(x, .backward, .permutationLimiting, z)
        // X/Y Y\Z -> X\Z
        case let (.functor(yy, .forward, .permutationLimiting, z),
                  .functor(x, .backward, .permutationLimiting, y))
            where y == yy:
            return .functor(x, .forward, .permutationLimiting, z)
        default:
            return nil
        }
    }
    
}

/// MARK: - Applicativity
extension Category : Applicative {
    
    public func apply(to other: Category) -> Category? {
        switch (self, other) {
        case let (.functor(x, .forward, _, y), arg) where arg == y,
             let (.functor(x, .backward, _, y), arg) where arg == y:
            return x
        case let (.functor(.functor(.variable,
                                    .backward,
                                    .applicationOnly,
                                    .variable),
                           .forward,
                           .applicationOnly,
                           .variable), arg)
            where !arg.containsVariable:
            return .functor(arg, .backward, .applicationOnly, arg)
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
                        .variable,
                        .functor(.variable, direction.inverse, .variable, self))
    }
    
    func raised(toComposeWith neighbor: Category) -> Category? {
        guard case .atom(_) = self,
            case let .functor(.functor(x, direction, feature, y), _, _, _) = neighbor,
            self == y else { return nil }
        return .functor(x, .forward, feature, .functor(x, direction, feature, y))
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
                            .permissive,
                            .functor(.atom(.sentence(.none)), .backward, .permissive, self))
        default:
            return .none
        }
    }


    // NP -> (S\NP)/((S\NP)/NP)
    func NPRaised2() -> Category? {
        switch self {
        case .atom(.nounPhrase):
            return .functor(.functor(.atom(.sentence(.none)), .backward, .permissive, self),
                            .forward,
                            .permissive,
                            .functor(.functor(.atom(.sentence(.none)), .backward, .permissive, self),
                                     .forward,
                                     .permissive,
                                     self))
        default:
            return .none
        }
    }

    // NP -> (S\NP)/((S\NP)/PP)
    func NPRaisedtoPP() -> Category? {
        switch self {
        case .atom(.nounPhrase):
            return .functor(.functor(.atom(.sentence(.none)), .backward, .permissive, self),
                            .forward,
                            .permissive,
                            .functor(.functor(.atom(.sentence(.none)), .backward, .permissive, self),
                                     .forward,
                                     .permissive,
                                     .atom(.prepositionalPhrase)))
        default:
            return .none
        }
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
        case let .functor(result, direction, feature, argument):
            return "(\(result) \(direction)\(feature) \(argument))"

        }
    }
    
}

public enum SentenceFeature : CustomStringConvertible {

    public enum ClauseFeature : CustomStringConvertible {
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

        public var description : String {
            switch self {
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
            }
        }
    }

    public enum LexiconFeature : CustomStringConvertible {
        /// attributive adjectives -- S[adj]\NP
        case adjective
        /// verb phrase features -- S[b]\NP
        case bareInfinitive
        case toInfinitive
        case passivePastParticiple
        case activePastParticiple
        case presentParticiple

        public var description: String {
            switch self {
                case .adjective:
                    return "adj"
                case .bareInfinitive:
                    return "b"
                case .toInfinitive:
                    return "to"
                case .passivePastParticiple:
                    return "pss"
                case .activePastParticiple:
                    return "pt"
                case .presentParticiple:
                    return "ng"
            }
        }

    }
    
    case none
    case clause(ClauseFeature)
    case lexicon(LexiconFeature)

    public var description : String {
        switch self {
            case .none:
                return ""
            case let .clause(x):
                return x.description
            case let .lexicon(x):
                return x.description

        }
    }

}

extension SentenceFeature : Equatable {
    public static func ==(lhs: SentenceFeature, rhs: SentenceFeature) -> Bool {
        switch (lhs, rhs) {
        case let (.clause(x), .clause(y)):
            return x == y
        case let (.lexicon(x), .lexicon(y)):
            return x == y
        default:
            return lhs == rhs
        }
    }
}







