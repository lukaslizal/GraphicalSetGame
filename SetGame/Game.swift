//
//  Game.swift
//  SetGame
//
//  Created by Lukas on 17/05/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import Foundation

struct Game {
    var cardsOnTable : [Card?]
    var cardsInPack : [Card]
    init?(with layedCards: Int) throws {
        cardsInPack = Card.allCombinations()
        cardsOnTable = [Card?](repeating: nil, count: 24)
        try dealCards(in: 12)
    }
    
    private mutating func dealCards(in quantity : Int, subtituting cards: [Card]? = nil) throws{
        var freeTableSpaceIndices = [Int]()
        var randomPackIndices = [Int]()
        let numberOfCards = cards != nil ? cards!.count : quantity
        for _ in 0..<numberOfCards{
            guard let freeTableSpaceIndex = cardsOnTable.firstIndex(of: nil) else{
                throw CardGameError.noSpaceOnTable
            }
            guard let randomCardIndex = (0..<cardsInPack.count).randomElement() else{
                throw CardGameError.noCardsInPack
            }
            freeTableSpaceIndices.append(freeTableSpaceIndex)
            randomPackIndices.append(randomCardIndex)
        }
        // only deal cards if there is enough space for them and there is enough cards in the dealing pack
        if(freeTableSpaceIndices.count == numberOfCards)
        {
            for index in 0..<numberOfCards{
                cardsOnTable[freeTableSpaceIndices[index]] = (cardsInPack.remove(at: randomPackIndices[index]))
            }
        }
    }
    
    mutating func dealCards(in quantity : Int) throws{
        try dealCards(in: quantity)
    }
    
    mutating func subtituteCards(from cards : [Card]) throws{
        try dealCards(in: 0, subtituting: cards)
    }
}

enum CardGameError: Error{
    case noSpaceOnTable
    case noCardsInPack
}

extension Collection where Self.Element : Equatable {
    func allElementsEqual() -> Bool {
        for element in self{
            guard self.first != element else{
                return false
            }
        }
        return true
    }
    func allElementsNotEqual() -> Bool {
        for element in self{
            for elementToCompare in self{
                guard elementToCompare == element else{
                    return false
                }
            }
        }
        return true
    }
}

extension Collection where Self.Element == Card {
    func evaluateSelection(of cards: [Self.Element]) -> Bool {
        if(self.allElementsEqual() || self.allElementsNotEqual()){
            return true
        }
        // TODO: Code the rest.
        return false
    }
    
    func anyOnlyTwoMatching(){
        
    }
}
