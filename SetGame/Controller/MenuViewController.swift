//
//  MenuViewController.swift
//  SetGame
//
//  Created by Lukas on 12/08/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    var isStatusbarHidden: Bool = true
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    internal override var prefersStatusBarHidden: Bool {
        return isStatusbarHidden
    }
    
    @IBOutlet weak var gameTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameTitle.numberOfLines = 0
        gameTitle.textColor = Constants.gameTitleTextColor
        gameTitle.textAlignment = .center
        view.backgroundColor = Constants.mainThemeBackgroundColor
        // Do any additional setup after loading the view.
    }
    
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isStatusbarHidden = false
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @IBAction func continueGame(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "game") {
            isStatusbarHidden = true
            UIView.animate(withDuration: 0.5) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
            present(vc, animated: true, completion: {
//                view.frame = UIApplication.shared.w
                print("gamePresented")
            })
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
