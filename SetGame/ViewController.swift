//
//  ViewController.swift
//  SetGame
//
//  Created by Lukas on 17/05/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var game : Game = Game()
    let signs : NSAttributedString = NSAttributedString(string: "▲●■")
    
    @IBAction func newGameButton(_ sender: UIButton) {
        newGame()
    }
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var CardButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        newGame()
    }
    
    func newGame(){
        game = Game()
    }
    
    func updateUI(){
        
    }
    
    func highlightSelection(){
        
    }
    
    func updateScoreLabel(){
        
    }
    
    func hideMatchedCards(){
        
    }
}

