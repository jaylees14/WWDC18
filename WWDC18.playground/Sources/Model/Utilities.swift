import Foundation
import UIKit

/**
 Utilities
 **/

//Convert from degrees to radians
public func degreesToRadians(_ degrees: Float) -> Float {
    return degrees * Float.pi/180
}

//Convert from radians to degrees
public func radiansToDegrees(_ radians: Float) -> Float {
    return radians / Float.pi * 180.0
}
