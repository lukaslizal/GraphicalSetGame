//
//  Constants.swift
//  SetGame
//
//  Created by Lukas on 19/07/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import Foundation
import UIKit

/**
 All Constants of this project.
 
 - author:
 Lukas Lizal
 */
extension GraphicalSetViewController {
    struct Constants {
        static let mainThemeBackgroundColor: UIColor = #colorLiteral(red: 0.3580985833, green: 0.3581614372, blue: 0.3580903332, alpha: 1)
        static let scoreGradeFirstSuffix: String = " 🧠"
        static let scoreGradeSecondSuffix: String = " 🥇"
        static let scoreGradeThirdSuffix: String = " 🥈"
        static let scoreGradeFourthSuffix: String = " 🥉"
        static let scoreGradeFifthSuffix: String = " 🥔"
        static let scoreZeroValue: String = "💩"
    }
}

extension MenuViewController {
    struct Constants {
        static let mainThemeBackgroundColor: UIColor = #colorLiteral(red: 0.590934428, green: 0.5910381495, blue: 0.5909208137, alpha: 1)
        static let gameTitleTextColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
}


extension UIView {
    struct Constants {
        static let shakeViewAmplitude: CGFloat = 20
        static let shakeViewDuration: TimeInterval = 0.6
        static let shakeViewSpringDamping: CGFloat = 0.3
        static let shakeViewInitialSpringVelocity: CGFloat = 1
        static let nodViewAmplitude: CGFloat = 12
        static let nodViewDuration: TimeInterval = 0.4
        static let nodViewSpringDamping: CGFloat = 1
        static let nodViewInitialSpringVelocity: CGFloat = 1
    }
}

extension UIFactory {
    struct Constants {
        static let scoreLabelThemeColor: UIColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        static let menuButtonEnabledColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let menuButtonDisabledColor: UIColor = #colorLiteral(red: 0.6839908859, green: 0.6711440114, blue: 0.6311190294, alpha: 1)
        static let buttonNormalTextColor: UIColor = #colorLiteral(red: 0.3332971931, green: 0.3333585858, blue: 0.3332890868, alpha: 1)
        static let buttonDisabledTextColor: UIColor = #colorLiteral(red: 0.5136986301, green: 0.5136986301, blue: 0.5136986301, alpha: 1)
        static let buttonBackgroundColor: UIColor = UIColor.white
        static let cornerRoundnessFactor: CGFloat = 1
        static let shadowRadius: CGFloat = 15
        static let shadowOpacity: Float = 0.7
        static let shadowOffset: CGSize = CGSize(width: 0, height: 15)
        static let shadowInsets: CGSize = CGSize(width: 2, height: 20)
        static let shadowColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
}

extension AnimationFactory {
    struct Constants {
        static let insetHideBehindButton: CGFloat = -3
        static let animationDealCardDuration: TimeInterval = 0.6
        static let animationDealCardOptions: UIView.AnimationOptions = [.curveEaseOut, .allowUserInteraction, .allowAnimatedContent]
        static let animationRearrangeCardDuration: TimeInterval = 0.25
        static let animationRearrangeCardOptions: UIView.AnimationOptions = [.curveEaseOut, .allowUserInteraction, .allowAnimatedContent]
        static let animationNewGameDuration: TimeInterval = 0.8
        static let animationNewGameOptions: UIView.AnimationOptions = [.curveEaseOut, .allowUserInteraction, .allowAnimatedContent]
        static let animationSuccessMatchDuration: TimeInterval = 0.3
        static let animationSuccessMatchOptions: UIView.AnimationOptions = [.curveEaseIn, .allowUserInteraction, .allowAnimatedContent]
    }
}

extension PlayingCardView {
    struct Constants {
        static let symbolAspectRatio: CGFloat = 12 / 5
        static let cardFrameAspectRatio: CGFloat = 5 / 7
        static let symbolInsetsRatio: CGFloat = 1 / 20
        static let cardColor: CGColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let selectedHighlightColor: CGColor = #colorLiteral(red: 0.7085952207, green: 0.9032234228, blue: 0.9764705896, alpha: 1)
        static let selectedSuccessColor: CGColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        static let cornerRadiusToWidthRatio: CGFloat = 1 / 10
    }
}

extension PlayingCardButton {
    struct Constants {
        static let buttonColor: CGColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        static let playingCardsSpacing: CGFloat = 4
        static let cornerRadiusToWidthRatio: CGFloat = 1 / 10
        static let animationButtonScaleDown: CGFloat = 0.9
        static let animationButtonScaleDownDuration: Double = 0.3
        static let animationButtonDownDamping: CGFloat = 0.3
        static let animationButtonScaleUp: CGFloat = 0.75
        static let animationButtonScaleUpDuration: Double = 0.15
        static let animationButtonUpDamping: CGFloat = 0.8
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
        static let cheatModeIsActive = true
        static let initialCardCountOnTable: Int = 21 // 20 cards is a maximum amount of card that can not create any set.
    }
}
