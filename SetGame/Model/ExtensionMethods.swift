//
//  ExtensionMethods.swift
//  Graphical SetGame
//
//  Created by Lukas on 20/06/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import Foundation
import UIKit

/**
 Miscellaneous extension methods.
 
 - author:
 Lukas Lizal
 */
extension UIView {
    /**
     Shakes UIView in a disapproving way (;_;)
     */
    internal func shake() {
        self.transform = CGAffineTransform(translationX: Constants.shakeViewAmplitude, y: 0)
        UIView.animate(withDuration: Constants.shakeViewDuration, delay: 0, usingSpringWithDamping: Constants.shakeViewSpringDamping, initialSpringVelocity: Constants.shakeViewInitialSpringVelocity, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    /**
     Nods UIView in an approving way (^_^)
     */
    internal func nod() {
        self.transform = CGAffineTransform(translationX: 0, y: -Constants.nodViewAmplitude)
        UIView.animate(withDuration: Constants.nodViewDuration, delay: 0, usingSpringWithDamping: Constants.nodViewSpringDamping, initialSpringVelocity: Constants.nodViewInitialSpringVelocity, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

extension UIColor {
    /**
     Three colors palette where each color is ordered and retrievable by a number.
     */
    struct ColorPalette {
        internal static var firstColor: UIColor { return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) }
        internal static var secondColor: UIColor { return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1) }
        internal static var thirdColor: UIColor { return #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1) }
        
        internal static func color(of type: Int) -> UIColor {
            switch(type) {
            case 0:
                return firstColor
            case 1:
                return secondColor
            case 2:
                return thirdColor
            default:
                return #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            }
        }
    }
}

extension CGRect {
    /**
     Map normalized CGPoint (floatin point values in range 0..1) to a point in full width and height of given CGRect.
     */
    internal func mappedPointFrom(normalized point: CGPoint) -> CGPoint {
        let x = 0 + point.x * self.width
        let y = 0 + point.y * self.height
        return CGPoint(x: x, y: y)
    }
}

extension Collection where Element == Card {
    /**
     Finding (non) matching card features in a collection of Cards.
     */
    internal func isSet()->Bool{
        //        Cheating:
        //        return true
        return !anyIncompleteMatches() && self.count == 3
    }
    
    /**
     Incomplete feature matches (meaning two cards with matching feature but third one without this feature).
    */
    internal func anyIncompleteMatches() -> Bool{
        var pairFeaturesComparison = Dictionary<Set<Card>,(Bool,Bool,Bool,Bool)>()
        var featureMatchesCounter = (0,0,0,0)
        for cardOne in self{
            // Link card with each other except itself, then compare features of these pairs.
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
extension Dictionary {
    /**
     Merges two dictionaries.
     */
    internal mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
extension UIButton {
    /**
     Makes UIButton disabled state change opacity.
     */
    open override var isEnabled: Bool{
        didSet {
            UIFactory.setupDealCardsButton(button: self)
        }
    }
}
extension UIApplication {
    /**
     Ignore any touch input across the wole app for specified time period.
     */
    internal static func ignoreInteractionEvents(for time: TimeInterval){
        UIApplication.shared.beginIgnoringInteractionEvents()
        DispatchQueue.main.asyncAfter(deadline: .now()+time) {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}
