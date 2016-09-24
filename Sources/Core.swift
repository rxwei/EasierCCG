/// Core.swift
/// EasierCCG
///
/// Created by Richard Wei on 9/14/16.
///

/// Combinatory categorial grammar
public enum Primitive {
    case sentence, noun, preposition, verb
    case nounPhrase, prepositionalPhrase, verbPhrase
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
    
}

extension Primitive : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .sentence:            return "S"
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

