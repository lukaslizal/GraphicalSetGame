//
//  Card.swift
//  SetGame
//
//  Created by Lukas on 17/05/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import Foundation

struct Card : Equatable{
    var mark: MarkingFeatures
    static func == (lhs: Card, rhs: Card) -> Bool{
        return false
    }
    init(shape: MarkingFeatures.Shape, color: MarkingFeatures.Color, pattern: MarkingFeatures.Pattern, quantity: MarkingFeatures.Quantity){
        mark.shape = shape
        mark.color = color
        mark.pattern = pattern
        mark.quantity = quantity
    }
    
    struct MarkingFeatures{
        fileprivate(set) var shape : Shape
        fileprivate(set) var color : Color
        fileprivate(set) var pattern : Pattern
        fileprivate(set) var quantity : Quantity
        
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
}

