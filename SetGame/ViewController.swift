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
    private let shapes: String = "▲●■"
    private let buttonBackgroundColor = #colorLiteral(red: 1, green: 0.9663769181, blue: 0.8609685167, alpha: 1)
    private let buttonBorderColor = #colorLiteral(red: 1, green: 0.963259467, blue: 0.8265509214, alpha: 1)
    private let buttonHightlightColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    private let buttonShadowColor = #colorLiteral(red: 1, green: 0.8534246596, blue: 0.8558675819, alpha: 1)
    let colors = [#colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1),#colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1),#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)]
    private let attributes: [NSAttributedString.Key : Any] = [
        .font: UIFont.systemFont(ofSize: 35),
        .foregroundColor: UIColor.green
    ]
    @IBOutlet var cardButtons: [UIButton]!
    @IBAction func cardPressed(_ sender: UIButton) {
        if let buttonIndex = cardButtons.firstIndex(of: sender),    let selectedCard = game.cardsOnTable[buttonIndex]{
            print("pressed button: "+String(buttonIndex))
            game.select(selectedCard)
            updateUI()
        }
    }
    
    @IBOutlet weak var newGameButton: UIButton!
    @IBAction func newGamePressed(_ sender: UIButton) {
        print("pressed new game button")
        newGame()
    }
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        newGame()
        for cardButton in cardButtons{
            cardButton.layer.cornerRadius = 10
            cardButton.backgroundColor = buttonBackgroundColor
        }
    }
    
    func newGame(){
        game = Game()
        updateUI()
    }
    
    func updateUI(){
        for buttonIndex in 0..<cardButtons.count{
            if let cardFromTable = game.cardsOnTable[buttonIndex]{
                // Reveals card.
                cardButtons[buttonIndex].layer.opacity = 1
                setupUIButton(at: buttonIndex, with: cardFromTable)
            }
            else{
                // Hides card.
                cardButtons[buttonIndex].layer.opacity = 0
            }
        }
        hideMatchedCards()
        highlightSelection()
        updateScoreLabel()
    }
    
    func highlightSelection(){
        for buttonIndex in 0..<cardButtons.count{
            cardButtons[buttonIndex].layer.borderWidth = 0
            if let cardOnTable = game.cardsOnTable[buttonIndex], game.cardsSelected.contains(cardOnTable){
                cardButtons[buttonIndex].layer.borderColor = buttonHightlightColor.cgColor
                cardButtons[buttonIndex].layer.borderWidth = 3
            }
        }
    }
    
    func updateScoreLabel(){
        print("refreshed score")
        scoreLabel.text = "Score: "+String(Score.shared().playerScore)
    }
    
    func setupUIButton(at index: Int, with card: Card){
        let button = cardButtons[index]
        var iconAttributes : [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: 30)]
        var colorAttributes : [[NSAttributedString.Key : Any]] =
            [[.foregroundColor : colors[0]],
             [.foregroundColor : colors[1]],
             [.foregroundColor : colors[2]]]
        var patternAttributes : [[NSAttributedString.Key : Any]] =
            [[.strokeWidth : -7],
             [.strokeWidth : -7, .foregroundColor: colors[card.color.rawValue].withAlphaComponent(0.5)],
             [.strokeWidth : 7]]
        var iconString = ""
        for _ in 0...card.quantity.rawValue{
            let shapeIndex = shapes.index(shapes.startIndex, offsetBy: card.shape.rawValue)
            iconString.append(shapes[shapeIndex])
        }
        iconAttributes.merge(dict: colorAttributes[card.color.rawValue])
        iconAttributes.merge(dict: patternAttributes[card.pattern.rawValue])
        
        let icon = NSAttributedString(string: iconString, attributes: iconAttributes)
        button.setAttributedTitle(icon, for: UIControl.State.normal)
    }
    
        func hideMatchedCards(){
            for cardIndex in 0..<game.cardsOnTable.count{
                if let card = game.cardsOnTable[cardIndex], game.cardsMatched.contains(card){
                    cardButtons[cardIndex].layer.opacity = 0
                }
            }
        }
}

