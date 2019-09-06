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
        static let menuButtonsLabelTint: UIColor = #colorLiteral(red: 0.2827693394, green: 0.2828189714, blue: 0.2827628248, alpha: 1)
        static let scoreGradeFirstSuffix: String = " 🧠"
        static let scoreGradeSecondSuffix: String = " 🥇"
        static let scoreGradeThirdSuffix: String = " 🥈"
        static let scoreGradeFourthSuffix: String = " 🥉"
        static let scoreGradeFifthSuffix: String = " 🥔"
        static let scoreZeroValue: String = "💩"
        static let shadowOffset: CGSize = CGSize(width: 0, height: 5)
        static let blackShadowColor: CGColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
}

extension MenuViewController {
    struct Constants {
        static let mainThemeBackgroundColor: UIColor = #colorLiteral(red: 0.9791627526, green: 0.9965469241, blue: 0.9675421119, alpha: 1)
        static let continueButtonHighlightedColor: UIColor = #colorLiteral(red: 1, green: 0.6393888441, blue: 0.5101942697, alpha: 1)
        static let continueButtonColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let gameLogoTextColor: UIColor = #colorLiteral(red: 0.5318900347, green: 0.6458258629, blue: 0.9886173606, alpha: 1)
        static let creditsTextColor: UIColor = #colorLiteral(red: 0.9998316169, green: 0.9947374601, blue: 0.8880715051, alpha: 1) // #colorLiteral(red: 0.8968842446, green: 0.4420605146, blue: 0.6203331355, alpha: 1)
        static let gameLogoBackgroundColor: UIColor = #colorLiteral(red: 0.9998316169, green: 0.9947374601, blue: 0.8880715051, alpha: 1)
        static let shadowOffset: CGSize = CGSize(width: 0, height: 0)
        static let blueShadowColor: CGColor = #colorLiteral(red: 0.000983003544, green: 9.512937688e-05, blue: 0.003424657538, alpha: 0.7397260274)
        static let logoShadowColor: CGColor = #colorLiteral(red: 0.1312425712, green: 0, blue: 0.3047945205, alpha: 0.4691780822)
    }
}

extension ScoreView {
    struct Constants {
        static let defaultMaxScore: Int = 20
        static let scoreBackgroundColorLight: UIColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        static let scoreBackgroundColorDark: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    }
}

extension UIView {
    struct Constants {
        static let shakeViewAmplitude: CGFloat = 20
        static let shakeViewAmplitudeMultiplier: CGFloat = 0.02
        static let shakeViewDuration: TimeInterval = 0.6
        static let shakeViewSpringDamping: CGFloat = 0.3
        static let shakeViewInitialSpringVelocity: CGFloat = 1
        static let nodViewAmplitude: CGFloat = 18
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
        static let shadowOpacity: Float = 0.3
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
        static let animationSuccessMatchDelay: TimeInterval = 0.0
        static let animationSuccessMatchOptions: UIView.AnimationOptions = [.curveEaseIn, .allowUserInteraction, .allowAnimatedContent]
        static let animationButtonScaleDown: CGFloat = 0.8
        static let animationButtonScaleDownDuration: Double = 0.3
        static let animationButtonDownDamping: CGFloat = 0.3
        static let animationButtonScaleUp: CGFloat = 0.75
        static let animationButtonScaleUpDuration: Double = 0.15
        static let animationButtonUpDamping: CGFloat = 0.8
        static let animationTouchCircleDuration: TimeInterval = 0.6
        static let animationTouchCircleOptions: UIView.AnimationOptions = [.curveEaseOut, .allowUserInteraction, .allowAnimatedContent]
        static let animationUnsuccesfullMatchColorDuration: TimeInterval = 2
        static let animationUnsuccesfullMatchColorOptions: UIView.AnimationOptions = [.curveEaseOut, .allowUserInteraction, .allowAnimatedContent]
    }
}

extension PlayingCardView {
    struct Constants {
        static let symbolAspectRatio: CGFloat = 12 / 5
        static let cardFrameAspectRatio: CGFloat = 5 / 7
        static let symbolInsetsRatio: CGFloat = 1 / 20
        static let cardColor: UIColor = #colorLiteral(red: 0.9997372031, green: 0.9990465367, blue: 0.9589491605, alpha: 1)
        static let selectedHighlightColor: [UIColor] =  [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]  // [#colorLiteral(red: 0.8684809835, green: 1, blue: 0.7802248099, alpha: 1), #colorLiteral(red: 0.9276167073, green: 0.8917697381, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.8072766262, blue: 0.8798607505, alpha: 1)] //[#colorLiteral(red: 0.9381606324, green: 1, blue: 0.8966631661, alpha: 1), #colorLiteral(red: 0.9276167073, green: 0.8917697381, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.9525627755, blue: 0.8814069386, alpha: 1)] //[#colorLiteral(red: 0.7952026993, green: 0.8904109589, blue: 0.7313129523, alpha: 1), #colorLiteral(red: 0.8726476846, green: 0.8095779573, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.8483725166, blue: 0.9054789686, alpha: 1)] // [#colorLiteral(red: 0.884876195, green: 1, blue: 0.8076220702, alpha: 1), #colorLiteral(red: 0.8818091884, green: 0.8232765874, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.8072766262, blue: 0.8798607505, alpha: 1)]
        static let unsuccessfulHighlightColor: UIColor = #colorLiteral(red: 1, green: 0.6670580554, blue: 0.6670580554, alpha: 1)
        static let selectedSuccessColor: UIColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        static let cornerRadiusToWidthRatio: CGFloat = 1 / 10
    }
}

extension PlayingCardButton {
    struct Constants {
        static let buttonColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        static let outlineColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        static let playingCardsSpacing: CGFloat = 4
        static let cornerRadiusToWidthRatio: CGFloat = 1 / 10
        static let pressDownRectRatio: CGFloat = 0.05
    }
}

extension ShapeView {
    struct Constants {
        static let symbolInsetsRatio: CGFloat = 1 / 20
        static let symbolStrokeWidthToSymbolHeight: CGFloat = 1 / 10
        static let hatchStep: CGFloat = 6
        static let hatchStrokeWidth: CGFloat = 3
        static let shapeColors: [UIColor] = [#colorLiteral(red: 0.3864297653, green: 0.8245619936, blue: 0.5706961953, alpha: 1), #colorLiteral(red: 0.9279355407, green: 0.3509399891, blue: 0.611196816, alpha: 1), #colorLiteral(red: 0.8460462689, green: 0.5130195022, blue: 0.9950392842, alpha: 1)]
        //[#colorLiteral(red: 0.4474182725, green: 0.9546989799, blue: 0.6607666612, alpha: 1), #colorLiteral(red: 0.9279355407, green: 0.3509399891, blue: 0.611196816, alpha: 1), #colorLiteral(red: 0.8460462689, green: 0.5130195022, blue: 0.9950392842, alpha: 1)]
        //[#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)]
        //[#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.897260274, green: 0.680268734, blue: 0, alpha: 1)] //[#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)]
    }
}

extension Game {
    struct Constants {
        static let cheatModeIsActive = false
        static let initialCardCountOnTable: Int = 21 // 20 cards is a maximum amount of card that can not create any set.
    }
}

extension PushVerticalAnimator {
    struct Constants {
        static let transitionAnimationDuration: TimeInterval = 1
    }
}
