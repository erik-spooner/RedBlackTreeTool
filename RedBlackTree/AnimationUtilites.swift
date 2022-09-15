import Combine
import AppKit
import Foundation

class AnimationGroupHandler {
  private var animations : [AnimationGroup] = [AnimationGroup]()
  private var receiver : AnyCancellable! = nil
  
  var completionPublisher : PassthroughSubject<Bool, Never> = PassthroughSubject<Bool, Never>()
  
  func addAnimation(animation : AnimationGroup) {
    animations.append(animation)
  }
  
  func runAnimations() {
    if let animation = animations.first {
      receiver = animation.completionPublisher.sink(receiveValue: {_ in self.runAnimations()})
      
      animation.run()
      animations.remove(at: 0)
    }
    else {
      completionPublisher.send(true)
    }
  }
}

struct AnimationGroup {
  var duration : TimeInterval = 0
  var function : () -> Void = {}
  var completion : () -> Void = {}

  var completionPublisher : PassthroughSubject<Bool, Never> = PassthroughSubject<Bool, Never>()
  
  func run() {
    NSAnimationContext.runAnimationGroup({ context in
      context.duration = duration
      context.allowsImplicitAnimation = true
      function()
    }, completionHandler: {
      completion()
      completionPublisher.send(true)
    })
  }
}
