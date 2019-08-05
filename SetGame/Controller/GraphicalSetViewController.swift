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
// add info/tutorial screen + first opening tutorial x
// press animation scal factor relative to screen size not card size
//
// make card draw subrects as vertical stackview v
// device rotation sometimes stuck in disabled flag mode bug v
// shuffle not working bug x
//
// new game confirmation screen
// animate cards away before confirmation screen
// detect no more combinations -> end the game (other thread)
// add winner screen (Lottie animation)
// add local persistant high score

class GraphicalSetViewController: UIViewController, CardTap {

    // MARK: STORED PROPERTIES

    var game: Game = Game()
    var playingCardButtons: Array<PlayingCardButton> = Array<PlayingCardButton>()
    lazy var targetGrid = Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio), frame: playingBoardView.layer.bounds)
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
        self.view.backgroundColor = Constants.mainThemeColor
        self.newGameButton.backgroundColor = Constants.buttonBackgroundColor
        self.dealCardsButton.backgroundColor = Constants.buttonBackgroundColor
        self.scoreLabel.backgroundColor = Constants.scoreLabelThemeColor
        self.dealCardsButton.layer.zPosition = 1
        self.newGameButton.layer.zPosition = 1
        self.scoreLabel.superview?.layer.zPosition = 3
        self.newGameButton.layer.cornerRadius = self.newGameButton.frame.height / 2.0
        self.dealCardsButton.layer.cornerRadius = self.dealCardsButton.frame.height / 2.0
        self.scoreLabel.layer.cornerRadius = self.scoreLabel.frame.height / 2.0
        self.scoreLabel.clipsToBounds = true

//        newGameButton.titleLabel?.minimumScaleFactor = 0.5
//        newGameButton.titleLabel?.numberOfLines = 0
//        newGameButton.titleLabel?.adjustsFontSizeToFitWidth = true
//        newGameButton.titleLabel?.textAlignment = NSTextAlignment.center

        self.scoreLabel.layer.shouldRasterize = true
        self.scoreLabel.layer.rasterizationScale = UIScreen.main.scale
