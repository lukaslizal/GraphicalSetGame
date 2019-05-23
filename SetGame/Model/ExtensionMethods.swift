//
//  ExtensionMethods.swift
//  SetGame
//
//  Created by Lukas on 21/05/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import Foundation


extension Collection where Self.Element : Equatable {
    func allElementsEqual() -> Bool {
        for card in self{
            guard self.first != card else{
                return false
            }
        }
        return true
    }
    func allElementsNotEqual() -> Bool {
        for card in self{
            for cardToCompare in self{
                guard cardToCompare == card else{
                    return false
                }
            }
        }
        return true
    }
}

extension Set where Element == Card {
    func evaluateSelection(of cards: [Set.Element]) -> Bool {
        if(anyIncompleteMatches()){
            return false
        }
        return true
//        if(self.allElementsEqual() || self.allElementsNotEqual()){
//            return true
//        }
    }

    /// Incomplete feature matches (meaning two cards with matching feature but third one without this feature).
    func anyIncompleteMatches() -> Bool{
        var pairFeaturesComparison = Dictionary<Set<Card>,(Bool,Bool,Bool,Bool)>()
        for cardOne in self{
            // link card with each other except itself, then compare features of these pairs
            for cardTwo in self.drop(while: {$0 == cardOne}){
                let pair = Set<Card>(arrayLiteral: cardOne, cardTwo)
                let featureComparison = (cardOne.shape == cardTwo.shape,cardOne.color == cardTwo.color,cardOne.pattern == cardTwo.pattern,cardOne.quantity == cardTwo.quantity)
                pairFeaturesComparison[pair] = featureComparison
            }
        }
        var featureMatchesCounter = (0,0,0,0)
        for (pairOne, comparisonOne) in pairFeaturesComparison{
            for (_, comparisonTwo) in pairFeaturesComparison.drop(while: {($0.key == pairOne)}){
                featureMatchesCounter.0 += (comparisonOne.0 == comparisonTwo.0) ? 1 : 0
                featureMatchesCounter.1 += (comparisonOne.1 == comparisonTwo.1) ? 1 : 0
                featureMatchesCounter.2 += (comparisonOne.2 == comparisonTwo.2) ? 1 : 0
                featureMatchesCounter.3 += (comparisonOne.3 == comparisonTwo.3) ? 1 : 0
            }
        }
        // for debugging purposes
        if(featureMatchesCounter.0 == 2 || featureMatchesCounter.1 == 2 || featureMatchesCounter.2 == 2 || featureMatchesCounter.3 == 2)
        {
            print("Invalid matching function state - TWO PAIRS comparisons match - It would need to be ALL THREE or JUST ONE or ZERO ")
        }
        return featureMatchesCounter.0 == 1 || featureMatchesCounter.1 == 1 || featureMatchesCounter.2 == 1 || featureMatchesCounter.3 == 1
    }
}
