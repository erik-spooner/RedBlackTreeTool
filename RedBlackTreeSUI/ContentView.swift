//
//  ContentView.swift
//  RedBlackTreeSUI
//
//  Created by Erik Spooner on 2022-03-08.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
  let windowFrame : CGSize = CGSize(width: 1200, height: 1000)
  let buttonFrame : CGSize = CGSize(width: 1200, height: 100)
  
  @ObservedObject var scene : TreeScene
  
  @State var displayText = " "
  
  @State private var key = ""
  @State private var play = false

    
  var body: some View {
    VStack {
      createTopButtons()
            
      SpriteView(scene: scene).frame(width: windowFrame.width, height: windowFrame.height - buttonFrame.height, alignment: .center)
    }
  }
  
  func insert() {
    if let k = Int(key) {
      scene.insert(key: k)
    }
    else {
      print("Not a valid Integer")
    }
    
    key = ""
  }
  
  func delete() {
    if let k = Int(key) {
      scene.remove(key: k)
    }
    else {
      print("Not a valid Integer")
    }
    
    key = ""
  }
  
  func pause() {
    play.toggle()
    scene.play = play
  }
  
  func nextStep() {
    scene.next()
  }

  func prevStep() {
    scene.previous()
  }

  func skip() {
    print("Skip")
  }
    
  private func createTopButtons() -> some View {
    return VStack {
        HStack {
          // Create the Pause Button
          Button(play ? "Pause" : "Play", action: pause)

          // Create the next and prev buttons
          Button("Next Step", action: nextStep).disabled(play)
          Button("Prev Step", action: prevStep).disabled(play)
          Button("Skip", action: skip).disabled(play)
          
          TextField(
            "Key",
            text: $key
          ).frame(width: buttonFrame.width / 10.0)
          
          // Insert and delete buttons
          VStack{
            Button("Insert", action: insert)
            Button("Delete", action: delete)
          }
        }
      Text(scene.stepDescription)
    }.frame(width: buttonFrame.width, height: buttonFrame.height, alignment: .center).border(Color.blue)
  }
}
