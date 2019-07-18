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
    var cheatMode: Bool = true
    private(set) var cardsOnTable: Array<Card>
    private(set) var cardsSelected = Set<Card>()
    private(set) var cardsInPack: Set<Card>
    var cardsToDeal = Set<Card>()
    var cardsMatched: Set<Card>
    {
        var matched = Set<Card>()
        if cardsSelected.isSet() || (cardsSelected.count == 3 && cheatMode) {
            matched = cardsSelected
        }
        return matched
    }
    private(set) var selectedIsMatch = false {
        didSet {
            if selectedIsMatch {
                Score.shared().playerScore += 3
            }
        }
    }

    init(with startingCardCount: Int) {
        cardsInPack = Card.allCombinations()
        cardsOnTable = [Card]()
        cardsToDeal = Set<Card>()
        dealCards(quantity: startingCardCount)
    }

    init() {
        self.init(with: 12)
    }

    // Deal cards in places specified by [Card?] array (cards on table). When toReplace are nil, procedure finds blank spots on table and deals card over those in quantity of elements in toReplace array. When toReplace cards are not nil, new cards are dealt over cards on table specified in toReplace array.
    private mutating func subtitute(cards toReplace: [Card]) {
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
            else{
                guard let indexToRemove = cardsOnTable.firstIndex(of: cardToReplace) else {
                    return
                }
                cardsOnTable.remove(at: indexToRemove)
            }
        }
    }
    // Shuffle cards on table
    internal mutating func shuffle(){
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
        }
        else {
            // When selection are 3 cards (not including this card), deselect all and replace cards with new from deck if cards are a match.
            if cardsSelected.count == 3 {
                let oldSelection = cardsSelected
                cardsSelected = Set<Card>()
                if selectedIsMatch {
                    subtitute(cards: Array<Card>(oldSelection))
                }
            }
            // Select card
            if cardsOnTable.contains(card) {
                cardsSelected.insert(card)
            }
        }
        if cheatMode && cardsSelected.count == 3 {
            selectedIsMatch = true
        }
        else {
            selectedIsMatch = cardsSelected.isSet()
        }
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
