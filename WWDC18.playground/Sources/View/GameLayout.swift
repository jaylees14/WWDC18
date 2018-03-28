import Foundation
import ARKit

//GameBoardLayout deals with the user interaction of the game board.
//This involves drawing the board and associated items, animating the moves
//and notifying the GameLogic of moves made
//It is also notified, by the game logic, of necessary changes required to the UI

public class GameLayout: GameLayoutDelegate {
    private var board: GameBoard?
    public let boardSize = (width: 7, height: 6)
    public var logicDelegate: GameLogicDelegate?
    public var viewDelegate: ViewDelegate?
    public var planeAnchor: ARPlaneAnchor? {
        didSet {
            guard let anchor = planeAnchor else { return }
            if board == nil {
                self.board = GameBoard(anchor: anchor)
            } else {
                self.board?.updatePosition(to: anchor)
            }
        }
    }
    
    public func getBoard() -> SCNNode? {
        return board
    }
    
    public func processTouch(_ touch: SCNHitTestResult){
        if let column = board?.getColumn(for: touch) {
            logicDelegate?.movePlayed(column: column)
        }
    }
    
    public func reset(){
        board?.reset()
    }
    
    //MARK: - GameLayoutDelegate
    public func makeMove(player: Player, column: Int, row: Int){
        let puck = PlayerPuck(player: player, column: column)
        board?.addPuck(puck)
        puck.drop(to: row)
    }
    
    public func allMovesMade(for column: Int){
        board?.remove(column)
    }
    
    public func gameWon(by player: Player){
        board?.removeAllColumns()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
            self.viewDelegate?.showAlert(title: "Congratulations!",
                                         message: "\(player.rawValue) won! \(player.other().rawValue), think you can do better? Click reset below to play again!")
        })
        
    }
    
    public func gameDrawn(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
            self.viewDelegate?.showAlert(title: "Oh no!",
                                         message: "Looks like it was a draw! Want to try again? Hit the reset button below!")
        })
    }
}
