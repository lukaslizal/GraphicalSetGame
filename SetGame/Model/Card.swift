//
//  Card.swift
//  SetGame
//
//  Created by Lukas on 17/05/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import Foundation

/**
 Playing card in Set! game.
 
 - author:
 Lukas Lizal
 */
struct Card : Equatable, Hashable{
    let shape : Feature
    let color : Feature
    let pattern : Feature
    let quantity : Feature
    
    init(shape: Feature, color: Feature, pattern: Feature, quantity: Feature){
        self.shape = shape
        self.color = color
        self.pattern = pattern
        self.quantity = quantity
    }
    // Return Set of all possible combinations of features in a card. 4 features, 3 options each results in 3*3*3*3 = 81 cards
    static func allCombinations() -> Set<Card>{
        var packOfAllCards = Set<Card>()
        for color in Feature.allCases{
            for pattern in Feature.allCases{
                for quantity in Feature.allCases{
                    for shape in Feature.allCases{
                        let newCard = Card(shape: shape, color: color, pattern: pattern, quantity: quantity)
                        packOfAllCards.insert(newCard)
                    }
                }
            }
        }
        return packOfAllCards
    }
    
//    func matchingFeatures(with otherCard: Card) -> (Bool,Bool,Bool,Bool){
//        return (shape == otherCard.shape, color == otherCard.color, pattern == otherCard.pattern, quantity == otherCard.quantity)
//    }
    
    //Generic card feature.
    enum Feature : CaseIterable {
        case type1
        case type2
        case type3
    }
}

