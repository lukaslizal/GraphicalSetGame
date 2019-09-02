//
//  MenuViewController.swift
//  SetGame
//
//  Created by Lukas on 12/08/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    private var isStatusbarHidden: Bool = true
    internal var gameMVC: GraphicalSetViewController?
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    internal override var prefersStatusBarHidden: Bool {
        return isStatusbarHidden
    }
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
        navigationController?.popToViewController(gameMVC!, animated: true)
    }
    @IBOutlet weak var continueBar: UIView!
    @IBOutlet weak var continueBarVerticalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var logo: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let backgroundView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100,height: 100)))
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
        backgroundView.backgroundColor = UIColor.red
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        self.view.clipsToBounds = true
        self.continueBarVerticalCenterConstraint.constant = 100
        continueGameButton.layer.cornerRadius = continueGameButton.frame.height / 2
        restartGameButton.layer.cornerRadius = restartGameButton.frame.height / 2
        tutorialButton.layer.cornerRadius = tutorialButton.frame.height / 2
        highScoresButton.layer.cornerRadius = highScoresButton.frame.height / 2
        continueBar.layer.cornerRadius = continueBar.frame.height / 2
        logo.layer.cornerRadius = restartGameButton.frame.height / 2
        yesRestartButton.layer.cornerRadius = yesRestartButton.frame.height / 2
        noRestartButton.layer.cornerRadius = noRestartButton.frame.height / 2
        confirmationRestartButton.layer.cornerRadius = confirmationRestartButton.frame.height / 2
        restartGameButton.layer.cornerRadius = restartGameButton.frame.height / 2
        restartGameButton.superview?.clipsToBounds = true
        
        self.continueGameButton.backgroundColor = Constants.continueButtonColor
        UIView.animate(withDuration: 0.8, delay: 0, options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction], animations: {
            self.continueGameButton.backgroundColor = Constants.continueButtonHighlightedColor
        }, completion: nil)
    }

    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isStatusbarHidden = false
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
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
        CATransaction.begin()
        navigationController?.popToViewController(gameMVC!, animated: true)
        CATransaction.setCompletionBlock({
            self.gameMVC?.restartGame()
        })
        CATransaction.commit()
    }

}
