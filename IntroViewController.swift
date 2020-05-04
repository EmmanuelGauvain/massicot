//
//  IntroViewController.swift
//  Massicot
//
//  Created by vaneffen on 13/06/2015.
//  Copyright (c) 2015 EMG. All rights reserved.
//


import UIKit
import SpriteKit



class IntroViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var choixFait = "choix"
    let globalBouton = UIButton(type: UIButtonType.System)
    var imageViewhaut1 = UIImageView(frame: CGRectMake(26, 66, 180, 360));
    var imageViewhaut2 = UIImageView(frame: CGRectMake(116, 66, 180, 360));
    let boutonA = UIButton(type: UIButtonType.System)
    let boutonB = UIButton(type: UIButtonType.System)
    let boutonC = UIButton(type: UIButtonType.System)
    var imageViewFond = UIImageView(frame: CGRectMake(10, 10, 340, 490));
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
    }
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func boutonDepart(sender: UIButton) {
            let gruuok:GameViewController = GameViewController(nibName: nil, bundle: nil)
            self.presentViewController(gruuok, animated: true, completion: nil)
    }
    
    func gameIntro() {
        
    
        
        
    }
    
    
    func gameBegin() {
        
        
    }
    
    func boutonTouche(sender:UIButton!)
    {
    }


    @IBAction func didTap(sender: UITapGestureRecognizer) {
        
        
    }
    
    @IBOutlet weak var boutona: UIButton!
    
    @IBOutlet weak var boutonb: UIButton!
    
    @IBOutlet weak var boutonc: UIButton!
    
    
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
    }
    
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        
    }
    

    
    
    // #2

}

