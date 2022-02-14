//
//  TreeScene.swift
//  RedBlackTreeTool
//
//  Created by Erik Spooner on 2022-02-11.
//

import SpriteKit
import GameplayKit

class TreeScene: SKScene
{
  
  private var treeNode : SKShapeNode?
  private var connectionNode : SKShapeNode?
  
  private var nodeRadius : CGFloat = 75
  private var baseLength : CGFloat = 100
  
  
  override func didMove(to view: SKView) {
    treeNode = SKShapeNode.init(circleOfRadius: nodeRadius)
    if let n = treeNode {
      n.fillColor = .clear
      n.strokeColor = .black
      n.lineWidth = 0.03
    }
    
    
    
    connectionNode = SKShapeNode()
    var pathToDraw = CGMutablePath()
    pathToDraw.move(to: CGPoint(x: 0, y: 0))
    pathToDraw.addLine(to: CGPoint(x: 0, y: baseLength))
    connectionNode!.path = pathToDraw
    connectionNode!.strokeColor = .black
    
    connectionNode!.zRotation = .pi
    
    addChild(connectionNode!)

    if let n = treeNode?.copy() as! SKShapeNode? {
      self.addChild(n)
      
      let label = SKLabelNode(text: "nil")
      label.fontColor = .black
      label.fontSize = 50
      label.position = CGPoint(x: 0, y: -15)
      
      n.addChild(label)
      
    }
  }
  
  
  func touchDown(atPoint pos : CGPoint) {
  }
  
  func touchMoved(toPoint pos : CGPoint) {
  }
  
  func touchUp(atPoint pos : CGPoint) {
  }
  
  override func mouseDown(with event: NSEvent) {
  }
  
  override func mouseDragged(with event: NSEvent) {
  }
  
  override func mouseUp(with event: NSEvent) {
  }
  
  override func keyDown(with event: NSEvent) {
    switch event.keyCode {
    case 0x31:
      print("Space")
      break
      
    default:
      print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
    }
  }
  
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
  }
}
