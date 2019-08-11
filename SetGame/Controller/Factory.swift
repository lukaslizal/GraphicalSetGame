//
//  Factory.swift
//  SetGame
//
//  Created by Lukas on 07/08/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

class UIFactory {
    static func setup(graphicalSetViewController: GraphicalSetViewController) {
        graphicalSetViewController.view.backgroundColor = GraphicalSetViewController.Constants.mainThemeColor
        UIFactory.setupUIGestrues(for: graphicalSetViewController)
        graphicalSetViewController.newGameButton = UIFactory.setupMenuButton(button: graphicalSetViewController.newGameButton)
        graphicalSetViewController.scoreLabel = UIFactory.setupScoreButton(label: graphicalSetViewController.scoreLabel)
        graphicalSetViewController.dealCardsButton = UIFactory.setupDealCardsButton(button: graphicalSetViewController.dealCardsButton)
        graphicalSetViewController.targetGrid = UIFactory.setupGrid(inside: graphicalSetViewController.playingBoardView.layer.bounds)
    }
    @discardableResult
    static func setupMenuButton(button: UIButton) -> UIButton {
        button.backgroundColor = Constants.buttonBackgroundColor
        button.layer.zPosition = 1
        button.layer.cornerRadius = button.frame.height / 2.0
        button.layer.shouldRasterize = true
        button.layer.rasterizationScale = UIScreen.main.scale
        return button
    }
    @discardableResult
    static func setupScoreButton(label: UILabel) -> UILabel {
        label.backgroundColor = Constants.scoreLabelThemeColor
        label.superview?.layer.zPosition = 4
        label.layer.cornerRadius = label.frame.height / 2.0
        label.clipsToBounds = true
        label.layer.shouldRasterize = true
        label.layer.rasterizationScale = UIScreen.main.scale
        return label
    }
    @discardableResult
    static func setupDealCardsButton(button: UIButton) -> UIButton {
        button.backgroundColor = Constants.buttonBackgroundColor
        button.layer.zPosition = 1
        button.layer.cornerRadius = button.frame.height / 2.0
        button.layer.shouldRasterize = true
        button.layer.rasterizationScale = UIScreen.main.scale
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.setTitleColor(Constants.buttonNormalTextColor, for: .normal)
        button.setTitleColor(Constants.buttonDisabledTextColor, for: .disabled)
        button.backgroundColor = button.isEnabled ? Constants.menuButtonEnabledColor : Constants.menuButtonDisabledColor
        return button
    }
    static func setupUIGestrues(for viewController: GraphicalSetViewController) {
        let swipeGesture = UISwipeGestureRecognizer(target: viewController, action: #selector(viewController.swipeToDealCards))
        swipeGesture.direction = .down
        viewController.view.addGestureRecognizer(swipeGesture)
        let rotateGesture = UIRotationGestureRecognizer(target: viewController, action: #selector(viewController.rotateToShuffle(_:)))
        viewController.view.addGestureRecognizer(rotateGesture)
    }
    static func setupGrid(inside rect: CGRect) -> Grid {
        return Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio), frame: rect)
    }
    static func updateGrid(toSize cellCount: Int, inside rect: CGRect) -> Grid {
        var grid = Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio), frame: rect)
        grid.cellCount = cellCount
        return grid
    }
    static func roundedCorners(on view: UIView?) {
        if let roundCornerView = view {
            roundCornerView.layer.cornerRadius = CGFloat.minimum(roundCornerView.frame.height, roundCornerView.frame.height) / 2.0 * Constants.cornerRoundnessFactor
        }
    }
    static func customShadow(on view: UIView?) {
        if let shadowView = view {
            shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.bounds.insetBy(dx: Constants.shadowInsets.width, dy: Constants.shadowInsets.height)).cgPath
            shadowView.layer.shadowColor = Constants.shadowColor
            shadowView.layer.shadowRadius = Constants.shadowRadius
            shadowView.layer.shadowOpacity = Constants.shadowOpacity
            shadowView.layer.shadowOffset = Constants.shadowOffset
        }
    }
    static func filterCardsToRearrange(cardModel: [Card], with previousCardsGridLayout: [Card:(Int,Int)], layoutChangedFlag: Bool, grid: Grid, dealCards: Set<Card>, matchedCards: Set<Card>) -> [Card] {
        return cardModel.filter() {
            var cardsPreviousGridPositionMatches = false
            // Determine whether cards position in a grid changed since last ui update - subject to optimalization - get rid of previous card coordinates and update grid after this?
            if let cardButtonIndex = cardModel.firstIndex(of: $0), let previousCardCoordinates = previousCardsGridLayout[$0] {
                cardsPreviousGridPositionMatches = (previousCardCoordinates == grid.getCoordinates(at: cardButtonIndex))
            }
            // When card is on the table, didn't change position in targetGrid coordinates or target grid has changed its layout, then include this card into cards to rearrange animation cards.
            return !dealCards.contains($0) && !matchedCards.contains($0) && (!cardsPreviousGridPositionMatches || layoutChangedFlag)
        }
    }
}

