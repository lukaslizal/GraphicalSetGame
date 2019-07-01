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
    var playingCardButtons: [PlayingCardView] = []
    @IBOutlet weak var playingBoardView: UIView!
    @IBOutlet weak var newGameButton: UIButton!
    @IBAction func newGamePressed(_ sender: UIButton) {
        newGame()
    }
    @IBOutlet weak var dealCardsButton: UIButton!
    @IBAction func dealCardsPressed(_ sender: UIButton) {
        dealThreeCards()
    }
    @IBOutlet weak var scoreLabel: UILabel!
    
    @objc func tappedCard(_ sender: UITapGestureRecognizer){
        switch sender.state {
        case .ended:
            // Find PlayingCard view on sender.view object.
            var playingCardView = sender.view as? PlayingCardView
            if playingCardView == nil {
                for subview in sender.view?.subviews ?? []{
                    if let playingCardSubview = subview as? PlayingCardView{
                        playingCardView = playingCardSubview
                    }
                }
            }
            // Select card in model.
            if let card = playingCardView, let buttonIndex = playingCardButtons.firstIndex(of: card) {
                let selectedCard = game.cardsOnTable[buttonIndex]
                game.select(selectedCard)
                updateUI()
            }
        default:
            return
        }
    }
    @objc func swipeToDealCards(_ sender: UISwipeGestureRecognizer){
        switch sender.state {
        case .ended:
            dealThreeCards()
            updateUI()
        default:
            return
        }
    }
    @objc func rotateToShuffle(_ sender: UIRotationGestureRecognizer){
        switch sender.state {
        case .began:
            game.shuffle()
            updateUI()
        default:
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.newGameButton.backgroundColor = UIColor.white
        self.dealCardsButton.backgroundColor = UIColor.white
        newGame()
        setupGestrues()
    }
    
    func setupGestrues(){
        for button in playingCardButtons{
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCard))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            button.addGestureRecognizer(tapGesture)
        }
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToDealCards))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateToShuffle(_:)))
        view.addGestureRecognizer(rotateGesture)
    }
    
    override func viewDidLayoutSubviews() {
        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.newGameButton.layer.cornerRadius = self.newGameButton.frame.height/2.0
            self.dealCardsButton.layer.cornerRadius = self.dealCardsButton.frame.height/2.0
            self.updateUI()
        }
    }
    
    private func newGame() {
        game = Game()
        Score.reset()
        updateUI()
        
    }
    
    private func updateUI() {
        layoutTableCards()
        highlightSelection()
        updateScoreLabel()
        markSuccessfulMatch()
        manageDealButton()
    }
    
    func layoutTableCards(){
        var cardGrid = Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio), frame: playingBoardView.layer.bounds)
        cardGrid.cellCount = game.cardsOnTable.count
        playingCardButtons = []
        for view in playingBoardView.subviews{
            view.removeFromSuperview()
        }
        for index in 0..<game.cardsOnTable.count{
            let cardModel = game.cardsOnTable[index]
            if let cardRect = cardGrid[index] {
                let cardButton = PlayingCardView(frame: cardRect, shapeType: cardModel.shape.rawValue, quantityType: cardModel.quantity.rawValue, fillType: cardModel.pattern.rawValue, colorType: cardModel.color.rawValue)
                playingCardButtons.append(cardButton)
                playingBoardView.addSubview(cardButton)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCard))
                tapGesture.numberOfTapsRequired = 1
                tapGesture.numberOfTouchesRequired = 1
                cardButton.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    private func highlightSelection() {
        for index in 0..<game.cardsOnTable.count{
            playingCardButtons[index].unhighlight()
            if game.cardsSelected.contains(game.cardsOnTable[index]){
                playingCardButtons[index].selectedHighlight()
            }
        }
    }
    
    private func markSuccessfulMatch() {
        for index in 0..<game.cardsOnTable.count{            if game.cardsMatched.contains(game.cardsOnTable[index]){
                playingCardButtons[index].successHighlight()
            }
        }
    }
    
    private func updateScoreLabel() {
        let suffix = " 🎖"
        scoreLabel.text = String(Score.shared().playerScore)+suffix
    }
    
    private func manageDealButton() {
        dealCardsButton.isEnabled = !game.cardsInPack.isEmpty
    }
    
    private func dealThreeCards(){
        if game.selectedIsMatch, let oneOfMatched = game.cardsSelected.first {
            // By selecting one of matching cards, cards are replaced with new
            game.select(oneOfMatched)
        }
        else {
            game.dealCards(quantity: 3)
        }
        updateUI()
    }
}

extension GraphicalSetViewController {
    struct Constants {
        static let playingCardsSpacing: CGFloat = 4
    }
}