//        self.scoreLabel.layer.masksToBounds = true

        self.newGameButton.layer.shouldRasterize = true
        self.newGameButton.layer.rasterizationScale = UIScreen.main.scale

        self.dealCardsButton.layer.shouldRasterize = true
        self.dealCardsButton.layer.rasterizationScale = UIScreen.main.scale

        dealCardsButton.titleLabel?.minimumScaleFactor = 0.5
        dealCardsButton.titleLabel?.numberOfLines = 0
        dealCardsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        dealCardsButton.titleLabel?.textAlignment = NSTextAlignment.center
        dealCardsButton.setTitleColor(Constants.buttonNormalTextColor, for: .normal)
        dealCardsButton.setTitleColor(Constants.buttonDisabledTextColor, for: .disabled)

        newGame()
        setupGestures()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // When orientation changes targetGrid layout changes
        self.targetGridFlagLayoutChanged = true
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.newGameButton.layer.cornerRadius = self.newGameButton.frame.height / 2.0
            self.dealCardsButton.layer.cornerRadius = self.dealCardsButton.frame.height / 2.0
            self.scoreLabel.layer.cornerRadius = self.scoreLabel.frame.height / 2.0
            self.setupGrid(cellCount: self.game.cardsOnTable.count)
            self.updateUI()

            self.dealCardsButton.layer.shadowPath = UIBezierPath(rect: self.dealCardsButton.bounds.insetBy(dx: 2, dy: 20)).cgPath
            self.dealCardsButton.layer.shadowColor = UIColor.black.cgColor
            self.dealCardsButton.layer.shadowRadius = 15
            self.dealCardsButton.layer.shadowOpacity = 0.6
            self.dealCardsButton.layer.shadowOffset = CGSize(width: 0, height: 15)

            self.newGameButton.layer.shadowPath = UIBezierPath(rect: self.newGameButton.bounds.insetBy(dx: 2, dy: 20)).cgPath
            self.newGameButton.layer.shadowColor = UIColor.black.cgColor
            self.newGameButton.layer.shadowRadius = 15
            self.newGameButton.layer.shadowOpacity = 0.7
            self.newGameButton.layer.shadowOffset = CGSize(width: 0, height: 15)

            self.scoreLabel.superview?.layer.shadowPath = UIBezierPath(roundedRect: self.scoreLabel.bounds.insetBy(dx: 2, dy: 20), cornerRadius: self.scoreLabel.layer.cornerRadius).cgPath
            self.scoreLabel.superview?.layer.shadowColor = UIColor.black.cgColor
            self.scoreLabel.superview?.layer.shadowRadius = 15
            self.scoreLabel.superview?.layer.shadowOpacity = 0.7
            self.scoreLabel.superview?.layer.shadowOffset = CGSize(width: 0, height: 15)
        }
    }

    // Support disabling device autorotation when cards are animated on table. Autoratation would cause
    // cards to endup on wrong place - playce that would be only correct in previous orientation's layout
    override var shouldAutorotate: Bool {
        return freeRotationFlag
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if freeRotationFlag {
            return .all
        }
        else {
            return .portrait
        }
    }

    // MARK: CONTROLLER

    private func updateUI() {
        // Rebuild UI from model.
//        initTableCards()
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

    private func resetUI() {
        // Empty UI data structures before recreating them from ground up.
        playingCardButtons = []
        for view in playingBoardView.subviews {
            view.removeFromSuperview()
        }
    }
    private func clearAnimationFlags() {
        animationFlagNewGame = false
        animationFlagDealMoreCards = false
        animationFlagSuccessMatch = false
        targetGridFlagLayoutChanged = false
    }

    private func setupGrid(cellCount: Int) {
        let oldDimensions = targetGrid.dimensions
        targetGrid = Grid(layout: .aspectRatio(PlayingCardView.Constants.cardFrameAspectRatio), frame: playingBoardView.layer.bounds)
        targetGrid.cellCount = cellCount
        let newDimensions = targetGrid.dimensions

//         case where grid changes!

        targetGridFlagLayoutChanged = targetGridFlagLayoutChanged || (oldDimensions != newDimensions)

//        !((oldDimensions.columnCount-newDimensions.columnCount) == 0 && (oldDimensions.rowCount-newDimensions.rowCount) == 0)
    }

    func setupPlayingCardsDelegate() {
        for playingCardButton in playingCardButtons {
            playingCardButton.delegate = self
        }
    }

    func updatePlayingCardButtons() {
        //

        // Save last View state's card's coordinates in a grid for later use.
        previousCardsGridLayout = [:]
        // Collection contains newly added cards after we filter this collection using cards from last View state.
        var newCardsOnTableModel = game.cardsOnTable
        var buttonsToRemove: [PlayingCardButton] = []
        var indicesToFill: [Int] = []

        for index in 0..<playingCardButtons.count {
            let card = playingCardButtons[index].playingCardView
            // If card is present in model.
            if let model = game.cardsOnTable.first(where: { cardModelEqualsCardView(cardModel: $0, cardView: card) }) {
                // Save last View state's card's coordinates in a grid for later use.
                previousCardsGridLayout[model] = targetGrid.getCoordinates(at: index)
                // Filter using cards from last View state.
                newCardsOnTableModel.removeAll(where: { cardModelEqualsCardView(cardModel: $0, cardView: card) })
            }
            else {
                // Collect card buttons not present in model anymore.
                buttonsToRemove.append(playingCardButtons[index])
                indicesToFill.append(index)
            }
        }

        // Remove card buttons not present in model anymore.
        for button in buttonsToRemove {
            if let indexToRemove = playingCardButtons.firstIndex(of: button) {
                print("indexToRemove: " + String(indexToRemove))
                playingCardButtons[indexToRemove].removeFromSuperview()
                playingCardButtons.remove(at: indexToRemove)
            }
        }

        // Create new UI card buttons.
        for cardModel in newCardsOnTableModel {
//            if game.cardsOnTable.firstIndex(of: cardModel) != nil {
            let cardRect = CGRect(x: -20, y: -20, width: 90, height: 90) //dealCardsButton.convert(dealCardsButton.bounds, to: playingBoardView)
//            let cardRect = CGRect(x: 1000,y: 0,width: 10,height: 10)

            let cardCornerRadius = cardRect.width * PlayingCardButton.Constants.cornerRadiusToWidthRatio
            let cardButton = PlayingCardButton(frame: cardRect, cornerRadius: cardCornerRadius, shapeType: cardModel.shape.rawValue, quantityType: cardModel.quantity.rawValue, fillType: cardModel.pattern.rawValue, colorType: cardModel.color.rawValue)
            if let _ = indicesToFill.first {
                playingCardButtons.insert(cardButton, at: indicesToFill.removeFirst())
            }
            else {
                playingCardButtons.insert(cardButton, at: playingCardButtons.endIndex)
            }
            playingBoardView.addSubview(cardButton)

            // Setup self as playing card buttons delegate to recieve tap events.
            cardButton.delegate = self
//            }
        }

//        setupPlayingCardsDelegate()
    }

    func cardModelEqualsCardView(cardModel: Card, cardView: PlayingCardView) -> Bool {
        return cardView.shapeType == cardModel.shape.rawValue && cardView.colorType == cardModel.color.rawValue && cardView.fillType == cardModel.pattern.rawValue && cardView.quantity == cardModel.quantity.rawValue + 1
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
                let cardCornerRadius = cardRect.width * PlayingCardButton.Constants.cornerRadiusToWidthRatio
                let cardButton = PlayingCardButton(frame: cardRect, cornerRadius: cardCornerRadius, shapeType: cardModel.shape.rawValue, quantityType: cardModel.quantity.rawValue, fillType: cardModel.pattern.rawValue, colorType: cardModel.color.rawValue)
                playingCardButtons.append(cardButton)
                playingBoardView.addSubview(cardButton)
            }
        }
        // Setup self as playing card buttons delegate to recieve tap events.
        setupPlayingCardsDelegate()
    }

    private func newGame() {
        resetUI()
        game = Game()
//        playingCardButtons = []
//        previousCardsGridLayout = [:]
        setupGrid(cellCount: game.cardsOnTable.count)
        animationFlagNewGame = true
//        updateUI()
        updateScoreLabel()
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

    // MARK: ANIMATIONS

    private func animate(cards: [Card], onto targetViewBy: (_ index: Int) -> (UIView?), duration: TimeInterval, waitFor: TimeInterval, animationTimeSpacing: TimeInterval, animationOptions: UIView.AnimationOptions, targetElementSpacing: CGFloat, onComplete: @escaping (_ finished: Bool) -> (Void)) {
        var delay = 0.0
//        CATransaction.begin()
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
//        CATransaction.commit()
    }

    private func animateRearrangeCards() {
        //        UIApplication.ignoreInteractionEvents(for: Constants.animationOldCardDuration + Constants.animationOldCardDelayIncrement/2)
        setupGrid(cellCount: game.cardsOnTable.count)

        let cardsToRearrange = game.cardsOnTable.filter() {
            var cardsPreviousGridPositionMatches = false
            if let cardButtonIndex = game.cardsOnTable.firstIndex(of: $0), let previousCardCoordinates = previousCardsGridLayout[$0] {
                cardsPreviousGridPositionMatches = (previousCardCoordinates == targetGrid.getCoordinates(at: cardButtonIndex))
            }
            print("!cardsPreviousGridPositionMatches: " + String(!cardsPreviousGridPositionMatches) + ", targetGridFlagLaoutChanged: " + String(targetGridFlagLayoutChanged))
            return !game.cardsToDeal.contains($0) && !game.cardsMatched.contains($0) && (!cardsPreviousGridPositionMatches || targetGridFlagLayoutChanged)
        }
        print("cardsToRearrange: " + String(cardsToRearrange.count))
        if cardsToRearrange.count > 0 {
            freeRotationFlag = false
            animate(cards: cardsToRearrange, onto: targetGridViews, duration: Constants.animationOldCardDuration, waitFor: 0, animationTimeSpacing: Constants.animationOldCardDelayIncrement, animationOptions: Constants.animationOldCardOptions, targetElementSpacing: PlayingCardButton.Constants.playingCardsSpacing, onComplete: { [unowned self] (finished: Bool) -> (Void) in
                self.game.cardsToDeal = Set<Card>()
                self.freeRotationFlag = true
            })
        }
        
    }

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
            prepareForNewGameAnimation()

            UIApplication.ignoreInteractionEvents(for: Constants.animationNewGameDuration + Constants.animationNewGameCardDelayIncrement / 2)
            freeRotationFlag = false
            animationFlagNewGame = false
            setupGrid(cellCount: game.cardsOnTable.count)

            animate(cards: Array(game.cardsOnTable), onto: targetGridViews, duration: Constants.animationNewGameDuration, waitFor: 0, animationTimeSpacing: Constants.animationNewGameCardDelayIncrement, animationOptions: Constants.animationNewGameCardOptions, targetElementSpacing: PlayingCardButton.Constants.playingCardsSpacing, onComplete: { [unowned self] (finished: Bool) -> (Void) in
                    self.game.cardsToDeal = Set<Card>()
                    print(self.freeRotationFlag)
                    self.freeRotationFlag = true
                })
        }
    }

    private func animateSuccessMatch() {
        if animationFlagSuccessMatch {
            prepareForSuccessMatchAnimation()
            UIApplication.ignoreInteractionEvents(for: Constants.animationSuccessMatchWaitFor + Constants.animationSuccessMatchDuration + Constants.animationSuccessMatchDelayIncrement / 2 - Constants.animationSuccessMatchDelayIncrement / Double(game.cardsMatched.count))
            freeRotationFlag = false

            animate(cards: Array(game.cardsMatched), onto: targetViewScoreLabel, duration: Constants.animationSuccessMatchDuration, waitFor: Constants.animationSuccessMatchWaitFor, animationTimeSpacing: Constants.animationSuccessMatchDelayIncrement, animationOptions: Constants.animationSuccessMatchOptions, targetElementSpacing: 0, onComplete: { [unowned self] (finished: Bool) -> Void in
                    self.view.nod()
                    self.replaceMatchedCards()
                    self.animationFlagDealMoreCards = true
                    self.updateScoreLabel()
                    // WEIRD!
                    // o.O score label update causes deal card animation to freak out.
                    // Probably because fighting autolayout system but thats only hypothesis.
                    // So I've tried to delay deal cards animation start after autolayout system
                    // is done with uilabel. But this workaround only is effective when delay
                    // is set to 1 second - despite the fact actual deal card animation is
                    // not delayed even a tiny bit AND the issue is for unknow reason fixed.
                    // ¯\_(ツ)_/¯ #meh
                    DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(1)) {
                        self.updateUI()
//                        UIApplication.ignoreInteractionEvents(for: Constants.animationDealCardDuration + Constants.animationDealCardDelayIncrement / 2 - Constants.animationDealCardDelayIncrement / Double(self.game.cardsToDeal.count))
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
            playingCardButton.layer.removeAllAnimations()
            playingCardButton.playingCardView.layer.removeAllAnimations()
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
        view.frame = scoreLabel.convert(scoreLabel.layer.bounds, to: self.playingBoardView)
        return view }

}