class AnimationFactory {
    static func rearrangeAnimation(toRearrangeModel: [Card], tableModel: [Card], views: [PlayingCardButton], grid: Grid, completion: @escaping (UIViewAnimatingPosition) -> ()) {
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

    // Returns UIView positioned and sized according to specified index in a card grid.
    private static func targetView(from grid: Grid, at index: Int) -> UIView? {
        let view = UIView()
        if let rect = grid[index] {
            view.layer.cornerRadius = PlayingCardView.Constants.cornerRadiusToWidthRatio * rect.width
            view.frame = rect
            return view
        }
        return nil
    }

    static func dealCardsAnimation(toDealModel: [Card], tableModel: [Card], views: [PlayingCardButton], grid: Grid, startView: UIView, completion: @escaping (UIViewAnimatingPosition) -> ()) {
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

    private static func prepareDealCardsAnimation(buttons: [PlayingCardButton], to startView: UIView) {
        for view in buttons {
            view.frame = startView.convert(startView.bounds, to: view.superview).insetBy(dx: Constants.insetHideBehindButton, dy: Constants.insetHideBehindButton)
            view.layer.cornerRadius = startView.layer.cornerRadius
            view.playingCardView.layer.cornerRadius = startView.layer.cornerRadius
            //                    playingCardButtons[indexOnTable].setNeedsLayout()
        }
    }

    static func newGameAnimation(tableModel: [Card], views: [PlayingCardButton], grid: Grid, startView: UIView, completion: @escaping (UIViewAnimatingPosition) -> ()) {
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

    private static func prepareNewGameAnimation(buttons: [PlayingCardButton], to startView: UIView) {
        for view in buttons {
            view.layer.removeAllAnimations()
            view.frame = startView.convert(startView.bounds, to: view.superview).insetBy(dx: Constants.insetHideBehindButton, dy: Constants.insetHideBehindButton)
            view.layer.cornerRadius = startView.layer.cornerRadius
            view.playingCardView.layer.cornerRadius = startView.layer.cornerRadius
            view.setNeedsLayout()
        }
    }

    static func successMatchAnimation(matchedModel: [Card], tableModel: [Card], views: [PlayingCardButton], targetView: UIView, completion: @escaping (UIViewAnimatingPosition) -> ()) {
        var delay: CGFloat = 0.0
        for (index, cardModel) in matchedModel.enumerated() {
            let lastIndex = index == matchedModel.count - 1
            if let cardIndex = tableModel.firstIndex(of: cardModel) {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: Constants.animationSuccessMatchDuration, delay: TimeInterval(delay), options: Constants.animationSuccessMatchOptions, animations: {
                        views[cardIndex].frame = targetView.convert(targetView.layer.bounds, to: views[cardIndex].superview)
                        views[cardIndex].layer.cornerRadius = targetView.layer.cornerRadius
                        views[cardIndex].playingCardView.layer.cornerRadius = targetView.layer.cornerRadius
                    }, completion: lastIndex ? completion : nil)
                delay += CGFloat(Constants.animationSuccessMatchDuration / 2.0) / CGFloat(matchedModel.count)
            }
        }
    }


}
