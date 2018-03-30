import Foundation


/**
 ViewDelegate
 - Controls interaction between the game layout and the UI
 **/
public protocol ViewDelegate {
    func showAlert(title: String, message: String)
    func change(to player: Player)
}
