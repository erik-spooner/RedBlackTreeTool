//
//  TreeScene.swift
//  RedBlackTreeTool
//
//  Created by Erik Spooner on 2022-02-11.
//

import SpriteKit
import GameplayKit
import Combine

class TreeScene: SKScene, ObservableObject
{
  private var tree : RedBlackSKTree = RedBlackSKTree()
  private var oldTouchPoint : CGPoint = CGPoint()
  
  var play : Bool = false
  
  @Published var stepDescription = "A"
  
  var annimationRunning : Bool {
    get { return tree.animationRunning }
  }
    
  override func didMove(to view: SKView) {
    backgroundColor = .white
        
    tree.drawFromTree()
    addChild(tree)
  }
  
  func insert(key: Int) {
    _ = tree.insert(key: key)
  }
  
  func remove(key: Int) {
    _ = tree.remove(key: key)
  }
  
  func find(key: Int) {
    tree.find(key: key)
  }
  
  func next() {
    if !annimationRunning {
      let s = tree.next()
      print(s)
      stepDescription = s
      print(stepDescription)
    }
  }
  
  func previous() {
    
  }

  func touchDown(atPoint pos : CGPoint) {
    oldTouchPoint = pos
  }
  
  func touchMoved(toPoint pos : CGPoint) {
    tree.position = tree.position.applying(CGAffineTransform(translationX: pos.x - oldTouchPoint.x, y: pos.y - oldTouchPoint.y))
    
    oldTouchPoint = pos
  }
  
  func touchUp(atPoint pos : CGPoint) {
    
  }
  
  override func mouseDown(with event: NSEvent) {
    touchDown(atPoint: event.location(in: self))
  }
  
  override func mouseDragged(with event: NSEvent) {
    touchMoved(toPoint: event.location(in: self))
  }
  
  override func mouseUp(with event: NSEvent) {
  }
    
  override func keyDown(with event: NSEvent) {
    switch event.keyCode {
            
    case 0x6:
      // zoom in
      tree.setScale(tree.xScale * 1.1)
      break

    case 0x7:
      // zoom out
      tree.setScale(tree.xScale * 0.9)
      break

    case 0x31:
      // Reset the postion of the tree
      tree.position = CGPoint()
      tree.setScale(1.0)
      break
      
    case 0x35:
      view!.window!.close()
      break
      
      
    default:
      print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
    }
  }
  
  
  override func update(_ currentTime: TimeInterval) {
    tree.update()
    
    if play {
      next()
    }
  }
}
