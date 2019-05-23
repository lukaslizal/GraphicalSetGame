//
//  Game.swift
//  SetGame
//
//  Created by Lukas on 17/05/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import Foundation

struct Game {
    var cardsOnTable : Array<Card?>
    var cardsInPack : Set<Card>
    init?(with layedCards: Int) throws {
        cardsInPack = Card.allCombinations()
        cardsOnTable = [Card?](repeating: nil, count: 24)
        try dealCards(in: 12)
    }
    
    private mutating func subtitute(cards toReplace : [Card?]) throws{
        var freeTableSpaceIndices = [Int]()
        let numberOfCards = toReplace.count
        for index in 0..<numberOfCards{
            if let cardToReplace = toReplace[index], cardsOnTable.contains(cardToReplace)
            {
                freeTableSpaceIndices.append(cardsOnTable.firstIndex(of: cardToReplace)!)
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
    
    mutating func dealCards(in quantity : Int) throws{
        let toReplace = Array<Card?>(repeating: nil, count: quantity)
        try subtitute(cards: toReplace)
    }
    
    mutating func dealCards(cards toReplace : [Card]) throws{
        try subtitute(cards: toReplace)
    }
}

enum CardGameError: Error{
    case noSpaceOnTable
    case noCardsInPack
}

