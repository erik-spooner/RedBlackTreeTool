//
//  RedBlackTreeToolTests.swift
//  RedBlackTreeToolTests
//
//  Created by Erik Spooner on 2022-05-05.
//

import XCTest
@testable import RedBlackTreeSUI

class RedBlackTreeToolTests: XCTestCase {
  
  override func setUpWithError() throws {
  }

  override func tearDownWithError() throws {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func addChild(parent : RedBlackNode, child : RedBlackNode, relation : ParentRelation) {
    parent.children[relation] = child
    child.parent = parent
  }
  
  
  func testVerify() throws {
    let tree = RedBlackTree()
    
    // Tree is empty which is a valid tree
    XCTAssert(tree.root == nil)
    XCTAssert(tree.verify())
    
    // Tree with a single black root node of 5
    tree.root = RedBlackNode(key: 5, colour: .black)
    XCTAssert(tree.verify())

    // Add 3 as red left child
    addChild(parent: tree.root!, child: RedBlackNode(key: 3, colour: .red), relation: .left)
    
    XCTAssert(tree.verify())

    // Add 1 and 4 as black children to 3 and add 6 as the black right child of 5
    addChild(parent: tree.root!.leftChild!, child: RedBlackNode(key: 1, colour: .black), relation: .left)
    addChild(parent: tree.root!.leftChild!, child: RedBlackNode(key: 4, colour: .black), relation: .right)
    
    addChild(parent: tree.root!, child: RedBlackNode(key: 6, colour: .black), relation: .right)

    XCTAssert(tree.verify())
    
    // Add 2 as the right red child of 1, and 7 as the right red child of 6
    addChild(parent: tree.root!.leftChild!.leftChild!, child: RedBlackNode(key: 2, colour: .red), relation: .right)
    addChild(parent: tree.root!.rightChild! , child: RedBlackNode(key: 7, colour: .red), relation: .right)
    
    XCTAssert(tree.verify())
  }
  
  // Invalid placement in tree
  func testVerifyFail1() throws {
    let tree = RedBlackTree()
    
    tree.root = RedBlackNode(key: 5, colour: .black)
    
    // Add 6 as the red left child of 5
    addChild(parent: tree.root!, child: RedBlackNode(key: 6, colour: .red), relation: .left)
    
    XCTAssert(!tree.verify())
  }

  // Unblanced black nodes
  func testVerifyFail2() throws {
    let tree = RedBlackTree()
    
    tree.root = RedBlackNode(key: 5, colour: .black)
    
    // Add 6 as the black right child of 5
    addChild(parent: tree.root!, child: RedBlackNode(key: 6, colour: .black), relation: .right)
    
    XCTAssert(!tree.verify())
  }
  
  // Red node parenting a red node
  func testVerifyFail3() throws {
    let tree = RedBlackTree()
    
    tree.root = RedBlackNode(key: 5, colour: .black)
    
    // Add 3 as the red left child of 5
    addChild(parent: tree.root!, child: RedBlackNode(key: 3, colour: .red), relation: .left)

    // Add 2 as the red left child of 3
    addChild(parent: tree.root!.leftChild!, child: RedBlackNode(key: 2, colour: .red), relation: .left)
    
    XCTAssert(!tree.verify())
  }
  
  func testFind() throws {
    let tree = RedBlackTree()
    
    tree.root = RedBlackNode(key: 5, colour: .black)

    // Add 3 as red left child
    addChild(parent: tree.root!, child: RedBlackNode(key: 3, colour: .red), relation: .left)
    
    // Add 1 and 4 as black children to 3 and add 6 as the black right child of 5
    addChild(parent: tree.root!.leftChild!, child: RedBlackNode(key: 1, colour: .black), relation: .left)
    addChild(parent: tree.root!.leftChild!, child: RedBlackNode(key: 4, colour: .black), relation: .right)
    
    addChild(parent: tree.root!, child: RedBlackNode(key: 6, colour: .black), relation: .right)
    
    XCTAssert(tree.find(key: 5) != nil)
    XCTAssert(tree.find(key: 4) != nil)
    XCTAssert(tree.find(key: 8) == nil)
    XCTAssert(tree.find(key: 2) == nil)
  }

  func testInsertion() throws {
    var set = Set<Int>(0...100)
    let tree = RedBlackTree()
    
    while (!set.isEmpty) {
      let i = set.randomElement()!
      set.remove(i)
      
      XCTAssert(tree.insert(key: i))
      XCTAssert(tree.verify())
    }
    
    for i in 0...100 {
      XCTAssert(tree.find(key: i) != nil)
    }
  }
  
  func testDeletion() throws {
    var set = Set<Int>(0...100)
    let tree = RedBlackTree()
    
    while (!set.isEmpty) {
      let i = set.randomElement()!
      set.remove(i)
      
      _ = tree.insert(key: i)
    }
    
    set = Set<Int>(0...100)
    
    while (!set.isEmpty) {
      let i = set.randomElement()!
      set.remove(i)
      
      XCTAssert(tree.remove(key: i))
      XCTAssert(tree.verify())
    }
    
    for i in 0...100 {
      XCTAssert(tree.find(key: i) == nil)
    }
  }

  func testLargeInsertionAndDeletion() throws {
    let tree = RedBlackTree()
    
    var inserted = Set<Int>()
    
    XCTAssert(tree.verify())
    
    for _ in 0 ... 10000 {
      
      if (Int.random(in: 1...10) < 7 || inserted.isEmpty) {
        let i = Int.random(in: 0...200)
        
        inserted.insert(i)
        
        _ = (tree.insert(key: i))
      }
      else {
        let i = inserted.randomElement()!
        
        inserted.remove(i)
        
        _ = (tree.remove(key: i))
      }
      
      XCTAssert(tree.verify())
    }
    
    
  }
}

extension RedBlackTree {
  // verifies the properties of a Red Black tree. Returns true iff the tree satisfies them
  func verify() -> Bool {
    if let r = root {
      do {
        return try r.recursiveVerify().proper
      } catch {
        return false
      }
      
    }
    
    return true
  }
}


extension RedBlackNode {
  func recursiveVerify() throws -> (height: Int, proper: Bool) {
    // verify the children
    let left = leftChild == nil ? (height: 0, proper: true) : try leftChild!.recursiveVerify()
    let right = rightChild == nil ? (height: 0, proper: true) : try rightChild!.recursiveVerify()

    let height = left.height
    var proper = left.height == right.height && left.proper && right.proper
    

    // Check to see that the node is the proper child of its parent
    if let p = parent {
      if let child = p.children[parentRelation] {
        XCTAssert(key == child.key)
        proper = proper && key == child.key
      }
      else {
        proper = false
      }
    }

    // Check to see that the node is infact the parent to its children
    if let l = leftChild {
      XCTAssert(self.key == l.parent!.key)
    }

    if let r = rightChild {
      XCTAssert(self.key == r.parent!.key)
    }

    if colour == .black {
      return (height + 1, proper)
    }
    else if let p = parent {
      // check see that the node and the parent are not both red
      return (height, proper && p.colour != .red)
    }
    else {
      return(height, proper)
    }
  }
}
