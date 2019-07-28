//
//  PlayingCardButton.swift
//  SetGame
//
//  Created by Lukas on 22/07/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

protocol CardTap: class {
    func tapped(playingCardButton: PlayingCardButton)
}

class PlayingCardButton: UIView {
    var playingCardView = PlayingCardView()

    var blurView = UIView()
    weak var delegate: CardTap?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    init(frame: CGRect, shapeType: Int, quantityType: Int, fillType: Int, colorType: Int) {
        super.init(frame: frame)
        layer.backgroundColor = UIColor.red.cgColor
        clipsToBounds = true
        setupPlayingCardView(shapeType: shapeType, quantityType: quantityType, fillType: fillType, colorType: colorType)
        setupGestures()
    }

    private func setupPlayingCardView(shapeType: Int, quantityType: Int, fillType: Int, colorType: Int) {
        let rect = self.layer.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing)
        playingCardView = PlayingCardView(frame: rect, shapeType: shapeType, quantityType: quantityType, fillType: fillType, colorType: colorType)
        addSubview(playingCardView)
    }

    func setupGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func tapHandler(sender: UITapGestureRecognizer) {
        print("gg")
        switch sender.state {
        case .ended:
            self.delegate?.tapped(playingCardButton: self)
        default:
            return
        }
    }
    override func isEqual(_ object: Any?) -> Bool {
        guard let otherButton = object as? PlayingCardButton else {
            return false
        }
        return playingCardView == otherButton.playingCardView
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playingCardView.setNeedsLayout()
        playingCardView.layer.cornerRadius = self.layer.bounds.width * Constants.cornerRadiusToWidthRatio
        playingCardView.frame = self.layer.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing)
        blurView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }

    func selectedHighlight() {
        playingCardView.selectedHighlight()
    }
    func successHighlight() {
        playingCardView.successHighlight()
    }
    func unhighlight() {
        playingCardView.unhighlight()
    }

}
