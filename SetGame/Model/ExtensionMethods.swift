//
//  ExtensionMethods.swift
//  SetGame
//
//  Created by Lukas on 21/05/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import Foundation
import UIKit

/**
 Extension methods helping core gameplay mechanic to be checked. That is finding (non) matching card features.
 
 - author:
 Lukas Lizal
 */
extension Collection where Element == Card {
    func isSet()->Bool{
        //        Cheating:
//        return true
        return !anyIncompleteMatches() && self.count == 3
    }
    
    // Incomplete feature matches (meaning two cards with matching feature but third one without this feature).
    func anyIncompleteMatches() -> Bool{
        var pairFeaturesComparison = Dictionary<Set<Card>,(Bool,Bool,Bool,Bool)>()
        var featureMatchesCounter = (0,0,0,0)
        for cardOne in self{
            // Link card with each other except itself, then compare features of these pairs.
            print("iteration")
            for cardTwo in self{
                if cardTwo != cardOne {
                    let pair = Set<Card>(arrayLiteral: cardOne, cardTwo)
                    let featureComparison = (cardOne.shape == cardTwo.shape,cardOne.color == cardTwo.color,cardOne.pattern == cardTwo.pattern,cardOne.quantity == cardTwo.quantity)
                    pairFeaturesComparison[pair] = featureComparison
                }
            }
        }
        // Compares features and update feature matching counter accordingly
        for (_, featuresMatching) in pairFeaturesComparison{
            featureMatchesCounter.0 += featuresMatching.0 ? 1 : 0
            featureMatchesCounter.1 += featuresMatching.1 ? 1 : 0
            featureMatchesCounter.2 += featuresMatching.2 ? 1 : 0
            featureMatchesCounter.3 += featuresMatching.3 ? 1 : 0
        }
        // If there is any feature that was matched only once, it means there are only two cards of some feature and therefore selection is not a Set.
        return featureMatchesCounter.0 == 1 || featureMatchesCounter.1 == 1 || featureMatchesCounter.2 == 1 || featureMatchesCounter.3 == 1
    }
}
/**
 Extension method merges two dictionaries
 
 - author:
 Lukas Lizal
 */
extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
/**
 Extension method makes UIButton disabled state change opacity
 
 - author:
 Lukas Lizal
 */
extension UIButton {
    
    open override var isEnabled: Bool{
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
}
