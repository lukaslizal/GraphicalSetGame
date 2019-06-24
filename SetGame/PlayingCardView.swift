//
//  PlayingCardView.swift
//  Graphical SetGame
//
//  Created by Lukas on 20/06/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

class PlayingCardView: UIView {
    var shapeViews: [ShapeView] = [] { didSet { setNeedsLayout() } }
    var symbolGridView: UIView = UIView() { didSet { setNeedsLayout() } }
    var quantity: Int = 3{ didSet{ setNeedsLayout() } }
    var colorOption: Int = 0{
        didSet{
            for view in shapeViews {
                view.color = UIColor.ShapeColor.color(of: colorOption)
            }
            setNeedsLayout()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        addSubview(symbolGridView)
        for index in 0..<quantity{
            self.shapeViews.append(ShapeView())
            addSubview(shapeViews[index])
        }
        layer.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(symbolGridView)
        for index in 0..<quantity{
            self.shapeViews.append(ShapeView())
            addSubview(shapeViews[index])
        }
        addSubview(symbolGridView)
        layer.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
    }

    convenience init(frame: CGRect, shapeView: ShapeView, quantity: Int, colorOption: Int) {
        self.init(frame: frame)
        self.quantity = quantity
        self.colorOption = colorOption
        for index in 0..<quantity{
            self.shapeViews.append(ShapeView())
            addSubview(shapeViews[index])
        }
        addSubview(symbolGridView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let symbolInsets = layer.bounds.width * Constants.symbolInsetsRatio
        let symbolsAreaRect = layer.bounds.insetBy(dx: symbolInsets, dy: symbolInsets)
//        symbolGridView.frame = symbolsAreaRect
//        symbolGridView.backgroundColor = UIColor.blue
        var gridOfShapes = Grid(layout: Grid.Layout.aspectRatio(Constants.symbolAspectRatio), frame: symbolsAreaRect)
        gridOfShapes.cellCount = quantity
        for index in 0..<quantity{
            let spacingX = shapeViews[index].frame.width * Constants.symbolSpacingToCardRatio
            let spacingY = shapeViews[index].frame.height * Constants.symbolSpacingToCardRatio
            shapeViews[index].frame = (gridOfShapes[index]?.insetBy(dx: spacingX, dy: spacingY))!
            shapeViews[index].backgroundColor = UIColor.red
        }
    }
}

class ShapeView: UIView {
    var shape: Shape { didSet { setNeedsDisplay() } }
    var color: CGColor { didSet { setNeedsDisplay() } }
    var pattern: FillPattern { didSet { setNeedsDisplay() } }
    lazy var drawingArea: CGRect = {
        let insets = layer.bounds.width * Constants.symbolInsetsRatio
        return self.frame.insetBy(dx: insets, dy: insets)
    }()
    
    required init?(coder aDecoder: NSCoder) {
        self.shape = .rhombus
        self.color = UIColor.purple.cgColor
        self.pattern = .stroke
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        self.shape = .rhombus
        self.color = UIColor.purple.cgColor
        self.pattern = .stroke
        super.init(frame: frame)
    }

    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath()
        path.lineWidth = frame.height * Constants.symbolStrokeWidthToSymbolHeight
        path.lineJoinStyle = .round
        path.move(to: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.1), y: CGFloat(0.5))))
        path.addLine(to: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.5), y: CGFloat(0.1))))
        path.addLine(to: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.9), y: CGFloat(0.5))))
        path.addLine(to: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.5), y: CGFloat(0.9))))
        path.close()
        UIColor.black.set()
        UIColor.red.setFill()
        path.stroke()
    }
}

enum FillPattern {
    case stroke
    case fill
    case hatch
}

enum Shape {
    case rhombus
    case oval
    case squiggle
}

extension UIColor {
    struct ShapeColor {
        static var firstColor: CGColor { return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) }
        static var secondColor: CGColor { return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1) }
        static var thirdColor: CGColor { return #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1) }

        static func color(of type: Int) -> CGColor {
            switch(type) {
            case 0:
                return firstColor
            case 1:
                return secondColor
            case 2:
                return thirdColor
            default:
                return #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            }
        }
    }
}
extension CGRect{
    func calculatePointFrom(normalized point: CGPoint) -> CGPoint{
        let x = 0 + point.x * self.width
        let y = 0 + point.y * self.height
        return CGPoint(x: x, y: y)
    }
}
extension PlayingCardView {
    private struct Constants {
        static let symbolAspectRatio: CGFloat = 12 / 5
        static let cardAspectRatio: CGFloat = 5 / 7
        static let symbolInsetsRatio: CGFloat = 1 / 20
        static let symbolWidthToBoundsRatio: CGFloat = 4 / 5
        static let symbolHeightToBoundsRatio: CGFloat = 4 / 5
        static let symbolSpacingToCardRatio: CGFloat = 1 / 20
    }
}
extension ShapeView {
    private struct Constants {
        static let symbolInsetsRatio: CGFloat = 1 / 20
        static let symbolStrokeWidthToSymbolHeight: CGFloat = 1 / 10
    }
}

