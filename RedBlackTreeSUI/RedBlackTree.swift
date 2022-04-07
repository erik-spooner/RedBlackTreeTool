//
//  RedBlackTree.swift
//  RedBlackTree
//
//  Created by Erik Spooner on 2021-12-31.
//

import Foundation

class RedBlackTree
{
  var root : RedBlackNode? = nil
  
  private var animationQueue : [AnimationType] = [AnimationType]()
  private var animationIndex : Int = 0
  
  func next() -> AnimationType? {
    guard !animationQueue.isEmpty else {
      print("No animation is playing")
      return nil
    }

    // play the animation
    let animation = animationQueue[animationIndex]
    animationIndex = min(animationIndex + 1, animationQueue.count - 1)
    
    return animation
  }
  
  func previous() -> AnimationType?  {
    guard !animationQueue.isEmpty else {
      print("No animation is playing")
      return nil
    }
    
    animationIndex = max(0, animationIndex - 1)
    // Play the animation in reverse
    return animationQueue[animationIndex]
  }
  
  func skip() {
    guard !animationQueue.isEmpty else {
      print("No animation is playing")
      return
    }
    
    animationIndex = animationQueue.count - 1
  }
  
  private func resetAnimationQueue() {
    animationQueue.removeAll()
    animationIndex = 0
  }
  
  
  // Given a key will return the RBN that correspondes to that key. Will return nil if the key is not in the tree
  func find(key: Int) -> RedBlackNode? {
    // Animation
    resetAnimationQueue()
    animationQueue.append(AnimationType.text(description: "Begining find operation for \(key)"))
    animationQueue.append(AnimationType.text(description: "Start at the root node"))
    
    var parentKey : Int? = nil
    var parentRelation : ParentRelation = .no_parent
    var node = root
    
    
    while(node != nil) {
      animationQueue.append(AnimationType.highlight(nodes: [node!.identifier], description: "Comparing the current node, \(node!.key), with the desired key of \(key)"))
      
      // Left traversal
      if key < node!.key {
        animationQueue.append(AnimationType.text(description: "\(key) < \(node!.key) so traversing to left child of node"))
        
        parentKey = node!.key
        parentRelation = .left
        node = node!.leftChild
      }
      // Right traversal
      else if key > node!.key {
        animationQueue.append(AnimationType.text(description: "\(key) > \(node!.key) so traversing to right child of node"))
        
        parentKey = node!.key
        parentRelation = .right
        node = node!.rightChild
      }
      // The node's key is the same as the given key so we have found the one that we are looking for
      else {
        animationQueue.append(AnimationType.text(description: "\(key) = \(node!.key) so desired node has been found"))
        animationQueue.append(AnimationType.text(description: "Ending find operation for \(key), returning the coresponding node"))
        return node
      }
    }
    
    animationQueue.append(AnimationType.highlight(nodes: [NodeIdentification(k: nil, p: parentKey, r: parentRelation)], description: "Nil node encountered. Thus key does not exist in the tree"))
    
    animationQueue.append(AnimationType.text(description: "Ending find operation for \(key), returning nil as key was not found"))

    return nil
  }
  
  
  // Inserts the given key into the tree, returns true if the insertion was successful and false if the key is already in use
  func insert(key: Int) -> Bool {
    
    // Animation
    resetAnimationQueue()
    animationQueue.append(AnimationType.text(description: "Begining insert operation for \(key)"))
    animationQueue.append(AnimationType.text(description: "Start at the root node"))

    
    // Find the place in the tree to insert
    var parent : RedBlackNode? = nil
    var node = root
    
    var parentKey : Int? = nil
    var parentRelation : ParentRelation = .no_parent
    
    while(node != nil) {
      parent = node
      
      animationQueue.append(AnimationType.highlight(nodes: [node!.identifier], description: "Comparing the current node, \(node!.key), with the desired key of \(key)"))
      
      // Left traversal
      if key < node!.key {
        animationQueue.append(AnimationType.text(description: "\(key) < \(node!.key) so traversing to left child of node"))
        
        parentKey = node!.key
        parentRelation = .left
        node = node!.leftChild
      }
      // Right traversal
      else if key > node!.key {
        animationQueue.append(AnimationType.text(description: "\(key) > \(node!.key) so traversing to right child of node"))
        
        parentKey = node!.key
        parentRelation = .right
        node = node!.rightChild
      }
      // The node's key is the same as the given key so we have found the one that we are looking for
      else {
        animationQueue.append(AnimationType.text(description: "\(key) = \(node!.key), the node already exists in the tree"))
        animationQueue.append(AnimationType.text(description: "Ending insert operation for \(key), returning false as the node already exists"))
        return false
      }
    }

    animationQueue.append(AnimationType.highlight(nodes: [NodeIdentification(k: nil, p: parentKey, r: parentRelation)], description: "Nil node encountered. Place for insertion has been found"))
    
    // Create the new node and assign the parent/child relationship
    var n = RedBlackNode(key: key, colour: .red)
    n.parent = parent
    
    animationQueue.append(AnimationType.nodeCreation(node: NodeIdentification(k: key, p: parentKey, r: parentRelation), description: "Create a red node for \(key)"))
    
    // If the parent exists make the new node a child
    if let p = parent {
      p.children[n.parentRelation] = n
    }
    
    animationQueue.append(AnimationType.text(description: "Proceeding to balance the tree and ensure Red Black properties are maintained"))
    
    // After we have inserted the new node, we need to balance the tree by starting at the node that we inserted and moving up the tree
    while (true) {
      
      // Case 1 the parent is a black node so we are all good
      if let p = n.parent {
        if p.colour == .black {
          animationQueue.append(AnimationType.highlight(nodes: [NodeIdentification(k: p.key, p: nil, r: .no_parent)], description: "Parent of \(n.key) is black, so red black properties were not violated and tree is still balanced"))
          break
        }
      }
      // Case 0 the parent does not exist, so we are inserting the root node
      else {
        // if the parent does not exist make the new node the root
        animationQueue.append(AnimationType.highlight(nodes: [NodeIdentification(k: n.key, p: nil, r: .no_parent)], description: "Parent of \(n.key) does not exist, so assigning \(n.key) to be the new root node of the tree"))
        root = n
        break
      }

      assert(n.parent != nil) // Parent must exist
      assert(n.parent!.parent != nil) // GrandParent must exist
      
      var p = n.parent! // Parent must exist and its colour is red
      let g = p.parent! // GrandParent must exist and be black beacuse parent is red
      let uncle = p.parentRelation == .left ? g.rightChild : g.leftChild // Uncle may not exist
      
      var animatedNodes = [p.identifier, g.identifier]
      animationQueue.append(AnimationType.highlight(nodes: animatedNodes, description: "Parent of \(n.key), is red with key \(p.key), and grandparent is black with key \(g.key)"))
      
      // Case 2 If the uncle is red. Repaint p and u black and g red
      if let u = uncle {
        if u.colour == .red {
          
          animatedNodes = [u.identifier]
          animationQueue.append(AnimationType.highlight(nodes: animatedNodes, description: "Uncle of \(n.key) exists and is red with key \(u.key)"))
          
          p.colour = .black
          u.colour = .black
          g.colour = .red

          animatedNodes = [p.identifier, u.identifier, g.identifier]
          let colours = [Colour.black, Colour.black, Colour.red]
          animationQueue.append(AnimationType.colourChange(nodes: animatedNodes, colours: colours, description: "Repaint the parent, uncle and grandparent"))
          
          animatedNodes = [g.identifier]
          // update the node to be the grandparent (if the grandparent is not the root) and continue
          animationQueue.append(AnimationType.highlight(nodes: animatedNodes, description: "Update the node that needs to be balanced to be the grandparent and continue"))
          n = g
          
          if n.key == root!.key {
            animationQueue.append(AnimationType.highlight(nodes: animatedNodes, description: "Root node encoutered so balancing is complete"))
          }
          continue
        }
      }
      
      // Case 3  If the uncle is black (or doesnt exist)
      // Case 3a If n is an internal node to g. We need to rotate up the node to the parent postion
      if n.parentRelation != p.parentRelation {
        animatedNodes = [n.identifier, n.identifier]
        animationQueue.append(AnimationType.rotationUp(nodes: animatedNodes, description: "The node is an internal node of its grandparent, so rotate up the node to its parent's position"))
        assert(rotateUp(node: n))
        
        // do a name swap for n and p
        animatedNodes = [p.identifier]
        animationQueue.append(AnimationType.highlight(nodes: animatedNodes, description: "Reasign the former parent to be the node that we are trying to balance"))
        let temp = n
        n = p
        p = temp
      }
      
      // The node is an external node to g so we rotate up p and swap the colours for p and g after this the tree is fine
      animatedNodes = [p.identifier, g.identifier]
      animationQueue.append(AnimationType.rotationUp(nodes: animatedNodes, description: "The node is an external node of its grandparent, so rotate up the parent the grandparents position's position"))
      assert(rotateUp(node: p))
      
      animatedNodes = [p.identifier, g.identifier]
      let colours = [Colour.black, Colour.red]
      animationQueue.append(AnimationType.colourChange(nodes: animatedNodes, colours: colours, description: "Swap the colours for parent and grandparent"))
      p.colour = .black
      g.colour = .red
      break
    }
        
    // Ensure that the root node is black
    animationQueue.append(AnimationType.colourChange(nodes: [root!.identifier], colours: [Colour.black], description: "Ensure that the root node is black"))
    root!.colour = .black
        
    // Return true since the insertion was successful
    animationQueue.append(AnimationType.text(description: "Ending insertion operation, returning true as \(key) was succuessfully inserted into the tree"))
    return true
  }
  
  
  // Removes the node corresponding to the given key, returns true if the deletion was successful and false if not
  func remove(key: Int) -> Bool {
    
    // Animation
    resetAnimationQueue()
    animationQueue.append(AnimationType.text(description: "Begining delete operation for \(key)"))
    animationQueue.append(AnimationType.text(description: "Start at the root node"))
    
    // Find the place in the tree to delete
    var parentKey : Int? = nil
    var parentRelation : ParentRelation = .no_parent
    var node = root
    
    while(true) {
      // return false if the node that the key corresponds to does not exist
      if node == nil  {
        animationQueue.append(AnimationType.highlight(nodes: [NodeIdentification(k: nil, p: parentKey, r: parentRelation)], description: "Nil node encountered, \(key) not found within tree"))
        animationQueue.append(AnimationType.text(description: "Ending delete opertation, returning false, as \(key) did not exist in the tree"))
        return false
      }
      
      animationQueue.append(AnimationType.highlight(nodes: [node!.identifier], description: "Comparing the current node, \(node!.key), with the desired key of \(key)"))
      
      // Left traversal
      if key < node!.key {
        animationQueue.append(AnimationType.text(description: "\(key) < \(node!.key) so traversing to left child of node"))
        
        parentKey = node!.key
        parentRelation = .left
        node = node!.leftChild
      }
      // Right traversal
      else if key > node!.key {
        animationQueue.append(AnimationType.text(description: "\(key) > \(node!.key) so traversing to right child of node"))
        
        parentKey = node!.key
        parentRelation = .right
        node = node!.rightChild
      }
      else {
        // We found the node to remove
        animationQueue.append(AnimationType.text(description: "\(key) = \(node!.key), node to delete has been found"))
        break
      }
    }
    
    // Now that we have found the node to delete need to determine the case that we are in
    var animatedNodes : [NodeIdentification]
    var n = node!
    
    // Case 0 the only node is the root
    if (n.key == root!.key && n.leftChild == nil && n.rightChild == nil) {
      animationQueue.append(AnimationType.nodeDeletion(node: n.identifier, description: "\(key) is the root node and the only node in the tree, so it is safe to delete"))
      root = nil
      
      animationQueue.append(AnimationType.text(description: "Ending delete operation, returning true, as \(key) has been sucessfully removed"))
      return true
    }
    
    // Case 1 The node to delete has two non nil children
    if let _ = n.leftChild, let _ = n.rightChild {
      // find the predecessor node to replace with n. We know the predecessor is non nil as n must have a left child
      animationQueue.append(AnimationType.text(description: "The node to delete has two non nil children, so find the predecessor node to \(n.key)"))
      var p = predecessor(node: n)!
      
      // swap n with p. We now know that n must have at most one non nil child (left child) and can proceed with deleting n
      animatedNodes = [n.identifier, p.identifier]
      animationQueue.append(AnimationType.swapNodes(nodes: animatedNodes, description: "Found the predecessor node \(p.key), so swap \(n.key) with \(p.key)"))
      swap(A: &n, B: &p)
      assert(n.rightChild == nil)
    }
    
    // Case 2a n has a left child (Child must be red, n must be black)
    if let child = n.leftChild {
      assert(n.colour == .black)
      assert(child.colour == .red)
      
      animatedNodes = [n.identifier, child.identifier, NodeIdentification(k: nil, p: n.key, r: ParentRelation.right)]
      animationQueue.append(AnimationType.highlight(nodes: animatedNodes, description: "\(n.key) is black, with \(child.key) being the red left child, and a nil right child"))
      
      // Delete n and replace it with its child changing the childs colour to black
      child.parent = n.parent
      child.colour = .black
      
      animatedNodes = [n.identifier, child.identifier]
      animationQueue.append(AnimationType.swapNodes(nodes: animatedNodes, description: "Swap \(n.key) with its child \(child.key)"))
      animationQueue.append(AnimationType.nodeDeletion(node: NodeIdentification(k: nil, p: child.key, r: .left), description: "Delete \(n.key)"))
      if let parent = n.parent {
        parent.children[n.parentRelation] = child
      }
      else {
        animationQueue.append(AnimationType.highlight(nodes: [NodeIdentification(k: nil, p: nil, r: .no_parent)], description: "\(n.key) was the root so make \(child.key) the new root of the tree"))
        root = child
      }

      animationQueue.append(AnimationType.text(description: "As we have only removed a red leaf node we have not broke any red black properties"))
      animationQueue.append(AnimationType.text(description: "Ending delete operation, returning true, as \(key) has been sucessfully removed"))
      return true
    }
    
    // Case 2b n has a right child (Child must be red, n must be black)
    if let child = n.rightChild {
      assert(n.colour == .black)
      assert(child.colour == .red)
      
      animatedNodes = [n.identifier, child.identifier, NodeIdentification(k: nil, p: n.key, r: .left)]
      animationQueue.append(AnimationType.text(description: "\(n.key) is black, with \(child.key) being the red right child, and a nil left child"))

      
      // Delete n and replace it with its child changing the childs colour to black
      child.parent = n.parent
      child.colour = .black
      
      animatedNodes = [n.identifier, child.identifier]
      animationQueue.append(AnimationType.swapNodes(nodes: animatedNodes, description: "Swap \(n.key) with its child \(child.key)"))
      animationQueue.append(AnimationType.nodeDeletion(node: NodeIdentification(k: nil, p: child.key, r: .right), description: "Delete \(n.key)"))
      if let parent = n.parent {
        parent.children[n.parentRelation] = child
      }
      else {
        animationQueue.append(AnimationType.highlight(nodes: [NodeIdentification(k: nil, p: nil, r: .no_parent)], description: "\(n.key) was the root so make \(child.key) the new root of the tree"))
        root = child
      }

      animationQueue.append(AnimationType.text(description: "As we have only removed a red leaf node we have not broke any red black properties"))
      animationQueue.append(AnimationType.text(description: "Ending delete operation, returning true, as \(key) has been sucessfully removed"))
      return true
    }
    
    // Now we are only dealing with leaf nodes that have parents
    assert(n.leftChild == nil)
    assert(n.rightChild == nil)
    assert(n.parent != nil)
    
    // Case 3 n is red
    if (n.colour == .red) {
      animationQueue.append(AnimationType.nodeDeletion(node: n.identifier, description: "\(n.key) is a red leaf node so it is safe to delete"))

      // simply delete n
      n.parent!.children[n.parentRelation] = nil
      
      animationQueue.append(AnimationType.text(description: "Ending delete operation, returning true, as \(key) has been sucessfully removed"))
      return true
    }
    // Case 4 n is black
    else {
      // Delete the node
      animationQueue.append(AnimationType.nodeDeletion(node: n.identifier, description: "\(n.key) is a black leaf node the tree will need to be balanced after deleting it"))
      n.parent!.children[n.parentRelation] = nil
      
      // Need to traverse up the tree to the root to balance out deleting a black node
      while let p = n.parent {
        
        // Need to get the sibling and nephew relations
        let s = p.children[!n.parentRelation]!  // sibling
        let closeCousin = s.children[!s.parentRelation]   // close nephew
        let distantCousin = s.children[s.parentRelation]    // distant nephew
        
        animationQueue.append(AnimationType.text(description: "Observe the close relations of \(n.key)"))
        
        // Case 1 s is red (then p, c, and d must be black)
        if (s.colour == .red) {
          assert(closeCousin != nil)
          assert(distantCousin != nil)
          
          animatedNodes = [s.identifier, p.identifier, closeCousin!.identifier, distantCousin!.identifier]
          animationQueue.append(AnimationType.highlight(nodes: animatedNodes, description: "The sibling \(s.key) is red, thus the parent \(p.key), the close cousin \(closeCousin!.key), and the distant cousin \(distantCousin!.key) are black"))

          deleteCase1(parent: p, sibling: s, closeCousin: closeCousin!, distantCousin: distantCousin!)
          // Balancing will be complete so exit the loop
          break
        }
        
        if let d = distantCousin, d.colour == .red {
          animatedNodes = [d.identifier]
          animationQueue.append(AnimationType.highlight(nodes: animatedNodes, description: "The distant cousin \(distantCousin!.key) is red"))
          
          deleteCase3(parent: p, sibling: s, distantCousin: d)
          // Balancing will be complete so exit the loop
          break
        }
        
        if let c = closeCousin, c.colour == .red {
          animatedNodes = [c.identifier]
          animationQueue.append(AnimationType.highlight(nodes: animatedNodes, description: "The close cousin \(closeCousin!.key) is red"))

          deleteCase2(parent: p, sibling: s, closeCousin: c, distantCousin: distantCousin)
          // Balancing will be complete so exit the loop
          break
        }
        
        if p.colour == .red {
          animatedNodes = [s.identifier, p.identifier]
          let colours = [Colour.red, Colour.black]
          animationQueue.append(AnimationType.colourChange(nodes: animatedNodes, colours: colours, description: "The parent \(p.key) is red and both cousins are not, so the tree can be balanced by making the sibling \(s.key) red, and the parent \(p.key) black"))
          // Since the parent is red and both cousins are not red we can make p black and s red to balance the tree
          s.colour = .red
          p.colour = .black
          break
        }
        
        // change the colour of the sibling to reduce the sibling branch's black count by 1
        animatedNodes = [s.identifier]
        let colours = [Colour.red]
        animationQueue.append(AnimationType.colourChange(nodes: animatedNodes, colours: colours, description: "Change the colour of the sibling \(s.key) to red to reduce the sibling branch's black count by 1"))
        s.colour = .red
                
        // move up the tree one step
        animatedNodes = [p.identifier]
        animationQueue.append(AnimationType.highlight(nodes: animatedNodes, description: "The tree has been balanced as much as possible at the current depth. Need to move up the tree by looking at the parent node \(p.key)"))
        n = p
      }
      
      // finally ensure the root node is black
      animationQueue.append(AnimationType.colourChange(nodes: [root!.identifier], colours: [Colour.black], description: "Ensure that the root node is black"))
      root!.colour = .black
      
      animationQueue.append(AnimationType.text(description: "Ending delete operation, returning true, as \(key) has been sucessfully removed"))
      return true
    }
  }
  
  
  private func deleteCase1(parent: RedBlackNode, sibling: RedBlackNode, closeCousin: RedBlackNode?, distantCousin: RedBlackNode?) {
    let p = parent
    var s = sibling
    var c = closeCousin
    var d = distantCousin
    
    // Rotate up s and change the colour of p and s
    var animatedNodes = [s.identifier, p.identifier]
    animationQueue.append(AnimationType.rotationUp(nodes: animatedNodes, description: "Rotate up the sibling \(s.key)"))
    assert(rotateUp(node: s))
    
    animatedNodes = [s.identifier, p.identifier]
    var colours = [Colour.black, Colour.red]
    animationQueue.append(AnimationType.colourChange(nodes: animatedNodes, colours: colours, description: "Change the colours of the former parent \(p.key) to red, and the former sibling \(s.key) to black"))
    s.colour = .black
    p.colour = .red
    
    // reassign the relations to n
    s = c!
    c = s.children[!s.parentRelation]
    d = s.children[s.parentRelation]
    
    if let dC = d, dC.colour == .red {
      animatedNodes = [dC.identifier]
      animationQueue.append(AnimationType.highlight(nodes: animatedNodes, description: "The distant cousin \(dC.key) is now red"))
      
      deleteCase3(parent: p, sibling: s, distantCousin: dC)
      // Balancing will be complete
      return
    }
    
    if let cC = c, cC.colour == .red {
      animatedNodes = [cC.identifier]
      animationQueue.append(AnimationType.highlight(nodes: animatedNodes, description: "The close cousin \(cC.key) is now red"))

      deleteCase2(parent: p, sibling: s, closeCousin: cC, distantCousin: d)
      // Balancing will be complete
      return
    }
    
    animatedNodes = [s.identifier, p.identifier]
    colours = [.red, .black]
    animationQueue.append(AnimationType.colourChange(nodes: animatedNodes, colours: colours, description: "The parent \(p.key) is red and both cousins are not, so the tree can be balanced by making the sibling \(s.key) red, and the parent \(p.key) black"))
    // Since the parent is red and both cousins are not red we can make p black and s red to balance the tree
    s.colour = .red
    p.colour = .black
  }
  
