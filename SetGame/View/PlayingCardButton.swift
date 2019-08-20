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
        UIFactory.setupLongPressGesture(for: self)
    }

    private func setupPlayingCardView(cornerRadius: CGFloat, shapeType: Int, quantityType: Int, fillType: Int, colorType: Int) {
        let rect = self.layer.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing)
        let cardViewCornerRadius = rect.width * (cornerRadius / layer.bounds.width)
        playingCardView = PlayingCardView(frame: rect, cornerRadius: cardViewCornerRadius, shapeType: shapeType, quantityType: quantityType, fillType: fillType, colorType: colorType)
        addSubview(playingCardView)
    }

    // MARK: TOUCH CONTROLS

    @objc func longPressHandler(sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began:
            if !selected {
                AnimationFactory.animationPressView(view: self)
            }
            else {
                AnimationFactory.animationReleaseView(view: self)
            }
        case .changed:
            let inside = self.point(inside: sender.location(in: self), with: nil)
            if !inside && !selected {
                sender.cancel()
            }
        case .cancelled:
            if !selected {
                AnimationFactory.animationReleaseView(view: self)
            }
            else {
                AnimationFactory.animationPressView(view: self)
            }
        case .ended:
            let inside = self.point(inside: sender.location(in: self), with: nil)
            if inside {
                if let tapDelegate = self.delegate {
                    selected = tapDelegate.tapped(playingCardButton: self)
                    if !selected {
                        AnimationFactory.animationTouchCircle(view: playingCardView, to: UIColor(cgColor: PlayingCardView.Constants.cardColor), touchPoint: sender.location(in: self))
                    }
                    else {
                        AnimationFactory.animationTouchCircle(view: playingCardView, to: UIColor(cgColor: PlayingCardView.Constants.selectedHighlightColor), touchPoint: sender.location(in: self))
                    }
                }
            }
            else {
                if !selected {
                    AnimationFactory.animationReleaseView(view: self)
                }
                else {
                    AnimationFactory.animationPressView(view: self)
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

    /**
     Visually highlights button as a selected card.
     */
    internal func selectedHighlight() {
//        playingCardView.backgroundColor = UIColor(cgColor: PlayingCardView.Constants.selectedHighlightColor)
        selected = true
    }
    /**
     Visually highlights button as a successfuly matched card.
     */
    internal func successHighlight() {
        AnimationFactory.animationReleaseView(view: self)
        UIFactory.successColorOverlay(view: playingCardView)
    }
    /**
     Unhighlights buttons color back to normal state.
     */
    internal func unhighlight() {
//        playingCardView.backgroundColor = UIColor(cgColor: PlayingCardView.Constants.cardColor)
        selected = false
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
