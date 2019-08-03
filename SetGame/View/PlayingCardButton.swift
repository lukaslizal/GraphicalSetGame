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
        layer.backgroundColor = Constants.buttonColor
        clipsToBounds = true
        setupPlayingCardView(cornerRadius: cornerRadius, shapeType: shapeType, quantityType: quantityType, fillType: fillType, colorType: colorType)
        setupGestures()
    }

    private func setupPlayingCardView(cornerRadius: CGFloat, shapeType: Int, quantityType: Int, fillType: Int, colorType: Int) {
        let rect = self.layer.bounds.insetBy(dx: Constants.playingCardsSpacing, dy: Constants.playingCardsSpacing)
        let cardViewCornerRadius = rect.width * (cornerRadius / layer.bounds.width)
        playingCardView = PlayingCardView(frame: rect, cornerRadius: cardViewCornerRadius, shapeType: shapeType, quantityType: quantityType, fillType: fillType, colorType: colorType)
        addSubview(playingCardView)
    }

    func setupGestures() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
        self.addGestureRecognizer(tapGestureRecognizer)
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panHandler))
//        self.addGestureRecognizer(panGestureRecognizer)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.07, delay: 0, options: [.curveEaseOut], animations: {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }, completion: nil)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.0, delay: 0, options: [.curveEaseOut], animations: {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }, completion: nil)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.05, animations: {
            self.transform = CGAffineTransform.identity
        })
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.05, animations: {
            self.transform = CGAffineTransform.identity
        })
    }
    @objc func tapHandler(sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            self.delegate?.tapped(playingCardButton: self)
        default:
            return
        }
    }

    @objc func panHandler(sender: UIPanGestureRecognizer) {
//        switch sender.state {
//        case .began:
//            UIView.animate(withDuration: 0.1, animations: {
//                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//            })
//        case .cancelled:
//            UIView.animate(withDuration: 0.1, animations: {
//                self.transform = CGAffineTransform.identity
//            })
//        case .ended:
//            UIView.animate(withDuration: 0.1, animations: {
//                self.transform = CGAffineTransform.identity
//            })
//            self.delegate?.tapped(playingCardButton: self)
//        default:
//            return
//        }
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
