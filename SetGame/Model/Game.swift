//
//  Game.swift
//  Graphical SetGame
//
//  Created by Lukas on 20/06/2019.
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
    var score: Score = Score()
    private(set) var cardsOnTable: Array<Card>
    private(set) var cardsSelected = Set<Card>()
    private(set) var cardsInPack = Set<Card>()
    var cardsToDeal = Set<Card>()
    var cardsMatched: Set<Card>
    {
        var matched = Set<Card>()
        if cardsSelected.isSet() || (cardsSelected.count == 3 && Constants.cheatModeIsActive) {
            matched = cardsSelected
        }
        return matched
    }
    var selectedIsMatch: Bool {
        var isMatch = false
        if cardsSelected.count == 3 && (cardsSelected.isSet() || Constants.cheatModeIsActive) {
            isMatch = true
            score.increaseScore()
        }
        return isMatch
    }

    init(with startingCardCount: Int) {
        cardsInPack = Card.allCombinations()
        cardsOnTable = [Card]()
        cardsToDeal = Set<Card>()
        dealCards(quantity: startingCardCount)
    }

    init() {
        self.init(with: Constants.initialCardCountOnTable)
    }

    // Deal cards in places specified by [Card?] array (cards on table). When toReplace are nil, procedure finds blank spots on table and deals card over those in quantity of elements in toReplace array. When toReplace cards are not nil, new cards are dealt over cards on table specified in toReplace array.
    internal mutating func subtitute(cards toReplace: [Card]) {
        let numberOfCards = toReplace.count
        for index in 0..<numberOfCards {
            let cardToReplace = toReplace[index]
            if let randomCardFromPack = cardsInPack.randomElement(), let dealCard = cardsInPack.remove(randomCardFromPack) {
                cardsToDeal.insert(dealCard)
                if let indexOnTable = cardsOnTable.firstIndex(of: cardToReplace) {
                    cardsOnTable[indexOnTable] = dealCard
                }
                else {
                    cardsOnTable.append(dealCard)
                }
            }
            // When there is no more cards in th deck, just remove the card from table
                else {
                    guard let indexToRemove = cardsOnTable.firstIndex(of: cardToReplace) else {
                        return
                    }
                    cardsOnTable.remove(at: indexToRemove)
            }
        }
    }
    // Shuffle cards on table
    internal mutating func shuffle() {
        cardsOnTable.shuffle()
    }
    // Deal new cards by number of cards to deal.
    internal mutating func dealCards(quantity count: Int) {
        cardsToDeal = []
        for _ in 0..<count {
            guard let randomCardInPack = cardsInPack.randomElement(), let dealCard = cardsInPack.remove(randomCardInPack) else {
                return
            }
            cardsOnTable.append(dealCard)
            cardsToDeal.insert(dealCard)
        }
    }

    // Select or deselect card depending on situation.
    internal mutating func select(_ card: Card) {
        cardsToDeal = []
        // When less then three cards are slected and you tap already selected card. Deselect given card.
        if cardsSelected.count < 3, cardsSelected.contains(card) {
            cardsSelected.remove(card)
            return
        }
        // Else deselect all.
            else if cardsSelected.count == 3 {
                cardsSelected = Set<Card>()
        }
        // And add only only one card to selection.
        if cardsOnTable.contains(card) {
            cardsSelected.insert(card)
        }
    }
}
