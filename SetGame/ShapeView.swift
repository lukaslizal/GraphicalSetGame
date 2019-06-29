//
//  ShapeView.swift
//  SetGame
//
//  Created by Lukas on 27/06/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

class ShapeView: UIView {
    var shape: ShapeType = ShapeType(rawValue: 0)! { didSet { setNeedsDisplay() } }
    var shapeColor: UIColor = UIColor.ColorPalette.color(of: 0) { didSet { setNeedsDisplay() } }
    var fill: FillType = FillType(rawValue: 0)! { didSet { setNeedsDisplay() } }
    lazy var drawingArea: CGRect = {
        let insets = layer.bounds.width * Constants.symbolInsetsRatio
        return self.frame.insetBy(dx: insets, dy: insets)
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentMode = .redraw
    }

    override init(frame: CGRect) {
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
        if(fill == .fill) {
            path.fill()
        }
        if(fill == .hatch) {
            hatchShape(path)
        }
    }

    private func rhombusPath(_ path: UIBezierPath) {
        path.move(to: frame.mappedPointFrom(normalized: CGPoint(x: CGFloat(0.1), y: CGFloat(0.5))))
        path.addLine(to: frame.mappedPointFrom(normalized: CGPoint(x: CGFloat(0.5), y: CGFloat(0.1))))
        path.addLine(to: frame.mappedPointFrom(normalized: CGPoint(x: CGFloat(0.9), y: CGFloat(0.5))))
        path.addLine(to: frame.mappedPointFrom(normalized: CGPoint(x: CGFloat(0.5), y: CGFloat(0.9))))
        path.close()
    }

    private func ovalPath(_ path: UIBezierPath) {
        path.move(to: frame.mappedPointFrom(normalized: CGPoint(x: CGFloat(0.3), y: CGFloat(0.1))))
        path.addLine(to: frame.mappedPointFrom(normalized: CGPoint(x: CGFloat(0.7), y: CGFloat(0.1))))
        path.addCurve(to: frame.mappedPointFrom(normalized: CGPoint(x: CGFloat(0.7), y: CGFloat(0.9))),
            controlPoint1: frame.mappedPointFrom(normalized: CGPoint(x: CGFloat(0.95), y: CGFloat(0.1))),
            controlPoint2: frame.mappedPointFrom(normalized: CGPoint(x: CGFloat(0.95), y: CGFloat(0.9))))
        path.addLine(to: frame.mappedPointFrom(normalized: CGPoint(x: CGFloat(0.3), y: CGFloat(0.9))))
        path.addCurve(to: frame.mappedPointFrom(normalized: CGPoint(x: CGFloat(0.3), y: CGFloat(0.1))),
            controlPoint1: frame.mappedPointFrom(normalized: CGPoint(x: CGFloat(0.05), y: CGFloat(0.9))),
            controlPoint2: frame.mappedPointFrom(normalized: CGPoint(x: CGFloat(0.05), y: CGFloat(0.1))))
        path.close()
    }

    private func squigglePath(_ path: UIBezierPath) {
        let mirrorAroundCenter = CGAffineTransform.identity.translatedBy(x: 0.5, y: 0.5).rotated(by: CGFloat.pi).translatedBy(x: -0.5, y: -0.5)

        let point1 = CGPoint(x: CGFloat(0.143), y: CGFloat(0.211))
        let point2 = CGPoint(x: CGFloat(0.636), y: CGFloat(0.211))
        let controlPoint3 = CGPoint(x: CGFloat(0.355), y: CGFloat(-0.211))
        let controlPoint4 = CGPoint(x: CGFloat(0.5), y: CGFloat(0.423))
        let point5 = point1.applying(mirrorAroundCenter)
        let controlPoint6 = CGPoint(x: CGFloat(0.84), y: CGFloat(-0.152))
        let controlPoint7 = CGPoint(x: CGFloat(1.0), y: CGFloat(0.542))
        let point8 = point2.applying(mirrorAroundCenter)
        let controlPoint9 = controlPoint3.applying(mirrorAroundCenter)
        let controlPoint10 = controlPoint4.applying(mirrorAroundCenter)
        let point11 = point1
        let controlPoint12 = controlPoint6.applying(mirrorAroundCenter)
        let controlPoint13 = controlPoint7.applying(mirrorAroundCenter)

        path.move(to: frame.mappedPointFrom(normalized: point1))
        path.addCurve(to: frame.mappedPointFrom(normalized: point2),
            controlPoint1: frame.mappedPointFrom(normalized: controlPoint3),
            controlPoint2: frame.mappedPointFrom(normalized: controlPoint4))
        path.addCurve(to: frame.mappedPointFrom(normalized: point5),
            controlPoint1: frame.mappedPointFrom(normalized: controlPoint6),
            controlPoint2: frame.mappedPointFrom(normalized: controlPoint7))
        path.addCurve(to: frame.mappedPointFrom(normalized: point8),
            controlPoint1: frame.mappedPointFrom(normalized: controlPoint9),
            controlPoint2: frame.mappedPointFrom(normalized: controlPoint10))
        path.addCurve(to: frame.mappedPointFrom(normalized: point11),
            controlPoint1: frame.mappedPointFrom(normalized: controlPoint12),
            controlPoint2: frame.mappedPointFrom(normalized: controlPoint13))
        path.close()
    }

    private func hatchShape(_ path: UIBezierPath) {
        path.addClip()
        path.lineWidth = Constants.hatchStrokeWidth
        for horizontalStep in stride(from: 0, to: layer.bounds.width, by: Constants.hatchStep) {
            path.move(to: CGPoint(x: CGFloat(horizontalStep), y: CGFloat(0.0)))
            path.addLine(to: CGPoint(x: CGFloat(horizontalStep), y: CGFloat(layer.bounds.height)))
        }
        path.stroke()
    }
}

extension ShapeView {
    struct Constants {
        static let symbolInsetsRatio: CGFloat = 1 / 20
        static let symbolStrokeWidthToSymbolHeight: CGFloat = 1 / 10
        static let hatchStep: CGFloat = 6
        static let hatchStrokeWidth: CGFloat = 3
    }
}

enum FillType: Int {
    case stroke = 0
    case fill = 1
    case hatch = 2
}

enum ShapeType: Int {
    case rhombus = 0
    case oval = 1
    case squiggle = 2
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
extension CGRect {
    func mappedPointFrom(normalized point: CGPoint) -> CGPoint {
        let x = 0 + point.x * self.width
        let y = 0 + point.y * self.height
        return CGPoint(x: x, y: y)
    }
}
