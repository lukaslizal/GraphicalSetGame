//
//  Constants.swift
//  SetGame
//
//  Created by Lukas on 19/07/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import Foundation
import UIKit


extension GraphicalSetViewController {
    struct Constants {
        static let insetHideBehindButton: CGFloat = -3
        static let clearFlagsDelay: Double = 0.1
        static let replaceCardsDelay: TimeInterval = 1.5
        static let animationDealCardDuration: TimeInterval = 0.5
        static let animationDealCardDelayIncrement: TimeInterval = 0.2 * 3
        static let animationDealCardOptions: UIView.AnimationOptions = [.curveEaseOut, .allowUserInteraction, .allowAnimatedContent]
        static let animationOldCardDuration: TimeInterval = 0.25
        static let animationOldCardDelayIncrement: TimeInterval = 0.03 * 12
        static let animationOldCardOptions: UIView.AnimationOptions = [.curveEaseOut, .allowUserInteraction, .allowAnimatedContent]
        static let animationNewGameDuration: TimeInterval = 0.8
        static let animationNewGameCardDelayIncrement: TimeInterval = 1 / 12 * 12
        static let animationNewGameCardOptions: UIView.AnimationOptions = [.curveEaseOut, .allowUserInteraction, .allowAnimatedContent]
        static let animationSuccessMatchDuration: TimeInterval = 0.5
        static let animationSuccessMatchWaitFor: TimeInterval = 0.1
        static let animationSuccessMatchDelayIncrement: TimeInterval = 0.1
        static let animationSuccessMatchOptions: UIView.AnimationOptions = [.curveEaseIn, .allowUserInteraction, .allowAnimatedContent]
    }
}

extension UIView {
    struct Constants {
        static let shakeViewAmplitude: CGFloat = 20
        static let shakeViewDuration: TimeInterval = 0.6
        static let shakeViewSpringDamping: CGFloat = 0.3
        static let shakeViewInitialSpringVelocity: CGFloat = 1
        static let nodViewAmplitude: CGFloat = 11
        static let nodViewDuration: TimeInterval = 0.6
        static let nodViewSpringDamping: CGFloat = 1
        static let nodViewInitialSpringVelocity: CGFloat = 1
    }
}

extension PlayingCardView {
    struct Constants {
        static let symbolAspectRatio: CGFloat = 12 / 5
        static let cardFrameAspectRatio: CGFloat = 5 / 7
        static let symbolInsetsRatio: CGFloat = 1 / 20
        static let symbolWidthToBoundsRatio: CGFloat = 4 / 5
        static let symbolHeightToBoundsRatio: CGFloat = 4 / 5
        static let symbolSpacingToCardRatio: CGFloat = 1 / 20
        static let cardColor: CGColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let selectedHighlightColor: CGColor = #colorLiteral(red: 0.8480308219, green: 0.9113513129, blue: 1, alpha: 1)
        static let selectedSuccessColor: CGColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        static let cornerRadiusToWidthRatio: CGFloat = 1 / 10
    }
}

extension PlayingCardButton {
    struct Constants {
        static let buttonFrameAspectRatio: CGFloat = 5 / 7
        static let playingCardsSpacing: CGFloat = 4
        static let cornerRadiusToWidthRatio: CGFloat = 1 / 10
    }
}

extension ShapeView {
    struct Constants {
        static let symbolInsetsRatio: CGFloat = 1 / 20
        static let symbolStrokeWidthToSymbolHeight: CGFloat = 1 / 10
        static let hatchStep: CGFloat = 6
        static let hatchStrokeWidth: CGFloat = 3
    }
}

extension Game {
    struct Constants {
        static let initialCardCountOnTable: Int = 21 // 20 cards is a maximum amount of card that can not create any set.
    }
}
