import Foundation


public func degreesToRadians(_ degrees: Float) -> Float {
    return degrees * Float.pi/180
}

public func radiansToDegrees(_ radians: Float) -> Float {
    return radians / Float.pi * 180.0
}
