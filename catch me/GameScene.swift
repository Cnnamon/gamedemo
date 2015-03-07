//
//  GameScene.swift
//  catch me
//
//  Created by Tautvydas Stakėnas on 3/7/15.
//  Copyright (c) 2015 Tautvydas Stakėnas. All rights reserved.
//

import Foundation
import SpriteKit


public class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let None         : UInt32 = 0
        static let All          : UInt32 = UInt32.max
        static let Ground       : UInt32 = 0b1       // 1
        static let Hero         : UInt32 = 0b10      // 2
    }
    
    let heroSprite = SKSpriteNode(imageNamed: "Hero.png")
    
    var groundArray = [SKSpriteNode]()
    
    var moveToRight = false
    var moveToLeft = false
    var stopMove = false
    
    public override func didMoveToView(view: SKView) {
        
        view.showsPhysics = true
        scaleMode = .ResizeFill
        createHero(view)
        
        for(var i = 0; i < 10; i++) {
            var ground = SKSpriteNode(imageNamed: "Ground.png")
            createGround(ground, view: view)
            groundArray += [ground]
            addChild(ground)
        }
        
        physicsWorld.gravity = CGVectorMake(0, -2)
        physicsWorld.contactDelegate = self
        addChild(heroSprite)
        
        
    }
    
    public override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        var touch = touches.anyObject() as UITouch!
        var touchLocation = touch.locationInNode(self)
        
        if touchLocation.x > self.frame.width/2 {
            moveToRight = true
        }else{
            moveToLeft = true
        }
        
    }
    
    public override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
       stopMove = true
    }
    
    public override func update(currentTime: NSTimeInterval) {
        if stopMove {
            stopMove = false
            moveToRight = false
            moveToLeft = false
        }
        
        if(moveToLeft){
            heroSprite.position = CGPoint(x: heroSprite.position.x - 2, y: heroSprite.position.y)
        }else if(moveToRight){
            heroSprite.position = CGPoint(x: heroSprite.position.x + 1, y: heroSprite.position.y)
        }
    }
    
    private func createHero(view: SKView){
        
        //size = imagesize
        heroSprite.position = CGPoint(x: view.frame.width / 2, y: 200)
        heroSprite.physicsBody = SKPhysicsBody(rectangleOfSize: heroSprite.size/*, center: CGPoint(x: -heroSprite.frame.width/16, y: -heroSprite.frame.height/16)*/)
        heroSprite.physicsBody?.dynamic = true
        heroSprite.physicsBody?.categoryBitMask = PhysicsCategory.Hero
        heroSprite.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        
    }
    
    private func createGround(ground: SKSpriteNode, view: SKView){
        
        //size = imagesize
        ground.anchorPoint = CGPoint(x: 0, y: 0)
        ground.position = CGPoint(x: 70*groundArray.count, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.frame.size, center: CGPoint(x: ground.frame.width / 2, y: ground.frame.height / 2))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        //ground.physicsBody?.collisionBitMask = PhysicsCategory.None
        
    }
    
    
    
}