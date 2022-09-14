//
//  RedBlackNodeView.swift
//  RedBlackTreeSUI
//
//  Created by Erik Spooner on 2022-09-01.
//

import Foundation
import AppKit


class RedBlackNodeView : NSView
{
  
  // Red Black Information
  var parent : RedBlackNodeView? = nil
  var parentRelation : ParentRelation {
    get {
      // If the parent is a RedBlackNode
      if let p = parent {
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
  var key : Int? {
    didSet {
      // Change the label
      if let k = key {
        label.stringValue = String(k)
      }
      else {
        label.stringValue = "nil"
      }
    }
  }
  
  @objc dynamic var color : NSColor {
    didSet { needsDisplay = true }
  }
  
  // 
  var linkNodes : [Link]
  var spacer : NSView
  var label : NSTextField
  
  // Easy access for left and right child
  var leftChild : RedBlackNodeView? {
    willSet {
      leftChild?.parent = nil
      
      // remove the existing child from the super view
      leftChild?.removeFromSuperview()
      linkNodes[0].removeFromSuperview()

      // deactivate the existing positional constraints
      NSLayoutConstraint.deactivate(childrenPositionalConstraints[0])
    }
    didSet {
      // If the child is not nil
      if let child = leftChild {
        child.parent = self
        
        // add the child to the scene
        superview!.addSubview(child)
        superview!.addSubview(linkNodes[0])
                
        updatePositionalConstraints(relation: .left)
        
        // The childs positional constraints may need to be updated as well
        child.updatePositionalConstraints(relation: .left)
        child.updatePositionalConstraints(relation: .right)
      }
    }
  }
  var rightChild : RedBlackNodeView? {
    willSet {
      rightChild?.parent = nil
      
      // remove the existing child from the super view
      rightChild?.removeFromSuperview()
      linkNodes[1].removeFromSuperview()
      
      // deactivate the existing positional constraints
      NSLayoutConstraint.deactivate(childrenPositionalConstraints[1])
    }
    didSet {
      // If the child is not nil
      if let child = rightChild {
        child.parent = self

        // add the child to the scene
        superview!.addSubview(child)
        superview!.addSubview(linkNodes[1])

        updatePositionalConstraints(relation: .right)
        
        // The childs positional constraints may need to be updated as well
        child.updatePositionalConstraints(relation: .left)
        child.updatePositionalConstraints(relation: .right)
      }
    }
  }
  /// Subscript operator for access to children
  subscript(index: ParentRelation) -> RedBlackNodeView? {
    get {
      switch index {
      case .left:
        return leftChild
      case .right:
        return rightChild
      case .no_parent:
        return nil
      }
    }
    set(newElm) {
      switch index {
      case .left:
        leftChild = newElm
      case .right:
        rightChild = newElm
      case .no_parent:
        break
      }
    }
  }

  private var horizontalSpacingConstant : CGFloat = 100
  private var verticalSpacingConstant : CGFloat = 100
  private var nodeRadius : CGFloat = 40
  
  private var childrenPositionalConstraints : [[NSLayoutConstraint]] = [[NSLayoutConstraint]]()
  private var spacerConstraints : [NSLayoutConstraint] = [NSLayoutConstraint]()
  private var linkConstraints : [[NSLayoutConstraint]] = [[NSLayoutConstraint]]()

  init(modelNode : RedBlackNode?) {
    var text = "nil"
    self.color = NSColor.black
    
    childrenPositionalConstraints.append([NSLayoutConstraint]())
    childrenPositionalConstraints.append([NSLayoutConstraint]())

    linkConstraints.append([NSLayoutConstraint]())
    linkConstraints.append([NSLayoutConstraint]())

    spacer = NSView(frame: NSRect(x: 0, y: 0, width: nodeRadius * 2, height: nodeRadius * 2))
    linkNodes = [Link]()
        
    // If the model exists
    if let n = modelNode {
      key = n.key
      
      text = String(n.key)
      self.color = n.colour == Colour.black ? .black : .red
    }
    
    // Create a label to diplay the text for the node
    label = NSTextField(frame: NSRect(x: 0, y: 0, width: 40, height: 40))
    label.isBordered = false
    label.isBezeled = false
    label.drawsBackground = false
    label.isSelectable = false
    label.isEditable = false
    label.translatesAutoresizingMaskIntoConstraints = false

    label.stringValue = text
    label.alignment = .center
    label.textColor = .black
    label.font = NSFont(descriptor: NSFontDescriptor(name: "Helvetica", size: 8), size: 20)

    super.init(frame: NSRect(x: 0, y: 0, width: nodeRadius * 2, height: nodeRadius * 2))
    
    // add the label as a sub view
    self.addSubview(label)

    self.wantsLayer = true
    self.translatesAutoresizingMaskIntoConstraints = false
    self.layer?.zPosition = 1.0

    
    // add the spacer so that the two children are equally spaced from the parent
    spacer.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(spacer)

    // add the constraints for the spacer
    spacerConstraints = [
      spacer.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: verticalSpacingConstant),
      spacer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: horizontalSpacingConstant),
      spacer.heightAnchor.constraint(equalToConstant: verticalSpacingConstant),
    ]

    NSLayoutConstraint.activate(spacerConstraints)
    
    // Add the links between the parent and children nodes
    linkNodes.append(Link(frame: frame, direction: true, key: key))
    linkNodes.append(Link(frame: frame, direction: false, key: key))
    
    // Add the width and height Constraints
    var constraints = [
      self.widthAnchor.constraint(equalToConstant: nodeRadius * 2),
      self.heightAnchor.constraint(equalToConstant: nodeRadius * 2),
    ]

    NSLayoutConstraint.activate(constraints)


    // Add the constraints for the label
    constraints = [
      label.widthAnchor.constraint(equalTo: self.widthAnchor),
      label.heightAnchor.constraint(equalToConstant: 30),
      label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
    ]
    
    NSLayoutConstraint.activate(constraints)

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ dirtyRect: NSRect) {
    let lineWidth : CGFloat = 3
    let rect = CGRect(x: dirtyRect.minX + lineWidth, y: dirtyRect.minY + lineWidth, width: dirtyRect.maxX - lineWidth * 2, height: dirtyRect.maxY - lineWidth * 2)
    
    let path = NSBezierPath(ovalIn: rect)
        
    NSColor.white.setFill()
    path.fill()
    
    path.lineWidth = lineWidth
    color.setStroke()
    path.stroke()
  }
  
  override func animation(forKey key: NSAnimatablePropertyKey) -> Any? {
    if key == "color" {
      return CABasicAnimation()
    }
    else {
      return super.animation(forKey: key)
    }
  }
  
  func drawFromModel(model: RedBlackNode?) {
    // If the model is nil we no longer need draw more for this branch of the tree
    guard let m = model else {
      return
    }
    
    // Create and the children nodes
    leftChild = RedBlackNodeView(modelNode: m.leftChild)
    rightChild = RedBlackNodeView(modelNode: m.rightChild)
        
    // Recursively call on the children
    leftChild!.drawFromModel(model: m.leftChild)
    rightChild!.drawFromModel(model: m.rightChild)
  }
  
  func addToDepthTable(depthTable : inout [[NSView]], depth : Int) {
    // create a new row to the table if necessary
    if depthTable.count <= depth {
      depthTable.append([NSView]())
    }
    
    // add the current node to the depth table
    depthTable[depth].append(self)
    
    // recursively add the left child then the right child
    leftChild?.addToDepthTable(depthTable: &depthTable, depth: depth + 1)
    rightChild?.addToDepthTable(depthTable: &depthTable, depth: depth + 1)
  }
  
  func setLinkNodesAlpha(alpha : Double, relation : ParentRelation) {
    
    if relation != .no_parent {
      linkNodes[relation].animator().alphaValue = alpha
    }
    else {
      for link in linkNodes {
        link.animator().alphaValue = alpha
      }
    }
  }
  
  private func removeChildren() {
    if let l = leftChild {
      l.removeFromSuperview()
      leftChild = nil
    }
    if let r = rightChild {
      r.removeFromSuperview()
      rightChild = nil
    }
  }
  
  private func updatePositionalConstraints(relation : ParentRelation) {
    guard relation != .no_parent else {
      return
    }
    
    // If the child is not nil
    if let child = self[relation] {
      // add the child to the scene
      superview!.addSubview(child)
            
      // create and activate new positional constraints on the child
      childrenPositionalConstraints[relation] = relation == .left ?
        [
          child.centerXAnchor.constraint(lessThanOrEqualTo: self.centerXAnchor, constant: -horizontalSpacingConstant),
          child.centerXAnchor.constraint(greaterThanOrEqualTo: self.centerXAnchor, constant: -horizontalSpacingConstant),
          spacer.leadingAnchor.constraint(equalTo: child.trailingAnchor),
        ]
        : [
          child.centerXAnchor.constraint(greaterThanOrEqualTo: self.centerXAnchor, constant: horizontalSpacingConstant),
          child.centerXAnchor.constraint(lessThanOrEqualTo: self.centerXAnchor, constant: horizontalSpacingConstant),
          spacer.trailingAnchor.constraint(equalTo: child.leadingAnchor),
        ]
      
      childrenPositionalConstraints[relation].append(contentsOf: [
        child.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: verticalSpacingConstant),
      ])
      
      // The maximum X distance constraints on the children are lower priorty
      childrenPositionalConstraints[relation][1].priority = NSLayoutConstraint.Priority(500)
      
      NSLayoutConstraint.activate(childrenPositionalConstraints[relation])
      
      // create and active the new constraints on the link
      let link = linkNodes[relation]
      linkConstraints[relation] = link.direction ? [
        link.topAnchor.constraint(equalTo: self.centerYAnchor),
        link.trailingAnchor.constraint(equalTo: self.centerXAnchor),
        link.widthAnchor.constraint(equalTo: spacer.widthAnchor, multiplier: 0.5, constant: nodeRadius),
        link.heightAnchor.constraint(equalToConstant: verticalSpacingConstant),
      ]
      : [
        link.topAnchor.constraint(equalTo: self.centerYAnchor),
        link.leadingAnchor.constraint(equalTo: self.centerXAnchor),
        link.widthAnchor.constraint(equalTo: spacer.widthAnchor, multiplier: 0.5, constant: nodeRadius),
        link.heightAnchor.constraint(equalToConstant: verticalSpacingConstant),
      ]
      
      NSLayoutConstraint.activate(linkConstraints[relation])
    }
  }
  
}


///
/// A line drawn between a parent and child node
///
class Link : NSView {
  var direction : Bool
  let key : Int?
    
  init(frame : CGRect, direction : Bool, key : Int?) {
    self.direction = direction
    self.key = key
    
    super.init(frame: frame)
            
    self.translatesAutoresizingMaskIntoConstraints = false
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    let line = NSBezierPath()
    if direction {
      line.move(to: NSMakePoint(bounds.minX, bounds.minY))
      line.line(to: NSMakePoint(bounds.maxX, bounds.maxY))
    }
    else {
      line.move(to: NSMakePoint(bounds.minX, bounds.maxY))
      line.line(to: NSMakePoint(bounds.maxX, bounds.minY))
    }
    line.lineWidth = 2
    
    NSColor.white.setStroke()
    line.stroke()
  }
}