  private func deleteCase2(parent: RedBlackNode, sibling: RedBlackNode, closeCousin: RedBlackNode, distantCousin: RedBlackNode?) {
    let p = parent
    var s = sibling
    let c = closeCousin
    var d = distantCousin

    // rotate up the close cousin
    var animatedNodes = [c.identifier, s.identifier]
    animationQueue.append(AnimationType.rotationUp(nodes: animatedNodes, description: "Rotate up the close cousin \(c.key)"))
    assert(rotateUp(node: c))
    
    // reassin the colours of s and c
    animatedNodes = [s.identifier, c.identifier]
    let colours = [Colour.red, Colour.black]
    animationQueue.append(AnimationType.colourChange(nodes: animatedNodes, colours: colours, description: "Change the colours of the former sibling \(s.key) to red, and the former close cousin \(c.key) to black"))
    s.colour = .red
    c.colour = .black
    
    // reassign the relation ships to n
    d = s
    s = c
    
    // distant cousin now guaranteed to exist
    assert(d != nil)
    
    deleteCase3(parent: p, sibling: s, distantCousin: d!)
  }

  private func deleteCase3(parent: RedBlackNode, sibling: RedBlackNode, distantCousin: RedBlackNode) {
    let p = parent
    let s = sibling
    let d = distantCousin
    
    // rotate up the sibling
    var animatedNodes = [s.identifier, p.identifier]
    animationQueue.append(AnimationType.rotationUp(nodes: animatedNodes, description: "Rotate up the sibling \(s.key)"))
    assert(rotateUp(node: s))
    
    // reassign colours
    animatedNodes = [s.identifier, p.identifier, d.identifier]
    let colours = [p.colour, .black, .black]
    animationQueue.append(AnimationType.colourChange(nodes: animatedNodes, colours: colours, description: "Change the colours of the former sibling \(s.key) to \(p.colour), the former parent \(p.key) to black, and the former distant cousin \(d.key) to black to finish balancing the tree"))
    s.colour = p.colour
    p.colour = .black
    d.colour = .black
  }

  
  
