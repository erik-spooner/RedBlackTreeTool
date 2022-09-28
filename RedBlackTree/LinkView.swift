//
//
//
//
//  
//

import Foundation
import AppKit


///
/// A line drawn between a parent and child node
///
class Link : NSView {
  var direction : Bool
    
  init(frame : CGRect, direction : Bool) {
    self.direction = direction
    
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
