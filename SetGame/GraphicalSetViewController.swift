//
//  GraphicalSetViewController.swift
//  SetGame
//
//  Created by Lukas on 30/06/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

// TODO: add animated cards:
// deal v
// sucess match x
// unsuccessful match x
// deal inplace v
// new game v
// shuffle x
// rearrange v
// didlayoutsubviews initial animation x
//
//
//
// new game confirmation screen
// animate cards away before confirmation screen
// animated buttons
// refactor animation clutter
// add info/tutorial screen + first opening tutorial
// detect no more combinations -> end the game
// add winner screen (Lottie animation)
// add countdown
// add local high score

class GraphicalSetViewController: UIViewController {

    var game: Game = Game()
    var playingCardViews: [PlayingCardView] = []
    lazy var targetGrid = Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio), frame: playingBoardView.layer.bounds)
    var flagNewGame = false
    var flagDealMoreCards = false
    @IBOutlet weak var playingBoardView: UIView!
    @IBOutlet weak var newGameButton: UIButton!
    @IBAction func newGamePressed(_ sender: UIButton) {
//        clearFlags()
        newGame()
    }
    @IBOutlet weak var dealCardsButton: UIButton!
    @IBAction func dealCardsPressed(_ sender: UIButton) {
//        clearFlags()
        dealThreeCards()
    }
    @IBOutlet weak var scoreLabel: UILabel!

    @objc func tappedCard(_ sender: UITapGestureRecognizer) {
//        clearFlags()
        switch sender.state {
        case .ended:
            // Select card in model.
            if let playingCard = sender.view?.subviews.first as? PlayingCardView, let buttonIndex = playingCardViews.firstIndex(of: playingCard) {
                let selectedCard = game.cardsOnTable[buttonIndex]
                game.select(selectedCard)
                updateUI()
            }
        default:
            return
        }
    }

    @objc func swipeToDealCards(_ sender: UISwipeGestureRecognizer) {
//        clearFlags()
        switch sender.state {
        case .ended:
            dealThreeCards()
        default:
            return
        }
    }

    @objc func rotateToShuffle(_ sender: UIRotationGestureRecognizer) {
//        clearFlags()
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
        self.dealCardsButton.layer.zPosition = 1
        self.newGameButton.layer.zPosition = 1
        newGame()
        setupGestures()
    }

    func setupGestures() {
        for button in playingCardViews {
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
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.newGameButton.layer.cornerRadius = self.newGameButton.frame.height / 2.0
            self.dealCardsButton.layer.cornerRadius = self.dealCardsButton.frame.height / 2.0
            self.setupGrid(cellCount: self.game.cardsOnTable.count)
            self.updateUI()
        }
    }

    private func newGame() {
        game = Game()
        Score.reset()
        playingCardViews = []
        setupGrid(cellCount: game.cardsOnTable.count)
        flagNewGame = true
        updateUI()
    }

    private func updateUI() {

        initTableCards()
        highlightSelection()
        updateScoreLabel()
        markSuccessfulMatch()
        manageDealButton()

        // Animation
        animateRearrangeCards()
        animateDealCards()
        animateNewGame()
        animateShuffledCards()
        animateSuccessMatch()
        DispatchQueue.main.asyncAfter(deadline: .now()+Constants.clearFlagsDelay){
            self.clearFlags()
        }
    }

    private func clearFlags() {
        flagNewGame = false
        flagDealMoreCards = false
    }

    private func setupGrid(cellCount: Int) {
        targetGrid = Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio), frame: playingBoardView.layer.bounds)
        targetGrid.cellCount = cellCount
    }

    func initTableCards() {
        // Empty UI data structures before recreating them from ground up.
        playingCardViews = []
        for view in playingBoardView.subviews {
            view.removeFromSuperview()
        }
        for cardModel in game.cardsOnTable {
            if let indexOnTable = game.cardsOnTable.firstIndex(of: cardModel) {
                let cardRect = targetGrid[indexOnTable] ?? dealCardsButton.convert(dealCardsButton.bounds, to: playingBoardView)
                let cardButton = UIView()
                // Cards already on the table
                cardButton.frame = cardRect
                let cardView = PlayingCardView(frame: cardButton.layer.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing), shapeType: cardModel.shape.rawValue, quantityType: cardModel.quantity.rawValue, fillType: cardModel.pattern.rawValue, colorType: cardModel.color.rawValue)
                cardButton.addSubview(cardView)
                playingCardViews.append(cardView)
                playingBoardView.addSubview(cardButton)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCard))
                tapGesture.numberOfTapsRequired = 1
                tapGesture.numberOfTouchesRequired = 1
                cardButton.addGestureRecognizer(tapGesture)
            }
        }
    }

    private func animateCards<T>(cards: T, duration: TimeInterval, animationTimeSpacing: TimeInterval, animationOptions: UIView.AnimationOptions) where T: Sequence, T.Element == Card {
        var delay = 0.0
        for card in cards {
            if let cardIndex = game.cardsOnTable.firstIndex(of: card), let cardButton = playingCardViews[cardIndex].superview, let endRect = targetGrid[cardIndex] {
                UIView.animate(withDuration: duration, delay: delay, options: animationOptions, animations: {
                    cardButton.frame = endRect
                    let rect = cardButton.layer.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing)
                    self.playingCardViews[cardIndex].frame = rect
                    self.playingCardViews[cardIndex].layer.cornerRadius = PlayingCardView.Constants.cornerRadiusToWidthRatio * rect.width
                },
                    completion: nil)
            }
            delay += animationTimeSpacing
        }
    }


    private func animateRearrangeCards() {
        let cardsToRearrange = game.cardsOnTable.filter() { !game.cardsToDeal.contains($0) }
        for cardModel in cardsToRearrange {
            if let indexOnTable = game.cardsOnTable.firstIndex(of: cardModel), let cardRect = targetGrid[indexOnTable] {
                let cardView = playingCardViews[indexOnTable]
                guard let cardButton = cardView.superview else {
                    return
                }
                // Set cards animation starting frame
                cardButton.frame = cardRect
                cardView.frame = cardButton.layer.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing)
            }
        }
        setupGrid(cellCount: game.cardsOnTable.count)
        animateCards(cards: cardsToRearrange, duration: Constants.animationOldCardDuration, animationTimeSpacing: Constants.animationOldCardDelayIncrement, animationOptions: Constants.animationOldCardOptions)
        
    }

    private func animateDealCards() {
        if flagDealMoreCards {
            for cardModel in game.cardsToDeal {
                if let indexOnTable = game.cardsOnTable.firstIndex(of: cardModel) {
                    let cardView = playingCardViews[indexOnTable]
                    guard let cardButton = cardView.superview else {
                        return
                    }
                    // Set cards to deal animation starting frame
                    cardButton.frame = dealCardsButton.convert(dealCardsButton.bounds, to: playingBoardView)
                    cardButton.layer.cornerRadius = dealCardsButton.layer.cornerRadius
                    cardView.frame = dealCardsButton.convert(dealCardsButton.bounds, to: cardButton)
                    cardView.layer.cornerRadius = dealCardsButton.layer.cornerRadius
                }
            }
            setupGrid(cellCount: game.cardsOnTable.count)

            animateCards(cards: Array(game.cardsToDeal), duration: Constants.animationDealCardDuration, animationTimeSpacing: Constants.animationDealCardDelayIncrement, animationOptions: Constants.animationDealCardOptions)
//            flagDealMoreCards = false
        }
    }

    private func animateNewGame() {
        if flagNewGame {
            for playingCard in playingCardViews {
                if let button = playingCard.superview {
                    button.frame = newGameButton.convert(newGameButton.bounds, to: playingBoardView)
                    button.layer.cornerRadius = newGameButton.layer.cornerRadius
                    playingCard.frame = newGameButton.convert(newGameButton.bounds, to: button)
                    playingCard.layer.cornerRadius = newGameButton.layer.cornerRadius
                }
            }
            setupGrid(cellCount: game.cardsOnTable.count)

            animateCards(cards: game.cardsOnTable, duration: Constants.animationNewGameDuration, animationTimeSpacing: Constants.animationNewGameCardDelayIncrement, animationOptions: Constants.animationNewGameCardOptions)
//            flagNewGame = false
        }
    }

    private func animateSuccessMatch() {

    }

    private func animateShuffledCards() {
    }
    private func highlightSelection() {
        for index in 0..<game.cardsOnTable.count {
            playingCardViews[index].unhighlight()
            if game.cardsSelected.contains(game.cardsOnTable[index]) {
                playingCardViews[index].selectedHighlight()
            }
        }
    }

    private func markSuccessfulMatch() {
        for index in 0..<game.cardsOnTable.count { if game.cardsMatched.contains(game.cardsOnTable[index]) {
            playingCardViews[index].successHighlight()
        }
        }
    }

    private func updateScoreLabel() {
        let suffix = " 🎖"
        scoreLabel.text = String(Score.shared().playerScore) + suffix
    }

    private func manageDealButton() {
        dealCardsButton.isEnabled = !game.cardsInPack.isEmpty
    }

    private func dealThreeCards() {
        flagDealMoreCards = true
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
        static let clearFlagsDelay: Double = 0.1
        static let animationDealCardDuration: TimeInterval = 0.6
        static let animationDealCardDelayIncrement: TimeInterval = 0.2
        static let animationDealCardOptions: UIView.AnimationOptions = [.curveEaseOut]
        static let animationOldCardDuration: TimeInterval = 0.25
        static let animationOldCardDelayIncrement: TimeInterval = 0.005
        static let animationOldCardOptions: UIView.AnimationOptions = [.curveEaseOut]
        static let animationNewGameDuration: TimeInterval = 0.8
        static let animationNewGameCardDelayIncrement: TimeInterval = 1 / 12
        static let animationNewGameCardOptions: UIView.AnimationOptions = [.curveEaseOut]
    }
}
