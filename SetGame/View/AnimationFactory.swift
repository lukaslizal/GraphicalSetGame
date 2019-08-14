//
//  AnimationFactory.swift
//  SetGame
//
//  Created by Lukas on 12/08/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

/**
 Helping to setup and run playing table card animations.
 
 - author:
 Lukas Lizal
 */
class AnimationFactory {
    /**
     Starts rearrange cards animation onto the new positions on the playing table.
     */
    internal static func rearrangeAnimation(toRearrangeModel: [Card], tableModel: [Card], views: [PlayingCardButton], grid: Grid, completion: @escaping (UIViewAnimatingPosition) -> ()) {
        var delay: CGFloat = 0.0
        for (index, cardModel) in toRearrangeModel.enumerated() {
            let lastIndex = index == toRearrangeModel.count - 1
            if let cardIndex = tableModel.firstIndex(of: cardModel), let targetView = targetView(from: grid, at: cardIndex) {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: Constants.animationRearrangeCardDuration, delay: TimeInterval(delay), options: Constants.animationRearrangeCardOptions, animations: {
                    views[cardIndex].frame = targetView.frame
                    views[cardIndex].layer.cornerRadius = targetView.layer.cornerRadius
                    views[cardIndex].playingCardView.layer.cornerRadius = targetView.layer.cornerRadius
                }, completion: lastIndex ? completion : nil)
                delay += CGFloat(Constants.animationRearrangeCardDuration) / CGFloat(views.count)
            }
        }
    }
    /**
     Returns UIView positioned and sized according to specified index in a card grid.
     */
    private static func targetView(from grid: Grid, at index: Int) -> UIView? {
        let view = UIView()
        if let rect = grid[index] {
            view.layer.cornerRadius = PlayingCardView.Constants.cornerRadiusToWidthRatio * rect.width
            view.frame = rect
            return view
        }
        return nil
    }
    /**
     Starts dealing cards animation from playing deck onto the playing table.
     */
    internal static func dealCardsAnimation(toDealModel: [Card], tableModel: [Card], views: [PlayingCardButton], grid: Grid, startView: UIView, completion: @escaping (UIViewAnimatingPosition) -> ()) {
        var buttonsToAnimateIndices: [PlayingCardButton:Int] = [:]
        for cardModel in toDealModel {
            if let cardIndex = tableModel.firstIndex(of: cardModel) {
                buttonsToAnimateIndices[views[cardIndex]] = cardIndex
            }
        }
        prepareDealCardsAnimation(buttons: Array(buttonsToAnimateIndices.keys), to: startView)
        var delay: CGFloat = 0.0
        for (index, view) in buttonsToAnimateIndices.keys.enumerated() {
            let lastIndex = index == toDealModel.count - 1
            if let buttonIndex = buttonsToAnimateIndices[view], let targetView = targetView(from: grid, at: buttonIndex) {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: Constants.animationDealCardDuration, delay: TimeInterval(delay), options: Constants.animationDealCardOptions, animations: {
                    view.frame = targetView.frame
                    view.layer.cornerRadius = targetView.layer.cornerRadius
                    view.playingCardView.layer.cornerRadius = targetView.layer.cornerRadius
                }, completion: lastIndex ? completion : nil)
                delay += CGFloat(Constants.animationDealCardDuration) / CGFloat(toDealModel.count)
            }
        }
    }
    /**
     Prepares cards before dealing card animation by setting their initial position and corner radius to a startView.
     */
    private static func prepareDealCardsAnimation(buttons: [PlayingCardButton], to startView: UIView) {
        for view in buttons {
            view.frame = startView.convert(startView.bounds, to: view.superview).insetBy(dx: Constants.insetHideBehindButton, dy: Constants.insetHideBehindButton)
            view.layer.cornerRadius = startView.layer.cornerRadius
            view.playingCardView.layer.cornerRadius = startView.layer.cornerRadius
            //                    playingCardButtons[indexOnTable].setNeedsLayout()
        }
    }
    /**
     Starts animating cards from playing deck onto the playing table.
     */
    internal static func newGameAnimation(tableModel: [Card], views: [PlayingCardButton], grid: Grid, startView: UIView, completion: @escaping (UIViewAnimatingPosition) -> ()) {
        prepareNewGameAnimation(buttons: views, to: startView)
        var delay: CGFloat = 0.0
        for (index, cardModel) in tableModel.enumerated() {
            let lastIndex = index == tableModel.count - 1
            if let cardIndex = tableModel.firstIndex(of: cardModel), let targetView = targetView(from: grid, at: cardIndex) {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: Constants.animationNewGameDuration, delay: TimeInterval(delay), options: Constants.animationNewGameOptions, animations: {
                    views[cardIndex].frame = targetView.frame
                    views[cardIndex].layer.cornerRadius = targetView.layer.cornerRadius
                    views[cardIndex].playingCardView.layer.cornerRadius = targetView.layer.cornerRadius
                }, completion: lastIndex ? completion : nil)
                delay += CGFloat(Constants.animationNewGameDuration) / CGFloat(tableModel.count)
            }
        }
    }
    /**
     Prepares cards before new game animation by setting their initial position and corner radius to a startView.
     */
    private static func prepareNewGameAnimation(buttons: [PlayingCardButton], to startView: UIView) {
        for view in buttons {
            view.layer.removeAllAnimations()
            view.frame = startView.convert(startView.bounds, to: view.superview).insetBy(dx: Constants.insetHideBehindButton, dy: Constants.insetHideBehindButton)
            view.layer.cornerRadius = startView.layer.cornerRadius
            view.playingCardView.layer.cornerRadius = startView.layer.cornerRadius
            view.setNeedsLayout()
        }
    }
    /**
     Starts animating successfuly matched cards away from the playing table.
     */
    internal static func successMatchAnimation(matchedModel: [Card], tableModel: [Card], views: [PlayingCardButton], targetView: UIView, completion: @escaping (UIViewAnimatingPosition) -> ()) {
        var delay: CGFloat = 0.0
        for (index, cardModel) in matchedModel.enumerated() {
            let lastIndex = index == matchedModel.count - 1
            if let cardIndex = tableModel.firstIndex(of: cardModel) {
                views[cardIndex].layer.zPosition = 1
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: Constants.animationSuccessMatchDuration, delay: TimeInterval(delay), options: Constants.animationSuccessMatchOptions, animations: {
                    views[cardIndex].frame = targetView.convert(targetView.layer.bounds, to: views[cardIndex].superview)
                    views[cardIndex].playingCardView.frame = targetView.layer.bounds
                    views[cardIndex].layer.cornerRadius = targetView.layer.cornerRadius
                    views[cardIndex].playingCardView.layer.cornerRadius = targetView.layer.cornerRadius
                }, completion: lastIndex ? completion : nil)
                delay += CGFloat(Constants.animationSuccessMatchDuration / 2.0) / CGFloat(matchedModel.count)
            }
        }
    }
}
