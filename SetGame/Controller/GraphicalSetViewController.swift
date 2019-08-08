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
        didSet{
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
    
    lazy var newGameAnimator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: GraphicalSetViewController.Constants.animationNewGameDuration, curve: GraphicalSetViewController.Constants.animationNewGameCardTimingCurve)
    lazy var dealCardAnimator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: GraphicalSetViewController.Constants.animationDealCardDuration, curve: GraphicalSetViewController.Constants.animationDealCardTimingCurve)
    lazy var successAnimator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: GraphicalSetViewController.Constants.animationSuccessMatchDuration, curve: GraphicalSetViewController.Constants.animationSuccessMatchTimingCurve)
    lazy var rearrangeAnimator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: GraphicalSetViewController.Constants.animationRearrangeCardDuration, curve: GraphicalSetViewController.Constants.animationRearrangeCardTimingCurve)

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
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.clearFlagsDelay) {
            self.clearAnimationFlags()
        }
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
        for button in playingCardButtons.filter({!newCardsOnTableButton.contains($0)}){
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
//        switch playingCardButtons.count {
//        case 0...21:
//            suffix = Constants.scoreGradeFirstSuffix
//        case 22...31:
//            suffix = Constants.scoreGradeSecondSuffix
//        case 32...41:
//            suffix = Constants.scoreGradeThirdSuffix
//        case 42...51:
//            suffix = Constants.scoreGradeFourthSuffix
//        default:
//            suffix = Constants.scoreGradeFifthSuffix
//        }
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

//    private func animate(cards: [Card], onto targetViewBy: (_ index: Int) -> (UIView?), duration: TimeInterval, waitFor: TimeInterval, animationTimeSpacing: TimeInterval, animationOptions: UIView.AnimationOptions, targetElementSpacing: CGFloat, onComplete: @escaping (_ finished: Bool) -> (Void)) {
//        var delay = 0.0
//        for (index, card) in cards.enumerated() {
//            if let cardIndex = game.cardsOnTable.firstIndex(of: card), let animationTargetView = targetViewBy(cardIndex) {
//                playingCardButtons[cardIndex].cornerRadiusAnimationWithDuration(duration: CFTimeInterval(duration), to: animationTargetView.layer.cornerRadius, delay: waitFor + (Double(delay) / TimeInterval(cards.count)))
//                playingCardButtons[cardIndex].playingCardView.cornerRadiusAnimationWithDuration(duration: CFTimeInterval(duration), to: animationTargetView.layer.cornerRadius, delay: waitFor + (Double(delay) / TimeInterval(cards.count)))
//                let completionBlock = index == cards.endIndex - 1 ? onComplete : nil
//                UIView.animate(withDuration: duration, delay: waitFor + (delay / TimeInterval(cards.count)), options: animationOptions, animations: { [weak self] in
//                        self?.playingCardButtons[cardIndex].frame = animationTargetView.frame
//                    },
//                    completion: completionBlock)
//            }
//            delay += animationTimeSpacing
//        }
//    }
    
    
    private func animate(cards: [Card], onto targetViewBy: (_ index: Int) -> (UIView?), duration: TimeInterval, waitFor: TimeInterval, animationTimeSpacing: TimeInterval, animationOptions: UIView.AnimationOptions, targetElementSpacing: CGFloat, onComplete: @escaping (_ finished: Bool) -> (Void)) {
        var delay = 0.0
        for (index, card) in cards.enumerated() {
            if let cardIndex = game.cardsOnTable.firstIndex(of: card), let animationTargetView = targetViewBy(cardIndex) {
                playingCardButtons[cardIndex].cornerRadiusAnimationWithDuration(duration: CFTimeInterval(duration), to: animationTargetView.layer.cornerRadius, delay: waitFor + (Double(delay) / TimeInterval(cards.count)))
                playingCardButtons[cardIndex].playingCardView.cornerRadiusAnimationWithDuration(duration: CFTimeInterval(duration), to: animationTargetView.layer.cornerRadius, delay: waitFor + (Double(delay) / TimeInterval(cards.count)))
                let completionBlock = index == cards.endIndex - 1 ? onComplete : nil
                UIView.animate(withDuration: duration, delay: waitFor + (delay / TimeInterval(cards.count)), options: animationOptions, animations: { [weak self] in
                    self?.playingCardButtons[cardIndex].frame = animationTargetView.frame
                    },
                               completion: completionBlock)
            }
            
            delay += animationTimeSpacing
        }
    }
    
    private func animateRearrangeCards() {
        // Update grid for animating cards into the new updated grid layout.
        targetGrid = UIFactory.updateGrid(toSize: game.cardsOnTable.count, inside: playingBoardView.layer.bounds)
        // Determine which cards should be rearranged on table to new position.
        let cardsToRearrange = game.cardsOnTable.filter() {
            var cardsPreviousGridPositionMatches = false
            // Determine whether cards position in a grid changed since last ui update - subject to optimalization - get rid of previous card coordinates and update grid after this?
            if let cardButtonIndex = game.cardsOnTable.firstIndex(of: $0), let previousCardCoordinates = previousCardsGridLayout[$0] {
                cardsPreviousGridPositionMatches = (previousCardCoordinates == targetGrid.getCoordinates(at: cardButtonIndex))
            }
            // When card is on the table, didn't change position in targetGrid coordinates or target grid has changed its layout, then include this card into cards to rearrange animation cards.
            return !game.cardsToDeal.contains($0) && !game.cardsMatched.contains($0) && (!cardsPreviousGridPositionMatches || targetGridFlagLayoutChanged)
        }
        // Animate selected cards.
        if cardsToRearrange.count > 0 {
            freeRotationFlag = false
            var delay: CGFloat = 0.0
            for (index, card) in cardsToRearrange.enumerated(){
                if let cardIndex = game.cardsOnTable.firstIndex(of: card), let targetView = targetGridViews(index: cardIndex) {
                    rearrangeAnimator.addAnimations({
                    self.playingCardButtons[cardIndex].frame = targetView.frame
                    self.playingCardButtons[cardIndex].layer.cornerRadius = targetView.layer.cornerRadius
                    self.playingCardButtons[cardIndex].playingCardView.layer.cornerRadius = targetView.layer.cornerRadius
                    }, delayFactor: delay )
                delay += Constants.animationRearrangeCardRelativeDelay/CGFloat(cardsToRearrange.count)
                }
            }
            rearrangeAnimator.addCompletion { _ in
                self.game.cardsToDeal = Set<Card>()
                self.freeRotationFlag = true
            }
            rearrangeAnimator.startAnimation()
        }
    }
//    private func animateRearrangeCards() {
//        targetGrid = UIFactory.updateGrid(toSize: game.cardsOnTable.count, inside: playingBoardView.layer.bounds)
//
//        let cardsToRearrange = game.cardsOnTable.filter() {
//            var cardsPreviousGridPositionMatches = false
//            if let cardButtonIndex = game.cardsOnTable.firstIndex(of: $0), let previousCardCoordinates = previousCardsGridLayout[$0] {
//                cardsPreviousGridPositionMatches = (previousCardCoordinates == targetGrid.getCoordinates(at: cardButtonIndex))
//            }
//            print("!cardsPreviousGridPositionMatches: " + String(!cardsPreviousGridPositionMatches) + ", targetGridFlagLaoutChanged: " + String(targetGridFlagLayoutChanged))
//            return !game.cardsToDeal.contains($0) && !game.cardsMatched.contains($0) && (!cardsPreviousGridPositionMatches || targetGridFlagLayoutChanged)
//        }
//        print("cardsToRearrange: " + String(cardsToRearrange.count))
//        if cardsToRearrange.count > 0 {
//            freeRotationFlag = false
//            animate(cards: cardsToRearrange, onto: targetGridViews, duration: Constants.animationRearrangeCardDuration, waitFor: 0, animationTimeSpacing: Constants.animationRearrangeCardDelayIncrement, animationOptions: Constants.animationRearrangeCardOptions, targetElementSpacing: PlayingCardButton.Constants.playingCardsSpacing, onComplete: { [unowned self] (finished: Bool) -> (Void) in
//                self.game.cardsToDeal = Set<Card>()
//                self.freeRotationFlag = true
//            })
//        }
//    }

    private func animateDealCards() {
        if animationFlagDealMoreCards {
            UIApplication.ignoreInteractionEvents(for: Constants.animationDealCardDuration + Constants.animationDealCardDelayIncrement / 2)
            prepareForDealCardsAnimation()
            freeRotationFlag = false

            animate(cards: Array(game.cardsToDeal), onto: targetGridViews, duration: Constants.animationDealCardDuration, waitFor: 0, animationTimeSpacing: Constants.animationDealCardDelayIncrement, animationOptions: Constants.animationDealCardOptions, targetElementSpacing: PlayingCardButton.Constants.playingCardsSpacing, onComplete: { [unowned self] (finished: Bool) -> (Void) in
                    self.game.cardsToDeal = Set<Card>()
                    self.freeRotationFlag = true
                })
        }
    }

    private func animateNewGame() {
        if animationFlagNewGame {
            UIApplication.ignoreInteractionEvents(for: Constants.animationNewGameDuration + Constants.animationNewGameCardDelayIncrement / 2)
            prepareForNewGameAnimation()
            freeRotationFlag = false
            animationFlagNewGame = false
            targetGrid = UIFactory.updateGrid(toSize: game.cardsOnTable.count, inside: playingBoardView.layer.bounds)

            animate(cards: Array(game.cardsOnTable), onto: targetGridViews, duration: Constants.animationNewGameDuration, waitFor: 0, animationTimeSpacing: Constants.animationNewGameCardDelayIncrement, animationOptions: Constants.animationNewGameCardOptions, targetElementSpacing: PlayingCardButton.Constants.playingCardsSpacing, onComplete: { [unowned self] (finished: Bool) -> (Void) in
                    self.game.cardsToDeal = Set<Card>()
                    print(self.freeRotationFlag)
                    self.freeRotationFlag = true
                })
        }
    }
    
    private func animateSuccessMatch() {
        if animationFlagSuccessMatch {
            UIApplication.ignoreInteractionEvents(for: Constants.animationSuccessMatchWaitFor + Constants.animationSuccessMatchDuration + Constants.animationSuccessMatchDelayIncrement / 2 - Constants.animationSuccessMatchDelayIncrement / Double(game.cardsMatched.count))
            prepareForSuccessMatchAnimation()
            freeRotationFlag = false

            animate(cards: Array(game.cardsMatched), onto: targetViewScoreLabel, duration: Constants.animationSuccessMatchDuration, waitFor: Constants.animationSuccessMatchWaitFor, animationTimeSpacing: Constants.animationSuccessMatchDelayIncrement, animationOptions: Constants.animationSuccessMatchOptions, targetElementSpacing: 0, onComplete: { [unowned self] (finished: Bool) -> Void in
                    self.view.nod()
                    self.replaceMatchedCards()
                    self.animationFlagDealMoreCards = true
                    self.updateScoreLabel()
                    // Eventough we want to updateUI() at this point to trigger deal new cards animation, we don't call it here. updateUI() gets called by viewDidLayoutSubviews() after updateScoreLabel() change triggers autolayout rearrangement. So Calling updateUI inhere would cause some troubles.
                })
        }
    }
    // Setup cards for deal animation starting frame.
    private func prepareForDealCardsAnimation() {
        for cardModel in game.cardsToDeal {
            if let indexOnTable = game.cardsOnTable.firstIndex(of: cardModel) {
                playingCardButtons[indexOnTable].frame = dealCardsButton.convert(dealCardsButton.bounds, to: playingBoardView).insetBy(dx: Constants.insetHideBehindButton, dy: Constants.insetHideBehindButton)
                playingCardButtons[indexOnTable].layer.cornerRadius = dealCardsButton.layer.cornerRadius
                playingCardButtons[indexOnTable].playingCardView.layer.cornerRadius = dealCardsButton.layer.cornerRadius
                playingCardButtons[indexOnTable].setNeedsLayout()
            }
        }
    }
    // Setup cards for new game animation starting frame.
    private func prepareForNewGameAnimation() {
        for playingCardButton in playingCardButtons {
            playingCardButton.layer.removeAllAnimations()
            playingCardButton.playingCardView.layer.removeAllAnimations()
            playingCardButton.frame = newGameButton.convert(newGameButton.bounds, to: playingBoardView).insetBy(dx: Constants.insetHideBehindButton, dy: Constants.insetHideBehindButton)
            playingCardButton.layer.cornerRadius = newGameButton.layer.cornerRadius
            playingCardButton.playingCardView.layer.cornerRadius = newGameButton.layer.cornerRadius
            playingCardButton.setNeedsLayout()
        }
    }
    // Setup cards for sucess match animation starting frame.
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
    // Returns UIView positioned and sized according to specified index in a card grid.
    private func targetGridViews(index: Int) -> UIView? {
        let view = UIView()
        if let rect = self.targetGrid[index] {
            view.layer.cornerRadius = PlayingCardView.Constants.cornerRadiusToWidthRatio * rect.width
            view.frame = rect
            return view
        }
        return nil
    }
    // Retruns UIView positioned and sized according to Score label.
    private func targetViewScoreLabel(index: Int) -> UIView? {
        let view = UIView()
        view.layer.cornerRadius = scoreLabel.layer.cornerRadius
        view.frame = scoreLabel.convert(scoreLabel.layer.bounds, to: self.playingBoardView)
        return view }

}


