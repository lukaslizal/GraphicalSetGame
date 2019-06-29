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

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = layer.bounds.width * Constants.cornerRadiusToWidthRatio
        let symbolInsets = layer.bounds.width * Constants.symbolInsetsRatio
        let symbolsAreaRect = layer.bounds.insetBy(dx: symbolInsets, dy: symbolInsets)
        var gridOfShapes = Grid(layout: Grid.Layout.aspectRatio(Constants.symbolAspectRatio), frame: symbolsAreaRect)
        gridOfShapes.cellCount = quantity
        for index in 0..<shapeViews.count {
            if index < quantity{
                let spacingX = shapeViews[index].frame.width * Constants.symbolSpacingToCardRatio
                let spacingY = shapeViews[index].frame.height * Constants.symbolSpacingToCardRatio
                shapeViews[index].frame = (gridOfShapes[index]?.insetBy(dx: spacingX, dy: spacingY))!
                shapeViews[index].isOpaque = false
            }
        }
    }

    func selectedHighlight() {
        layer.borderColor = Constants.selectedHighlightColor
        layer.borderWidth = 3
    }
    func successHighlight() {
        layer.borderColor = Constants.selectedSuccessColor
        layer.borderWidth = 5
    }
    func unhighlight() {
        layer.borderWidth = 0
    }
}

extension PlayingCardView {
    struct Constants {
        static let symbolAspectRatio: CGFloat = 12 / 5
        static let cardFrameAspectRatio: CGFloat = 5 / 7
        static let symbolInsetsRatio: CGFloat = 1 / 20
        static let symbolWidthToBoundsRatio: CGFloat = 4 / 5
        static let symbolHeightToBoundsRatio: CGFloat = 4 / 5
        static let symbolSpacingToCardRatio: CGFloat = 1 / 20
        static let cardColor: CGColor = #colorLiteral(red: 0.9683051419, green: 0.9683051419, blue: 0.9683051419, alpha: 1)
        static let selectedHighlightColor: CGColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        static let selectedSuccessColor: CGColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        static let cornerRadiusToWidthRatio: CGFloat = 1 / 10
    }
}

