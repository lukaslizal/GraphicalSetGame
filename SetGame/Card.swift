//
//  Card.swift
//  SetGame
//
//  Created by Lukas on 17/05/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import Foundation

struct Card : Equatable{
    let shape : Feature
    let color : Feature
    let pattern : Feature
    let quantity : Feature
    
    static func allCombinations() -> [Card]{
        var packOfAllCards = [Card]()
        for color in Feature.allCases{
            for pattern in Feature.allCases{
                for quantity in Feature.allCases{
                    for shape in Feature.allCases{
                        let newCard = Card(shape: shape, color: color, pattern: pattern, quantity: quantity)
                        packOfAllCards.append(newCard)
                    }
                }
            }
        }
        return packOfAllCards
    }
    
    func matchingFeatures(with otherCard: Card) -> (Bool,Bool,Bool,Bool){
        return (shape == otherCard.shape, color == otherCard.color, pattern == otherCard.pattern, quantity == otherCard.quantity)
    }
    
    init(shape: Feature, color: Feature, pattern: Feature, quantity: Feature){
        self.shape = shape
        self.color = color
        self.pattern = pattern
        self.quantity = quantity
    }
    
    //MARK: Card feature definitions.
    enum Feature : CaseIterable {
        case type1
        case type2
        case type3
    }
}

