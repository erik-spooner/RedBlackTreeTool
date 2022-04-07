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
  var animationSpeed : Double = 3.0
  
  private var lock : NSLock = NSLock()
  private (set) var animationRunning = false
  
  private var tree = RedBlackTree()
  var rootNode : RedBlackSKNode = RedBlackSKNode(modelNode: nil)
  private var swapedNode : RedBlackSKNode? = nil // The node that is out of place because it has been moved
  
  func drawFromTree() {
    lock.lock()
    removeAllChildren()
    
    rootNode = RedBlackSKNode(modelNode: tree.root)
    rootNode.drawFromModel(model: tree.root)
    
    addChild(rootNode)
    lock.unlock()
  }
  
  func next() -> String {
    if let a = tree.next() {
      return applyAnimation(animation: a)
    } else {
      return "No animation queued"
    }
  }
  
  func previous() -> String {
    if let a = tree.previous() {
      return applyAnimation(animation: a)
    } else {
      return "No animation queued"
    }
  }
  
  func update() {
    lock.lock()
    rootNode.updateConnectionNodes()
    lock.unlock()
  }
  
  func find(key: Int) {
    swapedNode = nil
    tree.find(key: key)
  }
  
  func insert(key: Int) -> Bool {
    swapedNode = nil
    drawFromTree()
    return tree.insert(key: key)
  }
  
  func remove(key: Int) -> Bool {
    swapedNode = nil
    drawFromTree()
    return tree.remove(key: key)
  }
  
  private func applyAnimation(animation : AnimationType) -> String {
    lock.lock()
    
    var description = ""
    animationRunning = true
    
    switch animation {
    case .text(let d):
      description = d
      run(SKAction.wait(forDuration: 2.0), completion: {self.animationRunning = false})
      break
    
    case .highlight(let i, let d):
      highlight(identifiers: i)
      description = d
      break

    case .nodeCreation(let i, let d):
      createNode(identifier: i)
      description = d
      break

    case .colourChange(let i, let c, let d):
      colourChange(identifiers: i, colours: c)
      description = d
      break

    case .rotationUp(let i, let d):
      rotateUp(identifier: i[0])
      description = d
      break

    case .nodeDeletion(let i, let d):
      deleteNode(identifier: i)
      description = d
      break

    case .swapNodes(let i, let d):
      swapNodes(identifiers: i)
      description = d
      break

    default:
      print("Animation Type not implemented")
      animationRunning = false
    }
    lock.unlock()
    
    return description
  }
  
  private func reverseAnimation(animation : AnimationType) -> String {
    lock.lock()
    
    var description = ""
    animationRunning = true
    
    switch animation {
      // dont need to do anything for text
    case .text(let d):
      description = d
      run(SKAction.wait(forDuration: 2.0), completion: {self.animationRunning = false})
      break
    
    case .highlight(let i, let d):
      // dont need to do anything for highlight
      highlight(identifiers: i)
      description = d
      break

    case .nodeCreation(let i, let d):
      // instead of creating a node delete it
      deleteNode(identifier: i)
      description = d
      break

    case .colourChange(let i, var c, let d):
      // Reverse the colours
      for var colour in c {
        if colour == .black {
          colour = .red
        }
        else {
          colour = .black
        }
      }
      
      colourChange(identifiers: i, colours: c)
      description = d
      break

    case .rotationUp(let i, let d):
      // rotate up the former parent instead
      rotateUp(identifier: i[1])
      description = d
      break

    case .nodeDeletion(let i, let d):
      // Create the node instead
      createNode(identifier: i)
      description = d
      break

    case .swapNodes(let i, let d):
      // Dont need to change anything
      swapNodes(identifiers: i)
      description = d
      break

    default:
      print("Animation Type not implemented")
      animationRunning = false
    }
    lock.unlock()
    
    return description
  }

  // Given the identifier for a node return the node itself
  private func find(identifier: NodeIdentification) -> RedBlackSKNode {
    var key : Int
    var node : RedBlackSKNode
    
    if let nodeKey = identifier.key {
      key = nodeKey
      
      // Check for if the node that we are looking for is the one that may be out of place in the tree
      if let swapped = swapedNode {
        if swapped.key == key {
          return swapedNode!
        }
      }
      
    }
    else if let parentKey = identifier.parent {
      // The node is nil but the parent exists
      key = parentKey
    }
    else {
      // The node is nil and the parent is nil so it must be the root node
      return rootNode
    }
    
    node = rootNode
    
    while node.key != nil {
      if (key < node.key!) {
        node = node.leftChild!
      }
      else if (key > node.key!) {
        node = node.rightChild!
      }
      else {
        // Found the correct node so break out of the loop
        break
      }
      
      // The node's key should never be nil
      assert(node.key != nil)
    }
    
    if identifier.key == nil {
      // If we are looking for a nil node
      return node.rbChildren[identifier.relation]!
    }
    else {
      return node
    }
  }
  
  private func highlight(identifiers: [NodeIdentification], colour : NSColor = .yellow) {
    for identifier in identifiers {
      // find the node coresponding to the key
      let node = find(identifier: identifier)
      
      let currentColour = node.strokeColor
      
      let highlight = SKAction.run {
        node.strokeColor = colour
      }
      
      let old = SKAction.run {
        node.strokeColor = currentColour
      }
            
      // Highlight the node with the given colour for 2 seconds before changing it back to the original colour
      node.run(SKAction.sequence([highlight, SKAction.wait(forDuration: 2.0), old]), completion: {self.animationRunning = false})
    }
  }
  
  // The identifier key is the node to be created
  private func createNode(identifier: NodeIdentification) {
    // The key of the new node should not be nil
    assert(identifier.key != nil)
    
    // find the visual
    let node = find(identifier: NodeIdentification(k: nil, p: identifier.parent, r: identifier.relation))
    
    // The node found should be nil with height 0
    assert(node.key == nil)
    assert(node.height == 0)
    
    // give it a new key
    node.key = identifier.key
        
    // New nodes are created as red nodes
    node.strokeColor = .red
    
    // create and position nil children
    for i in 0...1 {
      node.rbChildren[i] = RedBlackSKNode(modelNode: nil)
      node.rbChildren[i]!.alpha = 0.0
      
      node.addChild(node.rbChildren[i]!)
      node.rbChildren[i]!.position = node.rbChildren[i]!.calculateOffset()
    }
    
    node.updateConnectionNodes()
    
    for child in node.rbChildren {
      node.fadeOutConnectionNode(relation: child!.parentRelation)
      node.fadeInConnectionNode(relation: child!.parentRelation, duration: 1.0)
      
      child!.run(SKAction.fadeIn(withDuration: 1.0), completion: {self.animationRunning = false})
    }
  }
  
  private func deleteNode(identifier: NodeIdentification) {
    let node = find(identifier: identifier)
    
    node.key = nil
    
    animationRunning = false
  }
  
  private func colourChange(identifiers : [NodeIdentification], colours : [Colour]) {
    assert(identifiers.count == colours.count)
    
    for i in 0...identifiers.count-1 {
      let node = find(identifier: identifiers[i])
      
      switch colours[i] {
      case .black:
        node.strokeColor = .black
        break
        
      case .red:
        node.strokeColor = .red
        break
      }
    }
    
    animationRunning = false
  }
  
  func rotateUp(identifier: NodeIdentification) {
    let n = find(identifier: identifier)
    
    // Get the importation nodes
    let p = n.parent as! RedBlackSKNode
    let s = p.rbChildren[!n.parentRelation]!
    let grandparent = p.parent! // could be the Tree (Not a Tree Node)
    let c = n.rbChildren[!n.parentRelation]!
    
    // Fade out the connection nodes of g->p->n->c
    if let g = grandparent as? RedBlackSKNode {
      g.fadeOutConnectionNode(relation: p.parentRelation)
    }
    p.fadeOutConnectionNode(relation: n.parentRelation)
    n.fadeOutConnectionNode(relation: !n.parentRelation)
    

    // Save the position of the node
    let nodeOldPosition = n.position
    
    // Move the node to the parent location
    // remove n as a child of p and add it as a child of the grandparent
    p.rbChildren[n.parentRelation] = c
    p.removeChildren(in: [n])
    n.position += p.position
    grandparent.addChild(n)
    
    if let g = grandparent as? RedBlackSKNode {
      g.rbChildren[n.parentRelation] = n
    }
    
    var delay = SKAction.wait(forDuration: 1.0)
    var moveVector : CGVector = p.position - n.position
    var moveAction = SKAction.move(by: moveVector, duration: animationSpeed)
    n.run(SKAction.sequence([delay, moveAction]))

    // Move the parent to the siblings location
    grandparent.removeChildren(in: [p])
    p.position = CGPoint() + (CGPoint() - nodeOldPosition)
    n.addChild(p)
    n.rbChildren[p.parentRelation] = p

    moveVector = s.position - p.position
    moveAction = SKAction.move(by: moveVector, duration: animationSpeed)
    p.run(SKAction.sequence([delay, moveAction]))

    // Move the nodes interior child to be the parent's child
    let childOldPosition = c.position
    n.removeChildren(in: [c])
    c.position += nodeOldPosition
    p.addChild(c)
    p.rbChildren[c.parentRelation] = c

    moveVector = CGPoint(x: -childOldPosition.x, y: childOldPosition.y) - c.position
    moveAction = SKAction.move(by: moveVector, duration: animationSpeed)
    c.run(SKAction.sequence([delay, moveAction]))
    
    // if the node's new parent is the tree, we now need to update the root node to be n
    if grandparent == self {
      rootNode = n
    }
    
    // Update the new heights of the nodes
    p.updateHeight()
    
    delay = SKAction.wait(forDuration: animationSpeed)
    
    var position = n.calculateOffset()
    n.run(SKAction.sequence([delay, SKAction.move(to: position, duration: animationSpeed)]), completion: {self.animationRunning = false})

    position = p.calculateOffset()
    p.run(SKAction.sequence([delay, SKAction.move(to: position, duration: animationSpeed)]))

    position = c.calculateOffset()
    c.run(SKAction.sequence([delay, SKAction.move(to: position, duration: animationSpeed)]))
    
    var parented = grandparent
    while let node = parented as? RedBlackSKNode {
      position = node.calculateOffset()
      node.run(SKAction.sequence([delay, SKAction.move(to: position, duration: animationSpeed)]))
      parented = node.parent!
    }
    
    // Fade in the connection nodes of g->n->p->c
    if let g = grandparent as? RedBlackSKNode {
      g.fadeInConnectionNode(relation: n.parentRelation, delay: animationSpeed)
    }
    
    p.fadeInConnectionNode(relation: c.parentRelation, delay: animationSpeed)
    n.fadeInConnectionNode(relation: p.parentRelation, delay: animationSpeed)
    
  }
  
  func swapNodes(identifiers: [NodeIdentification]) {
    assert(identifiers.count == 2)
    
    let nodeA = find(identifier: identifiers[0]) // node
    let nodeB = find(identifier: identifiers[1]) // child / predessor
    
    let keyA = nodeA.key
    nodeA.key = nodeB.key
    nodeB.key = keyA
    
    swapedNode = nodeB // NodeB will can now be out of place
    animationRunning = false
  }
}

