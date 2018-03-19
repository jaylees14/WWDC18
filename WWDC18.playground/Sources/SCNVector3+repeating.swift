import Foundation
import SceneKit

public extension SCNVector3 {
    init(repeating value: Float){
        self.init(value, value, value)
    }
}
