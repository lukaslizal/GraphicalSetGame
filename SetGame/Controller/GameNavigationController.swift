//
//  GameNavigationController.swift
//  SetGame
//
//  Created by Lukas on 26/08/2019.
//  Copyright © 2019 Lukas Lizal. All rights reserved.
//

import UIKit

class GameNavigationController: UINavigationController { //, UINavigationControllerDelegate {
    
    private var gameMVC: GraphicalSetViewController?
    
    // 1
    static private var coordinatorHelperKey = "UINavigationController.TransitionCoordinatorHelper"
    
    func addCustomTransitioning() {
//        // 3
//        var object = objc_getAssociatedObject(self, &GameNavigationController.coordinatorHelperKey)
//
//        guard object == nil else {
//            return
//        }
//
//        object = self
//
//        let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
//        objc_setAssociatedObject(self, &GameNavigationController.coordinatorHelperKey, object, nonatomic)
//
//        // 4
//        delegate = object as? UINavigationControllerDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        delegate = self
        addCustomTransitioning()
        // Do any additional setup after loading the view.
    }
    
//    internal func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        return transitionAnimator
//    }
//
//    // MARK: CUSTOM TRANSITIONING
//
//    func animationController(
//        forPresented presented: UIViewController,
//        presenting: UIViewController, source: UIViewController)
//        -> UIViewControllerAnimatedTransitioning? {
//            return transitionAnimator
//    }
//
//    func animationController(forDismissed dismissed: UIViewController)
//        -> UIViewControllerAnimatedTransitioning? {
//            return nil
//    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let menuViewController = segue.destination as? MenuViewController {
//            if let graphicalViewController = segue.source as? GraphicalSetViewController {
//                gameMVC = graphicalViewController
//            }
//            let menuMVC = segue.destination
//            menuMVC.transitioningDelegate = self
//        }
//        else if let graphicalViewController = segue.destination as? GraphicalSetViewController {
//            let menuMVC = graphicalViewController
//            menuMVC.transitioningDelegate = self
//        }
    }
}
