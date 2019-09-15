//
//  PushVerticalAnimator.swift
//  SetGame
//
//  Created by Lukas on 24/08/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import Foundation
import UIKit

public class PushVerticalAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    internal var presenting = true
    private let duration: TimeInterval = Constants.transitionAnimationDuration

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(UINavigationController.hideShowBarDuration)
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard let from = transitionContext.view(forKey: UITransitionContextViewKey.from) else { return }
        guard let to = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }
        container.addSubview(to)
        to.frame = presenting ? from.frame.offsetBy(dx: 0, dy: -to.layer.bounds.height) : from.frame.offsetBy(dx: 0, dy: to.layer.bounds.height)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [], animations: {
            to.frame = self.presenting ? to.frame.offsetBy(dx: 0, dy: to.layer.bounds.height) : to.frame.offsetBy(dx: 0, dy: -to.layer.bounds.height)
            from.frame = self.presenting ? from.frame.offsetBy(dx: 0, dy: from.layer.bounds.height) : from.frame.offsetBy(dx: 0, dy: -from.layer.bounds.height)
        })
        { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
