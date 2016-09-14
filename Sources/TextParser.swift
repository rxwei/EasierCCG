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
        | Lexer.token("S")  ^^ { _ in Category.atom(.sentence) }
        | Lexer.token("X")  ^^ { _ in Category.variable }

    static let slash =
          Lexer.token("/")  ^^ { _ in { Category.functor($0,  .forward, .permissive, $1) } }
        | Lexer.token("\\") ^^ { _ in { Category.functor($0, .backward, .permissive, $1) } }

    static let functorTerm = atom
                           | "(" ~~> functor <~~ ")"

    static let functor: Parser<Category> =
        functorTerm.infixedLeft(by: slash.amid(spaces)).amid(spaces)

    static let category: Parser<Category> = functor
                                          
}


