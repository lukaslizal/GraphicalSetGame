//
//  GraphicalSetViewController.swift
//  SetGame
//
//  Created by Lukas on 30/06/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

class GraphicalSetViewController: UIViewController {

    var game: Game = Game()
    var playingBoardView =
    @IBOutlet var cardButtons: [UIButton]!
    @IBAction func cardPressed(_ sender: UIButton) {
        if let buttonIndex = cardButtons.firstIndex(of: sender) {
            let selectedCard = game.cardsOnTable[buttonIndex]
            game.select(selectedCard)
            updateUI()
        }
    }
    @IBAction func newGamePressed(_ sender: UIButton) {
        newGame()
    }
    @IBOutlet weak var dealCardsButton: UIButton!
    @IBAction func dealCardsPressed(_ sender: UIButton) {
        if game.selectedIsMatch, let oneOfMatched = game.cardsSelected.first {
            // By selecting one of matching cards, cards are replaced with new
            game.select(oneOfMatched)
        }
        else {
            game.dealCards(quantity: 3)
        }
        updateUI()
    }
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        newGame()
    }
    
    private func newGame() {
        game = Game()
        Score.reset()
        updateUI()
        
    }
    
    private func updateUI() {
        for buttonIndex in 0..<cardButtons.count {
            if buttonIndex < game.cardsOnTable.count {
                let card = game.cardsOnTable[buttonIndex]
                _ = adjustButton(of: card) {
                    $0.layer.opacity = 1
                    setupUIButton(with: card)
                }
            }
            else {
                hideButton(at: buttonIndex)
            }
        }
        layoutTableCards()
        hideMatchedCards()
        highlightSelection()
        updateScoreLabel()
        markSuccessfulMatch()
        manageDealButton()
    }
    
    func layoutTableCards(){
        
    }
    
    private func highlightSelection() {
        for card in game.cardsOnTable {
            _ = adjustButton(of: card) { $0.layer.borderWidth = 0 }
            if game.cardsSelected.contains(card) {
                _ = adjustButton(of: card) {
                    $0.layer.borderColor = buttonHightlightColor.cgColor
                    $0.layer.borderWidth = 3
                }
            }
        }
    }
    
    private func markSuccessfulMatch() {
        for matchCard in game.cardsMatched {
            _ = adjustButton(of: matchCard) {
                $0.layer.borderColor = buttonSuccessColor.cgColor
                $0.layer.borderWidth = 5
            }
        }
    }
    
    private func updateScoreLabel() {
        print("refreshed score")
        scoreLabel.text = "Score: " + String(Score.shared().playerScore)
    }
    
    private func setupUIButton(with card: Card) {
        guard let index = game.cardsOnTable.firstIndex(of: card) else {
            return
        }
        let button = cardButtons[index]
        var iconAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 30)]
        var colorAttributes: [[NSAttributedString.Key: Any]] =
            [[.foregroundColor: colors[0]],
             [.foregroundColor: colors[1]],
             [.foregroundColor: colors[2]]]
        var patternAttributes: [[NSAttributedString.Key: Any]] =
            [[.strokeWidth: -7],
             [.strokeWidth: -7, .foregroundColor: colors[card.color.rawValue].withAlphaComponent(0.5)],
             [.strokeWidth: 7]]
        var iconString = ""
        for _ in 0...card.quantity.rawValue {
            let shapeIndex = shapes.index(shapes.startIndex, offsetBy: card.shape.rawValue)
            iconString.append(shapes[shapeIndex])
        }
        iconAttributes.merge(dict: colorAttributes[card.color.rawValue])
        iconAttributes.merge(dict: patternAttributes[card.pattern.rawValue])
        
        let icon = NSAttributedString(string: iconString, attributes: iconAttributes)
        button.setAttributedTitle(icon, for: UIControl.State.normal)
    }
    
    private func hideMatchedCards() {
        for card in Card.allCombinations() where !game.cardsOnTable.contains(card){
            _ = adjustButton(of: card) { $0.layer.opacity = 0 }
        }
    }
    
    private func adjustButton(of card: Card, with action: (UIButton) -> ()) -> UIButton? {
        if let buttonIndex = game.cardsOnTable.firstIndex(of: card) {
            action(cardButtons[buttonIndex])
            return cardButtons[buttonIndex]
        }
        return nil
    }
    
    private func hideButton(at index: Int) {
        cardButtons[index].layer.opacity = 0
    }
    
    private func manageDealButton() {
        dealCardsButton.isEnabled = !game.cardsInPack.isEmpty
    }
}
