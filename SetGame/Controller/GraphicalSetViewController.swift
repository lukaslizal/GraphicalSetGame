//
//  GraphicalSetViewController.swift
//  SetGame
//
//  Created by Lukas on 30/06/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

// TODO:
// animated deal v
// animated sucess match v
// animated unsuccessful match v
// animated sucess highlight crop circles x
// animated unsuccessful highlight crop circles x
// deal inplace of v
// animated new game v
// animated shuffle v
// animated rearrange v
// push insets to cardButtonView v
// didlayoutsubviews initial animation v
// refactor animation clutter v
// add info/tutorial screen + first opening tutorial x
// score label custom view animated rework x
// interuption succes animation no deal cards bug v
// add menu button x
// install bp replay font v
// animate shadows on deal cards x
//
// new game confirmation screen
// animate cards away before confirmation screen
// detect no more combinations -> end the game (other thread)
// add winner screen (Lottie animation)
// add local persistant high score

class GraphicalSetViewController: UIViewController, CardTap {

    // MARK: STORED PROPERTIES

    var game: Game = Game()
    var playingCardButtons: [PlayingCardButton] = []
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
//        updateScoreLabel()
    }
    @IBOutlet weak var scoreLabel: UILabel!

    // MARK: TOUCH CONTROLS

    func tapped(playingCardButton: PlayingCardButton) {
        // Select card in model. Card is a subview of tap gesture recognising UIView "button"
        if let buttonIndex = playingCardButtons.firstIndex(of: playingCardButton) {
            let selectedCard = game.cardsOnTable[buttonIndex]
            game.select(selectedCard)
            if game.selectedIsMatch {
                // Replace matched cards
                animationFlagSuccessMatch = true
            }
            else if game.cardsSelected.count == 3 {
                // Indicate invalid set selection.
                view.shake()
            }
            updateUI()
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
        self.scoreLabel.layer.zPosition = 3
//        newGameButton.titleLabel?.minimumScaleFactor = 0.5
//        newGameButton.titleLabel?.numberOfLines = 0
//        newGameButton.titleLabel?.adjustsFontSizeToFitWidth = true
//        newGameButton.titleLabel?.textAlignment = NSTextAlignment.center
        dealCardsButton.titleLabel?.minimumScaleFactor = 0.5
        dealCardsButton.titleLabel?.numberOfLines = 0
        dealCardsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        dealCardsButton.titleLabel?.textAlignment = NSTextAlignment.center
        dealCardsButton.setTitleColor(#colorLiteral(red: 0.3332971931, green: 0.3333585858, blue: 0.3332890868, alpha: 1) , for: .normal)
        dealCardsButton.setTitleColor(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) , for: .disabled)
//        dealCardsButton.setTitleColor(#colorLiteral(red: 0.6682514115, green: 0.6682514115, blue: 0.6682514115, alpha: 1) , for: .disabled)
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

    // MARK: CONTROLLER

    private func updateUI() {
        // Rebuild UI from model.
        initTableCards()
        highlightSelection()
        markSuccessfulMatch()
//        updateScoreLabel()
        manageDealButton()

        // Animate UI.
        animateRearrangeCards()
        animateDealCards()
        animateNewGame()
        animateSuccessMatch()

        // Clear flags.
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.clearFlagsDelay) {
            self.clearAnimationFlags()
        }
    }

    private func clearAnimationFlags() {
        animationFlagNewGame = false
        animationFlagDealMoreCards = false
        animationFlagSuccessMatch = false
    }

    private func setupGrid(cellCount: Int) {
        targetGrid = Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio), frame: playingBoardView.layer.bounds)
        targetGrid.cellCount = cellCount
    }

    func setupPlayingCardsDelegate() {
        for playingCardButton in playingCardButtons {
            playingCardButton.delegate = self
        }
    }

    func initTableCards() {
        // Save positions of cards from previous UI card layout.
        var previousCardLayout: [Card: CGRect] = [:]
        for playingCardButton in playingCardButtons {
            let card = playingCardButton.playingCardView
            if let model = game.cardsOnTable.first(where: { card.shapeType == $0.shape.rawValue && card.colorType == $0.color.rawValue && card.fillType == $0.pattern.rawValue && card.quantity == $0.quantity.rawValue + 1 }) {
                previousCardLayout[model] = playingCardButton.frame
            }
        }
        // Empty UI data structures before recreating them from ground up.
        playingCardButtons = []
        for view in playingBoardView.subviews {
            view.removeFromSuperview()
        }
        // Create new UI card buttons.
        for cardModel in game.cardsOnTable {
            if game.cardsOnTable.firstIndex(of: cardModel) != nil {
                let cardRect = previousCardLayout[cardModel] ?? dealCardsButton.convert(dealCardsButton.bounds, to: playingBoardView)
                let cardCornerRadius = cardRect.width*PlayingCardButton.Constants.cornerRadiusToWidthRatio
                let cardButton = PlayingCardButton(frame: cardRect, cornerRadius: cardCornerRadius, shapeType: cardModel.shape.rawValue, quantityType: cardModel.quantity.rawValue, fillType: cardModel.pattern.rawValue, colorType: cardModel.color.rawValue)
                playingCardButtons.append(cardButton)
                playingBoardView.addSubview(cardButton)
            }
        }
        // Setup self as playing card buttons delegate to recieve tap events.
        setupPlayingCardsDelegate()
    }

    private func newGame() {
        game = Game()
        Score.reset()
        playingCardButtons = []
        setupGrid(cellCount: game.cardsOnTable.count)
        animationFlagNewGame = true
        updateUI()
//        updateScoreLabel()
    }
    
    private func replaceCards(cards: [Card]) {
        animationFlagDealMoreCards = true
        if game.selectedIsMatch, let oneOfMatched = game.cardsSelected.first {
            // By selecting one of matching cards, matching cards are replaced with new ones from the deck
            game.select(oneOfMatched)
        }
        else {
            game.dealCards(quantity: 3)
        }
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
            playingCardButtons[index].unhighlight()
            if game.cardsSelected.contains(game.cardsOnTable[index]) {
                playingCardButtons[index].selectedHighlight()
            }
        }
    }

    private func markSuccessfulMatch() {
        for index in 0..<game.cardsOnTable.count {
            if game.cardsMatched.contains(game.cardsOnTable[index]) {
                playingCardButtons[index].successHighlight()
            }
        }
    }

    private func updateScoreLabel() {
        var suffix = ""
        switch playingCardButtons.count {
        case 0...21:
            suffix = " 🧠"
        case 22...31:
            suffix = " 🥇"
        case 32...41:
            suffix = " 🥈"
        case 42...51:
            suffix = " 🥉"
        default:
            suffix = " 👶"
        }
        var scoreText = ""
        switch Score.shared().playerScore {
            case 0:
                scoreText = "💩"
            default:
                scoreText = String(Score.shared().playerScore)
        }
        self.scoreLabel.text = scoreText + suffix
    }

    private func manageDealButton() {
        dealCardsButton.isEnabled = !game.cardsInPack.isEmpty
    }

    // MARK: ANIMATIONS

    private func animate(cards: [Card], onto targetViewBy: (_ index: Int) -> (UIView?), duration: TimeInterval, waitFor: TimeInterval ,animationTimeSpacing: TimeInterval, animationOptions: UIView.AnimationOptions, targetElementSpacing: CGFloat, onComplete: @escaping (_ finished: Bool) -> (Void)) {
        var delay = 0.0
        for (index, card) in cards.enumerated() {
            if let cardIndex = game.cardsOnTable.firstIndex(of: card), let animationTargetView = targetViewBy(cardIndex) {
                playingCardButtons[cardIndex].cornerRadiusAnimationWithDuration(duration: CFTimeInterval(duration), to: animationTargetView.layer.cornerRadius, delay: waitFor + (Double(delay) / TimeInterval(cards.count)))
                playingCardButtons[cardIndex].playingCardView.cornerRadiusAnimationWithDuration(duration: CFTimeInterval(duration), to: animationTargetView.layer.cornerRadius, delay: waitFor + (Double(delay) / TimeInterval(cards.count)))
                UIView.animate(withDuration: duration, delay: waitFor + (delay / TimeInterval(cards.count)), options: animationOptions, animations: {
                        self.playingCardButtons[cardIndex].frame = animationTargetView.frame
                    },
                    completion: { (finished: Bool) -> (Void) in
                        if index == cards.endIndex-1{
                            onComplete(finished)
                        }
                    })
            }
            delay += animationTimeSpacing
        }
    }

    private func animateRearrangeCards() {
        let cardsToRearrange = game.cardsOnTable.filter() { !game.cardsToDeal.contains($0) && !game.cardsMatched.contains($0) }
        setupGrid(cellCount: game.cardsOnTable.count)

        animate(cards: cardsToRearrange, onto: targetGridViews, duration: Constants.animationOldCardDuration, waitFor: 0, animationTimeSpacing: Constants.animationOldCardDelayIncrement, animationOptions: Constants.animationOldCardOptions, targetElementSpacing: PlayingCardButton.Constants.playingCardsSpacing, onComplete: { (finished: Bool) -> (Void) in
                self.game.cardsToDeal = Set<Card>() })

    }

    private func animateDealCards() {
        if animationFlagDealMoreCards {
            prepareForDealCardsAnimation()

            animate(cards: Array(game.cardsToDeal), onto: targetGridViews, duration: Constants.animationDealCardDuration, waitFor: 0, animationTimeSpacing: Constants.animationDealCardDelayIncrement, animationOptions: Constants.animationDealCardOptions, targetElementSpacing: PlayingCardButton.Constants.playingCardsSpacing, onComplete: { (finished: Bool) -> (Void) in
                    self.game.cardsToDeal = Set<Card>()
                })
        }
    }

    private func animateNewGame() {
        if animationFlagNewGame {
            prepareForNewGameAnimation()

            setupGrid(cellCount: game.cardsOnTable.count)

            animate(cards: Array(game.cardsOnTable), onto: targetGridViews, duration: Constants.animationNewGameDuration, waitFor: 0, animationTimeSpacing: Constants.animationNewGameCardDelayIncrement, animationOptions: Constants.animationNewGameCardOptions, targetElementSpacing: PlayingCardButton.Constants.playingCardsSpacing, onComplete: { (finished: Bool) -> (Void) in self.game.cardsToDeal = Set<Card>()
            })
        }
    }

    private func animateSuccessMatch() {
        if animationFlagSuccessMatch {
            prepareForSuccessMatchAnimation()
            // Disable user interaction before successfully matched card disappear and UI gets refreshed.
            view.isUserInteractionEnabled = false
            print("many success animations?")
            animate(cards: Array(game.cardsMatched), onto: targetViewScoreLabel, duration: Constants.animationSuccessMatchDuration, waitFor: Constants.animationSuccessMatchWaitFor, animationTimeSpacing: Constants.animationSuccessMatchDelayIncrement, animationOptions: Constants.animationSuccessMatchOptions, targetElementSpacing: 0, onComplete: { (finished: Bool) -> Void in
                    if finished {
                        print("xd")
                        self.view.nod()
                        self.dealThreeCards()
                        self.updateUI()
//                        self.updateScoreLabel()
                        // Enable user interaction again after UI is uptodate with model.
                        self.view.isUserInteractionEnabled = true
                    }
                })
        }
    }

    private func prepareForDealCardsAnimation() {
        for cardModel in game.cardsToDeal {
            if let indexOnTable = game.cardsOnTable.firstIndex(of: cardModel) {
                // Set cards to deal animation starting frame
                playingCardButtons[indexOnTable].frame = dealCardsButton.convert(dealCardsButton.bounds, to: playingBoardView).insetBy(dx: Constants.insetHideBehindButton, dy: Constants.insetHideBehindButton)
                playingCardButtons[indexOnTable].layer.cornerRadius = dealCardsButton.layer.cornerRadius
                playingCardButtons[indexOnTable].playingCardView.layer.cornerRadius = dealCardsButton.layer.cornerRadius
                playingCardButtons[indexOnTable].setNeedsLayout()
            }
        }
    }
    private func prepareForNewGameAnimation() {
        for playingCardButton in playingCardButtons {
            playingCardButton.frame = newGameButton.convert(newGameButton.bounds, to: playingBoardView).insetBy(dx: Constants.insetHideBehindButton, dy: Constants.insetHideBehindButton)
            playingCardButton.layer.cornerRadius = newGameButton.layer.cornerRadius
            playingCardButton.playingCardView.layer.cornerRadius = newGameButton.layer.cornerRadius
            playingCardButton.setNeedsLayout()
        }
    }
    private func prepareForSuccessMatchAnimation() {
        for cardModel in game.cardsMatched {
            if let indexOnTable = game.cardsOnTable.firstIndex(of: cardModel), let rect = targetGrid[indexOnTable] {
                playingCardButtons[indexOnTable].layer.zPosition = 2
                playingCardButtons[indexOnTable].frame = rect
                playingCardButtons[indexOnTable].layer.cornerRadius = PlayingCardView.Constants.cornerRadiusToWidthRatio * rect.width
                playingCardButtons[indexOnTable].playingCardView.layer.cornerRadius = PlayingCardView.Constants.cornerRadiusToWidthRatio * rect.width
                playingCardButtons[indexOnTable].setNeedsLayout()
            }
        }
    }

    private func targetGridViews(index: Int) -> UIView? {
        let view = UIView()
        if let rect = self.targetGrid[index] {
            view.layer.cornerRadius = PlayingCardView.Constants.cornerRadiusToWidthRatio * rect.width
            view.frame = rect
            return view
        }
        return nil
    }

    private func targetViewScoreLabel(index: Int) -> UIView? {
        let view = UIView()
        view.layer.cornerRadius = scoreLabel.layer.cornerRadius
        view.frame = scoreLabel.convert(scoreLabel.layer.bounds, to: self.playingBoardView).insetBy(dx: -PlayingCardButton.Constants.playingCardsSpacing, dy: -PlayingCardButton.Constants.playingCardsSpacing)
        return view }

}


