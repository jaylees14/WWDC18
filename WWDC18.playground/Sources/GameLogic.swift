import Foundation

///Each position on the board is represented as a 2D-coordinate, with the origin in the bottom left
///
/// (0,5) | (1,5) | (2,5) | (3,5) | (4,5) | (5,5) | (6,5)
/// (0,4) | (1,4) | (2,4) | (3,4) | (4,4) | (5,4) | (6,4)
/// (0,3) | (1,3) | (2,3) | (3,3) | (4,3) | (5,3) | (6,3)
/// (0,2) | (1,2) | (2,2) | (3,2) | (4,2) | (5,2) | (6,2)
/// (0,1) | (1,1) | (2,1) | (3,1) | (4,1) | (5,1) | (6,1)
/// (0,0) | (1,0) | (2,0) | (3,0) | (4,0) | (5,0) | (6,0)

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
        rows: for row in 0..<6 {
            //Keep iterating until we find a next empty spot
            guard board[row][column] == nil else { continue }
            
            //Place the player in the next empty space
            board[row][column] = currentPlayer
            layoutDelegate?.makeMove(player: currentPlayer, column: column, row: row)
            
            //If it is the last space available, notify UI to disable column
            if row == 5 {
                layoutDelegate?.allMovesMade(for: column)
            }
            break rows
        }
        
        if checkWin() {
             layoutDelegate?.gameWon(by: currentPlayer)
        } else if checkDraw() {
            layoutDelegate?.gameDrawn()
        }
        currentPlayer = currentPlayer == .red ? .yellow : .red
    }
    
    func checkWin() -> Bool {
        //There are four ways a game can be won:
        //1 - Horizontal Line
        for r in 0..<6 {
            var count = 0
            for c in 0..<7 {
                count = board[r][c] == currentPlayer ? count + 1 : 0
                if count == 4 {
                    return true
                }
            }
        }

        //2 - Vertical Line
        for c in 0..<7 {
            var count = 0
            for r in 0..<6 {
                count = board[r][c] == currentPlayer ? count + 1 : 0
                if count == 4 {
                    return true
                }
            }
        }
        
        //3 - L-R Diagonal
        //(0,3) (1,2) (2,1) (3,0)
        //(0,4) (1,3) (2,2) (3,1) (4,0)
        //(0,5) (1,4) (2,3) (3,2) (4,1) (5,0)
        for z in 3...5 {
            var x = 0
            var y = z
            var count = 0
            while y >= 0 {
                count = board[y][x] == currentPlayer ? count + 1 : 0
                x += 1
                y -= 1
                if count == 4 {
                    return true
                }
            }
        }
        
        //(1,5) (2,4) (3,3) (4,2) (5,1) (6,0)
        //(2,5) (3,4) (4,3) (5,2) (6,1)
        //(3,5) (4,4) (5,3) (6,2)
        for z in 1...3 {
            var x = z
            var y = 5
            var count = 0
            while x <= 6 {
                count = board[y][x] == currentPlayer ? count + 1 : 0
                x += 1
                y -= 1
                if count == 4 {
                    return true
                }
            }
        }
        
        //4 - R-L Diagonal
        //4 - R-L Diagonal
        //(0,2) (1,3) (2,4) (3,5)
        //(0,1) (1,2) (2,3) (3,4) (4,5)
        //(0,0) (1,1) (2,2) (3,3) (4,4) (5,5)
        for z in 0...2 {
            var x = 0
            var y = z
            var count = 0
            while y <= 5 {
                count = board[y][x] == currentPlayer ? count + 1 : 0
                x += 1
                y += 1
                if count == 4 {
                    return true
                }
            }
        }
        //(1,0) (2,1) (3,2) (4,3) (5,4) (6,5)
        //(2,0) (3,1) (4,2) (5,3) (6,4)
        //(3,0) (4,1) (5,2) (6,3)
        for z in 1...3 {
            var x = z
            var y = 0
            var count = 0
            while x <= 6 {
                count = board[y][x] == currentPlayer ? count + 1 : 0
                x += 1
                y += 1
                if count == 4 {
                    return true
                }
            }
        }
        return false
    }
    
    func checkDraw() -> Bool {
        return board.filter({$0.contains(where: {$0 == nil})}).count == 0
    }
    
}
