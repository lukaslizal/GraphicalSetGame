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

    internal var playingCardView = PlayingCardView()
    internal var selected: Bool = false
    internal weak var delegate: CardTap?
    private var animator: UIViewPropertyAnimator?

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
        backgroundColor = Constants.buttonColor
        clipsToBounds = true
        setupPlayingCardView(cornerRadius: cornerRadius, shapeType: shapeType, quantityType: quantityType, fillType: fillType, colorType: colorType)
        UIFactory.setupLongPressGesture(for: self)
    }

    private func setupPlayingCardView(cornerRadius: CGFloat, shapeType: Int, quantityType: Int, fillType: Int, colorType: Int) {
        let rect = self.layer.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing)
        let cardViewCornerRadius = rect.width * (cornerRadius / self.layer.bounds.width)
        playingCardView = PlayingCardView(frame: rect, cornerRadius: cardViewCornerRadius, shapeType: shapeType, quantityType: quantityType, fillType: fillType, colorType: colorType)
        addSubview(playingCardView)
    }
    
    // MARK: TOUCH CONTROLS

    @objc func longPressHandler(sender: UILongPressGestureRecognizer) {

        switch sender.state {
        case .began:
            // Remove unsuccessful match backgound color on tap.
            if let animator = animator{
                animator.pauseAnimation()
                animator.fractionComplete = 1
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                self.animator = nil
            }
            if !selected {
                AnimationFactory.animationPressView(view: playingCardView, targetFrame: self.bounds.insetBy(dx: Constants.playingCardsSpacing+self.frame.width*0.05, dy: Constants.playingCardsSpacing + self.frame.width*0.05))
            }
            else {
                AnimationFactory.animationReleaseView(view: playingCardView, targetFrame: self.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing))
            }
        case .changed:
            let inside = self.point(inside: sender.location(in: self), with: nil)
            if !inside && !selected {
                sender.cancel()
            }
        case .cancelled:
            if !selected {
                AnimationFactory.animationReleaseView(view: playingCardView, targetFrame: self.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing))
            }
            else {
                AnimationFactory.animationPressView(view: playingCardView, targetFrame: self.bounds.insetBy(dx: Constants.playingCardsSpacing+self.frame.width*0.05, dy:Constants.playingCardsSpacing + self.frame.width*0.05))
            }
        case .ended:
            let inside = self.point(inside: sender.location(in: self), with: nil)
            // If taped inside button, send event to tap delegate.
            if inside {
                if let tapDelegate = self.delegate {
                    selected = tapDelegate.tapped(playingCardButton: self)
                    // Highlight or Unhighlight selection with background color animation.
                    if !selected {
                        AnimationFactory.animationTouchCircle(view: playingCardView, to: PlayingCardView.Constants.cardColor, touchPoint: sender.location(in: self))
                    }
                    else {
                        AnimationFactory.animationTouchCircle(view: playingCardView, to: playingCardView.selectedColor, touchPoint: sender.location(in: self))
                    }
                }
            }
            else {
                if !selected {
                    AnimationFactory.animationReleaseView(view: playingCardView, targetFrame: self.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing))
                }
                else {
                    AnimationFactory.animationPressView(view: playingCardView, targetFrame: self.bounds.insetBy(dx: Constants.playingCardsSpacing+self.frame.width*0.05, dy:Constants.playingCardsSpacing + self.frame.width*0.05))
                }
            }

        default:
            return
        }
    }

    // MARK: OVERRIDDEN FUNCTIONS

    internal override func isEqual(_ object: Any?) -> Bool {
        guard let otherButton = object as? PlayingCardButton else {
            return false
        }
        return playingCardView == otherButton.playingCardView
    }

    // MARK: CHANGING APPEARANCE
    
//    /**
//     Visually highlights button as a successfuly matched card.
//     */
//    internal func selectedHighlight() {
//        UIFactory.successColorOverlay(view: playingCardView, with: playingCardView.selectedColor)
//    }
    /**
     Visually highlights button as a successfuly matched card.
     */
    internal func successHighlight() {
        AnimationFactory.animationReleaseView(view: playingCardView, targetFrame: self.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing))
        UIFactory.successColorOverlay(view: playingCardView, with: playingCardView.selectedColor)
    }
    
    /**
     Visually unhighlights button.
     */
    internal func unhighlight() {
        AnimationFactory.animationReleaseView(view: playingCardView, targetFrame: self.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing))
        AnimationFactory.animationTouchCircle(view: playingCardView, to: PlayingCardView.Constants.cardColor, touchPoint: playingCardView.center)
        selected = false
    }
    
    /**
     Visually highlights unsucceessful matched card using cards background color.
     */
    internal func unsuccessfulHighlight() {
        let animator = AnimationFactory.animationUnsuccessfulMatchColor(view: playingCardView, to: PlayingCardView.Constants.unsuccessfulHighlightColor)
        self.animator = animator
    }
    
    /**
     Visually highlights unsucceessful matched card using cards background color.
     */
    internal func refreshSelected() {
        if selected{
//            playingCardView.transform = CGAffineTransform.
        }
    }
}

// MARK: TOUCH CONTROLS

extension PlayingCardButton: UIGestureRecognizerDelegate {
    /**
     Allow resognising other gestures (swipe to deal, rotate to shuffle) while pressing card buttons.
     */
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

