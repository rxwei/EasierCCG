/// TextParser.swift
/// EasierCCG
///
/// Created by Richard Wei on 9/14/16.
///

import Parsey

enum TextGrammar {

    static let spaces = Lexer.whitespaces.?

    static let atom =
          Lexer.token("NP") ^^ { _ in Category.atom(.nounPhrase) }
        | Lexer.token("VP") ^^ { _ in Category.atom(.verbPhrase) }
        | Lexer.token("PP") ^^ { _ in Category.atom(.prepositionalPhrase) }
        | Lexer.token("N")  ^^ { _ in Category.atom(.noun) }
        | Lexer.token("V")  ^^ { _ in Category.atom(.verb) }
        | Lexer.token("P")  ^^ { _ in Category.atom(.preposition) }
        | Lexer.token("X")  ^^ { _ in Category.variable }
        | Lexer.token("S") ~~> Lexer.token("[") ~~> clauseFeature <~~ Lexer.token("]") ^^ { Category.atom(.sentence(SentenceFeature.clause($0))) }
        | Lexer.token("S") ~~> Lexer.token("[") ~~> lexiconFeature <~~ Lexer.token("]") ^^ { Category.atom(.sentence(.lexicon($0))) }


    static let clauseFeature =
          Lexer.token("dcl")  ^^ { _ in SentenceFeature.clause(.declarativeSentence) }
        | Lexer.token("wq")   ^^ { _ in SentenceFeature.clause(.whQuestion) }
        | Lexer.token("q")    ^^ { _ in SentenceFeature.clause(.yesNoQuestion) }
        | Lexer.token("qem")  ^^ { _ in SentenceFeature.clause(.embeddedQuestion) }
        | Lexer.token("em")   ^^ { _ in SentenceFeature.clause(.embeddedSentence) }
        | Lexer.token("bem")  ^^ { _ in SentenceFeature.clause(.subjunctiveSentence) }
        | Lexer.token("b")    ^^ { _ in SentenceFeature.clause(.subjunctiveSentence) }
        | Lexer.token("frg")  ^^ { _ in SentenceFeature.clause(.subjunctiveSentence) }
        | Lexer.token("for")  ^^ { _ in SentenceFeature.clause(.forClause) }
        | Lexer.token("intj") ^^ { _ in SentenceFeature.clause(.interjection) }
        | Lexer.token("inv")  ^^ { _ in SentenceFeature.clause(.ellipticalInversion) }

    static let lexiconFeature = 
          Lexer.token("adj")  ^^ { _ in SentenceFeature.lexicon(.adjective) }
        | Lexer.token("b")    ^^ { _ in SentenceFeature.lexicon(.bareInfinitive) }
        | Lexer.token("to")   ^^ { _ in SentenceFeature.lexicon(.toInfinitive) }
        | Lexer.token("pss")  ^^ { _ in SentenceFeature.lexicon(.passivePastParticiple) }
        | Lexer.token("pt")   ^^ { _ in SentenceFeature.lexicon(.activePastParticiple) }
        | Lexer.token("ng")   ^^ { _ in SentenceFeature.lexicon(.presentParticiple) }
    
    


    static let slash =
          Lexer.token("/")  ^^ { _ in { Category.functor($0,  .forward, $1) } }
        | Lexer.token("\\") ^^ { _ in { Category.functor($0, .backward, $1) } }

    static let functorTerm = atom
                           | "(" ~~> functor <~~ ")"

    static let functor: Parser<Category> =
        functorTerm.infixedLeft(by: slash.amid(spaces)).amid(spaces)

    static let category: Parser<Category> = functor
                                          
}


