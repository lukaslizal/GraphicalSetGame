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
    static func setupMenuButton(button: UIButton) -> UIButton {
        button.backgroundColor = Constants.buttonBackgroundColor
        button.layer.zPosition = 1
        button.layer.cornerRadius = button.frame.height / 2.0
        button.layer.shouldRasterize = true
        button.layer.rasterizationScale = UIScreen.main.scale
        return button
    }
    static func setupScoreButton(label: UILabel) -> UILabel {
        label.backgroundColor = Constants.scoreLabelThemeColor
        label.superview?.layer.zPosition = 4
        label.layer.cornerRadius = label.frame.height / 2.0
        label.clipsToBounds = true
        label.layer.shouldRasterize = true
        label.layer.rasterizationScale = UIScreen.main.scale
        return label
    }
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
}

class AnimationFactory {

}
