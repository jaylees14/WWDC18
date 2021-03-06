import UIKit
import SceneKit

/**
 Extensions
 - Utilities used to extend existing classes
 **/

public extension SCNVector3 {
    /// Initialise a SCNVector3 with the same value for x, y and z
    ///
    /// - Parameter v: value to be repeated
    init(repeating v: Float){
        self.init(v, v, v)
    }
}

extension UIColor {
    /// Initalise a UIColor from a hex string formatted as RRGGBB or RRGGBBAA, with or without a leading #
    ///
    /// - Parameter hex: A hex string, formatted as above
    public convenience init(fromHex hex: String){
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        var rgb: UInt32 = 0
        
        let sanitisedHex = hex.replacingOccurrences(of: "#", with: "")
        if Scanner(string: sanitisedHex).scanHexInt32(&rgb) {
            if sanitisedHex.count == 6 {
                red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
                green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
                blue = CGFloat((rgb & 0x0000FF)) / 255.0
            } else if sanitisedHex.count == 8 {
                red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
                green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
                blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
                alpha = CGFloat((rgb & 0x000000FF)) / 255.0
            }
        }
        self.init(displayP3Red: red, green: green, blue: blue, alpha: alpha)
    }
}

