import Foundation

public protocol GameLayoutDelegate {
    func allMovesMade(for row: Int)
    func gameWon(by player: Player)
    func gameDrawn()
}
