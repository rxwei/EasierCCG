//
//  PrettyPrint.swift
//  EasierCCG
//
//  Created by Richard Wei on 11/19/16.
//
//

extension Primitive : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .sentence(let x?):    return "S" + x.description
        case .sentence(nil):       return "S"
        case .noun:                return "N"
        case .preposition:         return "P"
        case .verb:                return "V"
        case .nounPhrase:          return "NP"
        case .prepositionalPhrase: return "PP"
        case .verbPhrase:          return "VP"
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
        case let .forwardFunctor(result, argument):
            return "(\(result) / \(argument))"
        case let .backwardFunctor(result, argument):
            return "(\(result) \\ \(argument))"
        }
    }
    
}

extension SentenceFeature : CustomStringConvertible {

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
