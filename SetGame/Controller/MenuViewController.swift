//
//  MenuViewController.swift
//  SetGame
//
//  Created by Lukas on 12/08/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

// TODO: Cleanup code, UIFactory, add comments, implement score indicator, menu->game poptransition - profile performance (many cards gets stuttery)

/**
 Game menu.
 
 Displays:
 + Interactive logo with credits
 + Continue game button with score bar
 + Restart game (with confirmation)
 + Tutorial Button
 + Highscores Button
 
 ViewController's main feature is responsive UI, works in both landscape and portrait mode and all device sizes
 
 - author:
 Lukas Lizal
 */
class MenuViewController: UIViewController, UIDynamicAnimatorDelegate {

    internal var gameMVC: GraphicalSetViewController?
    private var isStatusbarHidden: Bool = true
    private var dynamicAnimator: UIDynamicAnimator!
    private var snapBehavior: UISnapBehavior!
    private var disableRotationBehavior: UIDynamicItemBehavior!
    private var gameLogoDragPlaceholder: UIView!
    internal override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    internal override var prefersStatusBarHidden: Bool {
        return isStatusbarHidden
    }

    @IBOutlet weak var gameLogoContainer: UIView!
    @IBOutlet weak var gameLogoView: UIView!
    @IBOutlet weak var gameLogoLabel: UILabel!
    @IBOutlet weak var gameLogoShapeStack: UIStackView!
    @IBOutlet var gameLogoBackgroundCardDeck: [UIView]!
    @IBOutlet var creditsLabels: [UILabel]!

    @IBOutlet weak var restartGameButton: UIButton!
    @IBAction func restartGameConfirmation(_ sender: Any) {
        // show confirmation dialogue
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.yesRestartButton.isHidden = false
                self.noRestartButton.isHidden = false
                self.confirmationRestartButton.isHidden = false
                self.restartGameButton.isHidden = true
            }, completion: nil)
    }
    @IBOutlet weak var yesRestartButton: UIButton!
    @IBAction func yesRestart(_ sender: Any) {
        restartGame()
    }
    
    @IBOutlet weak var noRestartButton: UIButton!
    @IBAction func abortRestart(_ sender: Any) {
        // hide confirmation dialogue
        self.yesRestartButton.isHidden = true
        self.noRestartButton.isHidden = true
        self.confirmationRestartButton.isHidden = true
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self.restartGameButton.isHidden = false
            }, completion: nil)
    }
    @IBOutlet weak var confirmationRestartButton: UIButton!
    @IBOutlet weak var tutorialButton: UIButton!
    @IBOutlet weak var highScoresButton: UIButton!
    @IBOutlet weak var scoreView: ScoreView!
    @IBOutlet weak var continueGameButton: UIButton!
    @IBAction func continueGame(_ sender: Any) {
        // hide confirmation dialogue
        isStatusbarHidden = true
        self.continueBarVerticalCenterConstraint.constant = 100
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        // continue game
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var continueBar: UIView!
    @IBOutlet weak var continueBarVerticalCenterConstraint: NSLayoutConstraint!

    @objc func pan(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            dynamicAnimator.removeBehavior(snapBehavior)
            dynamicAnimator.removeBehavior(disableRotationBehavior)
            gameLogoView.isHidden = false
            gameLogoDragPlaceholder.isHidden = false
            let snapshot = gameLogoView.asImage()
            gameLogoDragPlaceholder.bounds = gameLogoView.bounds
            gameLogoDragPlaceholder.center = gameLogoView.center
            gameLogoDragPlaceholder.layer.cornerRadius = gameLogoView.layer.cornerRadius
            gameLogoDragPlaceholder.backgroundColor = UIColor(patternImage: snapshot)
            gameLogoView.isHidden = true
            gameLogoDragPlaceholder.isHidden = false
        case .changed:
            let translation = sender.translation(in: view)
            gameLogoDragPlaceholder.center = CGPoint(x: gameLogoDragPlaceholder.center.x + translation.x,
                y: gameLogoDragPlaceholder.center.y + translation.y)
            sender.setTranslation(.zero, in: view)
        case .ended, .failed, .cancelled:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.gameLogoDragPlaceholder.isHidden = true
                self.gameLogoView.isHidden = false
                self.gameLogoView.isUserInteractionEnabled = true
            }
            snapBehavior.snapPoint = gameLogoContainer.superview!.convert(CGPoint(x: gameLogoContainer.center.x, y: gameLogoContainer.center.y - 10), to: gameLogoContainer)
            dynamicAnimator.addBehavior(snapBehavior)
            dynamicAnimator.addBehavior(disableRotationBehavior)
        default:
            break
        }
    }
    
    @objc func appWillEnterForeground() {
        continueGameButton.backgroundColor = Constants.continueButtonHighlightedColor
        UIView.animate(withDuration: 0.8, delay: 0, options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction], animations: {
            self.continueGameButton.backgroundColor = Constants.continueButtonColor
        }, completion: nil)
    }

//    When seting self as delegate snap interaction stops working properly.
//    Instead of using this delegate method there is Dispatch queue with delay in pan handler method
//    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
//        self.gameLogoDragPlaceholder.isHidden = true
//        self.gameLogoView.isHidden = false
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification , object: nil)
        let backgroundView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100)))
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
        backgroundView.backgroundColor = UIColor.red
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "menuBackground.png")!)

        view.clipsToBounds = true
        continueBarVerticalCenterConstraint.constant = 100

        gameLogoLabel.textColor = Constants.gameLogoTextColor
        gameLogoView.backgroundColor = Constants.gameLogoBackgroundColor
        gameLogoDragPlaceholder = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        gameLogoContainer.addSubview(gameLogoDragPlaceholder)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan))
        gameLogoView.addGestureRecognizer(panGesture)
        gameLogoView.isUserInteractionEnabled = true

        dynamicAnimator = UIDynamicAnimator(referenceView: gameLogoContainer)
