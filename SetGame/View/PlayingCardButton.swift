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

    init(frame: CGRect, cornerRadius: CGFloat, shapeType: Int, quantityType: Int, fillType: Int, colorType: Int) {
        super.init(frame: frame)
        layer.cornerRadius = cornerRadius
        layer.backgroundColor = UIColor.clear.cgColor
        clipsToBounds = true
        setupPlayingCardView(cornerRadius: cornerRadius, shapeType: shapeType, quantityType: quantityType, fillType: fillType, colorType: colorType)
        setupGestures()
    }

    private func setupPlayingCardView(cornerRadius: CGFloat, shapeType: Int, quantityType: Int, fillType: Int, colorType: Int) {
        let rect = self.layer.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing)
        let cardViewCornerRadius = rect.width*(cornerRadius/layer.bounds.width)
        playingCardView = PlayingCardView(frame: rect, cornerRadius: cardViewCornerRadius, shapeType: shapeType, quantityType: quantityType, fillType: fillType, colorType: colorType)
        addSubview(playingCardView)
    }

    func setupGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func tapHandler(sender: UITapGestureRecognizer) {
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
        playingCardView.layer.cornerRadius = self.layer.bounds.width * Constants.cornerRadiusToWidthRatio
        playingCardView.setNeedsLayout()
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
