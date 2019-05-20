//
//  Card.swift
//  SetGame
//
//  Created by Lukas on 17/05/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import Foundation

struct Card : Equatable{
    fileprivate(set) var shape : Shape
    fileprivate(set) var color : Color
    fileprivate(set) var pattern : Pattern
    fileprivate(set) var quantity : Quantity
    
    static func == (lhs: Card, rhs: Card) -> Bool{
        return false
    }
    static func allCombinations() -> [Card]{
        var packOfAllCards = [Card]()
        for color in Color.allCases{
            for pattern in Pattern.allCases{
                for quantity in Quantity.allCases{
                    for shape in Shape.allCases{
                        let newCard = Card(shape: shape, color: color, pattern: pattern, quantity: quantity)
                        packOfAllCards.append(newCard)
                    }
                }
            }
        }
        return packOfAllCards
    }
    
    init(shape: Shape, color: Color, pattern: Pattern, quantity: Quantity){
        self.shape = shape
        self.color = color
        self.pattern = pattern
        self.quantity = quantity
    }
    
    //MARK: Card feature definitions.
    enum Shape : CaseIterable {
        case circle
        case square
        case triangle
    }
    enum Color : CaseIterable {
        case red
        case green
        case purple
    }
    enum Quantity : CaseIterable {
        case one
        case two
        case three
    }
    enum Pattern : CaseIterable {
        case fill
        case outline
        case transparent
    }
}

