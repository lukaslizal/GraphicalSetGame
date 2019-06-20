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
    var cardsOnTable: Array<Card>
    var cardsSelected = Set<Card>()
    var cardsInPack: Set<Card>
    {
        didSet {
            print(self.cardsInPack.count)
        }
    }
    var cardsMatched: Set<Card>
    {
        var matched = Set<Card>()
        if cardsSelected.isSet() {
            matched = cardsSelected
        }
        return matched
    }
    var selectedIsMatch = false {
        didSet {
            if selectedIsMatch {
                Score.shared().playerScore += 3
            }
        }
    }

    init(with startingCardCount: Int) {
        cardsInPack = Card.allCombinations()
        cardsOnTable = [Card]()
        dealCards(quantity: startingCardCount)
    }

    init() {
        self.init(with: 12)
    }

    // Deal cards in places specified by [Card?] array (cards on table). When toReplace are nil, procedure finds blank spots on table and deals card over those in quantity of elements in toReplace array. When toReplace cards are not nil, new cards are dealt over cards on table specified in toReplace array.
    mutating func subtitute(cards toReplace: [Card?]) {
        let numberOfCards = toReplace.count
        for index in 0..<numberOfCards {
            if let cardToReplace = toReplace[index], let randomCardFromPack = cardsInPack.randomElement(), let dealCard = cardsInPack.remove(randomCardFromPack) {
                if let indexOnTable = cardsOnTable.firstIndex(of: cardToReplace) {
                    cardsOnTable[indexOnTable] = dealCard
                }
                else {
                    cardsOnTable.append(dealCard)
                }
            }
        }
    }
    // Deal new cards by number of cards to deal.
    mutating func dealCards(quantity count: Int) {
        for _ in 0..<count {
            guard let randomCardInPack = cardsInPack.randomElement(), let dealCard = cardsInPack.remove(randomCardInPack) else {
                return
            }
            cardsOnTable.append(dealCard)
        }
    }
    // Select or deselect card depending on conditions. Returns true only when new card selection is a Set.
    mutating func select(_ card: Card) {
        // When less then three cards are slected and you tap already selected card. Deselect given card.
        if cardsSelected.count < 3, cardsSelected.contains(card) {
            cardsSelected.remove(card)
        }
        else {
            // When selection are 3 cards (not including this card), deselect all and replace cards with new from deck if cards are a match.
            if cardsSelected.count == 3 {
                let oldSelection = cardsSelected
                cardsSelected = Set<Card>()
                if selectedIsMatch {
                    subtitute(cards: Array<Card?>(oldSelection))
                }
            }
            // Select card
            if cardsOnTable.contains(card) {
                cardsSelected.insert(card)
            }
        }
        selectedIsMatch = cardsSelected.isSet()
    }
}

/**
 Error states of Set! game
 
 - author:
 Lukas Lizal
 */
class Score {
    var playerScore: Int
    private static var instance = {
        return Score()
    }()

    private init() {
        playerScore = 0
    }

    static func shared() -> Score {
        return instance
    }

    static func reset() {
        self.shared().playerScore = 0
    }
}
