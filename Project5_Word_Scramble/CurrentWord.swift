//
//  CurrentWord.swift
//  Project5_Word_Scramble
//
//  Created by Petro Strynada on 03.08.2023.
//

import UIKit

class CurrentWord: NSObject, Codable {
    var word: String
    var usedWords: [String]

    init(word: String, usedWords: [String]) {
        self.word = word
        self.usedWords = usedWords
    }
}
