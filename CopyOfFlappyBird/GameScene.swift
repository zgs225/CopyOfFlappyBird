//
//  GameScene.swift
//  CopyOfFlappyBird
//
//  Created by Yuez on 14/6/10.
//  Copyright (c) 2014年 yuez.me. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var bird: SKSpriteNode!
    var skyColor: SKColor!
    var pipeTextureUp: SKTexture!
    var pipeTextureDown: SKTexture!
    var movePipesAndRemove: SKAction!
    
    override func didMoveToView(view: SKView) {
        // set physics
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0)
        
        // set background color
        skyColor = SKColor(red: 81.0/255, green: 192.0/255, blue: 201.0/255, alpha: 1.0)
        self.backgroundColor = skyColor
        
        // set ground
        let groundTexture = SKTexture(imageNamed: "land")
        groundTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let moveGroundSprite = SKAction.moveByX(-groundTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.02 * groundTexture.size().width * 2.0))
        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0)
        let moveGroundForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite, resetGroundSprite]))
        
        for var i: CGFloat = 0; i < 2.0 + self.frame.size.width / (groundTexture.size().width * 2.0); ++i {
            let sprite = SKSpriteNode(texture: groundTexture)
            sprite.setScale(2.0)
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0)
            sprite.runAction(moveGroundForever)
            self.addChild(sprite)
        }
        
        // create the ground
        var ground = SKNode()
        ground.position = CGPointMake(0.0, groundTexture.size().height)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, groundTexture.size().height * 2.0))
        ground.physicsBody.dynamic = false
        self.addChild(ground)
        
        // set skyline
        let skyTexture = SKTexture(imageNamed: "sky")
        skyTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let moveSkySprite = SKAction.moveByX(-skyTexture.size().width * 2.0, y: 0, duration: NSTimeInterval(0.01 * skyTexture.size().width * 2.0))
        let resetSkySprite = SKAction.moveByX(skyTexture.size().width * 2.0, y: 0, duration: 0)
        let moveSkyForever = SKAction.repeatActionForever(SKAction.sequence([moveSkySprite, resetSkySprite]))
        
        for var i: CGFloat = 0; i < 2.0 + self.frame.size.width / (skyTexture.size().width * 2.0); ++i {
            let sprite = SKSpriteNode(texture: skyTexture)
            sprite.setScale(2.0)
            sprite.zPosition = -20
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2.0 + groundTexture.size().height * 2.0)
            sprite.runAction(moveSkyForever)
            self.addChild(sprite)
        }
        
        // create the pipes textures
        pipeTextureUp = SKTexture(imageNamed: "PipeUp")
        pipeTextureDown = SKTexture(imageNamed: "PipeDown")
        pipeTextureUp.filteringMode = SKTextureFilteringMode.Nearest
        pipeTextureDown.filteringMode = SKTextureFilteringMode.Nearest
        
        // create the pipes movement actions
        let distanceToMove = CGFloat(self.frame.size.width + pipeTextureUp.size().width * 2.0)
        let movePipes = SKAction.moveByX(-distanceToMove, y: 0, duration: NSTimeInterval(0.01 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes])
        
        // spawn pipes
        let spawn = SKAction.runBlock({ () in self.spawnPipes() })
        let delay = SKAction.waitForDuration(NSTimeInterval(2.0))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
        
        // setup birds
        let birdTexture1 = SKTexture(imageNamed: "Bird-01")
        let birdTexture2 = SKTexture(imageNamed: "Bird-02")
        birdTexture1.filteringMode = SKTextureFilteringMode.Nearest
        birdTexture2.filteringMode = SKTextureFilteringMode.Nearest
        
        let anim = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.2)
        let flap = SKAction.repeatActionForever(anim)
        
        bird = SKSpriteNode(texture: birdTexture1)
        bird.setScale(2.0)
        bird.position = CGPointMake(self.frame.size.width * 0.35, self.frame.size.height * 0.6)
        bird.runAction(flap)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        bird.physicsBody.dynamic = true
        bird.physicsBody.allowsRotation = false
    
        self.addChild(bird)
    }
    
    func spawnPipes() {
        let pipePair = SKNode()
        let verticalPipeGap = 150
        pipePair.position = CGPointMake(self.frame.size.width + pipeTextureUp.size().width * 2.0, 0)
        pipePair.zPosition = -10
        
        let height = UInt32(self.frame.size.height / 4)
        let y = arc4random() % height + height
        
        func spawnPipe(texture: SKTexture, position: CGPoint) -> SKSpriteNode {
            let pipe = SKSpriteNode(texture: texture)
            pipe.setScale(2.0)
            pipe.position = position
            pipe.physicsBody = SKPhysicsBody(rectangleOfSize: pipe.size)
            pipe.physicsBody.dynamic = false
            return pipe
        }
        
        let pipeDown = spawnPipe(pipeTextureDown, CGPointMake(0.0, CGFloat(y) + pipeTextureDown.size().height * 2.0 + CGFloat(verticalPipeGap)))
        let pipeUp   = spawnPipe(pipeTextureUp, CGPointMake(0.0, CGFloat(y)))
        pipePair.addChild(pipeDown)
        pipePair.addChild(pipeUp)
        
        pipePair.runAction(movePipesAndRemove)
        self.addChild(pipePair)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            bird.physicsBody.velocity = CGVectorMake(0, 0)
            bird.physicsBody.applyImpulse(CGVectorMake(0, 30))
        }
    }
    
    func clamp(min: CGFloat, max: CGFloat, value: CGFloat) -> CGFloat {
        if( value > max ) {
            return max
        } else if( value < min ) {
            return min
        } else {
            return value
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        bird.zRotation = self.clamp(-1, max: 0.5, value: bird.physicsBody.velocity.dy * (bird.physicsBody.velocity.dy < 0 ? 0.003 : 0.001))
    }
}
