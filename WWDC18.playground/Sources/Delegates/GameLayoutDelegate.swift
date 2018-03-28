import Foundation

public protocol GameLayoutDelegate {
    func makeMove(player: Player, column: Int, row: Int)
    func allMovesMade(for column: Int)
    func gameWon(by player: Player)
    func gameDrawn()
}
