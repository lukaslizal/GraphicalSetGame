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
// sucess match v
// unsuccessful match v
// sucess highlight x
// unsuccessful highlight x
// deal inplace v
// new game v
// shuffle v
// rearrange v
// didlayoutsubviews initial animation v
// refactor animation clutter v
// add info/tutorial screen + first opening tutorial x
// score updatewith animation completion x
// add menu button x
//
// new game confirmation screen
// animate cards away before confirmation screen
// animated buttons
// detect no more combinations -> end the game
// add winner screen (Lottie animation)
// add local persistant high score

class GraphicalSetViewController: UIViewController {

    // MARK: STORED PROPERTIES

    var game: Game = Game()
    var playingCardViews: [PlayingCardView] = []
    lazy var targetGrid = Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio), frame: playingBoardView.layer.bounds)
    var animationFlagNewGame = false
    var animationFlagDealMoreCards = false
    var animationFlagSuccessMatch = false

    // MARK: UI OUTLETS

    @IBOutlet weak var playingBoardView: UIView!
    @IBOutlet weak var newGameButton: UIButton!
    @IBAction func newGamePressed(_ sender: UIButton) {
        newGame()
    }
    @IBOutlet weak var dealCardsButton: UIButton!
    @IBAction func dealCardsPressed(_ sender: UIButton) {
        dealThreeCards()
        updateUI()
    }
    @IBOutlet weak var scoreLabel: UILabel!

    // MARK: TOUCH GESTURES

    @objc func tappedCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            // Select card in model. Card is a subview of tap gesture recognising UIView "button"
            if let playingCard = sender.view?.subviews.first as? PlayingCardView, let buttonIndex = playingCardViews.firstIndex(of: playingCard) {
                let selectedCard = game.cardsOnTable[buttonIndex]
                game.select(selectedCard)
                if game.selectedIsMatch {
                    // Replace matched cards
                    animationFlagSuccessMatch = true
//                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationSuccessMatchDuration + 2 * Constants.animationSuccessMatchDelayIncrement) {
//                        self.dealThreeCards()
//                        self.updateUI()
//                    }
                }
                else if game.cardsSelected.count == 3 {
                    view.shake()
                }
                updateUI()
            }
        default:
            return
        }
    }

    @objc func swipeToDealCards(_ sender: UISwipeGestureRecognizer) {
        switch sender.state {
        case .ended:
            dealThreeCards()
            updateUI()
        default:
            return
        }
    }

    @objc func rotateToShuffle(_ sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case .began:
            game.shuffle()
            updateUI()
        default:
            return
        }
    }

    func setupGestures() {
        // Remove Swipe and Rotate gesture recognizers if any attached before seting up new ones.
        if let recognizers = view.gestureRecognizers {
            for recognizer in recognizers {
                view.removeGestureRecognizer(recognizer as UIGestureRecognizer)
            }
        }
        for button in playingCardViews {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedCard))
            button.superview?.addGestureRecognizer(tapGesture)
            button.superview?.isMultipleTouchEnabled = true
        }
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeToDealCards))
        swipeGesture.direction = .down
        view.addGestureRecognizer(swipeGesture)
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateToShuffle(_:)))
        view.addGestureRecognizer(rotateGesture)
    }

    // MARK: VIEWCONTROLLER OVERRIDE METHODS

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.newGameButton.backgroundColor = UIColor.white
        self.dealCardsButton.backgroundColor = UIColor.white
        self.scoreLabel.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        self.dealCardsButton.layer.zPosition = 1
        self.newGameButton.layer.zPosition = 1
        self.scoreLabel.layer.zPosition = 1
        dealCardsButton.titleLabel?.minimumScaleFactor = 0.5
        dealCardsButton.titleLabel?.numberOfLines = 0
        dealCardsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        newGame()
        setupGestures()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.newGameButton.layer.cornerRadius = self.newGameButton.frame.height / 2.0
            self.dealCardsButton.layer.cornerRadius = self.dealCardsButton.frame.height / 2.0
            self.scoreLabel.layer.cornerRadius = self.scoreLabel.frame.height / 2.0
            self.scoreLabel.clipsToBounds = true
            self.setupGrid(cellCount: self.game.cardsOnTable.count)
            self.updateUI()
        }
    }

    private func updateUI() {
        // Rebuild UI from model.
        initTableCards()
        highlightSelection()
        markSuccessfulMatch()
        updateScoreLabel()
        manageDealButton()

        // Animate UI.
        animateRearrangeCards()
        animateDealCards()
        animateNewGame()
        animateSuccessMatch()
//        animateHighlightSuccess()
//        animateHighlightSelected()
//        animateDehighlight()

        // Clear flags.
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.clearFlagsDelay) {
            self.clearAnimationFlags()
        }
    }

    private func clearAnimationFlags() {
        animationFlagNewGame = false
        animationFlagDealMoreCards = false
    }

    private func setupGrid(cellCount: Int) {
        targetGrid = Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio), frame: playingBoardView.layer.bounds)
        targetGrid.cellCount = cellCount
    }

    func initTableCards() {
        var previousCardLayout: [Card: CGRect] = [:]
        for playingCard in playingCardViews {
            if let model = game.cardsOnTable.first(where: { playingCard.shapeType == $0.shape.rawValue && playingCard.colorType == $0.color.rawValue && playingCard.fillType == $0.pattern.rawValue && playingCard.quantity == $0.quantity.rawValue + 1 }) {
                previousCardLayout[model] = playingCard.superview?.frame
            }
        }
        // Empty UI data structures before recreating them from ground up.
        playingCardViews = []
        for view in playingBoardView.subviews {
            view.removeFromSuperview()
        }
        for cardModel in game.cardsOnTable {
            if game.cardsOnTable.firstIndex(of: cardModel) != nil {
                let cardRect = previousCardLayout[cardModel]
                    ?? dealCardsButton.convert(dealCardsButton.bounds, to: playingBoardView)
                let cardButton = UIView()
                // Cards already on the table
                cardButton.frame = cardRect
                let cardView = PlayingCardView(frame: cardButton.layer.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing), shapeType: cardModel.shape.rawValue, quantityType: cardModel.quantity.rawValue, fillType: cardModel.pattern.rawValue, colorType: cardModel.color.rawValue)
                cardButton.clipsToBounds = true
                cardButton.isMultipleTouchEnabled = true
                cardButton.isUserInteractionEnabled = true
                cardButton.addSubview(cardView)
                playingCardViews.append(cardView)
                playingBoardView.addSubview(cardButton)
                setupGestures()
            }
        }
    }

    private func newGame() {
        game = Game()
        Score.reset()
        playingCardViews = []
        setupGrid(cellCount: game.cardsOnTable.count)
        animationFlagNewGame = true
        updateUI()
    }

    private func dealThreeCards() {
        animationFlagDealMoreCards = true
        if game.selectedIsMatch, let oneOfMatched = game.cardsSelected.first {
            // By selecting one of matching cards, matching cards are replaced with new ones from the deck
            game.select(oneOfMatched)
        }
        else {
            game.dealCards(quantity: 3)
        }
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
        for index in 0..<game.cardsOnTable.count {
            if game.cardsMatched.contains(game.cardsOnTable[index]) {
                playingCardViews[index].successHighlight()
//            playingCardViews[index].superview?.backgroundColor = UIColor(cgColor: PlayingCardView.Constants.selectedSuccessColor)
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

    // MARK: ANIMATIONS

    private func animate(cards: [Card], onto targetViewBy: (_ index: Int) -> (UIView?), duration: TimeInterval, animationTimeSpacing: TimeInterval, animationOptions: UIView.AnimationOptions, targetElementSpacing: CGFloat, animateCardsAway: Bool, onComplete: @escaping (_ finished: Bool) -> (Void)) {
        var delay = 0.0
        for card in cards {
            if let cardIndex = game.cardsOnTable.firstIndex(of: card), let cardButton = playingCardViews[cardIndex].superview, let animationTargetView = targetViewBy(cardIndex) {
                cardButton.cornerRadiusAnimationWithDuration(duration: CFTimeInterval(duration), to: animationTargetView.layer.cornerRadius, delay: Double(delay) / TimeInterval(cards.count))
                playingCardViews[cardIndex].cornerRadiusAnimationWithDuration(duration: CFTimeInterval(duration), to: animationTargetView.layer.cornerRadius, delay: Double(delay) / TimeInterval(cards.count))
                UIView.animate(withDuration: duration, delay: delay / TimeInterval(cards.count), options: animationOptions, animations: {
                        if !animateCardsAway {
                            self.playingCardViews[cardIndex].frame = animationTargetView.layer.bounds.insetBy(dx: targetElementSpacing, dy: targetElementSpacing)
                        }
                        else{
                            self.playingCardViews[cardIndex].frame = animationTargetView.layer.bounds
                        }
                        cardButton.frame = animationTargetView.frame
                    },

                    completion: { (finished: Bool) -> (Void) in onComplete(finished)

                        cardButton.layer.cornerRadius = 0
                    })
            }
            delay += animationTimeSpacing
        }
    }

    private func animateRearrangeCards() {
        let cardsToRearrange = game.cardsOnTable.filter() { !game.cardsToDeal.contains($0) && !game.cardsMatched.contains($0) }
        setupGrid(cellCount: game.cardsOnTable.count)

        animate(cards: cardsToRearrange, onto: targetGridViews, duration: Constants.animationOldCardDuration, animationTimeSpacing: Constants.animationOldCardDelayIncrement, animationOptions: Constants.animationOldCardOptions, targetElementSpacing: Constants.playingCardsSpacing, animateCardsAway: false, onComplete: { (finished: Bool) -> (Void) in self.game.cardsToDeal = Set<Card>() })

    }

    private func animateDealCards() {
        if animationFlagDealMoreCards {
            prepareForDealCardsAnimation()

            animate(cards: Array(game.cardsToDeal), onto: targetGridViews, duration: Constants.animationDealCardDuration, animationTimeSpacing: Constants.animationDealCardDelayIncrement, animationOptions: Constants.animationDealCardOptions, targetElementSpacing: Constants.playingCardsSpacing, animateCardsAway: false, onComplete: { (finished: Bool) -> (Void) in
                    self.game.cardsToDeal = Set<Card>()
                })
        }
    }

    private func animateNewGame() {
        if animationFlagNewGame {
            prepareForNewGameAnimation()

            setupGrid(cellCount: game.cardsOnTable.count)

            animate(cards: Array(game.cardsOnTable), onto: targetGridViews, duration: Constants.animationNewGameDuration, animationTimeSpacing: Constants.animationNewGameCardDelayIncrement, animationOptions: Constants.animationNewGameCardOptions, targetElementSpacing: Constants.playingCardsSpacing, animateCardsAway: false, onComplete: { (finished: Bool) -> (Void) in self.game.cardsToDeal = Set<Card>() })
        }
    }

    private func animateSuccessMatch() {
        if animationFlagSuccessMatch {
            prepareForSuccessMatchAnimation()

            animate(cards: Array(game.cardsMatched), onto: targetViewScoreLabel, duration: Constants.animationSuccessMatchDuration, animationTimeSpacing: Constants.animationSuccessMatchDelayIncrement, animationOptions: Constants.animationSuccessMatchOptions, targetElementSpacing: 0, animateCardsAway: true, onComplete: { (finished: Bool) -> Void in
                if finished {
                    self.view.nod()
                    self.dealThreeCards()
                    self.updateUI()
                }
            })
        }
    }

    private func prepareForDealCardsAnimation() {
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
    }
    private func prepareForNewGameAnimation() {
        for playingCard in playingCardViews {
            if let button = playingCard.superview {
                button.frame = newGameButton.convert(newGameButton.bounds, to: playingBoardView)
                button.layer.cornerRadius = newGameButton.layer.cornerRadius
                playingCard.frame = newGameButton.convert(newGameButton.bounds, to: button)
                playingCard.layer.cornerRadius = newGameButton.layer.cornerRadius
            }
        }
    }
    private func prepareForSuccessMatchAnimation() {
        for cardModel in game.cardsMatched {
            if let indexOnTable = game.cardsOnTable.firstIndex(of: cardModel), let cardButton = playingCardViews[indexOnTable].superview, let rect = targetGrid[indexOnTable] {
                cardButton.frame = rect
                playingCardViews[indexOnTable].frame = cardButton.layer.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing)
                cardButton.layer.cornerRadius = PlayingCardView.Constants.cornerRadiusToWidthRatio * rect.width
                playingCardViews[indexOnTable].layer.cornerRadius = PlayingCardView.Constants.cornerRadiusToWidthRatio * rect.width
            }
        }
    }

    private func targetGridViews(index: Int) -> UIView? {
        let view = UIView()
        if let rect = self.targetGrid[index] {
            view.layer.cornerRadius = PlayingCardView.Constants.cornerRadiusToWidthRatio * rect.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing).width
            view.frame = rect
            return view
        }
        return nil
    }

    private func targetViewScoreLabel(index: Int) -> UIView? {
        let view = UIView()
        view.layer.cornerRadius = scoreLabel.layer.cornerRadius
        view.frame = scoreLabel.convert(scoreLabel.layer.bounds, to: self.playingBoardView).insetBy(dx: scoreLabel.layer.cornerRadius / 2, dy: 0)
        return view }

}


