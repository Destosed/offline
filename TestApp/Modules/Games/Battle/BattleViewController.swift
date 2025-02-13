//
//  BattleViewController.swift
//  TestApp
//
//  Created by Никита Лужбин on 26.10.2024.
//

import UIKit
import SpriteKit
import Lottie

enum BattleActions {
    case stay
    case attack
}

final class BattleViewController: UIViewController {

    private let lottieView = LottieAnimationView()
    
    private var sceneView: SKView!
    private var mainScene: BattleScene!

    private var isLandscape: Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .white
        
        lottieView.backgroundColor = .white
        lottieView.animation = .named("rotate_animation")
        lottieView.animationSpeed = 1
        lottieView.isHidden = isLandscape
        lottieView.loopMode = .loop
        if !isLandscape { lottieView.play() }
        
        let screenSize = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        let sceneSize = CGSize(width: screenSize.width * scale, height: screenSize.height * scale)
        
        // Set the scene size
        mainScene = BattleScene(size: sceneSize)
        sceneView = .init()
        
        view.addSubview(sceneView)
        view.addSubview(lottieView)
        
        lottieView.autoPinEdgesToSuperviewEdges()
        sceneView.autoPinEdgesToSuperviewEdges()
        
        sceneView.presentScene(mainScene)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        guard UIDevice.current.orientation.isLandscape else {
            lottieView.isHidden = false
            lottieView.play()

            return
        }

        lottieView.isHidden = true
        lottieView.stop()
    }
}

enum BattleAction: String {
    case stay
    case run
    case attack
    case die
    case block
}

final class SwordsmanNode: SKSpriteNode {
    
    // MARK: - Properties
    
    private let isPlayer: Bool
    private let maxHealth: Int
    private(set) var health: Int
    private let damage: Int

    private var healthBar: SKSpriteNode!
    
    // MARK: - Init
    
    init(isPlayer: Bool, health: Int, damage: Int) {
        self.isPlayer = isPlayer
        self.health = health
        self.maxHealth = health
        self.damage = damage
        
        let swordsmen = isPlayer ? "A" : "B"
        let atlas = SKTextureAtlas(named: "Swordsmen_\(swordsmen)")
        let initialTexture = atlas.textureNamed("swordsmen_\(swordsmen)_stay_1")
        
        super.init(texture: initialTexture, color: .green, size: .init(width: 400, height: 400))
        
        drawSelf()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Drawnings
    
    private func drawSelf() {
        texture = getTextures(for: .stay).first!
        addHealthBar()

//        run(SKAction.repeatForever(SKAction.animate(with: getTextures(for: .stay), timePerFrame: 0.25)))
    }

    // MARK: - Private Methods
    
    private func addHealthBar() {
        let healthBarBackground = SKSpriteNode(color: .red, size: CGSize(width: 130, height: 20))
        healthBarBackground.position = CGPoint(x: frame.midX - 70, y: frame.midY + 80)
        healthBarBackground.zPosition = 1
        healthBarBackground.anchorPoint = CGPoint(x: 0, y: 0.5)
        addChild(healthBarBackground)
        
        healthBar = SKSpriteNode(color: .green, size: CGSize(width: 130, height: 20))
        healthBar.position = CGPoint(x: frame.midX - 70, y: frame.midY + 80)
        healthBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthBar.zPosition = 2
        addChild(healthBar)
    }
        
    // Method to update the health bar based on the current health
    func updateHealth(newHealth: Int) {
        health = max(0, min(newHealth, maxHealth))  // Clamp health between 0 and maxHealth
        
        // Update health bar width based on the percentage of health remaining
        let healthPercentage = CGFloat(health) / CGFloat(maxHealth)
        healthBar.size.width = size.width * 0.3 * healthPercentage
    }

    // MARK: - Public Methods

    func getTextures(for action: BattleAction) -> [SKTexture] {
        let swordsmen = isPlayer ? "A" : "B"
        let atlas = SKTextureAtlas(named: "Swordsmen_\(swordsmen)")

        var textures: [SKTexture] = []

        var index = 1
        while true {
            let texture = atlas.textureNamed("swordsmen_\(swordsmen)_\(action.rawValue)_\(index)")
            
            if String(describing: texture).contains("'MissingResource.png'") {
                break
            } else {
                textures.append(texture)
                index += 1
            }
        }
        
        return textures
    }

    func attack(enemy: SwordsmanNode, completion: @escaping () -> Void) {
        let initialPos = position
        
        removeAllActions()

        let moveAction = SKAction.move(
            to: CGPoint(
                x: isPlayer ? enemy.position.x - 140 : enemy.position.x + 140,
                y: enemy.position.y),
            duration: 1.5
        )
        let runAction = SKAction.animate(with: getTextures(for: .run), timePerFrame: 1.5 / 10)
        
        let attackAction = SKAction.animate(with: getTextures(for: .attack), timePerFrame: 0.05)
        let dieAction = SKAction.animate(with: enemy.getTextures(for: .die), timePerFrame: 0.55)

        let runAndMoveActionGroup = SKAction.group([runAction, moveAction])
        let runAndAttackActionSequence = SKAction.sequence([
            runAndMoveActionGroup,
            SKAction.group([
                attackAction,
                SKAction.run { enemy.run(SKAction.animate(with: enemy.getTextures(for: .block),
                                                          timePerFrame: 0.1)) }])
        ])

        let turnAroundAction = SKAction.scaleX(to: -1, y: 1, duration: 0.25)
        let rumBackAction = SKAction.animate(with: getTextures(for: .run), timePerFrame: 1.5 / 10)
        let moveBackAction = SKAction.move(to: initialPos, duration: 1.5)
        
        let finallyRotateAction = SKAction.scaleX(to: 1, y: 1, duration: 0.25)

        let runAndMoveBackActionGroup = SKAction.group([rumBackAction, moveBackAction])
        
        run(
            SKAction.sequence(
                [
                    runAndAttackActionSequence,
                    SKAction.run {
                        let newHealth = enemy.health - self.damage

                        if newHealth <= 0 {
                            enemy.removeAllActions()
                            enemy.run(dieAction)
                        }

                        enemy.updateHealth(newHealth: enemy.health - self.damage)
                    },
                    turnAroundAction,
                    runAndMoveBackActionGroup,
                    finallyRotateAction
                ]
            ),
            completion: completion
        )
    }
    
    func die() {
        let dieAction = SKAction.animate(with: getTextures(for: .die), timePerFrame: 0.05)
        run(dieAction)
    }
}

class BattleScene: SKScene {
    
