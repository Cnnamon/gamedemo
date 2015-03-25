//
//  GameScene.swift
//  catch me
//
//  Created by Tautvydas Stakėnas on 3/7/15.
//  Copyright (c) 2015 Tautvydas Stakėnas. All rights reserved.
//

import Foundation
import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // ALL the collisions types
    struct PhysicsCategory {
        static let None         : UInt32 = 0
        static let All          : UInt32 = UInt32.max
        static let Ground       : UInt32 = 0b1       // 1
        static let Hero         : UInt32 = 0b10      // 2
        static let Bomb         : UInt32 = 0b100     // 4
    }
    
    struct ShadowCategory {
        static let None         : UInt32 = 0
        static let All          : UInt32 = UInt32.max
        static let Ground       : UInt32 = 0b1       // 1
        static let Hero         : UInt32 = 0b10      // 2
    }
    
    struct HeroStats {
        static var Shield               : Int = 0   //time left on shield (or block hits)
        static var Lifes                : Int = 1   //change in function
        static var ExplosionTime        : Int = 0
        static var ExplosionTimeDelay   : Int = 0
        static var BombPower            : Int = 0
        static var BombsCount           : Int = 0
    }
    
    // Main character
    let heroImage = SKTexture(imageNamed: "Hero.png")
    var heroSprite : SKSpriteNode!
    // Background
    var backgroundImagesArray = [SKTexture]()
    var backgroundArray = [SKSpriteNode]()
    // Terrain
    var groundArray = [SKSpriteNode]()
    // Bomb
    let bombImage = SKTexture(imageNamed: "Bomb.png")
    var bombSprite : SKSpriteNode!
    // Moving and jumping objects
    var moveToRight = false
    var moveToLeft = false
    var stopMove = false
    var prepareToJump = false
    var jump = false
    // Image mirroring
    var right = false
    // Indicator letting/banning from moving
    var colliding = 0
    // Flag indicating whether we've setup the camera system yet.
    var isCreated: Bool = false
    // The root node of your game world. Attach game entities
    // (player, enemies, &c.) to here.
    var world: SKNode?
    // The root node of our UI. Attach control buttons & state
    // indicators here.
    var overlay: SKNode?
    // The camera. Move this node to change what parts of the world are visible.
    var camera: SKNode?
    // Generated World coordinates to
    var generatedWorldToX: Int = 0
    var generatedWorldToY: Int = 0
    // Generated World coordinates from
    var generatedWorldFromX: Int = 0
    var generatedWorldFromY: Int = 0
    // Light for hero
    var light = SKLightNode()
    // Emiter for hero
    var emiter = SKEmitterNode()
    // Skaitiklis kiek bombu padeta
    var bombsCounter: Int = 0
    
    override func didMoveToView(view: SKView) {
        
        if !isCreated {
            
            isCreated = true
            
            //camera setup
            
            self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.world = SKNode()
            self.world?.name = "world"
            addChild(self.world!)
            self.camera = SKNode()
            self.camera?.name = "camera"
            self.world?.addChild(self.camera!)
            
            //ui setup
            self.overlay = SKNode()
            self.overlay?.name = "overlay"
            self.overlay?.zPosition = 10
            addChild(overlay!)
            
            //gravity
            physicsWorld.gravity = CGVectorMake(0, -5)
            
            //contact delegate class
            physicsWorld.contactDelegate = self
            
            //creating ground
            for(var i = 0; i < 100; i++) {
                var ground = SKSpriteNode(imageNamed: "Ground.png")
                ground.xScale = 0.5
                ground.yScale = 0.1
                createGround(ground, view: view)
                ground.shadowCastBitMask = ShadowCategory.Ground
                ground.zPosition = 1
                groundArray += [ground]
                world!.addChild(ground)
            }
            
            // creating main character
            createHero(view)
            setHeroStats()
            createLight(view)
            heroSprite?.addChild(light)
            world!.addChild(heroSprite!)
            
            // background color
            self.backgroundColor = UIColor.blackColor()
            
            // background images added to array
            for(var i = 0; i<5; i++){
                let imageText = "Background-\(i).png"
                let image = SKTexture(imageNamed: imageText)
                backgroundImagesArray += [image]
            }
            
            createBackground(view)
            
            //creating light for character
            
            
        }
    }
    
    func setHeroStats(){
        HeroStats.ExplosionTimeDelay = 5
        HeroStats.Lifes = 3
        HeroStats.BombsCount = 1
        HeroStats.ExplosionTime = 1
        HeroStats.BombPower = 1
    }
    
    func createBackground(view: SKView){
        
        let count = (UInt32)(backgroundImagesArray.count)
        
        let imageLengh = backgroundImagesArray[0].size().width
        let imageHeight = backgroundImagesArray[0].size().height
        
        var imageNumber = Int(arc4random_uniform(count))
        
        
        
        let maxX = heroSprite!.position.x + self.frame.width
        let minX = heroSprite!.position.x - self.frame.width
        let maxY = heroSprite!.position.y + self.frame.height
        let minY = heroSprite!.position.y - self.frame.height
        
        var collumn = Int (((maxX - minX) + imageLengh/2) / imageLengh)
        var row = Int ((maxY - minY) / imageHeight)
        
        for(var i = 0 ; i<row; i++){
            let index = imageLengh / 2
            for(var j = 0; j<collumn; j++){
                var imageNumber = Int(arc4random_uniform(count))
                var brick = SKSpriteNode(texture: backgroundImagesArray[imageNumber])
                if(j % 2 == 0){
                    brick.position.x = minX + (CGFloat(i) * imageLengh) + CGFloat(index)
                }else{
                    brick.position.x = minX + (CGFloat(i) * imageLengh)
                }
                brick.position.y = minY + CGFloat   (j) * imageHeight
                brick.zPosition = 0
                backgroundArray.append(brick)
            }
        }
        for (var i = 0 ; i<backgroundArray.count; i++){
            world!.addChild(backgroundArray[i])
        }
    }
    
    override func didSimulatePhysics() {
        
        if self.camera != nil {
            self.centerOnNode(self.camera!)
        }
        
    }
    
    func centerOnNode(node: SKNode) {
       
        let nodeScene = node.scene!
        let nodeParent = node.parent!
        let positionNew = nodeScene.convertPoint(node.position, fromNode: nodeParent)
        node.parent?.position = CGPoint(x: nodeParent.position.x - positionNew.x, y: nodeParent.position.y - positionNew.y)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        var touch = touches.anyObject() as UITouch!
        var touchLocation = touch.locationInNode(self)
        let x = countNormalx()
        let y = countNormaly()
        let heroHalfWidth = heroSprite.frame.width / 2
        let heroHalfHeight = heroSprite.frame.height / 2
        
        if(touchLocation.x > x - heroHalfWidth && touchLocation.x < x + heroHalfWidth && touchLocation.y > y - heroHalfHeight && touchLocation.y < y + heroHalfHeight){
            if(HeroStats.BombsCount > bombsCounter){
                dropBomb(heroSprite.position.x, y: heroSprite.position.y)
                bombsCounter++
            }
        }else{
            if touchLocation.x > x {
                moveToRight = true
            } else {
                moveToLeft = true
            }
            if touchLocation.y < y {
                prepareToJump = true
            }
        }
        
    }
    
    func dropBomb(x: CGFloat, y: CGFloat){
        var explosionEmitter = SKEmitterNode(fileNamed: "ExplosionFire.sks")
        var sparkingEmitter = SKEmitterNode(fileNamed: "SparkParticle.sks")
        
        bombSprite = SKSpriteNode(texture: bombImage)
        bombSprite.position.x = x
        bombSprite.position.y = y
        bombSprite.xScale = 0.5
        bombSprite.yScale = 0.5
        bombSprite!.physicsBody = SKPhysicsBody(rectangleOfSize: bombSprite!.size)
        bombSprite.physicsBody?.categoryBitMask = PhysicsCategory.Bomb
        bombSprite.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Bomb
        bombSprite.zPosition = 1
        bombSprite.physicsBody?.dynamic = true
        
        bombSprite.addChild(sparkingEmitter)
        let timeDelay = NSTimeInterval(HeroStats.ExplosionTimeDelay)
        let timeExploding = NSTimeInterval(HeroStats.ExplosionTime)
        bombSprite.runAction(SKAction.waitForDuration(timeDelay), completion: {
            sparkingEmitter.removeFromParent()
            explosionEmitter.position = self.bombSprite.position
            self.world!.addChild(explosionEmitter)
            self.bombSprite.removeFromParent()
            self.bombsCounter--
            self.world!.runAction(SKAction.waitForDuration(timeExploding), completion: {
                explosionEmitter.removeFromParent()
            })
        })
        world!.addChild(bombSprite)
        
    }
    
    func countNormalx() -> CGFloat { // count where in screen (not world) hero is (x axis)
        let herox = heroSprite?.position.x
        let camerax = self.camera?.position.x
        var normalx:CGFloat = camerax! - herox!
        return normalx
    }
    
    func countNormaly() -> CGFloat { // count where in screen (not world) hero is (y axis)
        let heroy = heroSprite?.position.y
        let cameray = self.camera?.position.y
        var normaly:CGFloat = cameray! - heroy!
        return normaly
    }
    
    func generateGround(){
        
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        stopMove = true
        
        var touch = [touches.anyObject() as UITouch!]
        var touchLocation = touch[0].locationInNode(self)
        
        let y = countNormaly()
        if prepareToJump && touchLocation.y > y {
            jump = true
        }
        
        prepareToJump = false
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        
        generateGround()
        
        if stopMove {
            
            stopMove = false
            moveToRight = false
            moveToLeft = false
            
        }
        
        if colliding != 0 {
            if moveToLeft {
                
                if right {
                    heroSprite!.xScale = heroSprite!.xScale * -1;
                    right = false
                }
                
                heroSprite!.position = CGPoint(x: heroSprite!.position.x - 5, y: heroSprite!.position.y)
                
                if jump {
                    jump = false
                    heroSprite!.physicsBody?.applyImpulse(CGVector(dx: -5, dy: 20))
                }
                
            } else if moveToRight {
                
                if !right {
                    heroSprite!.xScale = heroSprite!.xScale * -1;
                    right = true
                }
                
                heroSprite!.position = CGPoint(x: heroSprite!.position.x + 5, y: heroSprite!.position.y)
                
                if jump {
                    
                    jump = false
                    heroSprite!.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 20))
                    
                }
            }
        }
        
        let x = heroSprite!.position.x
        let y = heroSprite!.position.y
        
        if camera != nil {
            self.camera?.runAction(SKAction.moveTo(CGPointMake(x, y), duration: 0))
            //println(camera!.position.x)
        }
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
    
        if contact.bodyA.categoryBitMask == PhysicsCategory.Ground && contact.bodyB.categoryBitMask == PhysicsCategory.Hero {
            colliding++
        }
        
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == PhysicsCategory.Ground && contact.bodyB.categoryBitMask == PhysicsCategory.Hero {
            colliding--
        }
        
    }
    
    func createHero(view: SKView){
        
        //size = imagesize
        heroSprite = SKSpriteNode(texture: heroImage)
        heroSprite!.position = CGPoint(x: 300, y: 200)
        heroSprite!.physicsBody = SKPhysicsBody(rectangleOfSize: heroSprite!.size/*, center: CGPoint(x: -heroSprite.frame.width/16, y: -heroSprite.frame.height/16)*/)
        heroSprite!.physicsBody?.dynamic = true
        heroSprite!.physicsBody?.categoryBitMask = PhysicsCategory.Hero
        heroSprite!.physicsBody?.collisionBitMask = PhysicsCategory.Ground
        heroSprite!.zPosition = 1
        heroSprite!.xScale = heroSprite!.xScale * -1; // image apsukimas
        heroSprite!.physicsBody?.allowsRotation = false
        
    }
    
    func createGround(ground: SKSpriteNode, view: SKView){
        
        //size = imagesize
        ground.anchorPoint = CGPoint(x: 0, y: 0)
        var groundWidth: CGFloat = CGFloat (ground.frame.width)
        groundWidth = groundWidth * ground.xScale
        ground.position = CGPoint(x: Int(groundWidth) * groundArray.count, y: 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.frame.size, center: CGPoint(x: ground.frame.width / 2, y: ground.frame.height / 2))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.All
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
        ground.physicsBody?.affectedByGravity = false
        ground.zPosition = 1
        //ground.physicsBody?.pinned = true
        ground.physicsBody?.allowsRotation = false
        ground.shadowCastBitMask = ShadowCategory.All
        
    }
    
    func createLight(view: SKView){
        
        light = SKLightNode()
        light.categoryBitMask = ShadowCategory.Ground
        light.ambientColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
        light.lightColor = UIColor(red: 1.0, green: 1.0, blue: 0.1, alpha: 1)
        light.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7)
        light.enabled = true
        light.falloff = 1
        
    }
    
    
}