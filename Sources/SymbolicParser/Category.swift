//
//  Category.swift
//  EasierCCG
//
//  Created by Richard Wei on 9/14/16.
//
//

import Parsey
import CCG

enum ExpressionGrammar {

    static let spaces = Lexer.whitespaces.?

    static let atom: Parser<Category> =
          Lexer.token("NP") ^^ { _ in Category.atom(.nounPhrase) }
        | Lexer.token("VP") ^^ { _ in Category.atom(.verbPhrase) }
        | Lexer.token("PP") ^^ { _ in Category.atom(.prepositionalPhrase) }
        | Lexer.token("N")  ^^ { _ in Category.atom(.noun) }
        | Lexer.token("V")  ^^ { _ in Category.atom(.verb) }
        | Lexer.token("P")  ^^ { _ in Category.atom(.preposition) }
        | Lexer.token("X")  ^^ { _ in Category.variable }
        | Lexer.token("S") ~~> (Lexer.token("[") ~~> sentenceFeature <~~ Lexer.token("]")).?
            ^^ { Category.atom(.sentence($0)) }

    static let sentenceFeature = clauseFeature | lexicalFeature

    static let clauseFeature: Parser<SentenceFeature> =
          Lexer.token("dcl")  ^^ { _ in .declarativeSentence }
        | Lexer.token("wq")   ^^ { _ in .whQuestion }
        | Lexer.token("q")    ^^ { _ in .yesNoQuestion }
        | Lexer.token("qem")  ^^ { _ in .embeddedQuestion }
        | Lexer.token("em")   ^^ { _ in .embeddedSentence }
        | Lexer.token("bem")  ^^ { _ in .subjunctiveSentence }
        | Lexer.token("b")    ^^ { _ in .subjunctiveSentence }
        | Lexer.token("frg")  ^^ { _ in .subjunctiveSentence }
        | Lexer.token("for")  ^^ { _ in .forClause }
        | Lexer.token("intj") ^^ { _ in .interjection }
        | Lexer.token("inv")  ^^ { _ in .ellipticalInversion }

    static let lexicalFeature: Parser<SentenceFeature> =
          Lexer.token("adj")  ^^ { _ in .adjective }
        | Lexer.token("b")    ^^ { _ in .bareInfinitive }
        | Lexer.token("to")   ^^ { _ in .toInfinitive }
        | Lexer.token("pss")  ^^ { _ in .passivePastParticiple }
        | Lexer.token("pt")   ^^ { _ in .activePastParticiple }
        | Lexer.token("ng")   ^^ { _ in .presentParticiple }

    static let slash =
          Lexer.token("/")  ^^ { _ in { Category.forwardFunctor($0, $1) } }
        | Lexer.token("\\") ^^ { _ in { Category.backwardFunctor($0, $1) } }

    static let functorTerm = atom | "(" ~~> functor <~~ ")"

    static let functor: Parser<Category> =
        functorTerm.infixedLeft(by: slash.amid(spaces)).amid(spaces)

    static let category: Parser<Category> = functor
                                          
}
