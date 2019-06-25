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
                view.shapeColor = UIColor.ColorPalette.color(of: colorOption)
            }
            setNeedsLayout()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.backgroundColor = Constants.cardColor
        layer.isOpaque = false
        layer.cornerRadius = layer.bounds.width * Constants.cornerRadiusToWidthRatio
        initSubviews(quantity)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.backgroundColor = Constants.cardColor
        layer.isOpaque = false
        layer.cornerRadius = layer.bounds.width * Constants.cornerRadiusToWidthRatio
        initSubviews(quantity)
    }

    convenience init(frame: CGRect, shapeView: ShapeView, quantity: Int, colorOption: Int) {
        self.init(frame: frame)
        self.quantity = quantity
        self.colorOption = colorOption
        layer.backgroundColor = Constants.cardColor
        layer.isOpaque = false
        layer.cornerRadius = layer.bounds.width * Constants.cornerRadiusToWidthRatio
        initSubviews(quantity)
    }
    
    private func initSubviews(_ count: Int){
        for index in 0..<count{
            self.shapeViews.append(ShapeView())
            addSubview(shapeViews[index])
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let symbolInsets = layer.bounds.width * Constants.symbolInsetsRatio
        let symbolsAreaRect = layer.bounds.insetBy(dx: symbolInsets, dy: symbolInsets)
        var gridOfShapes = Grid(layout: Grid.Layout.aspectRatio(Constants.symbolAspectRatio), frame: symbolsAreaRect)
        gridOfShapes.cellCount = quantity
        for index in 0..<quantity{
            let spacingX = shapeViews[index].frame.width * Constants.symbolSpacingToCardRatio
            let spacingY = shapeViews[index].frame.height * Constants.symbolSpacingToCardRatio
            shapeViews[index].frame = (gridOfShapes[index]?.insetBy(dx: spacingX, dy: spacingY))!
            shapeViews[index].isOpaque = false
        }
    }
}

class ShapeView: UIView {
    var shape: Shape { didSet { setNeedsDisplay() } }
    var shapeColor: UIColor { didSet { setNeedsDisplay() } }
    var pattern: FillPattern { didSet { setNeedsDisplay() } }
    lazy var drawingArea: CGRect = {
        let insets = layer.bounds.width * Constants.symbolInsetsRatio
        return self.frame.insetBy(dx: insets, dy: insets)
    }()
    
    required init?(coder aDecoder: NSCoder) {
        self.shape = .rhombus
        self.shapeColor = UIColor.purple
        self.pattern = .stroke
        super.init(coder: aDecoder)
        self.contentMode = .redraw
    }

    override init(frame: CGRect) {
        self.shape = .squiggle
        self.shapeColor = UIColor.purple
        self.pattern = .hatch
        super.init(frame: frame)
        self.contentMode = .redraw
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.lineWidth = frame.height * Constants.symbolStrokeWidthToSymbolHeight
        path.lineJoinStyle = .round
        shapeColor.set()
        shapeColor.setFill()
        switch shape {
        case .rhombus:
            rhombusPath(path)
        case .squiggle:
            squigglePath(path)
        case .oval:
            ovalPath(path)
        }
        path.stroke()
        if(pattern == .fill){
            path.fill()
        }
        if(pattern == .hatch){
            hatchShape(path)
        }
    }
    
