import Foundation

public protocol GameLogicDelegate {
    func movePlayed(player: Player, column: Int)
}