    var swordsMenA = SwordsmanNode(isPlayer: true, health: 100, damage: 100)
    var swordsMenB = SwordsmanNode(isPlayer: false, health: 100, damage: 10)
    
    let attackControl = SKSpriteNode(texture: .init(imageNamed: "attack_icon"),
                                     size: .init(width: 100, height: 100))
    
    private func setupPlayer() {
        let background = SKSpriteNode(imageNamed: "battle_background")

        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.size = .init(width: frame.width, height: frame.height + 150)

        attackControl.position = CGPoint(x: 100, y: frame.height - 100)
        attackControl.anchorPoint = .init(x: 0, y: 1)
        attackControl.name = "ArrackControlNode"
        
        swordsMenA.position = .init(x: frame.midX - 400, y: 200)
        swordsMenB.position = .init(x: frame.midX + 400, y: 200)
        
        addChild(background)
        addChild(attackControl)
        addChild(swordsMenA)
        addChild(swordsMenB)

        swordsMenA.run(SKAction.repeatForever(SKAction.animate(with: swordsMenA.getTextures(for: .stay), timePerFrame: 0.07)))
        swordsMenB.run(SKAction.repeatForever(SKAction.animate(with: swordsMenB.getTextures(for: .stay), timePerFrame: 0.07)))
    }
        
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
            
        self.setupPlayer()
    }

    @objc private func didTapAttack() {
        swordsMenA.removeAllActions()
        swordsMenB.removeAllActions()

        swordsMenA.attack(enemy: swordsMenB) {
            if self.swordsMenB.health > 0 {
                self.swordsMenB.attack(enemy: self.swordsMenA, completion: {
                    self.swordsMenA.run(SKAction.repeatForever(SKAction.animate(with: self.swordsMenA.getTextures(for: .stay), timePerFrame: 0.25)))
                    self.swordsMenB.run(SKAction.repeatForever(SKAction.animate(with: self.swordsMenB.getTextures(for: .stay), timePerFrame: 0.25)))
                })
            } else {
                self.swordsMenA.run(SKAction.repeatForever(SKAction.animate(with: self.swordsMenA.getTextures(for: .stay), timePerFrame: 0.25)))
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard
            let touch = touches.first,
            let node = self.nodes(at: touch.location(in: self)).first
        else {
            return
        }

        if node.name == "ArrackControlNode" {
            didTapAttack()
            return
        }
    }
}
