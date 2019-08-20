//
//  UIFactory.swift
//  SetGame
//
//  Created by Lukas on 12/08/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

/**
 Helping to setup different UI elements
 
 - author:
 Lukas Lizal
 */
class UIFactory {
    internal static func setup(viewController: GraphicalSetViewController) {
        viewController.view.backgroundColor = GraphicalSetViewController.Constants.mainThemeBackgroundColor
        viewController.newGameButton = UIFactory.setupMenuButton(button: viewController.newGameButton)
        viewController.scoreLabel = UIFactory.setupScoreButton(label: viewController.scoreLabel)
        viewController.dealCardsButton = UIFactory.setupDealCardsButton(button: viewController.dealCardsButton)
        viewController.tableGrid = UIFactory.setupGrid(inside: viewController.playingBoardView.layer.bounds)
    }
    @discardableResult
    internal static func setupMenuButton(button: UIButton) -> UIButton {
        button.backgroundColor = Constants.buttonBackgroundColor
        button.layer.zPosition = 1
        button.layer.cornerRadius = button.frame.height / 2.0
        button.layer.shouldRasterize = true
        button.layer.rasterizationScale = UIScreen.main.scale
        return button
    }
    @discardableResult
    internal static func setupScoreButton(label: UILabel) -> UILabel {
        label.backgroundColor = Constants.scoreLabelThemeColor
        label.superview?.layer.zPosition = 4
        label.layer.cornerRadius = label.frame.height / 2.0
        label.clipsToBounds = true
        label.layer.shouldRasterize = true
        label.layer.rasterizationScale = UIScreen.main.scale
        return label
    }
    @discardableResult
    internal static func setupDealCardsButton(button: UIButton) -> UIButton {
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
    internal static func setupUISwipeGesture(for viewController: GraphicalSetViewController) {
        let swipeGesture = UISwipeGestureRecognizer(target: viewController, action: #selector(viewController.swipeToDealCards))
        swipeGesture.direction = .down
        swipeGesture.delegate = viewController
        viewController.view.addGestureRecognizer(swipeGesture)
    }
    internal static func setupUIRotateGesture(for viewController: GraphicalSetViewController) {
        let rotateGesture = UIRotationGestureRecognizer(target: viewController, action: #selector(viewController.rotateToShuffle(_:)))
        rotateGesture.delegate = viewController
        viewController.view.addGestureRecognizer(rotateGesture)
    }
    internal static func setupLongPressGesture(for view: PlayingCardButton) {
        let longPressGestureRecogniser = UILongPressGestureRecognizer(target: view, action: #selector(view.longPressHandler))
        longPressGestureRecogniser.minimumPressDuration = 0
        longPressGestureRecogniser.delegate = view
        view.addGestureRecognizer(longPressGestureRecogniser)
        view.isExclusiveTouch = true
    }
    internal static func setupGrid(inside rect: CGRect) -> Grid {
        return Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio), frame: rect)
    }
    internal static func updateGrid(toSize cellCount: Int, inside rect: CGRect) -> Grid {
        var grid = Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio), frame: rect)
        grid.cellCount = cellCount
        return grid
    }
    internal static func roundedCorners(on view: UIView?) {
        if let roundCornerView = view {
            roundCornerView.layer.cornerRadius = CGFloat.minimum(roundCornerView.frame.height, roundCornerView.frame.height) / 2.0 * Constants.cornerRoundnessFactor
        }
    }
    internal static func customShadow(on view: UIView?) {
        if let shadowView = view {
            shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.bounds.insetBy(dx: Constants.shadowInsets.width, dy: Constants.shadowInsets.height)).cgPath
            shadowView.layer.shadowColor = Constants.shadowColor
            shadowView.layer.shadowRadius = Constants.shadowRadius
            shadowView.layer.shadowOpacity = Constants.shadowOpacity
            shadowView.layer.shadowOffset = Constants.shadowOffset
        }
    }
    /**
     Returns only the cards that need any rearrangment on the table.
     */
    internal static func filterCardsToRearrange(cardModel: [Card], with previousCardsGridLayout: [Card: (Int, Int)], layoutChangedFlag: Bool, grid: Grid, dealCards: Set<Card>, matchedCards: Set<Card>) -> [Card] {
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

    /**
     Overlays view with success Color
     */
    internal static func successColorOverlay(view: UIView) {
        let succesOverlay = UIView(frame: view.bounds.insetBy(dx: -100, dy: -100))
        succesOverlay.isOpaque = false
        succesOverlay.layer.zPosition = 1000
        succesOverlay.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        succesOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(succesOverlay)
    }

}
