import Foundation

public protocol ViewDelegate {
    func showAlert(title: String, message: String)
    func change(to player: Player)
}
