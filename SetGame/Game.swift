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
        cardsInPack = [Card]()
        for color in Card.MarkingFeatures.Color.allCases{
            for pattern in Card.MarkingFeatures.Pattern.allCases{
                for quantity in Card.MarkingFeatures.Quantity.allCases{
                    for shape in Card.MarkingFeatures.Shape.allCases{
                        let newCard = Card(shape: shape, color: color, pattern: pattern, quantity: quantity)
                        cardsInPack.append(newCard)
                    }
                }
            }
        }
        cardsOnTable = [Card?](repeating: nil, count: 24)
        for _ in 0..<layedCards{
            if let randomIndex = (0..<cardsInPack.count).randomElement(){
                cardsOnTable.append(cardsInPack.remove(at: randomIndex))
            }
            else{
                throw CardGameError.outOfCardsError
            }
        }
    }
    
    mutating func dealCard() throws {
        guard let freeTableSpaceIndex = cardsOnTable.firstIndex(of: nil) else{
            throw CardGameError.noSpaceOnTable
        }
        guard let randomCardIndex = (0..<cardsInPack.count).randomElement() else{
            throw CardGameError.noCardsInPack
        }
        cardsOnTable[freeTableSpaceIndex] = cardsInPack.remove(at: randomCardIndex)
    }
    
    mutating func dealCards(in quantity: Int) throws{
        for _ in 0..<quantity{
            try dealCard()
        }
    }
}

enum CardGameError: Error{
    case outOfCardsError
    case noSpaceOnTable
    case noCardsInPack
}
