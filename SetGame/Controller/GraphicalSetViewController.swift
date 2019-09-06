//
//  GraphicalSetViewController.swift
//  SetGame
//
//  Created by Lukas on 30/06/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit
import Foundation

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
// press down animation, press up animation v
// tap circle animation v
// animated sucess highlight crop circles v
// animated unsuccessful highlight crop circles v
// selected, success, wrong highlight v
// hide statusbar ingame show in menu v
// shake ampliture relative to screen size v
// add menu button v
// add main menu screen v
// continue button reveal animation v
// continue button animation flashing v
// restart game confirmation v
// score view
// logo view
// menu animated background
// rework color scheme
// make launch screen x
// make gifs x
// add info/tutorial screen + first opening tutorial x
// custom card button add target-action pattern x
//
// deselect transfrom.identity doesnt scale to size of other cards v
// autolayout on (furious) device rotation breakdown v
// make card draw subrects as vertical stackview v
// device rotation sometimes stuck in disabled flag mode bug v
// shuffle not working bug v
//
// less than 21 cards remaining in pack -> end of game
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
class GraphicalSetViewController: UIViewController, UINavigationControllerDelegate, CardTap {

    // MARK: STORED PROPERTIES
    
    internal var transitionAnimator = PushVerticalAnimator()
    
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

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
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
    @IBOutlet weak var scoreView: ScoreView!
    @IBOutlet weak internal var menuView: UIView!
    @IBOutlet weak var menuBorder: UIView!
    @IBAction internal func newGamePressed(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "menu") {
            if let menuViewController = vc as? MenuViewController{
                menuViewController.gameMVC = self
                navigationController?.pushViewController(menuViewController, animated: true)
            }
//            present(vc, animated: true, completion: {
//                print("menuPresented")
//            })
        }
//        newGame()
//        updateUI()
    }
    @IBAction internal func dealCardsPressed(_ sender: UIButton) {
        dealThreeCards()
        updateUI()
        updateScoreLabel()
    }

    // MARK: TOUCH CONTROLS

    internal func tapped(playingCardButton: PlayingCardButton) -> Bool {
        // Select card button in model.
        if let buttonIndex = playingCardButtons.firstIndex(of: playingCardButton) {
            let selectedCard = game.cardsOnTable[buttonIndex]
            // Card gets deselected
            if !game.select(selectedCard) {
                updateUI()
                return false
            }
            // Successful attempt to match 3 cards.
            if game.selectedIsMatch {
                // Replace matched cards
                animationFlagSuccessMatch = true
            }
            // Unsuccessful attempt to match 3 cards
                else if game.cardsSelected.count == 3 {
                    // Indicate invalid set selection.
                    view.shake()

                    updateUI()
                    // Remove selected cards background color and Highlight selected cards with unsuccessful background color.
                    for button in playingCardButtons {
                        if button.selected {
                            button.unhighlight()
                            button.unsuccessfulHighlight()
                        }
                    }
                    playingCardButton.unhighlight()
                    playingCardButton.unsuccessfulHighlight()
                    return false
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
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .push:
            transitionAnimator.presenting = true
            return transitionAnimator
        case .pop:
            transitionAnimator.presenting = false
            return transitionAnimator
        default:
            return nil
        }
    }

    // MARK: VIEWCONTROLLER OVERRIDE METHODS

    internal override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.delegate = self
        
        newGameButton.imageView?.contentMode = .scaleAspectFit
        
        UIFactory.setup(viewController: self)
        UIFactory.setupUISwipeGesture(for: self)
        UIFactory.setupUIRotateGesture(for: self)
        self.menuView.layer.zPosition = 1000
        self.menuBorder.layer.cornerRadius = min(menuBorder.layer.bounds.width/2, menuBorder.layer.bounds.height/2)
        newGame()
    }
    
    internal override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // When orientation changes targetGrid layout changes
        self.targetGridFlagLayoutChanged = true
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.tableGrid = UIFactory.updateGrid(toSize: self.game.cardsOnTable.count, inside: self.playingBoardView.layer.bounds)
            // Button as round as it gets.
            UIFactory.setMaxCornerRadius(on: self.newGameButton)
            UIFactory.setMaxCornerRadius(on: self.scoreLabel)
            UIFactory.setMaxCornerRadius(on: self.dealCardsButton)
            self.scoreView.layer.cornerRadius = min(self.scoreView.frame.width, self.scoreView.frame.height) / 8
            
//            self.menuBorder.layer.cornerRadius = min(self.menuBorder.layer.bounds.width/2, self.menuBorder.layer.bounds.height/2)
            
            // Recalculate soft shadows.
            UIFactory.customShadow(on: self.newGameButton.superview, color: Constants.blackShadowColor, offset: Constants.shadowOffset)
            UIFactory.customShadow(on: self.scoreLabel.superview, color: Constants.blackShadowColor, offset: Constants.shadowOffset)
            UIFactory.customShadow(on: self.dealCardsButton.superview, color: Constants.blackShadowColor, offset: Constants.shadowOffset)
            UIFactory.customShadow(on: self.scoreView, color: Constants.blackShadowColor, offset: Constants.shadowOffset)
            
            // Setup deal button.
            UIFactory.setupDealCardsButton(button: self.dealCardsButton)
            // Update UI (cards) after buttons have been set up. Cards animations are dependent on buttons corner radiuses and and frames.
            self.updateUI()
        }
    }

    internal override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: CONTROLLER

    internal func restartGame(){
        newGame()
        updateUI()
    }
    
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
//            playingCardButtons[index].unhighlight()
            if game.cardsSelected.contains(game.cardsOnTable[index]) {
//                playingCardButtons[index].selectedHighlight()
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
            AnimationFactory.rearrangeAnimation(toRearrangeModel: cardsToRearrange, tableModel: game.cardsOnTable, views: playingCardButtons, grid: tableGrid, completion: { (animationPosition) in
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
            AnimationFactory.dealCardsAnimation(toDealModel: Array(game.cardsToDeal), tableModel: game.cardsOnTable, views: playingCardButtons, grid: tableGrid, startView: dealCardsButton, completion: { (animationPosition) in
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
            AnimationFactory.newGameAnimation(tableModel: game.cardsOnTable, views: playingCardButtons, grid: tableGrid, startView: newGameButton, completion: { (animationPosition) in
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
            AnimationFactory.successMatchAnimation(matchedModel: Array(game.cardsMatched), tableModel: game.cardsOnTable, views: playingCardButtons, targetView: scoreView, completion: { (animationPosition) in self.view.nod()
                    self.replaceMatchedCards()
                    self.animationFlagDealMoreCards = true
                    self.updateScoreLabel()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    // Eventough we want to updateUI() at this point to trigger deal new cards animation, we don't call it here. updateUI() gets called by viewDidLayoutSubviews() after updateScoreLabel() change triggers autolayout rearrangement. So Calling updateUI inhere would only cause some troubles.
                })
        }
    }
}

// MARK: TOUCH CONTROLS

extension GraphicalSetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer && gestureRecognizer.state == .began
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

