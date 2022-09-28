import Combine
import AppKit
import Foundation


/// Class made in conjunction with the AnimationGroup struct as a way to more nicely run sequential animations with
/// NSAnimationContext.runAnimationGroup
///
class AnimationGroupHandler {
  private var animations : [AnimationGroup] = [AnimationGroup]()
  private var receiver : AnyCancellable! = nil
  
  private (set) var completionPublisher : PassthroughSubject<Bool, Never> = PassthroughSubject<Bool, Never>()
  
  func addAnimation(animation : AnimationGroup) {
    animations.append(animation)
  }
  

  /// Runs all of the animation groups sequentially, removing each animation as it is played, and
  /// sending a completion message when there are no more animations left
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


/// Struct containing all the information necessary to create an NSAnimation Context and run a main function and completion function
/// Will send out a message via the completionPublisher to notify when the animationGroup has finished running
struct AnimationGroup {
  var duration : TimeInterval = 0
  var function : () -> Void = {}
  var completion : () -> Void = {}

  private (set) var completionPublisher : PassthroughSubject<Bool, Never> = PassthroughSubject<Bool, Never>()
  
  /// Creates and runs an animation group, sends a compeletion message when its done
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
