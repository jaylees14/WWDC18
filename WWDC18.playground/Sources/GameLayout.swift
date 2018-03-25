import Foundation
import ARKit

//GameBoardLayout deals with the user interaction of the game board.
//This involves drawing the board and associated items, animating the moves
//and notifying the GameLogic of moves made
//It is also notified, by the game logic, of necessary changes required to the UI

public class GameLayout: GameLayoutDelegate {
    private var board: GameBoard
    public var logicDelegate: GameLogicDelegate?
    public var viewDelegate: ViewDelegate?
    public let boardSize = (width: 7, height: 6)
    
    public init(){
        self.board = GameBoard()
    }
    
    public func getBoard() -> SCNNode {
        return board
    }
    
    public func processTouch(_ touch: SCNHitTestResult){
        if let column = board.getColumn(for: touch) {
            logicDelegate?.movePlayed(column: column)
        }
    }
    
    //MARK: - GameLayoutDelegate
    public func makeMove(player: Player, column: Int, row: Int){
        let puck = PlayerPuck(player: player, column: column)
        board.addChildNode(puck)
        puck.drop(to: row)
    }
    
    public func allMovesMade(for column: Int){
        board.remove(column)
    }
    
    public func gameWon(by player: Player){
        board.removeAllColumns()
        viewDelegate?.showAlert(title: "Congratulations!",
                                message: "\(player.rawValue) won! \(player.otherPlayer().rawValue), think you can do better? Click reset below to play again!")
    }
    
    public func gameDrawn(){
        board.removeAllColumns()
        viewDelegate?.showAlert(title: "Oh no!",
                                message: "Looks like it was a draw. You can definitely do better than that, hit reset below to have another go!")
    }
}
