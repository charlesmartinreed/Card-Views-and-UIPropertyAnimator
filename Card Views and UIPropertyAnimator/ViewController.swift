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
        
        //define gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(_:)))
        
        cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
    }
    

    //MARK:- Gesture handling
    @objc func handleCardTap(_ recognizer: UITapGestureRecognizer) {
        
    }
    
    @objc func handleCardPan(_ recognizer: UIPanGestureRecognizer) {
        //pan gesture recognizer has multiple states
        switch recognizer.state {
        case .began:
            //placed finger
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            //moved finger
            let translation = recognizer.translation(in: self.cardViewController.handleArea)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = isCardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            //lifted finger
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    //MARK:- Animation creation
    func animateTransationIfNeeded(state: CardState, duration: TimeInterval) {
        //called if animation is needed, like if runningAnimation arraya is empty
        
        if runningAnimations.isEmpty {
            //animating card height for cardViewController
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                //move card view up or down
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                }
            }
            
            //if card has been moved all the way up or down...
            frameAnimator.addCompletion { (_) in
                self.isCardVisible = !self.isCardVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            //animating corner radius for cardViewController
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.cardViewController.view.layer.cornerRadius = 12
                case .collapsed:
                    self.cardViewController.view.layer.cornerRadius = 0
                }
            }
            
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            //animating blur for view controller
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    self.visualEffectView.effect = nil
                }
            }
            
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
        }
    }
    
    //MARK:- Animation state handling
    func startInteractiveTransition(state: CardState, duration:TimeInterval) {
        //check if we currently have animations
        if runningAnimations.isEmpty {
            //no? Then, run animations.
            animateTransationIfNeeded(state: state, duration: duration)
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation() //set speed to 0, which makes them interactable
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted: CGFloat) {
        //update fraction complete for all animations
        for animator in runningAnimations {
            //moving finger up or down - this keeps all of our animations in the same state while we move across the screen
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition() {
        //setting params to 0 means the property animator uses the remaining time in our animations
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
   

}