  // verifies the properties of a Red Black tree. Returns true iff the tree satisfies them
  func verify() -> Bool {
    if let r = root {
      return r.recursiveVerify().proper
    }
    
    return true
  }
  
  
  // Function to rotate the given node to its parent's postion in the tree. Will return true iff the operation was sucessful (false if we try to rotate up the root node which has no parent)
  private func rotateUp(node : RedBlackNode) -> Bool {
    
    if (node.parent == nil) {
      return false
    }
    
    let parent = node.parent!
    let grandParent = parent.parent
    
    // Move the nodes interior child to be the parent's child
    let child = node.children[(!node.parentRelation)]
    parent.children[node.parentRelation] = child
    if let c = child {
      c.parent! = parent
    }
    
    // update the former parent's parent, and the node's parent
    parent.parent = node
    node.children[parent.parentRelation] = parent
    
    node.parent = grandParent
    
    // Now update the grandParent if it exists
    if let g = grandParent {
      g.children[node.parentRelation] = node
    }
    
    // if the node's parent does not exist we now need to update the root node
    if node.parent == nil {
      root = node
    }
    
    return true
  }
  
  // Given a node returns the predecessor
  private func predecessor(node : RedBlackNode) -> RedBlackNode? {
    if let leftChild = node.leftChild {
      var predecessor = leftChild
      
      while (predecessor.rightChild != nil) {
        predecessor = predecessor.rightChild!
      }
      
      return predecessor
    }
    else  {
      return nil
    }
  }
  
