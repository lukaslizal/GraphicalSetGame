//
//  PlayingCardView.swift
//  Graphical SetGame
//
//  Created by Lukas on 20/06/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

class PlayingCardView: UIView {
    var shapeViews: [ShapeView] = [ShapeView(), ShapeView(), ShapeView()]
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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    init(frame: CGRect, cornerRadius: CGFloat, shapeType: Int, quantityType: Int, fillType: Int, colorType: Int) {
        super.init(frame: frame)
        layer.cornerRadius = cornerRadius
        layer.backgroundColor = Constants.cardColor //UIColor.white.cgColor
        clipsToBounds = true
        setupSubviews(quantity: quantityType + 1, shapeType: shapeType, fillType: fillType, colorType: colorType)
    }

    private func setupSubviews(quantity: Int, shapeType: Int, fillType: Int, colorType: Int) {
        updateSymbolViewFrames()
        for index in 0..<quantity {
            shapeViews[index].isOpaque = false
        }
        self.shapeType = shapeType
        self.quantity = quantity
        self.colorType = colorType
        self.fillType = fillType
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight] // we dont want autolayout
    }


    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PlayingCardView else {
            return false
        }
        return self.shapeType == other.shapeType && self.quantity == other.quantity && self.fillType == other.fillType && self.colorType == other.colorType
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateSymbolViewFrames()
        if let parentButtonView = superview {
            layer.cornerRadius = layer.bounds.width * (parentButtonView.layer.cornerRadius / parentButtonView.layer.bounds.width)
        }
    }

    private func updateSymbolViewFrames() {
        
        let symbolInsets = layer.bounds.width * Constants.symbolInsetsRatio
        let symbolsAreaRect = layer.bounds.insetBy(dx: symbolInsets, dy: symbolInsets)
        let symbolAreaVerticalCenter = symbolInsets + symbolsAreaRect.height/2
        let symbolHeight = symbolsAreaRect.width / PlayingCardView.Constants.symbolAspectRatio
        var symbolOffsetAccumulation: CGFloat = -((symbolHeight)*CGFloat(quantity))/2
        for index in 0..<quantity {
            shapeViews[index].frame = CGRect(x: symbolInsets, y: symbolAreaVerticalCenter + symbolOffsetAccumulation, width: symbolsAreaRect.width, height: symbolsAreaRect.width/PlayingCardView.Constants.symbolAspectRatio) // symbolsAreaRect.width*PlayingCardView.Constants
            addSubview(shapeViews[index])
            
            symbolOffsetAccumulation += symbolHeight
        }
    }

    func selectedHighlight() {
        self.backgroundColor = UIColor(cgColor: Constants.selectedHighlightColor)
    }
    func successHighlight() {
        self.backgroundColor = UIColor(cgColor: Constants.selectedSuccessColor)
        for shapeView in self.shapeViews {
            shapeView.shapeColor = UIColor.clear
        }
    }
    func unhighlight() {
        self.backgroundColor = UIColor(cgColor: Constants.cardColor)
    }
}

