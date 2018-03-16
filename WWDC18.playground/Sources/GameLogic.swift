import Foundation

public class GameLogic: GameLogicDelegate {
    private var board: [[Player?]]
    public var layoutDelegate: GameLayoutDelegate?
    
    public init(){
        board = Array(repeating: Array(repeating: nil, count: 7), count: 6)
    }
    
    //MARK: - GameLogicDelegate
    public func movePlayed(player: Player, column: Int) {
        rows: for i in 0...5 {
            //Keep iterating until we find a next empty spot
            guard board[i][column] == nil else { continue }
            //Place the player in the next empty space
            board[i][column] = player
            //If it is the last space available, notify UI to disable column
            if i == 5 {
                layoutDelegate?.allMovesMade(for: column)
            }
            break rows
        }
        print(board)
    }
}
