//
//  ScoreView.swift
//  SetGame
//
//  Created by Lukas on 05/09/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

class ScoreView: UIView {
    var scoreBarsStack: UIStackView!
    var scoreBarViews = [UIView]()
    var maxScore: Int
    
    required init?(coder aDecoder: NSCoder) {
        maxScore = Constants.defaultMaxScore
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        maxScore = Constants.defaultMaxScore
        super.init(frame: frame)
    }
    
    init(frame: CGRect, maxScore: Int) {
        self.maxScore = maxScore
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        setupScoreView()
        setupBackgroudStripes()
    }
    
    func setupScoreView(){
        clipsToBounds = true
        scoreBarsStack = UIStackView(frame: bounds)
//        let subView = UIView(frame: bounds)
//        subView.backgroundColor = .yellow
//        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        insertSubview(subView, at: 0)
        addSubview(scoreBarsStack)
        scoreBarsStack.translatesAutoresizingMaskIntoConstraints = false
        let leadingConstraint = NSLayoutConstraint(item: scoreBarsStack!, attribute: .leading, relatedBy: .equal, toItem: scoreBarsStack.superview, attribute: .leading, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: scoreBarsStack!, attribute: .top, relatedBy: .equal, toItem: scoreBarsStack.superview, attribute: .top, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: scoreBarsStack!, attribute: .trailing, relatedBy: .equal, toItem: scoreBarsStack.superview, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: scoreBarsStack!, attribute: .bottom, relatedBy: .equal, toItem: scoreBarsStack.superview, attribute: .bottom, multiplier: 1, constant: 0)
        topConstraint.priority = .defaultHigh
        leadingConstraint.priority = .defaultHigh
        trailingConstraint.priority = .required
        bottomConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([leadingConstraint, topConstraint, trailingConstraint, bottomConstraint])
        
        scoreBarsStack.alignment = .fill
        scoreBarsStack.distribution = .fillEqually
        
        for _ in 0..<maxScore{
            let frame = CGRect(x: 0, y: 0, width: bounds.width/20, height: bounds.height)
            let view = UIView(frame: frame)
//            view.backgroundColor = index % 2 == 0 ? Constants.scoreBackgroundColorLight : Constants.scoreBackgroundColorDark
            scoreBarsStack.addArrangedSubview(view)
        }
    }
    
    func setupBackgroudStripes(){
        for index in 0..<scoreBarsStack.arrangedSubviews.count{
            let barView = scoreBarsStack.arrangedSubviews[index]
            barView.translatesAutoresizingMaskIntoConstraints = false
            barView.clipsToBounds = true
            let backgroundBar = UIView(frame: self.bounds)
            backgroundBar.backgroundColor = index % 2 == 0 ? Constants.scoreBackgroundColorLight : Constants.scoreBackgroundColorDark
            barView.addSubview(backgroundBar)
//            let heightConstraint = NSLayoutConstraint(item: backgroundBar, attribute: .height, relatedBy: .equal, toItem: backgroundBar.superview, attribute: .height, multiplier: 1, constant: 0) // CGFloat(index)*CGFloat(1)/CGFloat(index)
//            let widthConstraint = NSLayoutConstraint(item: backgroundBar, attribute: .width, relatedBy: .equal, toItem: backgroundBar.superview, attribute: .width, multiplier: 1, constant: 0)
//            let topConstraint = NSLayoutConstraint(item: backgroundBar, attribute: .top, relatedBy: .equal, toItem: backgroundBar.superview, attribute: .top, multiplier: 1, constant: 30)
//            let leadingConstraint = NSLayoutConstraint(item: backgroundBar, attribute: .leading, relatedBy: .equal, toItem: backgroundBar.superview, attribute: .leading, multiplier: 1, constant: 0)
//            let trailingConstraint = NSLayoutConstraint(item: backgroundBar, attribute: .trailing, relatedBy: .equal, toItem: backgroundBar.superview, attribute: .trailing, multiplier: 1, constant: 0)
//            let bottomConstraint = NSLayoutConstraint(item: backgroundBar, attribute: .bottom, relatedBy: .equal, toItem: backgroundBar.superview, attribute: .bottom, multiplier: 1, constant: 0)
//            heightConstraint.priority = .defaultLow
//            widthConstraint.priority = .defaultLow
//            topConstraint.priority = .defaultLow
//            leadingConstraint.priority = .defaultLow
//            trailingConstraint.priority = .defaultLow
//            bottomConstraint.priority = .defaultLow
//            NSLayoutConstraint.activate([topConstraint, leadingConstraint, trailingConstraint, bottomConstraint])
        }
    }
    
//    func setupBackgroundBars(){
//        for _ in 0..<maxScore{
//            let frame = CGRect(x: 0, y: 0, width: bounds.width/20, height: bounds.height)
//            let view = UIView(frame: frame)
//            //            view.backgroundColor = index % 2 == 0 ? Constants.scoreBackgroundColorLight : Constants.scoreBackgroundColorDark
//            scoreBarsStack.addArrangedSubview(view)
//        }
//    }
    
    func setupScoreBars(){
        
    }
    
    func recalculateScoreBarsOrientation(){
        guard let scoreBarsStack = scoreBarsStack else{
            return
        }
        if bounds.width < bounds.height{
            scoreBarsStack.axis = .vertical
        }
        else{
            scoreBarsStack.axis = .horizontal
        }
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        recalculateScoreBarsOrientation()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
