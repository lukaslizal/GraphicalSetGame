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
        static let mainThemeColor: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1) // #colorLiteral(red: 0.9990593791, green: 0.9387275577, blue: 0.7507612109, alpha: 1)
        static let scoreLabelThemeColor: UIColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1) // #colorLiteral(red: 0.4737035632, green: 0.8386717439, blue: 0.9746726155, alpha: 1)
        static let buttonNormalTextColor: UIColor = #colorLiteral(red: 0.3332971931, green: 0.3333585858, blue: 0.3332890868, alpha: 1)
        static let buttonDisabledTextColor: UIColor = #colorLiteral(red: 0.5136986301, green: 0.5136986301, blue: 0.5136986301, alpha: 1)
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
        static let scoreGradeFirstSuffix: String = " 🧠"
        static let scoreGradeSecondSuffix: String = " 🥇"
        static let scoreGradeThirdSuffix: String = " 🥈"
        static let scoreGradeFourthSuffix: String = " 🥉"
        static let scoreGradeFifthSuffix: String = " 🥔"
        static let scoreZeroValue: String = "💩"
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
        static let buttonColor: CGColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
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

extension UIButton {
    struct Constants {
        static let menuButtonEnabledColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let menuButtonDisabledColor: UIColor = #colorLiteral(red: 0.6839908859, green: 0.6711440114, blue: 0.6311190294, alpha: 1)
        static let menuButtonEnabledTitleColor: UIColor = #colorLiteral(red: 0.3332971931, green: 0.3333585858, blue: 0.3332890868, alpha: 1)
        static let menuButtonDisabledTitleColor: UIColor = #colorLiteral(red: 0.595890411, green: 0.595890411, blue: 0.595890411, alpha: 1)
    }
}