class RedBlackSKNode : SKShapeNode
{
  // Red Black Information
  var key : Int? {
    didSet {
      // Change the label
      if let k = key {
        label.text = String(k)
      }
      else {
        label.text = "nil"
        
        strokeColor = .black
        
        removeAllChildren()
        addChild(label)
        rbChildren = [nil, nil]
        connectionNodes = [nil, nil]
      }
    }
  }
  var rbChildren : [RedBlackSKNode?] = [nil, nil]

  var parentRelation : ParentRelation {
    get {
      // If the parent is a RedBlackNode
      if let p = parent as? RedBlackSKNode {
        // If the key exists
        if let k = key {
          if p.key! > k {
            return .left
          }
          else {
            return .right
          }
        }
        else {
          // Manually check to see if node is the left or right child
          if self == p.leftChild {
            return .left
          }
          else {
            return .right
          }
        }
      }
      //
      else {
        return .no_parent
      }
    }
  }

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
  var height = 0
  
  private var connectionNodes : [SKShapeNode?] = [nil, nil]
  private var connectionLocked : [Bool] = [false, false]
  
  init(modelNode : RedBlackNode?) {
    
    var text = "nil"
    var colour = NSColor.black
    
    // If the model exists
    if let n = modelNode {
      key = n.key
      
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
    
    // Create and add the children nodes
    rbChildren = [RedBlackSKNode(modelNode: m.leftChild), RedBlackSKNode(modelNode: m.rightChild)]

    addChild(leftChild!)
    addChild(rightChild!)
    
    // Recursively call on the children
    leftChild!.drawFromModel(model: m.leftChild)
    rightChild!.drawFromModel(model: m.rightChild)
    
    // set the height
    height = max(leftChild!.height + 1, rightChild!.height + 1)
            
    leftChild!.position = leftChild!.calculateOffset()
    rightChild!.position = rightChild!.calculateOffset()
  }
  
  // Modifies the connection nodes to connect the node with its children
  func updateConnectionNodes() {
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
      if connectionLocked[i] {
        continue
      }
      
      // If the connection nodes do not exist create them
      if connectionNodes[i] == nil {
        connectionNodes[i] = SKShapeNode()
        connectionNodes[i]!.strokeColor = .black
        connectionNodes[i]!.lineWidth = 2.0
        addChild(connectionNodes[i]!)
      }
            
      let line = vector_double2(Double(offsets[i].x), Double(offsets[i].y))
      let normal = normalize(line)
      
      let start = normal * Double(nodeRadius)
      let end = line - normal * Double(nodeRadius)
      
      let path = CGMutablePath()
      path.move(to: CGPoint(x: start.x, y: start.y))
      path.addLine(to: CGPoint(x: end.x, y: end.y))
      connectionNodes[i]!.path = path
    }
    
    leftChild!.updateConnectionNodes()
    rightChild!.updateConnectionNodes()
  }
  
