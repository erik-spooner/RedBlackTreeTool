//
//  RedBlackTreeAnimation.swift
//  RedBlackTreeTool
//
//  Created by Erik Spooner on 2022-02-14.
//

import Foundation
import simd
import SpriteKit

class RedBlackSKTree: SKNode {
  
  var nilNodesVisible : Bool = true
  
  var tree = RedBlackTree()
  var rootNode : RedBlackSKNode? = RedBlackSKNode(modelNode: nil)
  
  func drawFromTree() {
    removeAllChildren()
    
    rootNode = RedBlackSKNode(modelNode: tree.root)
    rootNode!.drawFromModel(model: tree.root)
    
    addChild(rootNode!)
  }
  
  func applyAnimation(animation : AnimationType) {
    
    switch animation {
    case .highlight(let key, let description):
        highlight(key: key)
        print(description)
      break
      
    default:
      print("Animation Type not implemented")
    }
    
  }
  
  func highlight(key: Int, colour : NSColor = .yellow) {

    // find the node coresponding to the key
    let node = rootNode!
    
    
    let currentColour = node.strokeColor
    
    let highlight = SKAction.run {
      node.strokeColor = colour
    }
    
    let old = SKAction.run {
      node.strokeColor = currentColour
    }
    
    // Highlight the node with the given colour for 2 seconds before changing it back to the original colour
    rootNode!.run(SKAction.sequence([highlight, SKAction.wait(forDuration: 2.0), old]))
  }
  
}


class RedBlackSKNode : SKShapeNode
{
  // Red Black Information
  var key : Int?
  var rbChildren : [RedBlackSKNode?] = [nil, nil]
  private(set) var parentRelation : ParentRelation = .no_parent

  // Easy access for left and right child
  var leftChild : RedBlackSKNode? {
    get {
      return rbChildren[0]
    }
    set {
      rbChildren[0] = newValue
    }
  }
  var rightChild : RedBlackSKNode? {
    get {
      return rbChildren[1]
    }
    set {
      rbChildren[1] = newValue
    }
  }
  
  
  private var label : SKLabelNode
  private var nodeRadius : CGFloat = 75
  private var baseHeight : CGFloat = 200
  private var baseDistance : CGFloat = 100
  var depth = 0
  
  
  private var connectionNodes : [SKShapeNode?] = [nil, nil]
  
  init(modelNode : RedBlackNode?) {
    
    var text = "nil"
    var colour = NSColor.black
    
    // If the model exists
    if let n = modelNode {
      key = n.key
      parentRelation = n.parentRelation
      
      text = String(n.key)
      colour = n.colour == Colour.black ? .black : .red
    }
    
    // Create a label to diplay the text for the node
    label = SKLabelNode.init(fontNamed: "HelveticaNeue-Bold")
    label.text = text
    label.fontColor = .black
    label.fontSize = 50
    label.position = CGPoint(x: 0, y: -15)
    label.setScale(1.0)
    
    super.init()
    
    // Create a circular path for the node
    let path = CGMutablePath()
    path.addArc(center: CGPoint.zero, radius: nodeRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
    self.path = path

    // Set the draw properties
    fillColor = .clear
    strokeColor = colour
    lineWidth = 3

    // Add the label as a child
    addChild(label)
  }
  
  
  func drawFromModel(model: RedBlackNode?) {
    
    // If the model is nil we no longer need draw more for this branch of the tree
    guard let m = model else {
      return
    }
    
    // Create the children nodes
    rbChildren = [RedBlackSKNode(modelNode: m.leftChild), RedBlackSKNode(modelNode: m.rightChild)]
        
    // Recursively call on the children
    leftChild!.drawFromModel(model: m.leftChild)
    rightChild!.drawFromModel(model: m.rightChild)
    
    // set the depth
    depth = max(leftChild!.depth + 1, rightChild!.depth + 1)
    
    let leftOffset = leftChild!.calculateOffset()
    let rightOffset = rightChild!.calculateOffset()
        
    leftChild!.position = leftOffset
    rightChild!.position = CGPoint(x: -rightOffset.x, y: rightOffset.y)

    // Create the connection nodes to the children and add the children to the scene
    addChild(leftChild!)
    addChild(rightChild!)
    
    modifyConnectionNodes()
  }
  
  
  // Modifies the connection nodes to connect the node with its children
  private func modifyConnectionNodes() {
    // if the model is nil remove the connection nodes if they exist
    guard key != nil else {
      // If the key does not exist delete the connection nodes, and remove the connection nodes
      if let left = connectionNodes[0], let right = connectionNodes[1] {
        removeChildren(in: [left, right])
      }
      connectionNodes = [nil, nil]
      return
    }
    
    let offsets = [leftChild!.position, rightChild!.position]

    for i in 0...1 {
      // If the connection nodes do not exist create them
      if connectionNodes[i] == nil {
        connectionNodes[i] = SKShapeNode()
        connectionNodes[i]!.strokeColor = .black
        connectionNodes[i]!.lineWidth = 2.0
      }
      
      let connection = connectionNodes[i]!
      
      let line = vector_double2(Double(offsets[i].x), Double(offsets[i].y))
      let normal = normalize(line)
      
      let start = normal * Double(nodeRadius)
      let end = line - normal * Double(nodeRadius)
      
      let path = CGMutablePath()
      path.move(to: CGPoint(x: start.x, y: start.y))
      path.addLine(to: CGPoint(x: end.x, y: end.y))
      connection.path = path
      
      addChild(connection)
    }

  }
  
  // Caculate the offset of a node to its parent
  func calculateOffset() -> (CGPoint) {
        
    let x = pow(2.0, CGFloat(depth - 1)) * baseDistance + pow(2.0, CGFloat(depth)) * nodeRadius
        
    return CGPoint(x: -x, y: -baseHeight)
  }
  
  
  override init() {
    // Create the label for the node
    label = SKLabelNode.init(fontNamed: "HelveticaNeue-Bold")
    label.text = "nil"
    label.fontColor = .black
    label.fontSize = 50
    label.position = CGPoint(x: 0, y: -15)
    
    super.init()
    
    // Create a circular path for the node
    let path = CGMutablePath()
    path.addArc(center: CGPoint.zero, radius: nodeRadius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
    self.path = path

    // Set the draw properties
    fillColor = .clear
    strokeColor = .black
    lineWidth = 0.2

    // Add the label as a child
    addChild(label)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
