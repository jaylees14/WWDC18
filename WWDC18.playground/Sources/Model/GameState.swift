import Foundation

public struct GameState {
    typealias Board = [[Player?]] 
    var board: Board
    var currentPlayer: Player
    var previousMove: (row: Int, column: Int)?
    
    init(board: Board, currentPlayer: Player, previousMove: (Int, Int)? = nil){
        self.board = board
        self.currentPlayer = currentPlayer
        self.previousMove = previousMove
    }
}
