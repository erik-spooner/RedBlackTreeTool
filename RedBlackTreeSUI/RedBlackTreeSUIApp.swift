//
//  RedBlackTreeSUIApp.swift
//  RedBlackTreeSUI
//
//  Created by Erik Spooner on 2022-03-17.
//

import SwiftUI

@main
struct RedBlackTreeSUIApp: App {
  let windowFrame : CGSize = CGSize(width: 1200, height: 1000)
  let buttonFrame : CGSize = CGSize(width: 1200, height: 100)
  
  let scene : TreeScene
  
  init() {
    scene = TreeScene()
    
    scene.size = CGSize(width: windowFrame.width, height: windowFrame.height - buttonFrame.height)
    scene.scaleMode = .fill

    scene.anchorPoint = CGPoint(x: 0.5, y: 0.8)
  }
  
  var body: some Scene {
    WindowGroup {
      ContentView(scene: scene)
    }
  }
}
