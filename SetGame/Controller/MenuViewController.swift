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

    override func viewDidLoad() {
        super.viewDidLoad()
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

    @IBAction func continueGame(_ sender: Any) {
        isStatusbarHidden = true
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
        // new game
//            performSegue(withIdentifier: "showGame", sender: self)
        // continue game
        navigationController?.popToViewController(gameMVC!, animated: true)
    }
}