  // Given two nodes in the tree swap their keys
  private func swap(A : inout RedBlackNode, B : inout RedBlackNode) {
    let tempKey = A.key
    A.key = B.key
    B.key = tempKey
    
    let temp = A
    A = B
    B = temp
  }
}




enum Colour {
  case black
  case red
}

enum ParentRelation : Int {
  case left = 0
  case right = 1
  case no_parent = 2
}



//
class RedBlackNode
{
  var colour : Colour = .red
  var parent : RedBlackNode? {
    didSet {
      if let p = parent {
        parentRelation = p.key > key ? .left : .right
      }
      else {
        parentRelation = .no_parent
      }
    }
  }
  
  private(set) var parentRelation : ParentRelation = .no_parent
  var identifier : NodeIdentification {
    get {
      return NodeIdentification(k: key, p: parent?.key, r: parentRelation)
    }
  }
  
  var children : [RedBlackNode?] = [nil, nil]
  var leftChild : RedBlackNode? {
    get {
      return children[0]
    }
    set {
      children[0] = newValue
    }
  }
  var rightChild : RedBlackNode? {
    get {
      return children[1]
    }
    set {
      children[1] = newValue
    }
  }
  
  var key : Int
  
  init(key : Int, colour : Colour) {
    self.key = key
    self.colour = colour
    self.parent = nil
  }
  
