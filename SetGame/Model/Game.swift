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
    var cardsSelected = Set<Card>()
    var selectedIsMatch = false {
        didSet{
            if selectedIsMatch == true {
                Score.shared().playerScore += 3
            }
        }
    }
    var matchedCards = Set<Card>()
    
    init(with startingCardCount: Int){
        cardsInPack = Card.allCombinations()
        cardsOnTable = [Card?](repeating: nil, count: 24)
        do{
            try dealCards(in: startingCardCount)
        }
        catch{
            print(error)
        }
    }
    
    init(){
        self.init(with: 12)
    }
    // Deal cards in places specified by [Card?] array (cards on table). When toReplace are nil, procedure finds blank spots on table and deals card over those in quantity of elements in toReplace array. When toReplace cards are not nil, new cards are dealt over cards on table specified in toReplace array.
    private mutating func subtitute(cards toReplace : [Card?]) throws{
        var freeTableSpaceIndices = [Int]()
        let numberOfCards = toReplace.count
        for index in 0..<numberOfCards{
            if let cardToReplace = toReplace[index], let indexOnTable = cardsOnTable.firstIndex(of: cardToReplace){
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
        if(freeTableSpaceIndices.count == numberOfCards){
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
    // Select or deselect card depending on conditions. Returns true only when new card selection is a Set.
    mutating func select(_ card: Card) -> Bool{
        // When less then three cards are slected and you tap already selected card.
        if cardsSelected.count < 3, cardsSelected.contains(card){
            cardsSelected.remove(card)
        }
        else{
            if cardsSelected.count == 3{
                // When selection is a Set, deselect all, remove from table and select given card.
                if selectedIsMatch{
                    let oldSelection = cardsSelected
                    if !cardsSelected.contains(card){
                        cardsSelected.insert(card)
                    }
                    for matchedCard in oldSelection{
                        cardsSelected.remove(matchedCard)
                        if let matchedIndex = cardsOnTable.firstIndex(of: matchedCard){
                            cardsOnTable.remove(at: matchedIndex)
                        }
                    }
                    do{
                        try subtitute(cards: Array<Card?>(oldSelection))
                    }
                    catch{
                        print(error)
                    }
                }
                else{
                    for cardToDeselect in cardsSelected{
                        cardsSelected.remove(cardToDeselect)
                    }
                    cardsSelected.insert(card)
                }
            }
            else{
                cardsSelected.insert(card)
                if cardsSelected.count == 3{
                    selectedIsMatch = cardsSelected.isSet()
                }
            }
        }
        return selectedIsMatch
    }
}

/**
 Error states of Set! game
 
 - author:
 Lukas Lizal
 */
class Score{
    var playerScore: Int
    private static var instance = {
        return Score()
    }()
    
    private init() {
        playerScore = 0
    }
    
    static func shared() -> Score{
        return instance
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

