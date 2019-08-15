//
//  PlayingCardView.swift
//  Graphical SetGame
//
//  Created by Lukas on 20/06/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

/**
 Visual representation of a plaing card with ability to render different shapes, quantities, fill patterns and color. Dynamicaly changes by changing these 4 properties.
 
 - author:
 Lukas Lizal
 */
class PlayingCardView: UIView {
    private var shapeViews: [ShapeView] = {
        var views = [ShapeView(), ShapeView(), ShapeView()]
        for index in 0..<3{
         views[index].isOpaque = false
        }
        return views
    }()
    internal var shape: Int = 0 {
        didSet {
            for view in shapeViews {
                view.shape = ShapeType(rawValue: shape)!
            }
            setNeedsLayout() } }
    internal var quantity: Int = 0 {
        didSet {
            setNeedsLayout() } }
    internal var fill: Int = 0 {
        didSet {
            for view in shapeViews {
                view.fill = FillType(rawValue: fill)!
            }
            setNeedsLayout() } }
    internal var color: Int = 0 {
        didSet {
            for view in shapeViews {
                view.shapeColor = UIColor.ColorPalette.color(of: color)
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
        layer.backgroundColor = Constants.cardColor
        clipsToBounds = true
        self.isExclusiveTouch = true

        setupShapeViews(quantity: quantityType + 1, shapeType: shapeType, fillType: fillType, colorType: colorType)
    }

    private func setupShapeViews(quantity: Int, shapeType: Int, fillType: Int, colorType: Int) {
        updateSymbolViewFrames()
        self.shape = shapeType
        self.quantity = quantity
        self.color = colorType
        self.fill = fillType
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight] // we dont want autolayout
    }

    internal override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? PlayingCardView else {
            return false
        }
        return self.shape == other.shape && self.quantity == other.quantity && self.fill == other.fill && self.color == other.color
    }

    internal override func layoutSubviews() {
        super.layoutSubviews()
        updateSymbolViewFrames()
        if let parentButtonView = superview {
            layer.cornerRadius = layer.bounds.width * (parentButtonView.layer.cornerRadius / parentButtonView.layer.bounds.width)
        }
    }
    /**
     Updates size and poition of symbols in a card according to its current size.
     */
    private func updateSymbolViewFrames() {
        
        let symbolInsets = layer.bounds.width * Constants.symbolInsetsRatio
        let symbolsAreaRect = layer.bounds.insetBy(dx: symbolInsets, dy: symbolInsets)
        let symbolAreaVerticalCenter = symbolInsets + symbolsAreaRect.height/2
        let symbolHeight = symbolsAreaRect.width / PlayingCardView.Constants.symbolAspectRatio
        var symbolOffsetAccumulation: CGFloat = -((symbolHeight)*CGFloat(quantity))/2
        for index in 0..<quantity {
            shapeViews[index].frame = CGRect(x: symbolInsets, y: symbolAreaVerticalCenter + symbolOffsetAccumulation, width: symbolsAreaRect.width, height: symbolsAreaRect.width/PlayingCardView.Constants.symbolAspectRatio)
            addSubview(shapeViews[index])
            
            symbolOffsetAccumulation += symbolHeight
        }
    }
    /**
     Visually highlights button as a selected card.
     */
    internal func selectedHighlight() {
        self.backgroundColor = UIColor(cgColor: Constants.selectedHighlightColor)
    }
    /**
     Visually highlights button as a successfuly matched card.
     */
    internal func successHighlight() {
        self.backgroundColor = UIColor(cgColor: Constants.selectedSuccessColor)
        for shapeView in self.shapeViews {
            shapeView.shapeColor = UIColor.clear
        }
    }
    /**
     Unhighlights button back to normal state.
     */
    internal func unhighlight() {
        self.backgroundColor = UIColor(cgColor: Constants.cardColor)
    }
}

