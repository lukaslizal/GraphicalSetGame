//
//  Card.swift
//  Graphical SetGame
//
//  Created by Lukas on 20/06/2019.
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
    
    init()
    {
        self.init(shape: Card.Feature.type1, color: Card.Feature.type1, pattern: Card.Feature.type1, quantity: Card.Feature.type1)
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
    // Card's generic feature (May be used for shape, color...).
    enum Feature : Int, CaseIterable {
        case type1 = 0, type2, type3
    }
}

