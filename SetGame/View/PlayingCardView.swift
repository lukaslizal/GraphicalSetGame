//
//  PlayingCardView.swift
//  Graphical SetGame
//
//  Created by Lukas on 20/06/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

protocol CardTap: class{
    func tapped(playingCard: PlayingCardView)
}

class PlayingCardView: UIView {
    var shapeViews: [ShapeView] = [ShapeView(), ShapeView(), ShapeView()]
    var symbolGridView: UIView = UIView() { didSet { setNeedsLayout() } }
    var shapeType: Int = 0 {
        didSet {
            for view in shapeViews {
                view.shape = ShapeType(rawValue: shapeType)!
            }
            setNeedsLayout() } }
    var quantity: Int = 0 {
        didSet {
            setNeedsLayout() } }
    var fillType: Int = 0 {
        didSet {
            for view in shapeViews {
                view.fill = FillType(rawValue: fillType)!
            }
            setNeedsLayout() } }
    var colorType: Int = 0 {
        didSet {
            for view in shapeViews {
                view.shapeColor = UIColor.ColorPalette.color(of: colorType)
            }
            setNeedsLayout()
        }
    }
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
        layer.cornerRadius = layer.bounds.width * Constants.cornerRadiusToWidthRatio
        layer.backgroundColor = UIColor.clear.cgColor
        clipsToBounds = true
        setupSubviews(quantity: quantityType + 1, shapeType: shapeType, fillType: fillType, colorType: colorType)
        setupGestures()
    }

    private func setupSubviews(quantity: Int, shapeType: Int, fillType: Int, colorType: Int) {
        for index in 0..<quantity {
            addSubview(shapeViews[index])
        }
        self.shapeType = shapeType
        self.quantity = quantity
        self.colorType = colorType
        self.fillType = fillType
        let blurEffect = UIBlurEffect(style: .regular)
        self.blurView = UIVisualEffectView(effect: blurEffect)
        self.blurView.translatesAutoresizingMaskIntoConstraints = false
        self.insertSubview(blurView, at: 0)
        self.blurView.backgroundColor = UIColor(cgColor: Constants.cardColor)
        blurView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    func setupGestures(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapHandler))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapHandler(sender: UITapGestureRecognizer){
        print("gg")
        switch sender.state {
        case .ended:
            self.delegate?.tapped(playingCard: self)
        default:
            return
        }
    }
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PlayingCardView else {
            return false
        }
        return self.shapeType == other.shapeType && self.quantity == other.quantity && self.fillType == other.fillType && self.colorType == other.colorType
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = layer.bounds.width * Constants.cornerRadiusToWidthRatio
        let symbolInsets = layer.bounds.width * Constants.symbolInsetsRatio
        let symbolsAreaRect = layer.bounds.insetBy(dx: symbolInsets, dy: symbolInsets)
        var gridOfShapes = Grid(layout: Grid.Layout.aspectRatio(Constants.symbolAspectRatio), frame: symbolsAreaRect)
        gridOfShapes.cellCount = quantity
        for index in 0..<shapeViews.count {
            if index < quantity {
                let spacingX = shapeViews[index].frame.width * Constants.symbolSpacingToCardRatio
                let spacingY = shapeViews[index].frame.height * Constants.symbolSpacingToCardRatio
                shapeViews[index].frame = (gridOfShapes[index]?.insetBy(dx: spacingX, dy: spacingY))!
                shapeViews[index].isOpaque = false
            }
        }
        blurView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }

    func selectedHighlight() {
        self.blurView.backgroundColor = UIColor(cgColor: Constants.selectedHighlightColor)
//        self.backgroundColor = UIColor(cgColor: Constants.selectedHighlightColor)
    }
    func successHighlight() {
        self.blurView.backgroundColor = UIColor(cgColor: Constants.selectedSuccessColor)
//        self.backgroundColor = UIColor(cgColor: Constants.selectedSuccessColor)
        for shapeView in self.shapeViews{
            shapeView.shapeColor = UIColor.clear
        }
    }
    func unhighlight() {
        self.blurView.backgroundColor = UIColor(cgColor: Constants.cardColor)
//        self.backgroundColor = UIColor(cgColor: Constants.cardColor)
    }
}