  func updateHeight() {
    if let _ = key {
      height = max(leftChild!.height + 1, rightChild!.height + 1)
    }
    else {
      height = 0
    }
    
    // update the height of the parent if it exists
    if let p = parent as? RedBlackSKNode {
      p.updateHeight()
    }
  }
  
  // Caculate the offset of a node to its parent
  func calculateOffset() -> CGPoint {
    let x = pow(2.0, CGFloat(height - 1)) * baseDistance + pow(2.0, CGFloat(height)) * nodeRadius
    
    switch parentRelation {
    case .left:
      return CGPoint(x: -x, y: -baseHeight)
    
    case .right:
      return CGPoint(x: x, y: -baseHeight)
      
    case .no_parent:
      return CGPoint()
    }
  }
  
  func fadeOutConnectionNode(relation : ParentRelation, duration : Double = 0.0) {
    if let n = connectionNodes[relation] {
      connectionLocked[relation] = true
      n.run(SKAction.fadeOut(withDuration: duration))
    }
  }
  func fadeInConnectionNode(relation : ParentRelation, duration : Double = 0.0, delay : Double = 0.0) {
    if let n = connectionNodes[relation] {
      let unlock = SKAction.run { self.connectionLocked[relation] = false }
      let action = SKAction.sequence([SKAction.wait(forDuration: delay), unlock, SKAction.fadeIn(withDuration: duration)])
      n.run(action)
    }
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
