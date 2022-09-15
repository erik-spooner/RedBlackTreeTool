//
//  ViewController.swift
//  RedBlackTree
//
//  Created by Erik Spooner on 2022-09-07.
//

import Cocoa
import Combine

class TreeViewController: NSViewController, NSTextFieldDelegate
{
  private var treeScene : TreeScene!
  
  private var mainStack : NSStackView!
  private var interfaceStack : NSStackView!
  
  private var nextButton : NSButton!
  private var prevButton : NSButton!
  private var skipButton : NSButton!
  private var insertButton : NSButton!
  private var removeButton : NSButton!

  private var inputField : NSTextField!
  private var stepDescriptionField : NSTextField!
  
  private var oldTouchPoint : NSPoint = NSPoint()
  
  private var receiver : AnyCancellable?
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
    treeScene = TreeScene()
    treeScene.insert(key: 1)
    treeScene.insert(key: 0)
    treeScene.insert(key: 2)
    treeScene.insert(key: 5)
    treeScene.insert(key: 4)
    treeScene.insert(key: 9)
    treeScene.skip()
    
    
    // Create the buttons
    nextButton = NSButton(title: "Next", target: self, action: #selector(self.next))
    prevButton = NSButton(title: "Previous", target: self, action: #selector(self.prev))
    skipButton = NSButton(title: "Skip", target: self, action: #selector(self.skip))
    insertButton = NSButton(title: "Insert", target: self, action: #selector(self.insert))
    removeButton = NSButton(title: "Remove", target: self, action: #selector(self.remove))
    
    // Create the text field
    inputField = NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 30))
    inputField.drawsBackground = true
    inputField.isEditable = true
    inputField.backgroundColor = .white
    inputField.delegate = self
    
    stepDescriptionField = NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 30))
    stepDescriptionField.isSelectable = false
    stepDescriptionField.isBordered = false
    stepDescriptionField.wantsLayer = true
    stepDescriptionField.layer?.backgroundColor = .black
    stepDescriptionField.alignment = .center
    stepDescriptionField.font = NSFont(descriptor: NSFontDescriptor(name: "Helvetica", size: 10), size: 20)
    
    // Add the buttons and textfield to the interface
    interfaceStack = NSStackView()
    interfaceStack.orientation = .horizontal
    interfaceStack.addArrangedSubview(nextButton)
    interfaceStack.addArrangedSubview(prevButton)
    interfaceStack.addArrangedSubview(skipButton)
    interfaceStack.addArrangedSubview(inputField)
    interfaceStack.addArrangedSubview(insertButton)
    interfaceStack.addArrangedSubview(removeButton)
    
    interfaceStack.wantsLayer = true
    interfaceStack.layer?.backgroundColor = .black


    // Add the scene and the interface to the view
    mainStack = NSStackView()
    mainStack.translatesAutoresizingMaskIntoConstraints = false
    mainStack.orientation = .vertical
    
    mainStack.addArrangedSubview(interfaceStack)
    mainStack.addArrangedSubview(stepDescriptionField)
    mainStack.addArrangedSubview(treeScene)
    
    self.view.addSubview(mainStack)
    
    // resise the scene with the view
    let constraints = [
      mainStack.topAnchor.constraint(equalTo: view.topAnchor),
      mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      stepDescriptionField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      stepDescriptionField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ]
    
    NSLayoutConstraint.activate(constraints)
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    self.view.window!.backgroundColor = .gray
    
    // Disable the buttons when an animation is running
    self.receiver = treeScene.animationPublisher.sink { value in
      self.nextButton.isEnabled = !value
      self.prevButton.isEnabled = !value
      self.skipButton.isEnabled = !value
    }
  }
  
  override func viewDidDisappear() {
    self.receiver = nil
  }
  
  func controlTextDidChange(_ obj: Notification) {
  }
  
  ///
  /// Button Press Function
  ///
  
  @objc private func next() {
    stepDescriptionField.stringValue = treeScene.next()
  }

  @objc private func prev() {
    stepDescriptionField.stringValue = treeScene.previous()
  }
  
  @objc private func insert() {
    treeScene.insert(key: inputField.integerValue)
    next()
  }

  @objc private func remove() {
    treeScene.remove(key: inputField.integerValue)
    next()
  }
  
  @objc private func skip() {
    treeScene.skip()
  }
  
  ///
  /// Mouse events
  ///
  override func mouseDown(with event: NSEvent) {
    oldTouchPoint = event.locationInWindow
  }

  override func mouseDragged(with event: NSEvent) {
    treeScene.rootNodeDisplacement = treeScene.rootNodeDisplacement + CGPoint(x: event.locationInWindow.x - oldTouchPoint.x,
                                                                              y: oldTouchPoint.y - event.locationInWindow.y)
    
    oldTouchPoint = event.locationInWindow
  }
  
  override func scrollWheel(with event: NSEvent) {
    if event.scrollingDeltaY > 0 {
      treeScene.scaleUnitSquare(to: NSSize(width: 1.01, height: 1.01))
    }
    else {
      treeScene.scaleUnitSquare(to: NSSize(width: 0.99, height: 0.99))
    }
  }


}



