//
//  TreeScene.swift
//  RedBlackTree
//
//  Created by Erik Spooner on 2022-09-07.
//

import Foundation
import AppKit
import Combine

class TreeScene : NSView
{
  private var rootNode : RedBlackNodeView
  private var model : RedBlackTree
  
  private var adjacencyConstraints : [NSLayoutConstraint]
  private var depthTable : [[NSView]]
  
  private var horizontalSpacingConstant : CGFloat = 100
  private var verticalSpacingConstant : CGFloat = 100
  
  private var rootNodePositionConstraints : [NSLayoutConstraint]
  var rootNodeDisplacement : CGPoint = CGPoint() {
    didSet {
      NSLayoutConstraint.deactivate(rootNodePositionConstraints)
      
      rootNodePositionConstraints = [
        rootNode.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: rootNodeDisplacement.x),
        rootNode.topAnchor.constraint(equalTo: self.topAnchor, constant: rootNodeDisplacement.y),
      ]
      
      NSLayoutConstraint.activate(rootNodePositionConstraints)
    }
  }
  
  private (set) var stepDescription : String = " "
  var animationPublisher : PassthroughSubject<Bool, Never>
  
  private (set) var animationRunning : Bool = false {
    didSet {
      animationPublisher.send(animationRunning)
    }
  }
  private var animationHandler : AnimationGroupHandler = AnimationGroupHandler()
  private var animationHandlerReceiver : AnyCancellable?
  
  init() {
    rootNode = RedBlackNodeView(modelNode: nil)
    model = RedBlackTree()
    
    adjacencyConstraints = [NSLayoutConstraint]()
    rootNodePositionConstraints = [NSLayoutConstraint]()
    depthTable = [[NSView]]()
    
    animationPublisher = PassthroughSubject<Bool, Never>()

    super.init(frame: NSRect(x: 0, y: 0, width: 500, height: 500))
    
    animationHandlerReceiver = animationHandler.completionPublisher.sink(receiveValue: { _ in self.animationRunning = false })
        
    self.translatesAutoresizingMaskIntoConstraints = false
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func drawFromModel() {
    subviews.removeAll()
        
    rootNode = RedBlackNodeView(modelNode: model.root)
    addSubview(rootNode)
    
    rootNode.drawFromModel(model: model.root)
  
    // add the constraints to set the root node to the center of the scene
    rootNodeDisplacement = CGPoint(x: 0, y: 100)
    
    
    // Create the depth table
    createDepthTable()
    
    // add the non sibling adjacency constraints
    addAdjacencyConstraints()
  }
  
  private func createDepthTable() {
    depthTable.removeAll()
        
    rootNode.addToDepthTable(depthTable: &depthTable, depth: 0)
  }
  
  private func addAdjacencyConstraints() {
    // clear the current constraints
    NSLayoutConstraint.deactivate(adjacencyConstraints)
    adjacencyConstraints.removeAll()

    for row in depthTable {
      
      guard row.count > 2 else {
        continue
      }
      // for any row except for the first there should be an even number of elements
      assert(row.count % 2 == 0)

      // for every odd index
      for index in 1 ..< row.count - 1 where index % 2 == 1 {
        let nodeA = row[index]
        let nodeB = row[index + 1]
        
        // ensure that there is enough space between adjacent nodes that are not siblings
        adjacencyConstraints.append(nodeB.leadingAnchor.constraint(greaterThanOrEqualTo: nodeA.trailingAnchor, constant: horizontalSpacingConstant))
      }
    }
    
    // activate the constraints
    NSLayoutConstraint.activate(adjacencyConstraints)
  }
  
  ///
  /// Animation Functions
  ///
  
  private func applyAnimation(animation : AnimationType) {
    switch animation {
    case .text(let d):
      stepDescription = d
      break
    
    case .highlight(let i, let d):
      highlight(identifiers: i)
      stepDescription = d
      break

    case .nodeCreation(let i, let k, let d):
      createNode(identifier: i, key: k)
      stepDescription = d
      break

    case .colourChange(let i, let c, let d):
      colourChange(identifiers: i, colours: c, reverse: false)
      stepDescription = d
      break

    case .rotationUp(let i, let d):
      rotateUp(identifier: i[0])
      stepDescription = d
      break

    case .nodeDeletion(let i, _, let d):
      deleteNode(identifier: i)
      stepDescription = d
      break

    case .swapNodes(let i, let d):
      swapNodes(identifiers: i)
      stepDescription = d
      break

    default:
      print("Animation Type not implemented")
    }
  }
  
  private func reverseAnimation(animation : AnimationType) {
    
    switch animation {
      // dont need to do anything for text
    case .text(let d):
      stepDescription = d
      break
    
    case .highlight(let i, let d):
      // dont need to do anything for highlight
      highlight(identifiers: i)
      stepDescription = d
      break

    case .nodeCreation(let i, _, let d):
      // instead of creating a node delete it
      deleteNode(identifier: i)
      stepDescription = d
      break

    case .colourChange(let i, let c, let d):
      colourChange(identifiers: i, colours: c, reverse: true)
      stepDescription = d
      break

    case .rotationUp(let i, let d):
      // rotate up the former parent instead
      rotateUp(identifier: i[1])
      stepDescription = d
      break

    case .nodeDeletion(let i, let k, let d):
      // Create the node instead
      createNode(identifier: i, key: k)
      stepDescription = d
      break

    case .swapNodes(let i, let d):
      // Dont need to change anything
      swapNodes(identifiers: i)
      stepDescription = d
      break

    default:
      print("Animation Type not implemented")
    }
  }

  // Given the identifier for a node return the node itself
  private func find(identifier: NodeIdentification) -> RedBlackNodeView {
    var key : Int
    var node : RedBlackNodeView

    if let parentKey = identifier.parent {
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

    // Now that we have found the parent return the correct child
    return node[identifier.relation]!
  }

  private func highlight(identifiers: [NodeIdentification], color : NSColor = .yellow) {
    for identifier in identifiers {
      // find the node coresponding to the key
      let node = find(identifier: identifier)

      // grab the current color of the node
      let currentColor = node.color
      
      // Set the color of the node to be the highlighted color for 1 second
      var animation1 = AnimationGroup()
      animation1.duration = 1
      animation1.function = {
        node.animator().color = color
      }
      
      // Turn the color back to the original color
      var animation2 = AnimationGroup()
      animation2.duration = 1
      animation2.function = { node.animator().color = currentColor }
      
      animationHandler.addAnimation(animation: animation1)
      animationHandler.addAnimation(animation: animation2)
    }
  }

  // The identifier key is the node to be created
  private func createNode(identifier: NodeIdentification, key: Int) {
    // find the visual
    let node = find(identifier: NodeIdentification(p: identifier.parent, r: identifier.relation))

    // The node found should be nil
    assert(node.key == nil)

    // give it the new key
    node.key = key

    // create  nil children
    node.leftChild = RedBlackNodeView(modelNode: nil)
    node.rightChild = RedBlackNodeView(modelNode: nil)
    
    node.leftChild!.alphaValue = 0.0
    node.rightChild!.alphaValue = 0.0
    
    self.addSubview(node.leftChild!)
    self.addSubview(node.rightChild!)
    
    // place the new nil children
    self.layoutSubtreeIfNeeded()

    //
    node.setLinkNodesAlpha(alpha: 0.0, relation: .no_parent)

    // Change the color of the node to red and modify the adjacency constraints to move the nodes to their new postion
    var animation1 = AnimationGroup()
    animation1.duration = 1
    animation1.function = {
      node.animator().color = .red
            
      self.createDepthTable()
      self.addAdjacencyConstraints()
      
      self.layoutSubtreeIfNeeded()
    }
    
    // Have the new nil nodes and the links to the parent node fade in
    var animation2 = AnimationGroup()
    animation2.duration = 1
    animation2.function = {
      node.leftChild!.animator().alphaValue = 1.0
      node.rightChild!.animator().alphaValue = 1.0
          
      node.setLinkNodesAlpha(alpha: 1.0, relation: .no_parent)
    }
    
    animationHandler.addAnimation(animation: animation1)
    animationHandler.addAnimation(animation: animation2)
  }

  private func deleteNode(identifier: NodeIdentification) {
    let node = find(identifier: identifier)
    
    // Set the nodes key to be nil
    node.key = nil
    
    // Fade out the connection nodes and the children, ensure that the node is black
    var animation1 = AnimationGroup()
    animation1.duration = 1
    animation1.function = {
      node.animator().color = .black
                    
      node.leftChild!.animator().alphaValue = 0.0
      node.rightChild!.animator().alphaValue = 0.0
          
      node.setLinkNodesAlpha(alpha: 0.0, relation: .no_parent)
            
      self.layoutSubtreeIfNeeded()
    }
    // Delete the children
    animation1.completion = {
      node.leftChild = nil
      node.rightChild = nil
    }
    
    // Recreate the depth tree and adjacency constraints to move nodes to their new position
    var animation2 = AnimationGroup()
    animation2.duration = 1
    animation2.function = {
      self.createDepthTable()
      self.addAdjacencyConstraints()
            
      self.layoutSubtreeIfNeeded()
    }
    
    animationHandler.addAnimation(animation: animation1)
    animationHandler.addAnimation(animation: animation2)
  }

  private func colourChange(identifiers : [NodeIdentification], colours : [(new : Colour, old : Colour)], reverse : Bool) {
    assert(identifiers.count == colours.count)
    
    var animation = AnimationGroup()
    animation.duration = 1
    animation.function = {
      for i in 0...identifiers.count-1 {
        let node = self.find(identifier: identifiers[i])

        switch !reverse ? colours[i].new : colours[i].old {
        case .black:
          node.animator().color = .black
          break

        case .red:
          node.animator().color = .red
          break
        }
      }
    }
    
    animationHandler.addAnimation(animation: animation)
  }
  
  func rotateUp(identifier: NodeIdentification) {
    let n = find(identifier: identifier)

    // Get the important relation nodes
    let p = n.parent!
    let grandParent = p.parent // could be the Tree (Not a node)
    let c = n[!n.parentRelation]! // the interior child
    
    let pRelation = n.parentRelation
    let gRelation = p.parentRelation
    
    // Fade out the connection nodes of g->p->n->c
    var animation1 = AnimationGroup()
    animation1.duration = 1
    animation1.function = {
      grandParent?.setLinkNodesAlpha(alpha: 0.0, relation: p.parentRelation)
      p.setLinkNodesAlpha(alpha: 0.0, relation: n.parentRelation)
      n.setLinkNodesAlpha(alpha: 0.0, relation: !n.parentRelation)
      
      self.layoutSubtreeIfNeeded()
    }
    // Reassign the new relations
    animation1.completion = {
      grandParent?[gRelation] = nil
      p[pRelation] = nil
      n[!pRelation] = nil

      if let g = grandParent {
        g[gRelation] = n
      }
      else {
        self.rootNode = n
        self.addSubview(n)
        
        //
        n[pRelation] = n[pRelation]
      }
      
      n[!pRelation] = p
      p[pRelation] = c
    }
    
    // Move (ALL nodes of the tree to their new positions)
    var animation2 = AnimationGroup()
    animation2.duration = 2
    animation2.function = {
      self.createDepthTable()
      self.addAdjacencyConstraints()
            
      NSLayoutConstraint.deactivate(self.rootNodePositionConstraints)
      self.rootNodePositionConstraints = [
        self.rootNode.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: self.rootNodeDisplacement.x),
        self.rootNode.topAnchor.constraint(equalTo: self.topAnchor, constant: self.rootNodeDisplacement.y),
      ]
      NSLayoutConstraint.activate(self.rootNodePositionConstraints)

      self.layout()
    }

    // Fade in the connection nodes of g->n->p->c
    var animation3 = AnimationGroup()
    animation3.duration = 1
    animation3.function = {
      grandParent?.setLinkNodesAlpha(alpha: 1.0, relation: gRelation)
      p.setLinkNodesAlpha(alpha: 1.0, relation: pRelation)
      n.setLinkNodesAlpha(alpha: 1.0, relation: !pRelation)
    }
    
    animationHandler.addAnimation(animation: animation1)
    animationHandler.addAnimation(animation: animation2)
    animationHandler.addAnimation(animation: animation3)
  }

  func swapNodes(identifiers: [NodeIdentification]) {
    assert(identifiers.count == 2)

    let nodeA = find(identifier: identifiers[0]) // node
    let nodeB = find(identifier: identifiers[1]) // child / predessor
    
    highlight(identifiers: identifiers)
      
    let keyA = nodeA.key
    nodeA.key = nodeB.key
    nodeB.key = keyA
  }

  
  ///
  /// Control Functions
  ///
  
  @discardableResult
  func next() -> String {
    animationRunning = true
    applyAnimation(animation: model.next())
    animationHandler.runAnimations()
    
    return stepDescription
  }
  
  @discardableResult
  func previous() -> String {
    animationRunning = true
    reverseAnimation(animation: model.previous())
    animationHandler.runAnimations()
    
    return stepDescription
  }

  @discardableResult
  func skip() -> String {
    model.skip()
    drawFromModel()
    
    return " "
  }
  
  func find(key: Int) {
    _ = model.find(key: key)
  }
  
  @discardableResult
  func insert(key: Int) -> Bool {
    return model.insert(key: key)
  }
  
  @discardableResult 
  func remove(key: Int) -> Bool {
    return model.remove(key: key)
  }
}
