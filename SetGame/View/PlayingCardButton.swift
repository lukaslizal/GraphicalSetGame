//
//  PlayingCardButton.swift
//  SetGame
//
//  Created by Lukas on 22/07/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

/**
 Custom tap delegate protocol.

 - author:
 Lukas Lizal
 */
protocol CardTap: class {
    func tapped(playingCardButton: PlayingCardButton) -> Bool
}

/**
 Represents custom touch responsive UIView with nested PlayingCardView.
 
 - author:
 Lukas Lizal
 */
class PlayingCardButton: UIView {
    
    // MARK: STORED PROPERTIES
    
    var playingCardView = PlayingCardView()
    var selected: Bool = false
    var gesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
    weak var delegate: CardTap?
    
    // MARK: INITIALIZATION
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    init(frame: CGRect, cornerRadius: CGFloat, shapeType: Int, quantityType: Int, fillType: Int, colorType: Int) {
        super.init(frame: frame)
        layer.cornerRadius = cornerRadius
        layer.backgroundColor = Constants.buttonColor
        clipsToBounds = true
        setupPlayingCardView(cornerRadius: cornerRadius, shapeType: shapeType, quantityType: quantityType, fillType: fillType, colorType: colorType)
        setupGestures()
    }

    private func setupPlayingCardView(cornerRadius: CGFloat, shapeType: Int, quantityType: Int, fillType: Int, colorType: Int) {
        let rect = self.layer.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing)
        let cardViewCornerRadius = rect.width * (cornerRadius / layer.bounds.width)
        playingCardView = PlayingCardView(frame: rect, cornerRadius: cardViewCornerRadius, shapeType: shapeType, quantityType: quantityType, fillType: fillType, colorType: colorType)
        addSubview(playingCardView)
    }
    
    // MARK: TOUCH CONTROLS
    
    // FIXME: Concurrent UILongPressGestureRecogniser on PlayingCardButton views.
    // This is where I am trying to setup this views UILongPressGestureRecogniser. I thought use of isExclusiveTouch and isMultipleTouchEnabled could help with my problem but doesn't seem to change anything in how touch works here.
    
    func setupGestures() {
        let longPressGestureRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressHandler))
        longPressGestureRecogniser.minimumPressDuration = 0
        longPressGestureRecogniser.delegate = self
        self.addGestureRecognizer(longPressGestureRecogniser)
        gesture = longPressGestureRecogniser
        self.isExclusiveTouch = true
//        self.isMultipleTouchEnabled = false
    }

    @objc func longPressHandler(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            if !selected {
                UIViewPropertyAnimator(duration: Constants.animationButtonScaleDownDuration, dampingRatio: Constants.animationButtonDownDamping) {
                    self.playingCardView.transform = CGAffineTransform(scaleX: Constants.animationButtonScaleDown, y: Constants.animationButtonScaleDown)
                }.startAnimation()
            }
            else {
                UIViewPropertyAnimator(duration: Constants.animationButtonScaleUpDuration, dampingRatio: Constants.animationButtonUpDamping) {
                    self.playingCardView.transform = CGAffineTransform.identity
                }.startAnimation()
            }
        case .changed:
            let inside = self.point(inside: sender.location(in: self), with: nil)
            if !inside && !selected {
                sender.cancel()
            }
        case .cancelled:
            if !selected {
                UIViewPropertyAnimator(duration: Constants.animationButtonScaleUpDuration, dampingRatio: Constants.animationButtonUpDamping) {
                    self.playingCardView.transform = CGAffineTransform.identity
                    }.startAnimation()
            }
        case .ended:
            let inside = self.point(inside: sender.location(in: self), with: nil)
            if inside {
                if let tapDelegate = self.delegate {
                    selected = tapDelegate.tapped(playingCardButton: self)
                }
            }
            else if !selected {
                UIViewPropertyAnimator(duration: Constants.animationButtonScaleUpDuration, dampingRatio: Constants.animationButtonUpDamping) {
                    self.playingCardView.transform = CGAffineTransform.identity
                }.startAnimation()
            }
        default:
            return
        }
    }
    
    // MARK: CHANGING APPEARANCE
    
    /**
     Visually highlights button as a selected card.
     */
    func selectedHighlight() {
        playingCardView.selectedHighlight()
        selected = true
    }
    /**
     Visually highlights button as a successfuly matched card.
     */
    func successHighlight() {
        UIViewPropertyAnimator(duration: Constants.animationButtonScaleUpDuration, dampingRatio: Constants.animationButtonUpDamping) {
            self.playingCardView.transform = CGAffineTransform.identity
            }.startAnimation()
        playingCardView.successHighlight()
    }
    /**
     Unhighlights buttons color back to normal state.
     */
    func unhighlight() {
        playingCardView.unhighlight()
        selected = false
    }
}

// MARK: TOUCH CONTROLS

extension PlayingCardButton: UIGestureRecognizerDelegate {
    
    // FIXME: Concurrent UILongPressGestureRecogniser on PlayingCardButton views
    
    /**
     Allow resognising other gestures (swipe to deal, rotate to shuffle) while pressing card buttons.
     */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // FIXME: Concurrent UILongPressGestureRecogniser on PlayingCardButton views
    // Function below could potentionally solve my problem? By requiring other UILongPressGestureRecognizer to fail so there would be only one - the first UIView that was touched that would be recognised. But I couldn't get this to work since this function doesn't seem to check against the same-type gesture recognisers in the scene.
    
//    /**
//     Require fail of other UILongPressGestureRecognizer.
//     */
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//
//        if otherGestureRecognizer is UILongPressGestureRecognizer
//        {
//            return true
//            // There seems to be zero UILongPressGestureRecognizer being run through this function.
//        }
//        return false
//        // but it runs through other UIGestureRecognisers - Swipe, Rotate
//    }
}

extension PlayingCardButton {
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherButton = object as? PlayingCardButton else {
            return false
        }
        return playingCardView == otherButton.playingCardView
    }
}
