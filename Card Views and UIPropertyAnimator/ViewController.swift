//
//  ViewController.swift
//  Card Views and UIPropertyAnimator
//
//  Created by Charles Martin Reed on 12/22/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum CardState {
        case expanded
        case collapsed
    }

    //MARK:- UIProperties
    var cardViewController: CardViewController!
    var visualEffectView: UIVisualEffectView! //used for creating the blur and animating it's intensity
    
    let cardHeight: CGFloat = 600
    let cardHandleAreaHeight: CGFloat = 65
    
    var isCardVisible = false //will be true if card is expanded, false if collapsed
    
    var nextState: CardState {
        return isCardVisible ? .collapsed : .expanded //if visible, we need to collapse the card, if not we need to expand it.
    }
    
    //MARK:- Animations
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCard()
    }
    
    func setupCard() {
        //add the blur effect
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        //init the cardViewController, add it and its view as childrend to main view controller
        cardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        //set cardViewController frame using the variables instanced above
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        cardViewController.view.clipsToBounds = true
    }
    

   

}
