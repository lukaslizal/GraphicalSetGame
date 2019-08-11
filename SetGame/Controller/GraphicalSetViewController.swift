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
// deal inplace of v
// animated new game v
// animated shuffle v
// animated rearrange v
// push insets to cardButtonView v
// didlayoutsubviews initial animation v
// refactor animation clutter v
// interuption succes animation no deal cards bug v
// install bp replay font v
// animation interupted by device rotation fix v
// press down animation, press up animation x
// tap circle animation x
// animated sucess highlight crop circles x
// animated unsuccessful highlight crop circles x
// selected, success, wrong highlight x
// animate shadows on deal cards x
// score label custom view animated rework x
// add menu button x
// add interuptable transition to menu x
// add info/tutorial screen + first opening tutorial x
// press animation scal factor relative to screen size not card size
//
// make card draw subrects as vertical stackview v
// device rotation sometimes stuck in disabled flag mode bug v
// shuffle not working bug v
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
    var targetGrid = Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio)) {
        didSet {
            // Flag signaling that all cards should be rearranged no matter wheter they haven't been changed, added or other.
            targetGridFlagLayoutChanged = targetGridFlagLayoutChanged || (oldValue.dimensions != targetGrid.dimensions)
        }
    }
    var targetGridFlagLayoutChanged = true
    var previousCardsGridLayout: [Card: (Int, Int)] = [:]
    var animationFlagNewGame = false
    var animationFlagDealMoreCards = false
    var animationFlagSuccessMatch = false
    var freeRotationFlag = true

    // MARK: UI OUTLETS

    @IBOutlet weak var playingBoardView: UIView!
    @IBOutlet weak var newGameButton: UIButton!
    @IBAction func newGamePressed(_ sender: UIButton) {
        newGame()
        updateUI()
    }
    @IBOutlet weak var dealCardsButton: UIButton!
    @IBAction func dealCardsPressed(_ sender: UIButton) {
        dealThreeCards()
        updateUI()
        updateScoreLabel()
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
            updateScoreLabel()
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

    // MARK: VIEWCONTROLLER OVERRIDE METHODS

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        UIFactory.setup(graphicalSetViewController: self)
        newGame()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // When orientation changes targetGrid layout changes
        self.targetGridFlagLayoutChanged = true
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.targetGrid = UIFactory.updateGrid(toSize: self.game.cardsOnTable.count, inside: self.playingBoardView.layer.bounds)
            self.updateUI()
            // Button as round as it gets.
            UIFactory.roundedCorners(on: self.newGameButton)
            UIFactory.roundedCorners(on: self.scoreLabel)
            UIFactory.roundedCorners(on: self.dealCardsButton)
            // Recalculate soft shadows.
            UIFactory.customShadow(on: self.newGameButton)
            UIFactory.customShadow(on: self.scoreLabel.superview)
            UIFactory.customShadow(on: self.dealCardsButton)
            // Setup deal button.
            UIFactory.setupDealCardsButton(button: self.dealCardsButton)
        }
    }

    // Support disabling device autorotation when cards are animated on table. Autoratation would cause
    // cards to endup on wrong place - playce that would be only correct in previous orientation's layout
    override var shouldAutorotate: Bool {
        return freeRotationFlag
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if freeRotationFlag {
            return .allButUpsideDown
        }
        else {
            return .portrait
        }
    }

    // MARK: CONTROLLER

    private func newGame() {
        resetUI()
        game = Game()
        targetGrid = UIFactory.updateGrid(toSize: game.cardsOnTable.count, inside: playingBoardView.layer.bounds)
        animationFlagNewGame = true
        updateScoreLabel()
    }

    private func resetUI() {
        // Empty UI data structures before recreating them from ground up.
        playingCardButtons = []
        for view in playingBoardView.subviews {
            view.removeFromSuperview()
        }
    }

    private func updateUI() {
        // Rebuild UI from model.
        updatePlayingCardButtons()
        highlightSelection()
        markSuccessfulMatch()
        manageDealButton()

        // Animate UI.
        animateRearrangeCards()
        animateDealCards()
        animateNewGame()
        animateSuccessMatch()

        // Clear flags.
        clearAnimationFlags()
    }

    func updatePlayingCardButtons() {
        // Save last View state's card's coordinates in a grid for later use.
        previousCardsGridLayout = [:]
        // Helper array for rearranging all buttons according to card order in model.
        var newCardsOnTableButton: [PlayingCardButton] = []
        // Go trough fresh model.
        for indexModel in 0..<game.cardsOnTable.count {
            let model = game.cardsOnTable[indexModel]
            // Update buttons order according to model.
            if let indexButton = playingCardButtons.firstIndex(where: { cardModelEqualsCardView(cardModel: model, cardView: $0.playingCardView) }) {
                previousCardsGridLayout[model] = targetGrid.getCoordinates(at: indexButton)
                newCardsOnTableButton.append(playingCardButtons[indexButton])
            }
            // And create buttons for any newly dealt cards.
                else {
                    let cardRect = CGRect(x: -20, y: -20, width: 90, height: 90) // Debug purposes. Real position for new cards will be set in prepareDealCardsAnimation().
                    let cardCornerRadius = cardRect.width * PlayingCardButton.Constants.cornerRadiusToWidthRatio
                    let cardButton = PlayingCardButton(frame: cardRect, cornerRadius: cardCornerRadius, shapeType: model.shape.rawValue, quantityType: model.quantity.rawValue, fillType: model.pattern.rawValue, colorType: model.color.rawValue)
                    newCardsOnTableButton.append(cardButton)
                    playingBoardView.addSubview(cardButton)

                    // Setup self as playing card buttons delegate to recieve tap events.
                    cardButton.delegate = self
            }
        }
        // Remove unnecessery buttons.
        for button in playingCardButtons.filter({ !newCardsOnTableButton.contains($0) }) {
            button.removeFromSuperview()
        }
        // Commit from helper array.
        playingCardButtons = newCardsOnTableButton

    }
    // True if model card equals ui view card.
    func cardModelEqualsCardView(cardModel: Card, cardView: PlayingCardView) -> Bool {
        return cardView.shapeType == cardModel.shape.rawValue && cardView.colorType == cardModel.color.rawValue && cardView.fillType == cardModel.pattern.rawValue && cardView.quantity == cardModel.quantity.rawValue + 1
    }

    private func replaceMatchedCards() {
        game.subtitute(cards: Array(game.cardsSelected))
    }

    private func dealThreeCards() {
        animationFlagDealMoreCards = true
        game.dealCards(quantity: 3)
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
        var suffix = Constants.scoreGradeFirstSuffix
        switch playingCardButtons.count {
        case 0...21:
            suffix = Constants.scoreGradeFirstSuffix
        case 22...31:
            suffix = Constants.scoreGradeSecondSuffix
        case 32...41:
            suffix = Constants.scoreGradeThirdSuffix
        case 42...51:
            suffix = Constants.scoreGradeFourthSuffix
        default:
            suffix = Constants.scoreGradeFifthSuffix
        }
        var scoreText = ""
        switch game.score.playerScore {
        case 0:
            scoreText = Constants.scoreZeroValue
        default:
            scoreText = String(game.score.playerScore)
        }
        self.scoreLabel.text = scoreText + suffix
    }

    private func manageDealButton() {
        dealCardsButton.isEnabled = !game.cardsInPack.isEmpty
    }

    private func clearAnimationFlags() {
        animationFlagNewGame = false
        animationFlagDealMoreCards = false
        animationFlagSuccessMatch = false
        targetGridFlagLayoutChanged = false
    }

    // MARK: ANIMATIONS

    private func animateRearrangeCards() {
        // Update grid for animating cards into the new updated grid layout.
        targetGrid = UIFactory.updateGrid(toSize: game.cardsOnTable.count, inside: playingBoardView.layer.bounds)
        // Determine which cards should be rearranged on table to new position.
        let cardsToRearrange = UIFactory.filterCardsToRearrange(cardModel: game.cardsOnTable, with: previousCardsGridLayout, layoutChangedFlag: targetGridFlagLayoutChanged, grid: targetGrid, dealCards: game.cardsToDeal, matchedCards: game.cardsMatched)
//        print(cardsToRearrange.count)

        // Animate selected cards.
        if cardsToRearrange.count > 0 {
            freeRotationFlag = false
            AnimationFactory.rearrangeAnimation(toRearrangeModel: cardsToRearrange, tableModel: game.cardsOnTable, views: playingCardButtons, grid: targetGrid, completion: {(animationPosition) in
                self.game.cardsToDeal = Set<Card>()
                self.freeRotationFlag = true
            })
        }
    }

    private func animateDealCards() {
        if animationFlagDealMoreCards {
            freeRotationFlag = false
            if game.cardsToDeal.count > 0 {
                UIApplication.shared.beginIgnoringInteractionEvents()
            }
            AnimationFactory.dealCardsAnimation(toDealModel: Array(game.cardsToDeal), tableModel: game.cardsOnTable, views: playingCardButtons, grid: targetGrid, startView: dealCardsButton, completion: {(animationPosition) in
                self.game.cardsToDeal = Set<Card>()
                self.freeRotationFlag = true
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        }
    }

    private func animateNewGame() {
        if animationFlagNewGame {
            UIApplication.shared.beginIgnoringInteractionEvents()
            freeRotationFlag = false
            animationFlagNewGame = false
            targetGrid = UIFactory.updateGrid(toSize: game.cardsOnTable.count, inside: playingBoardView.layer.bounds)

            AnimationFactory.newGameAnimation(tableModel: game.cardsOnTable, views: playingCardButtons, grid: targetGrid, startView: newGameButton, completion: {(animationPosition) in
                self.game.cardsToDeal = Set<Card>()
                self.freeRotationFlag = true
                UIApplication.shared.endIgnoringInteractionEvents()
            })
        }
    }

    private func animateSuccessMatch() {
        if animationFlagSuccessMatch {
            UIApplication.shared.beginIgnoringInteractionEvents()
            freeRotationFlag = false

            AnimationFactory.successMatchAnimation(matchedModel: Array(game.cardsMatched), tableModel: game.cardsOnTable, views: playingCardButtons, targetView: scoreLabel, completion: {(animationPosition) in self.view.nod()
                self.replaceMatchedCards()
                self.animationFlagDealMoreCards = true
                self.updateScoreLabel()
                UIApplication.shared.endIgnoringInteractionEvents()
                // Eventough we want to updateUI() at this point to trigger deal new cards animation, we don't call it here. updateUI() gets called by viewDidLayoutSubviews() after updateScoreLabel() change triggers autolayout rearrangement. So Calling updateUI inhere would cause some troubles.
            })
        }
    }
}
