//
//  main.swift
//  EasierCCG
//
//  Created by Richard Wei on 9/14/16.
//
//

import Parsey

let NP: Category = .atom(.nounPhrase)

/// (S\NP)/NP
let proved: Category = .functor(.functor(.atom(.sentence),
                                         .backward,
                                         .permissive,
                                         .atom(.nounPhrase)),
                                .forward,
                                .permissive,
                                .atom(.nounPhrase))

var entries = [ "I" : [NP] ,
                "Marcel" : [NP],
                "disproved" : [proved],
                "proved" : [proved] ]

var lexicon: Lexicon = Lexicon(entries: entries)

/// For testing purposes
while true {
    print("Enter a lexicon entry: ")
    do {
        if let word = readLine(), !word.isEmpty {
            print("Enter CCG category expression: ")
            do {
                if let line = readLine(), !line.isEmpty {
                    let cat = try TextGrammar.category.parse(line)
                    print(cat)
                    lexicon.addEntry(word: word, category: cat)
                }
            }
        }
    }

    catch let error as ParseFailure {
        print(error)
    }
    print(lexicon)
}
