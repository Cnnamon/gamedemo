//
//  ViewController.swift
//  catch me
//
//  Created by Tautvydas Stakėnas on 3/4/15.
//  Copyright (c) 2015 Tautvydas Stakėnas. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    
    
    @IBOutlet weak var randomView: SKView!
    var gameScene: GameScene!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        randomView.showsFPS = true
        randomView.showsNodeCount = true
        randomView.showsPhysics = true
        randomView.multipleTouchEnabled = true
        
        gameScene = GameScene(size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
        gameScene.scaleMode = .ResizeFill
        randomView.presentScene(gameScene)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }


}