    private func rhombusPath(_ path: UIBezierPath){
        path.move(to: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.1), y: CGFloat(0.5))))
        path.addLine(to: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.5), y: CGFloat(0.1))))
        path.addLine(to: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.9), y: CGFloat(0.5))))
        path.addLine(to: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.5), y: CGFloat(0.9))))
        path.close()
    }

    private func ovalPath(_ path: UIBezierPath){
        path.move(to: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.3), y: CGFloat(0.1))))
        path.addLine(to: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.7), y: CGFloat(0.1))))
        path.addCurve(to: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.7), y: CGFloat(0.9))),
                      controlPoint1: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.95), y: CGFloat(0.1))),
                      controlPoint2: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.95), y: CGFloat(0.9))))
        path.addLine(to: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.3), y: CGFloat(0.9))))
        path.addCurve(to: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.3), y: CGFloat(0.1))),
                      controlPoint1: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.05), y: CGFloat(0.9))),
                      controlPoint2: frame.calculatePointFrom(normalized:  CGPoint(x: CGFloat(0.05), y: CGFloat(0.1))))
        path.close()
    }
    
    private func squigglePath(_ path: UIBezierPath){
        let mirrorAroundCenter = CGAffineTransform.identity.translatedBy(x: 0.5, y: 0.5).rotated(by: CGFloat.pi).translatedBy(x: -0.5, y: -0.5)
        let scaleDown = CGAffineTransform.identity.translatedBy(x: 0.5, y: 0.5).scaledBy(x: 0.85, y: 0.85).translatedBy(x: -0.5, y: -0.5)
        
        let point1 = CGPoint(x: CGFloat(0.08), y: CGFloat(0.16)).applying(scaleDown)
        let point2 = CGPoint(x: CGFloat(0.66), y: CGFloat(0.16)).applying(scaleDown)
        let controlPoint3 = CGPoint(x: CGFloat(0.33), y: CGFloat(-0.34)).applying(scaleDown)
        let controlPoint4 = CGPoint(x: CGFloat(0.5), y: CGFloat(0.41)).applying(scaleDown)
        let point5 = point1.applying(mirrorAroundCenter)
        let controlPoint6 = CGPoint(x: CGFloat(0.9), y: CGFloat(-0.15)).applying(scaleDown)
        let controlPoint7 = CGPoint(x: CGFloat(1.09), y: CGFloat(0.55)).applying(scaleDown)
        let point8 = point2.applying(mirrorAroundCenter)
        let controlPoint9 = controlPoint3.applying(mirrorAroundCenter)
        let controlPoint10 = controlPoint4.applying(mirrorAroundCenter)
        let point11 = point1
        let controlPoint12 = controlPoint6.applying(mirrorAroundCenter)
        let controlPoint13 = controlPoint7.applying(mirrorAroundCenter)

        path.move(to: frame.calculatePointFrom(normalized:  point1))
        path.addCurve(to: frame.calculatePointFrom(normalized:  point2),
                      controlPoint1: frame.calculatePointFrom(normalized:  controlPoint3),
                      controlPoint2: frame.calculatePointFrom(normalized:  controlPoint4))
        path.addCurve(to: frame.calculatePointFrom(normalized:  point5),
                      controlPoint1: frame.calculatePointFrom(normalized:  controlPoint6),
                      controlPoint2: frame.calculatePointFrom(normalized:  controlPoint7))
        path.addCurve(to: frame.calculatePointFrom(normalized: point8),
                      controlPoint1: frame.calculatePointFrom(normalized: controlPoint9),
                      controlPoint2: frame.calculatePointFrom(normalized: controlPoint10))
        path.addCurve(to: frame.calculatePointFrom(normalized: point11),
                      controlPoint1: frame.calculatePointFrom(normalized: controlPoint12),
                      controlPoint2: frame.calculatePointFrom(normalized: controlPoint13))
        path.close()
    }
    
    private func hatchShape(_ path: UIBezierPath){
        path.addClip()
        path.lineWidth = Constants.hatchStrokeWidth
        for horizontalStep in stride(from: 0, to: layer.bounds.width, by: Constants.hatchStep){
            path.move(to: CGPoint(x: CGFloat(horizontalStep), y: CGFloat(0.0)))
            path.addLine(to: CGPoint(x: CGFloat(horizontalStep), y: CGFloat(layer.bounds.height)))
        }
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
    struct ColorPalette {
        static var firstColor: UIColor { return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1) }
        static var secondColor: UIColor { return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1) }
        static var thirdColor: UIColor { return #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1) }

        static func color(of type: Int) -> UIColor {
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
        static let cardColor: CGColor = #colorLiteral(red: 0.9683051419, green: 0.9683051419, blue: 0.9683051419, alpha: 1)
        static let cornerRadiusToWidthRatio: CGFloat = 1/10
    }
}
extension ShapeView {
    private struct Constants {
        static let symbolInsetsRatio: CGFloat = 1 / 20
        static let symbolStrokeWidthToSymbolHeight: CGFloat = 1 / 10
        static let hatchStep: CGFloat = 6
        static let hatchStrokeWidth: CGFloat = 3
    }
}