  func recursiveVerify() -> (height: Int, proper: Bool) {
    
    let left = leftChild == nil ? (height: 0, proper: true) : leftChild!.recursiveVerify()
    let right = rightChild == nil ? (height: 0, proper: true) : rightChild!.recursiveVerify()
    
    let height = left.height
    let proper = left.height == right.height && left.proper && right.proper
    
    if let l = leftChild {
      assert(self.key == l.parent!.key)
    }

    if let r = rightChild {
      assert(self.key == r.parent!.key)
    }
    
    if colour == .black {
      return (height + 1, proper)
    }
    else if let p = parent {
      return (height, proper && p.colour != .red)
    }
    else {
      return(height, proper)
    }
  }
}


extension ParentRelation {
  static prefix func ! (parentRelation: ParentRelation) -> ParentRelation {
    switch parentRelation {
    case .left:
      return .right
      
    case .right:
      return .left
    
    default:
      return .no_parent
    }
  }
}


extension Array {
  subscript(index: ParentRelation) -> Element {
      get {
        return self[index.rawValue]
      }
      set(newElm) {
        self[index.rawValue] = newElm
      }
  }
}

enum AnimationType
{
  case text(description: String)
  case highlight(nodes : [NodeIdentification], description : String)
  case nodeCreation(node : NodeIdentification, description : String)
  case nodeDeletion(node : NodeIdentification, description : String)
  case colourChange(nodes : [NodeIdentification], colours : [Colour], description : String)
  case rotationUp(nodes : [NodeIdentification], description : String)
  case swapNodes(nodes : [NodeIdentification], description : String)
}

struct NodeIdentification {
  let key : Int?
  let parent : Int?
  let relation : ParentRelation
  
  init(k : Int?, p : Int?, r : ParentRelation) {
    key = k
    parent = p
    relation = r
  }
}


class TextAnimation
{
  func play(animation : AnimationType) {
    
    switch animation {
    case .highlight(_, let description):
      print(description)
      break
      
    default:
      print("Animation type not implemented")
    }
    
    print()
  }
  
  func reverse(animation : AnimationType) {
    
    switch animation {
    case .highlight(_, let description):
      let r : [Character] = description.reversed()
      print(String(r))
      break
      
    default:
      print("Animation type not implemented")
    }
    
  }
}

