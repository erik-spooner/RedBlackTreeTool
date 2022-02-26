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
  private var tree : RedBlackSKTree = RedBlackSKTree()
  
  private var oldTouchPoint : CGPoint = CGPoint()
  
  
  override func didMove(to view: SKView) {
    print(view.setFrameSize(NSSize(width: 1600, height: 1200)))
    
    addChild(tree)
    
    tree.drawFromTree()
    
    _ = tree.tree.insert(key: 0)
    _ = tree.tree.insert(key: 1)
    _ = tree.tree.insert(key: 2)
    _ = tree.tree.insert(key: 3)
    _ = tree.tree.insert(key: 4)

    tree.drawFromTree()
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
    
    case 0x0:
//      _ = tree.tree.insert(key: Int.random(in: 0...40))
//      tree.drawFromTree()
      tree.rotateUp(identifier: NodeIdentification(k: 4, p: nil, r: .no_parent))
      
      break
    
    case 0x1:
      // play next animation
      tree.next()
      break

      
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
  }
}
