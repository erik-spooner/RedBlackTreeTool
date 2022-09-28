## Overview

This project is a tool to help a user understand the process of the Red Black Tree's insertion and deletion algorithms through the use of a visual aid. A user can insert and delete values into a Red Black tree and watch the step by step process with a small explanation of each step. A user can also step backwards through each operation as well.


## Use Instructions

Upon launch the user will see a the interface with an empty Red Black Tree (contains only one nil node). From here they can type integer values into the text field that will either be inserted or deleted from the tree. Once a value has been put into the input field and the insert or delete buttons have been pressed the animation for the appropriate operation can be played/paused by pressing the play/pause button. If the animation has been paused each step of the operation can be explored though the use of the next and previous buttons. Finally the animation can be skiped entirely through the use of the skip button.


## Red Black Algorithm

A Red Black Tree is a variation on a binary tree that offers the advantage that it balances the nodes of the tree during insertion and deletion operations in such a way that these operations have strict bounds on time complexity (O(log n) to be exact). Both the insertion and deletion operations can be broken down into applying a sequence of smaller more basic operations that modify the nodes of the tree in some local area. These smaller operations are the creation and deletion of a node, rotation of a node, changing the color of a node, and swaping two nodes. Creating a new node is accomplished by taking an existing nil node, giving it the new key and then creating two new nil children. Deleting a node is done by changing the key of a node to nil, and removing its nil children (note that the algorithm will rearrage the tree such that the node that is being deleted will have children that are both nil). Rotation of a node is when a non-nil, non-root node is 'rotated' up to its parent's position, making the parent a child of itself, and making its interior child the interior child of the former parent (see the diagram below for an example of rotating a node n). Changing the color of a node is simply changing the color of the node to be black or red. Lastly swaping two nodes is done by exchanging the keys of two nodes, not their color (This is only ever done with predecessor/successor nodes). 


          g                     g
          |                     |
          p        ---->        n
         / \                   / \
        s   n                 p   d
           / \               / \
          c   d             s   c


## Graphics and Animation Queue

One thing that arises from a Red Black Tree is that the insertion and deletion operations are not inverses of eachother (i.e. if you insert value n then delete value n the tree could be in a different form than you stated with). Since one of our goals in this project was to be able to progress through the insertion and deletion operations forwards and backwards this presents two problems, one we cannot present the tree directly, and there is no easy way to go backwards through the operations. To solve this we modified the Red Black Tree slightly to produced a list of smaller steps that compose the larger operation (as described above), and then apply these steps sequentially to a visually representable tree of NSViews. These smaller operations are nice in the fact that they are easy to invert and thus by applying each inverted in reverse order we can move backwards through the insertion and deletion operations. Core Animation was used to animate the movement and changing colors in the visual tree. 


## Use of AutoLayout and Constraints

Maually positioning nodes in a binary tree to make the tree look nice is difficult, algorithms to calculate the position exist, however we deemed them to be not an ideal approach for this situation, as the layout of the entire tree could change several times during a single insertion/deletion. Autolayout offers a nice solution in that it is much easier to define a set of constraints on the nodes, and have them positioned automatically. With constraints it easy it to plan a goal for the layout of the tree and then define a system of constraints that will achieve this. For this project I had several requirements that I thought would make the layout look nice. 

1. All nodes on the same depth level of the tree should have the same vertical postion
2. The left child should appear to the left and right child should appear to the right of the parent
3. Both children nodes should be the same distance away from the parent 
4. All nodes on the same depth level should have some minimum distance between eachother 
5. The tree should take as little space as possible while satisfying the above 

To start a constraint was added to the root node to fix it to some postion. Then constraints were added between parent and children nodes such that there is some fixed vertical distance between the parent and child (This vertical distance is the same in all cases). Constraints were also added to ensure that the left child must be at least some constant distance to the left of the parent, and the right child be at least some constant distance to the right of the parent. Adding lower priority constraints that the children can be no further away from the parent that that same constant distance has the effect that the children will always maintain at least that constant distance away from its parent but will try to minimize it so long as it can still satisfy all higher priority constraints.

To ensure that the children nodes were equal distance away from the parent a spacer (an invisible NSView) was added with the the constraints that the left edge of the spacer's frame has the x-coordinate of the left child's center, the right edge of the spacer has x-coordinate of the right child's center, and the center point of the spacer has the x-coordinate of the parent's center.

Lastly to ensure that all nodes at the same depth level should have some minimum distance between eachother, constraints are applied to nodes at the same depth level that are adjacent but are not siblings. The first constraint ensures that adjacent nodes are at least some constant distance away from eachother, while a second lower priority constraint is added so that they can be no more than that constant distance away.

The links between nodes are also placed via autolayout simply by constraining one corner of the link to be at the center of the parent and opposite corner ath the center of the child. 


## Files

The files in the project are

- AppDelegate - exists
- ViewController - contains the ViewController which sets up the interface for user input
- TreeScene - contains the TreeScene class which handles animating the tree
- RedBlackNodeView - contains the RedBlackNodeView class which encapsulates a single visible node of the tree. Also handles the logic / adding of constraints when making a node a child of another
- RedBlackTree - contains all the classes and logic for the actual Red Black Tree
- AnimationUtilites - contains a class for more cleanly and easily run sequential animations using NSAnimationContext
- Utilities - contains some convienence operations for CGPoints and CGVectors
