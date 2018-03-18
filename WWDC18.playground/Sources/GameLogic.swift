import Foundation

///Each position on the board is represented as a 2D-coordinate, with the origin in the bottom left
///
/// (5,0) | (5,1) | (5,2) | (5,3) | (5,4) | (5,5) | (5,6)
/// (4,0) | (4,1) | (4,2) | (4,3) | (4,4) | (4,5) | (4,6)
/// (3,0) | (3,1) | (3,2) | (3,3) | (3,4) | (3,5) | (3,6)
/// (2,0) | (2,1) | (2,2) | (2,3) | (2,4) | (2,5) | (2,6)
/// (1,0) | (1,1) | (1,2) | (1,3) | (1,4) | (1,5) | (1,6)
/// (0,0) | (0,1) | (0,2) | (0,3) | (0,4) | (0,5) | (0,6)
public class GameLogic: GameLogicDelegate {
    private var board: [[Player?]]
    private var currentPlayer: Player
    public var layoutDelegate: GameLayoutDelegate?

    public init(){
        currentPlayer = .red
        board = Array(repeating: Array(repeating: nil, count: 7), count: 6)
    }
    
    //MARK: - GameLogicDelegate
    public func movePlayed(column: Int) {
        rows: for i in 0...5 {
            //Keep iterating until we find a next empty spot
            guard board[i][column] == nil else { continue }
            
            //Place the player in the next empty space
            board[i][column] = currentPlayer
            layoutDelegate?.makeMove(player: currentPlayer, column: column, row: i)
            
            //If it is the last space available, notify UI to disable column
            if i == 5 {
                layoutDelegate?.allMovesMade(for: column)
            }
            break rows
        }
        
        checkWin()
        
        //Check Draw
        if board.filter({$0.contains(where: {$0 == nil})}).count == 0 {
            layoutDelegate?.gameDrawn()
        }
        currentPlayer = currentPlayer == .red ? .yellow : .red
    }
    
    func checkWin(){
        //There are four ways a game can be won:
        
        //1 - Horizontal Line
        for r in 0..<6 {
            var count = 0
            for c in 0..<7 {
                count = board[r][c] == currentPlayer ? count + 1 : 0
                if count == 4 {
                    print("Horizontal line")
                    layoutDelegate?.gameWon(by: currentPlayer)
                    return
                }
            }
        }
    
        //2 - Vertical Line
        for c in 0..<7 {
            var count = 0
            for r in 0..<6 {
                count = board[r][c] == currentPlayer ? count + 1 : 0
                if count == 4 {
                    print("Vertical line")
                    layoutDelegate?.gameWon(by: currentPlayer)
                    return
                }
            }
        }
        
        
        //3 - L-R Diagonal
        
        
        //4 - R-L Diagonal
    }
    
}
