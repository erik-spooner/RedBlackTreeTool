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
    
  init() {
    rootNode = RedBlackNodeView(modelNode: nil)
    model = RedBlackTree()
    
    adjacencyConstraints = [NSLayoutConstraint]()
    rootNodePositionConstraints = [NSLayoutConstraint]()
    depthTable = [[NSView]]()
    
    publisher = PassthroughSubject<Any, Never>()

    super.init(frame: NSRect(x: 0, y: 0, width: 500, height: 500))
    
//    wantsLayer = true
//    layer!.backgroundColor = NSColor.gray.cgColor
    
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

      //
      let currentColour = node.color
      
      NSAnimationContext.runAnimationGroup({ context in
        context.duration = 1
                
        node.animator().color = color
                        
      }, completionHandler: {
        NSAnimationContext.runAnimationGroup({ context in
          context.duration = 1
                  
          node.animator().color = currentColour
        })
      })
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
    
    createDepthTable()

    // Have the new nodes and the links to the parent node fade in
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 1
      context.allowsImplicitAnimation = true
              
      // New nodes are created as red nodes
      node.animator().color = .red
            
      addAdjacencyConstraints()
      
      self.layoutSubtreeIfNeeded()
      
    }, completionHandler: {
      NSAnimationContext.runAnimationGroup({ context in
        context.duration = 1
        context.allowsImplicitAnimation = true

        node.leftChild!.animator().alphaValue = 1.0
        node.rightChild!.animator().alphaValue = 1.0
            
        node.setLinkNodesAlpha(alpha: 1.0, relation: .no_parent)
      })
    })
  }

  private func deleteNode(identifier: NodeIdentification) {
    let node = find(identifier: identifier)
    
    node.key = nil
            
    // Fade out the connection nodes and the children
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 2
      context.allowsImplicitAnimation = true
      
      node.animator().color = .black
                    
      node.leftChild!.animator().alphaValue = 0.0
      node.rightChild!.animator().alphaValue = 0.0
          
      node.setLinkNodesAlpha(alpha: 0.0, relation: .no_parent)
            
      self.layoutSubtreeIfNeeded()
      
    }, completionHandler: {
      node.leftChild = nil
      node.rightChild = nil
      self.createDepthTable()

      NSAnimationContext.runAnimationGroup({ context in
        context.duration = 2
        context.allowsImplicitAnimation = true

        self.addAdjacencyConstraints()
        
        for link in self.rootNode.linkNodes {
          link.needsLayout = true
        }
        
        self.layoutSubtreeIfNeeded()
        
      }, completionHandler: {
        
      })
    })


    // set the node's key to be nil and delete the children
    node.key = nil
  }

  private func colourChange(identifiers : [NodeIdentification], colours : [(new : Colour, old : Colour)], reverse : Bool) {
    assert(identifiers.count == colours.count)

    for i in 0...identifiers.count-1 {
      let node = find(identifier: identifiers[i])

      switch !reverse ? colours[i].new : colours[i].old {
      case .black:
        node.color = .black
        break

      case .red:
        node.color = .red
        break
      }
    }
  }
  
  func rotateUp(identifier: NodeIdentification) {
    let n = find(identifier: identifier)

    // Get the importation nodes
    let p = n.parent!
    let grandParent = p.parent // could be the Tree (Not a node)
    let c = n[!n.parentRelation]! // the interior child
    
    // Fade out the connection nodes of g->p->n->c
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = 1
      context.allowsImplicitAnimation = true
      
      grandParent?.setLinkNodesAlpha(alpha: 0.0, relation: p.parentRelation)
      p.setLinkNodesAlpha(alpha: 0.0, relation: n.parentRelation)
      n.setLinkNodesAlpha(alpha: 0.0, relation: !n.parentRelation)
      
      self.layoutSubtreeIfNeeded()
      
    }, completionHandler: {

      // Reassign the new relations
      let pRelation = n.parentRelation
      let gRelation = p.parentRelation
      
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

      // Move (ALL nodes of the tree to their new positions)
      NSAnimationContext.runAnimationGroup({ context in
        context.duration = 2
        context.allowsImplicitAnimation = true
        
        self.createDepthTable()
        self.addAdjacencyConstraints()
        
        // Fade in the connection nodes of g->n->p->c
        grandParent?.setLinkNodesAlpha(alpha: 1.0, relation: p.parentRelation)
        p.setLinkNodesAlpha(alpha: 1.0, relation: n.parentRelation)
        n.setLinkNodesAlpha(alpha: 1.0, relation: !n.parentRelation)
        
        NSLayoutConstraint.deactivate(self.rootNodePositionConstraints)
        self.rootNodePositionConstraints = [
          self.rootNode.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: self.rootNodeDisplacement.x),
          self.rootNode.topAnchor.constraint(equalTo: self.topAnchor, constant: self.rootNodeDisplacement.y),
        ]
        NSLayoutConstraint.activate(self.rootNodePositionConstraints)

        self.layout()
      }, completionHandler: {
        // Fade in the connection nodes of g->n->p->c
        NSAnimationContext.runAnimationGroup({ context in
          context.duration = 1
          context.allowsImplicitAnimation = true
          
          grandParent?.setLinkNodesAlpha(alpha: 1.0, relation: p.parentRelation)
          p.setLinkNodesAlpha(alpha: 1.0, relation: n.parentRelation)
          n.setLinkNodesAlpha(alpha: 1.0, relation: !n.parentRelation)
        })
      })

    })

    
    
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
    applyAnimation(animation: model.next())
    return stepDescription
  }
  
  @discardableResult
  func previous() -> String {
    reverseAnimation(animation: model.previous())
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