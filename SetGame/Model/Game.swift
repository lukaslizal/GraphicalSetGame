//
//  Game.swift
//  SetGame
//
//  Created by Lukas on 17/05/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import Foundation

/**
 Set! game engine.
    ## Basic game rules:
        1. Three cards, where two cards share same one feature but third card does not, is not considered a set.
        2. Any other three cards are considered a set
 
 - author:
 Lukas Lizal
 */
struct Game {
    var cardsOnTable : Array<Card?>
    var cardsInPack : Set<Card>
    
    init?(with startingCardCount: Int) throws {
        cardsInPack = Card.allCombinations()
        cardsOnTable = [Card?](repeating: nil, count: 24)
        try dealCards(in: startingCardCount)
    }
    
    init?() throws {
        try self.init(with: 12)
    }
    // Deal cards in places specified by [Card?] array. When toReplace are nil, procedure deals new cards in blank spots on table in number of elements of toReplace array. When toReplace are not nil new cards are delt insted of cards in this array.
    private mutating func subtitute(cards toReplace : [Card?]) throws{
        var freeTableSpaceIndices = [Int]()
        let numberOfCards = toReplace.count
        for index in 0..<numberOfCards{
            if let cardToReplace = toReplace[index], let indexOnTable = cardsOnTable.firstIndex(of: cardToReplace)
            {
                freeTableSpaceIndices.append(indexOnTable)
            }
            else{
                guard let freeTableSpaceIndex = cardsOnTable.firstIndex(of: nil) else{
                    throw CardGameError.noSpaceOnTable
                }
                freeTableSpaceIndices.append(freeTableSpaceIndex)
            }
        }
        // only deal cards if there is enough space for them and there is enough cards in the dealing pack
        if(freeTableSpaceIndices.count == numberOfCards)
        {
            for index in 0..<numberOfCards{
                guard let randomCardInPack = cardsInPack.randomElement() else{
                    throw CardGameError.noCardsInPack
                }
                cardsOnTable[freeTableSpaceIndices[index]] = (cardsInPack.remove(randomCardInPack))
            }
        }
    }
    // Deal new cards by number.
    mutating func dealCards(in quantity : Int) throws{
        let toReplace = Array<Card?>(repeating: nil, count: quantity)
        try subtitute(cards: toReplace)
    }
    // Deal new cards on place of old ones specified in toReplace.
    mutating func dealCards(cards toReplace : [Card]) throws{
        try subtitute(cards: toReplace)
    }
}

/**
 Error states of Set! game
 
 - author:
 Lukas Lizal
 */
enum CardGameError: Error{
    case noSpaceOnTable
    case noCardsInPack
}

