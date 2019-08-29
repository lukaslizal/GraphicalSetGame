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
    @IBAction func restartGame(_ sender: Any) {
        isStatusbarHidden = true
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
    @IBOutlet weak var tutorialButton: UIButton!
    @IBOutlet weak var highScoresButton: UIButton!
    @IBOutlet weak var continueGameButton: UIButton!
    @IBAction func continueGame(_ sender: Any) {
        isStatusbarHidden = true
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        // continue game
        navigationController?.popToViewController(gameMVC!, animated: true)
    }
    @IBOutlet weak var continueBar: UIView!
    @IBOutlet weak var logo: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        continueGameButton.layer.cornerRadius = continueGameButton.frame.height / 2
        restartGameButton.layer.cornerRadius = restartGameButton.frame.height / 2
        tutorialButton.layer.cornerRadius = tutorialButton.frame.height / 2
        highScoresButton.layer.cornerRadius = highScoresButton.frame.height / 2
//        continueBar.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        continueBar.layer.cornerRadius = continueBar.frame.height / 2
        logo.layer.cornerRadius = restartGameButton.frame.height / 2

        // Do any additional setup after loading the view.
//        gameTitle.numberOfLines = 0
//        gameTitle.textColor = Constants.gameTitleTextColor
//        gameTitle.textAlignment = .center
//        view.backgroundColor = Constants.mainThemeBackgroundColor
    }

    internal override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isStatusbarHidden = false
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

}
