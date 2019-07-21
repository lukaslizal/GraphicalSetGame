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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    init(frame: CGRect, shapeType: Int, quantityType: Int, fillType: Int, colorType: Int) {
        super.init(frame: frame)
        layer.cornerRadius = layer.bounds.width * Constants.cornerRadiusToWidthRatio
        layer.backgroundColor = Constants.cardColor
        layer.isOpaque = false
        clipsToBounds = true
        initSubviews(quantity: quantityType + 1, shapeType: shapeType, fillType: fillType, colorType: colorType)
    }

    private func initSubviews(quantity: Int, shapeType: Int, fillType: Int, colorType: Int) {
        for index in 0..<quantity {
            addSubview(shapeViews[index])
        }
        self.shapeType = shapeType
        self.quantity = quantity
        self.colorType = colorType
        self.fillType = fillType
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
    }

    func selectedHighlight() {
        self.backgroundColor = UIColor(cgColor: Constants.selectedHighlightColor)
    }
    func successHighlight() {
        self.backgroundColor = UIColor(cgColor: Constants.selectedSuccessColor)
        for shapeView in self.shapeViews{
            shapeView.shapeColor = UIColor.clear
        }
    }
    func unhighlight() {
        self.backgroundColor = UIColor(cgColor: Constants.cardColor)
    }
}

