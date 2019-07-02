//
//  GraphicalSetViewController.swift
//  SetGame
//
//  Created by Lukas on 30/06/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

// TODO: maximalise card button area, add animated cards - deal, sucess, add info screen, add winner screen (Lottie animation)

class GraphicalSetViewController: UIViewController {

    var game: Game = Game()
    var playingCardViews: [PlayingCardView] = []
    var playingCardButtonsDictionary: [UIView:PlayingCardView] = [:]
    
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
            // Select card in model.
            if let button = sender.view, let card = playingCardButtonsDictionary[button], let buttonIndex = playingCardViews.firstIndex(of: card) {
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
        for button in playingCardViews{
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
        playingCardViews = []
        playingCardButtonsDictionary = [:]
        for view in playingBoardView.subviews{
            view.removeFromSuperview()
        }
        for index in 0..<game.cardsOnTable.count{
            let cardModel = game.cardsOnTable[index]
            if let cardRect = cardGrid[index] {
                let cardButton = UIView(frame: cardRect)
                let cardView = PlayingCardView(frame: cardButton.layer.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing), shapeType: cardModel.shape.rawValue, quantityType: cardModel.quantity.rawValue, fillType: cardModel.pattern.rawValue, colorType: cardModel.color.rawValue)
                cardButton.addSubview(cardView)
                playingCardViews.append(cardView)
                playingBoardView.addSubview(cardButton)
                playingCardButtonsDictionary[cardButton] = cardView
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCard))
                tapGesture.numberOfTapsRequired = 1
                tapGesture.numberOfTouchesRequired = 1
                cardButton.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    private func highlightSelection() {
        for index in 0..<game.cardsOnTable.count{
            playingCardViews[index].unhighlight()
            if game.cardsSelected.contains(game.cardsOnTable[index]){
                playingCardViews[index].selectedHighlight()
            }
        }
    }
    
    private func markSuccessfulMatch() {
        for index in 0..<game.cardsOnTable.count{            if game.cardsMatched.contains(game.cardsOnTable[index]){
                playingCardViews[index].successHighlight()
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
