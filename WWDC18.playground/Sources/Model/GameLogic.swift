import Foundation

/**
 GameLogic
    - Controls the "logic" behind the game
    - Stores moves made
    - Determines if a game has been won/drawn
    - Notifies the game layout if all moves have been made for a given column
 **/

//Each position on the board is represented as a 2D-coordinate, with the origin in the bottom left
//(0,5) | (1,5) | (2,5) | (3,5) | (4,5) | (5,5) | (6,5)
//(0,4) | (1,4) | (2,4) | (3,4) | (4,4) | (5,4) | (6,4)
//(0,3) | (1,3) | (2,3) | (3,3) | (4,3) | (5,3) | (6,3)
//(0,2) | (1,2) | (2,2) | (3,2) | (4,2) | (5,2) | (6,2)
//(0,1) | (1,1) | (2,1) | (3,1) | (4,1) | (5,1) | (6,1)
//(0,0) | (1,0) | (2,0) | (3,0) | (4,0) | (5,0) | (6,0)

public class GameLogic: GameLogicDelegate {
    typealias Move = Int
    public let boardSize = (rows: 6, cols: 7)
    private var store: Store<GameState, Move>
    private let moveReducer = Reducer<GameState, Move> { state, column in
        let row = state.board[column].filter { $0 == nil }.count - 1
        var board = state.board
        board[column][row] = state.currentPlayer
        return GameState(board: board, currentPlayer: state.currentPlayer.other(), previousMove: (row: row, column: column))
    }
    public var layoutDelegate: GameLayoutDelegate?
    
    //MARK: - Initializer
    public init(){
        let emptyBoard: GameState.Board = Array(repeating: Array(repeating: nil, count: 6), count: 7)
        let initialState = GameState(board: emptyBoard, currentPlayer: .red)
        store = Store(reducer: moveReducer, initialState: initialState)
        store.subscribe(determineOutcome)
        store.subscribe(columnLimit)
    }
    
    //MARK: - GameLogicDelegate
    public func movePlayed(column: Int) {
        store.dispatch(column)
    }
    
    
    //MARK: - State Subscribers
    private func columnLimit(_ gameState: GameState) {
        guard let move = gameState.previousMove else { return }
        print(gameState.board)
        if move.row == 0 {
            layoutDelegate?.allMovesMade(for: move.column)
        }
    }
    
    private func determineOutcome(_ gameState: GameState) {
        guard let move = gameState.previousMove else { return }
        //Notify the UI
        layoutDelegate?.makeMove(player: gameState.currentPlayer.other(), column: move.column, row: move.row)
        
        //Check if anyone has won, or is a draw
        if hasWon(board: gameState.board, player: gameState.currentPlayer.other()) {
            layoutDelegate?.gameWon(by: gameState.currentPlayer.other())
        } else {
            for row in gameState.board {
                if row.contains(where: {$0 == nil}) { return }
            }
            layoutDelegate?.gameDrawn()
        }
    }
    
    //MARK: - Game Outcome
    private func hasWon(board: [[Player?]], player: Player) -> Bool {
        //Horizontal Line
        for r in 0..<6 {
            var count = 0
            for c in 0..<7 {
                count = board[c][r] == player ? count + 1 : 0
                if count == 4 {
                    return true
                }
            }
        }
        
        //Vertical Line
        for c in 0..<7 {
            var count = 0
            for r in 0..<6 {
                count = board[c][r] == player ? count + 1 : 0
                if count == 4 {
                    return true
                }
            }
        }
        
        //L->R Diagonal
        for z in 3...5 {
            var c = 0,  r = z, count = 0
            while r >= 0 {
                count = board[c][r] == player ? count + 1 : 0
                c += 1
                r -= 1
                if count == 4 {
                    return true
                }
            }
        }
        
        for z in 1...3 {
            var c = z, r = 5, count = 0
            while c <= 6 {
                count = board[c][r] == player ? count + 1 : 0
                c += 1
                r -= 1
                if count == 4 {
                    return true
                }
            }
        }
        
        //R->L Diagonal
        for z in 0...2 {
            var c = 0, r = z, count = 0
            while r <= 5 {
                count = board[c][r] == player ? count + 1 : 0
                c += 1
                r += 1
                if count == 4 {
                    return true
                }
            }
        }
        
        for z in 1...3 {
            var c = z, r = 0, count = 0
            while c <= 6 {
                count = board[c][r] == player ? count + 1 : 0
                c += 1
                r += 1
                if count == 4 {
                    return true
                }
            }
        }
        return false
    }
}
