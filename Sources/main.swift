//
//  main.swift
//  EasierCCG
//
//  Created by Richard Wei on 9/14/16.
//
//

import Parsey


/// For testing purposes
while true {
    print("Enter CCG category expression: ")
    do {
        if let line = readLine(), !line.isEmpty {
            let cat = try TextGrammar.category.parse(line)
            print(cat)
        }
    }
    catch let error as ParseFailure {
        print(error)
    }
}
