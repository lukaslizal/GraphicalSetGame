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

/**
 Displays actual gameplay screen.
 ## Basic game rules:
 1. Three cards, where two cards share same one feature but third card does not, is not considered a set.
 2. Any other three cards are considered a set
 
 - author:
 Lukas Lizal
 */
class GraphicalSetViewController: UIViewController, CardTap {

    // MARK: STORED PROPERTIES

    private var game: Game = Game()
    var playingCardButtons: [PlayingCardButton] = []
    private var targetGridFlagLayoutChanged = true
    private var previousCardsGridLayout: [Card: (Int, Int)] = [:]
    private var animationFlagNewGame = false
    private var animationFlagDealMoreCards = false
    private var animationFlagSuccessMatch = false
    private var freeRotationFlag = true
    internal var tableGrid = Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio)) {
        didSet {
            // Flag signaling that all cards should be rearranged no matter wheter they haven't been changed, added or other.
            targetGridFlagLayoutChanged = targetGridFlagLayoutChanged || (oldValue.dimensions != tableGrid.dimensions)
        }
    }
    
    // MARK: AUTOROTATION
    
    /**
     Support disabling device autorotation when cards are animated on table. Autoratation would cause
     cards to endup on wrong place - playce that would be only correct in previous orientation's layout
     */
    override internal var shouldAutorotate: Bool {
        return freeRotationFlag
    }
    override internal var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if freeRotationFlag {
            return .allButUpsideDown
        }
        else {
            return .portrait
        }
    }

    // MARK: UI OUTLETS

    @IBOutlet weak internal var playingBoardView: UIView!
    @IBOutlet weak internal var newGameButton: UIButton!
    @IBOutlet weak internal var dealCardsButton: UIButton!
    @IBOutlet weak internal var scoreLabel: UILabel!
    @IBAction internal func newGamePressed(_ sender: UIButton) {
        newGame()
        updateUI()
    }
    @IBAction internal func dealCardsPressed(_ sender: UIButton) {
        dealThreeCards()
        updateUI()
        updateScoreLabel()
    }

    // MARK: TOUCH CONTROLS
    
    internal func tapped(playingCardButton: PlayingCardButton) -> Bool {
        // Select card in model. Card is a subview of tap gesture recognising UIView "button"
        if let buttonIndex = playingCardButtons.firstIndex(of: playingCardButton) {
            let selectedCard = game.cardsOnTable[buttonIndex]
            if !game.select(selectedCard){
                updateUI()
                return false
            }
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
        return true
    }

    @objc internal func swipeToDealCards(_ sender: UISwipeGestureRecognizer) {
        switch sender.state {
        case .ended:
            dealThreeCards()
            updateUI()
            updateScoreLabel()
        default:
            return
        }
    }

    @objc internal func rotateToShuffle(_ sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case .began:
            game.shuffle()
            updateUI()
        default:
            return
        }
    }

    // MARK: VIEWCONTROLLER OVERRIDE METHODS

    internal override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        UIFactory.setup(viewController: self)
        // FIXME: Concurrent UILongPressGestureRecogniser on PlayingCardButton views
        // This is where I am trying to setup UIRotateGestureRecogniser and UISwipeGestureRecogniser. I thought use of isExclusiveTouch and isMultipleTouchEnabled could the key to solving my concurent UILongPressGestureRecognisers but doesn't seem to change anything in how touch works when i put it here.
        UIFactory.setupUIGestrues(for: self)
//        self.view.isExclusiveTouch = true
//        self.view.isMultipleTouchEnabled = false
        newGame()
    }

    internal override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // When orientation changes targetGrid layout changes
        self.targetGridFlagLayoutChanged = true
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.tableGrid = UIFactory.updateGrid(toSize: self.game.cardsOnTable.count, inside: self.playingBoardView.layer.bounds)
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

    // MARK: CONTROLLER

    private func newGame() {
        resetUI()
        game = Game()
        tableGrid = UIFactory.updateGrid(toSize: game.cardsOnTable.count, inside: playingBoardView.layer.bounds)
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

    private func updatePlayingCardButtons() {
        // Save last View state's card's coordinates in a grid for later use.
        previousCardsGridLayout = [:]
        // Helper array for rearranging all buttons according to card order in model.
        var newCardsOnTableButton: [PlayingCardButton] = []
        // Go trough fresh model.
        for indexModel in 0..<game.cardsOnTable.count {
            let model = game.cardsOnTable[indexModel]
            // Update buttons order according to model.
            if let indexButton = playingCardButtons.firstIndex(where: { cardModelEqualsCardView(cardModel: model, cardView: $0.playingCardView) }) {
                previousCardsGridLayout[model] = tableGrid.getCoordinates(at: indexButton)
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
    private func cardModelEqualsCardView(cardModel: Card, cardView: PlayingCardView) -> Bool {
        return cardView.shape == cardModel.shape.rawValue && cardView.color == cardModel.color.rawValue && cardView.fill == cardModel.pattern.rawValue && cardView.quantity == cardModel.quantity.rawValue + 1
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
        let suffix = Constants.scoreGradeFirstSuffix
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
        tableGrid = UIFactory.updateGrid(toSize: game.cardsOnTable.count, inside: playingBoardView.layer.bounds)
        // Determine which cards should be rearranged on table to new position.
        let cardsToRearrange = UIFactory.filterCardsToRearrange(cardModel: game.cardsOnTable, with: previousCardsGridLayout, layoutChangedFlag: targetGridFlagLayoutChanged, grid: tableGrid, dealCards: game.cardsToDeal, matchedCards: game.cardsMatched)
        // Animate selected cards.
        if cardsToRearrange.count > 0 {
            freeRotationFlag = false
            AnimationFactory.rearrangeAnimation(toRearrangeModel: cardsToRearrange, tableModel: game.cardsOnTable, views: playingCardButtons, grid: tableGrid, completion: {(animationPosition) in
                self.game.allCardsDealt()
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
            AnimationFactory.dealCardsAnimation(toDealModel: Array(game.cardsToDeal), tableModel: game.cardsOnTable, views: playingCardButtons, grid: tableGrid, startView: dealCardsButton, completion: {(animationPosition) in
                self.game.allCardsDealt()
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
            tableGrid = UIFactory.updateGrid(toSize: game.cardsOnTable.count, inside: playingBoardView.layer.bounds)
            AnimationFactory.newGameAnimation(tableModel: game.cardsOnTable, views: playingCardButtons, grid: tableGrid, startView: newGameButton, completion: {(animationPosition) in
                self.game.allCardsDealt()
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

// MARK: TOUCH CONTROLS

extension GraphicalSetViewController: UIGestureRecognizerDelegate {
    // FIXME: Concurrent UILongPressGestureRecogniser on PlayingCardButton views
    /**
     Require fail of other gestures when swipe or rotation gestures are recognised. Prevents unwanted selecting of cards.
     */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer && gestureRecognizer.state == .ended
        {
            return true
        }
        if gestureRecognizer is UIRotationGestureRecognizer && gestureRecognizer.state == .began
        {
            return true
        }
        return false
    }
}
