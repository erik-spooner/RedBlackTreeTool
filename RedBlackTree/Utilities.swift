
/// Convienence fuctions/operations for CGPoints/Vectors
///
///

import Foundation

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGVector {
  return CGVector(dx: left.x - right.x, dy: left.y - right.y)
}

public func + (left: CGPoint, right: CGVector) -> CGPoint {
  return CGPoint(x: left.x + right.dx, y: left.y + right.dy)
}

public func - (left: CGPoint, right: CGVector) -> CGPoint {
  return CGPoint(x: left.x - right.dx, y: left.y - right.dy)
}

public func += (left: inout CGPoint, right: CGVector) {
  left = left + right
}

public func -= (left: inout CGPoint, right: CGVector) {
  left = left - right
}
