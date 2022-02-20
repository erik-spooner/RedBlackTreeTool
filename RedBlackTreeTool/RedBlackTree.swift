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
  
  private var animationQueue : [AnimationProtocol] = [AnimationProtocol]()
  private var animationIndex : Int = 0
  
  func next() {
    guard !animationQueue.isEmpty else {
      print("No animation is playing")
      return
    }

    // play the animation
    animationQueue[animationIndex].play()
    animationIndex = min(animationIndex + 1, animationQueue.count - 1)
  }
  
  func previous() {
    guard !animationQueue.isEmpty else {
      print("No animation is playing")
      return
    }
    
    animationIndex = max(0, animationIndex - 1)
    // Play the animation in reverse
    animationQueue[animationIndex].reverse()
  }
  
  func skip() {
    guard !animationQueue.isEmpty else {
      print("No animation is playing")
      return
    }
    
    animationQueue.last!.play()
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
    animationQueue.append(TextAnimation(description: "Begining find operation for \(key)"))
    animationQueue.append(TextAnimation(description: "Start at the root node"))
    
    var node = root
    
    while(node != nil) {
      
      animationQueue.append(TextAnimation(description: "Comparing the current node, \(node!.key), with the desired key"))
      
      // Left traversal
      if key < node!.key {
        
        animationQueue.append(TextAnimation(description: "\(key) < \(node!.key) so traversing to left child of node"))
        node = node!.leftChild
      }
      // Right traversal
      else if key > node!.key {
        animationQueue.append(TextAnimation(description: "\(key) > \(node!.key) so traversing to right child of node"))
        node = node!.rightChild
      }
      // The node's key is the same as the given key so we have found the one that we are looking for
      else {
        animationQueue.append(TextAnimation(description: "\(key) = \(node!.key) so desired node has been found"))
        animationQueue.append(TextAnimation(description: "Ending find operation for \(key), returning the coresponding node"))
        return node
      }
    }
    
    animationQueue.append(TextAnimation(description: "Nil node encountered. Thus key does not exist in the tree"))
    animationQueue.append(TextAnimation(description: "Ending find operation for \(key), returning nil as key was not found"))

    return nil
  }
  
  
  // Inserts the given key into the tree, returns true if the insertion was successful and false if the key is already in use
  func insert(key: Int) -> Bool {
    
    // Animation
    resetAnimationQueue()
    animationQueue.append(TextAnimation(description: "Begining insert operation for \(key)"))
    animationQueue.append(TextAnimation(description: "Start at the root node"))

    
    // Find the place in the tree to insert
    var parent : RedBlackNode? = nil
    var node = root
    
    while(node != nil) {
      parent = node

      // Left traversal
      if key < node!.key {
        animationQueue.append(TextAnimation(description: "\(key) < \(node!.key) so traversing to left child of node"))
        node = node!.leftChild
      }
      // Right traversal
      else if key > node!.key {
        animationQueue.append(TextAnimation(description: "\(key) > \(node!.key) so traversing to right child of node"))
        node = node!.rightChild
      }
      else {
        animationQueue.append(TextAnimation(description: "\(key) = \(node!.key). Key already exists in the Tree"))
        animationQueue.append(TextAnimation(description: "Ending insert operation for \(key), returning false as \(key) already exists in the tree"))

        // return false if the key is already in the tree
        return false
      }
    }
    
    animationQueue.append(TextAnimation(description: "Nil node encountered. Place for insertion has been found"))
    
    // Create the new node and assign the parent/child relationship
    animationQueue.append(TextAnimation(description: "Create a red node for \(key)"))
    var n = RedBlackNode(key: key, colour: .red)
    n.parent = parent
    
    
    if let p = parent {
      animationQueue.append(TextAnimation(description: "Attach \(key) to its parent"))
      p.children[n.parentRelation] = n
    }
    

    animationQueue.append(TextAnimation(description: "Proceeding to balance the tree and ensure Red Black properties are maintained"))

    
    // After we have inserted the new node, we need to balance the tree by starting at the node that we inserted and moving up the tree
    while (true) {
      
      // Case 1 the parent is a black node so we are all good
      if let p = n.parent {
        if p.colour == .black {
          animationQueue.append(TextAnimation(description: "Parent of \(n.key) is black, so red black properties were not violated and tree is still balanced"))
          break
        }
      }
      // Case 0 the parent does not exist, so we are inserting the root node
      else {
        // if the parent does not exist make the new node the root
        animationQueue.append(TextAnimation(description: "Parent of \(n.key) does not exist, so assigning \(n.key) to be the new root node of the tree"))
        root = n
        break
      }

      assert(n.parent != nil) // Parent must exist
      assert(n.parent!.parent != nil) // GrandParent must exist
      
      var p = n.parent! // Parent must exist and its colour is red
      let g = p.parent! // GrandParent must exist and be black beacuse parent is red
      let uncle = p.parentRelation == .left ? g.rightChild : g.leftChild // Uncle may not exist
      
      animationQueue.append(TextAnimation(description: "Parent of \(n.key), is red with key \(p.key), and grandparent is black with key \(g.key)"))
      
      // Case 2 If the uncle is red. Repaint p and u black and g red
      if let u = uncle {
        if u.colour == .red {
          
          animationQueue.append(TextAnimation(description: "Uncle of \(n.key) exists and is red with key \(u.key)"))
          animationQueue.append(TextAnimation(description: "Repaint the parent, uncle and grandparent"))
          
          p.colour = .black
          u.colour = .black
          g.colour = .red
          
          // update the node to be the grandparent and continue
          animationQueue.append(TextAnimation(description: "Update the node that needs to be balanced to be the grandparent and continue"))
          n = g
          continue
        }
      }
      
      // Case 3  If the uncle is black (or doesnt exist)
      // Case 3a If n is an internal node to g. We need to rotate up the node to the parent postion
      if n.parentRelation != p.parentRelation {
        animationQueue.append(TextAnimation(description: "The node is an internal node of its grandparent, so rotate up the node to its parent's position"))
        assert(rotateUp(node: n))
        
        // do a name swap for n and p
        animationQueue.append(TextAnimation(description: "Reasign the former parent to be the node that we are trying to balance"))
        let temp = n
        n = p
        p = temp
      }
      
      // The node is an external node to g so we rotate up p and swap the colours for p and g after this the tree is fine
      animationQueue.append(TextAnimation(description: "The node is an external node of its grandparent, so rotate up the node to its parent's position"))
      assert(rotateUp(node: p))
      
      animationQueue.append(TextAnimation(description: "Swap the colours for parent and grandparent"))
      p.colour = .black
      g.colour = .red
      break
    }
        
    // Ensure that the root node is black
    animationQueue.append(TextAnimation(description: "Ensure that the root node is black"))
    root!.colour = .black
    
    assert(verify())
    
    // Return true since the insertion was successful
    animationQueue.append(TextAnimation(description: "Ending insertion operation, returning true as \(key) was succuessfully inserted into the tree"))
    return true
  }
  
  
  // Removes the node corresponding to the given key, returns true if the deletion was successful and false if not
  func remove(key: Int) -> Bool {
    
    // Animation
    resetAnimationQueue()
    animationQueue.append(TextAnimation(description: "Begining delete operation for \(key)"))
    animationQueue.append(TextAnimation(description: "Start at the root node"))
    
    // Find the place in the tree to delete
    var node = root
    
    while(true) {
      // return false if the node that the key corresponds to does not exist
      if node == nil  {
        animationQueue.append(TextAnimation(description: "Nil node encountered, \(key) not found within tree"))
        animationQueue.append(TextAnimation(description: "Ending delete opertation, returning false, as \(key) did not exist in the tree"))
        return false
      }
      
      // Left traversal
      if key < node!.key {
        animationQueue.append(TextAnimation(description: "\(key) < \(node!.key) so traversing to left child of node"))
        node = node!.leftChild
      }
      // Right traversal
      else if key > node!.key {
        animationQueue.append(TextAnimation(description: "\(key) > \(node!.key) so traversing to right child of node"))
        node = node!.rightChild
      }
      else {
        // We found the node to remove
        animationQueue.append(TextAnimation(description: "\(key) = \(node!.key), node to delete has been found"))
        break
      }
    }
    
    // Now that we have found the node to delete need to determine the case that we are in
    var n = node!
    
    // Case 0 the only node is the root
    if (n.key == root!.key && n.leftChild == nil && n.rightChild == nil) {
      animationQueue.append(TextAnimation(description: "\(key) is the root node and the only node in the tree, so it is safe to delete"))
      root = nil
      
      animationQueue.append(TextAnimation(description: "Ending delete operation, returning true, as \(key) has been sucessfully removed"))
      return true
    }
    
    // Case 1 The node to delete has two non nil children
    if let _ = n.leftChild, let _ = n.rightChild {
      // find the predecessor node to replace with n. We know the predecessor is non nil as n must have a left child
      animationQueue.append(TextAnimation(description: "The node to delete has two non nil children, so find the predecessor node to \(n.key)"))
      var p = predecessor(node: n)!
      
      // swap n with p. We now know that n must have at most one non nil child (left child) and can proceed with deleting n
      animationQueue.append(TextAnimation(description: "Found the predecessor node \(p.key), so swap \(n.key) with \(p.key)"))
      swap(A: &n, B: &p)
      assert(n.rightChild == nil)
    }
    
    // Case 2a n has a left child (Child must be red, n must be black)
    if let child = n.leftChild {
      assert(n.colour == .black)
      assert(child.colour == .red)
      
      animationQueue.append(TextAnimation(description: "\(n.key) is black, with \(child.key) being the red left child, and no right child"))
      
      // Delete n and replace it with its child changing the childs colour to black
      child.parent = n.parent
      child.colour = .black
      
      animationQueue.append(TextAnimation(description: "Delete \(n.key) and replace it with \(child.key), changing \(child.key)'s colour to black"))
      if let parent = n.parent {
        parent.children[n.parentRelation] = child
      }
      else {
        animationQueue.append(TextAnimation(description: "\(n.key) was the root so make \(child.key) the new root of the tree"))
        root = child
      }

      animationQueue.append(TextAnimation(description: "As we have only removed a red leaf node we have not broke any red black properties"))
      animationQueue.append(TextAnimation(description: "Ending delete operation, returning true, as \(key) has been sucessfully removed"))
      return true
    }
    
    // Case 2b n has a right child (Child must be red, n must be black)
    if let child = n.rightChild {
      assert(n.colour == .black)
      assert(child.colour == .red)
      
      animationQueue.append(TextAnimation(description: "\(n.key) is black, with \(child.key) being the red right child, and no left child"))

      
      // Delete n and replace it with its child changing the childs colour to black
      child.parent = n.parent
      child.colour = .black
      
      animationQueue.append(TextAnimation(description: "Delete \(n.key) and replace it with \(child.key), changing \(child.key)'s colour to black"))
      if let parent = n.parent {
        parent.children[n.parentRelation] = child
      }
      else {
        animationQueue.append(TextAnimation(description: "\(n.key) was the root so make \(child.key) the new root of the tree"))
        root = child
      }

      animationQueue.append(TextAnimation(description: "As we have only removed a red leaf node we have not broke any red black properties"))
      animationQueue.append(TextAnimation(description: "Ending delete operation, returning true, as \(key) has been sucessfully removed"))
      return true
    }
    
    // Now we are only dealing with leaf nodes that have parents
    assert(n.leftChild == nil)
    assert(n.rightChild == nil)
    assert(n.parent != nil)
    
    // Case 3 n is red
    if (n.colour == .red) {
      animationQueue.append(TextAnimation(description: "\(n.key) is a red leaf node so it is safe to delete"))

      // simply delete n
      n.parent!.children[n.parentRelation] = nil
      
      animationQueue.append(TextAnimation(description: "Ending delete operation, returning true, as \(key) has been sucessfully removed"))
      return true
    }
    // Case 4 n is black
    else {
      // Delete the node
      animationQueue.append(TextAnimation(description: "\(n.key) is a black leaf node the tree will need to be balanced after deleting it"))
      n.parent!.children[n.parentRelation] = nil
      
      // Need to traverse up the tree to the root to balance out deleting a black node
      while let p = n.parent {
        
        // Need to get the sibling and nephew relations
        let s = p.children[!n.parentRelation]!  // sibling
        let closeCousin = s.children[!s.parentRelation]   // close nephew
        let distantCousin = s.children[s.parentRelation]    // distant nephew
        
        animationQueue.append(TextAnimation(description: "Observe the close relations of \(n.key)"))
        
        // Case 1 s is red (then p, c, and d must be black)
        if (s.colour == .red) {
          assert(closeCousin != nil)
          assert(distantCousin != nil)
          
          animationQueue.append(TextAnimation(description: "Proceeding to case 1 where the sibling \(s.key) is red, and the parent \(p.key), the close cousin \(closeCousin!.key), and the distant cousin \(distantCousin!.key) are black"))


          deleteCase1(parent: p, sibling: s, closeCousin: closeCousin!, distantCousin: distantCousin!)
          // Balancing will be complete so exit the loop
          break
        }
        
        if let d = distantCousin, d.colour == .red {
          animationQueue.append(TextAnimation(description: "Proceeding to case 3 where the distant cousin \(distantCousin!.key) is red"))
          
          deleteCase3(parent: p, sibling: s, distantCousin: d)
          // Balancing will be complete so exit the loop
          break
        }
        
        if let c = closeCousin, c.colour == .red {
          animationQueue.append(TextAnimation(description: "Proceeding to case 2 where the close cousin \(closeCousin!.key) is red"))

          deleteCase2(parent: p, sibling: s, closeCousin: c, distantCousin: distantCousin)
          // Balancing will be complete so exit the loop
          break
        }
        
        if p.colour == .red {
          animationQueue.append(TextAnimation(description: "The parent \(p.key) is red and both cousins are not, so the tree can be balanced by making the sibling \(s.key) red, and the parent \(p.key) black"))
          // Since the parent is red and both cousins are not red we can make p black and s red to balance the tree
          s.colour = .red
          p.colour = .black
          break
        }
        
        // change the colour of the sibling to reduce the sibling branch's black count by 1
        animationQueue.append(TextAnimation(description: "Change the colour of the sibling \(s.key) to red to reduce the sibling branch's black count by 1"))
        s.colour = .red
                
        // move up the tree one step
        animationQueue.append(TextAnimation(description: "\(n.key), has been balanced as much as possible. Need to move up the tree by looking at the parent node \(p.key)"))
        n = p
      }
      
      // finally ensure the root node is black
      animationQueue.append(TextAnimation(description: "Ensure that the root node \(root!.key) is black"))
      root!.colour = .black
      
      animationQueue.append(TextAnimation(description: "Ending delete operation, returning true, as \(key) has been sucessfully removed"))
      return true
    }
  }
  
  
  private func deleteCase1(parent: RedBlackNode, sibling: RedBlackNode, closeCousin: RedBlackNode?, distantCousin: RedBlackNode?) {
    let p = parent
    var s = sibling
    var c = closeCousin
    var d = distantCousin
    
    // Rotate up s and change the colour of p and s
    animationQueue.append(TextAnimation(description: "Rotate up the sibling \(s.key)"))
    assert(rotateUp(node: s))
    
    animationQueue.append(TextAnimation(description: "Change the colours of the former parent \(p.key) to red, and the former sibling \(s.key) to black"))
    s.colour = .black
    p.colour = .red
    
    // reassign the relations to n
    s = c!
    c = s.children[!s.parentRelation]
    d = s.children[s.parentRelation]
    
    if let dC = d, dC.colour == .red {
      animationQueue.append(TextAnimation(description: "Proceeding to case 3 where the distant cousin \(dC.key) is red"))
      
      deleteCase3(parent: p, sibling: s, distantCousin: dC)
      // Balancing will be complete
      return
    }
    
    if let cC = c, cC.colour == .red {
      animationQueue.append(TextAnimation(description: "Proceeding to case 2 where the close cousin \(cC.key) is red"))

      deleteCase2(parent: p, sibling: s, closeCousin: cC, distantCousin: d)
      // Balancing will be complete
      return
    }
    
    animationQueue.append(TextAnimation(description: "The parent \(p.key) is red and both cousins are not, so the tree can be balanced by making the sibling \(s.key) red, and the parent \(p.key) black"))
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
    animationQueue.append(TextAnimation(description: "Rotate up the close cousin \(c.key)"))
    assert(rotateUp(node: c))
    
    // reassin the colours of s and c
    animationQueue.append(TextAnimation(description: "Change the colours of the former sibling \(s.key) to red, and the former close cousin \(c.key) to black"))
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
    animationQueue.append(TextAnimation(description: "Rotate up the sibling \(s.key)"))
    assert(rotateUp(node: s))
    
    // reassign colours
    animationQueue.append(TextAnimation(description: "Change the colours of the former sibling \(s.key) to \(p.colour), the former parent \(p.key) to black, and the former distant cousin \(d.key) to black to finish balancing the tree"))
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
  case highlight(node: Int, description : String)
}


protocol AnimationProtocol
{
  var description : String { get set }
  
  func play()
  func reverse()
}

class TextAnimation: AnimationProtocol
{
  var description: String
  
  init(description d: String) {
    description = d
  }
  
  func play() {
    print(description)
  }
  
  func reverse() {
    let r : [Character] = description.reversed()
    print(String(r))
  }
}