//      When seting self as delegate snap interaction stops working properly.
//      Instead of using this delegate method there is Dispatch queue with delay in pan handler method
//        dynamicAnimator.delegate = self
        snapBehavior = UISnapBehavior(item: gameLogoDragPlaceholder, snapTo: CGPoint(x: gameLogoContainer.center.x, y: gameLogoContainer.center.y - 10))
        snapBehavior.damping = 0.2
        disableRotationBehavior = UIDynamicItemBehavior(items: [gameLogoDragPlaceholder])
        disableRotationBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(snapBehavior)
        dynamicAnimator.addBehavior(disableRotationBehavior)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.snapBehavior.snapPoint = CGPoint(x: self.gameLogoContainer.center.x, y: self.gameLogoContainer.center.y - 10)

                //        creditsLabels
                self.creditsLabels[0].text = "by"
                self.creditsLabels[0].font = self.creditsLabels[0].font.withSize(self.gameLogoContainer.frame.height / 6)
                self.creditsLabels[0].textColor = Constants.creditsTextColor
                self.creditsLabels[0].numberOfLines = 1
                UIFactory.customShadow(on: self.creditsLabels[0], color: Constants.blueShadowColor, offset: CGSize.zero)

                self.creditsLabels[1].text = "Lukáš\nLízal"
                self.creditsLabels[1].font = self.creditsLabels[1].font.withSize(self.gameLogoContainer.frame.height / 6)
                self.creditsLabels[1].textColor = Constants.creditsTextColor
                self.creditsLabels[1].numberOfLines = 2
                UIFactory.customShadow(on: self.creditsLabels[1], color: Constants.blueShadowColor, offset: CGSize.zero)
            })

        continueGameButton.layer.cornerRadius = continueGameButton.frame.height / 2
        restartGameButton.layer.cornerRadius = restartGameButton.frame.height / 2
        tutorialButton.layer.cornerRadius = tutorialButton.frame.height / 2
        highScoresButton.layer.cornerRadius = highScoresButton.frame.height / 2
        continueBar.layer.cornerRadius = continueBar.frame.height / 2
        gameLogoContainer.layer.cornerRadius = gameLogoContainer.frame.width / 5
        yesRestartButton.layer.cornerRadius = yesRestartButton.frame.height / 2
        noRestartButton.layer.cornerRadius = noRestartButton.frame.height / 2
        confirmationRestartButton.layer.cornerRadius = confirmationRestartButton.frame.height / 2
        restartGameButton.layer.cornerRadius = restartGameButton.frame.height / 2
        restartGameButton.superview?.clipsToBounds = true
        scoreView.layer.cornerRadius = scoreView.frame.height / 8


        gameLogoView.layer.cornerRadius = gameLogoContainer.frame.width / 5
        gameLogoLabel.font = gameLogoLabel.font.withSize(gameLogoLabel.frame.height)
        gameLogoLabel.adjustsFontSizeToFitWidth = true
        
        for view in gameLogoBackgroundCardDeck {
            view.layer.cornerRadius = gameLogoContainer.frame.width / 5
        }
        
        for index in 0..<gameLogoShapeStack.arrangedSubviews.count {
            let shapeViews = gameLogoShapeStack.arrangedSubviews as! [ShapeView]
            let shapeView = shapeViews[index]
            shapeView.shape = ShapeType(rawValue: index)!
            shapeView.shapeColor = ShapeView.Constants.shapeColors[index]
            shapeView.fill = FillType(rawValue: 1)!
        }

        UIFactory.customShadow(on: gameLogoView.superview, color: Constants.logoShadowColor, offset: Constants.shadowOffset)
        UIFactory.customShadow(on: continueGameButton, color: Constants.blueShadowColor, offset: Constants.shadowOffset)
        UIFactory.customShadow(on: scoreView, color: Constants.blueShadowColor, offset: Constants.shadowOffset)
        UIFactory.customShadow(on: restartGameButton, color: Constants.blueShadowColor, offset: Constants.shadowOffset)
        UIFactory.customShadow(on: yesRestartButton, color: Constants.blueShadowColor, offset: Constants.shadowOffset)
        UIFactory.customShadow(on: noRestartButton, color: Constants.blueShadowColor, offset: Constants.shadowOffset)
        UIFactory.customShadow(on: confirmationRestartButton, color: Constants.blueShadowColor, offset: Constants.shadowOffset)
        UIFactory.customShadow(on: tutorialButton, color: Constants.blueShadowColor, offset: Constants.shadowOffset)
        UIFactory.customShadow(on: highScoresButton, color: Constants.blueShadowColor, offset: Constants.shadowOffset)
    }

    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isStatusbarHidden = false
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        
        continueGameButton.backgroundColor = Constants.continueButtonHighlightedColor
        UIView.animate(withDuration: 0.8, delay: 0, options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction], animations: {
            self.continueGameButton.backgroundColor = Constants.continueButtonColor
        }, completion: nil)
        
        self.continueBarVerticalCenterConstraint.constant = 0
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 10, options: [.curveEaseOut], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    private func restartGame() {
        isStatusbarHidden = true

        self.continueBarVerticalCenterConstraint.constant = 100
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        // Clear out playing table before transitioning to restarted game.
        self.gameMVC?.flushGame()
        presentingViewController?.dismiss(animated: true, completion: {
            self.gameMVC?.restartGame()
        })
    }

}
