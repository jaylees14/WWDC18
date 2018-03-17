import Foundation

public protocol GameLayoutDelegate {
    func allMovesMade(for column: Int)
    func gameWon(by player: Player)
    func gameDrawn()
}
