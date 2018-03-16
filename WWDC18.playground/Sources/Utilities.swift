import Foundation
import UIKit


public func degreesToRadians(_ degrees: Float) -> Float {
    return degrees * Float.pi/180
}

public func radiansToDegrees(_ radians: Float) -> Float {
    return radians / Float.pi * 180.0
}

//Standard error function
func showError(title: String, withMessage: String, fromController: UIViewController){
    let alertView = UIAlertController(title: title, message: withMessage, preferredStyle: .alert)
    let okButton = UIAlertAction(title: "Okay", style: .default)
    alertView.addAction(okButton)
    fromController.present(alertView, animated: true, completion: nil)
}
