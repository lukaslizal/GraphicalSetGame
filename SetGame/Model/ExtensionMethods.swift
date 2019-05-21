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

extension Collection where Self.Element == Card {
    func evaluateSelection(of cards: [Self.Element]) -> Bool {
        if(self.allElementsEqual() || self.allElementsNotEqual()){
            return true
        }
        // TODO: Code the rest.
        return false
    }
    
    /// Incomplete matches as two cards with matching feature but third one without this feature
    func anyIncompleteMatches(){
        for card in self{
            var incompleteFeatureIndication = [false, false, false, false]
            // compare card with others in collection except itself
            for cardToCompare in self.drop(while: {$0 == card}){
                incompleteFeatureIndication.map(){(Bool)->Bool in
                    card.matchingFeatures(with: cardToCompare)
                }
            }
        }
    }
}
