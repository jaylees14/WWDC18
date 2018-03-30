import Foundation
import ARKit


/**
 GameLayout
    - Deals with user input and making corresponding moves
    - Creates all of the 3D models required
    - Notifies GameLogic of moves made
    - Is notified by GameLogic of any changes to the UI (logicDelegate)
 **/

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
    
    //Will determine if the user touched a selector and notify logic as necessary
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
        viewDelegate?.change(to: player.other())
    }
    
    //If all moves have been made for a column, remove the ability to select it
    public func allMovesMade(for column: Int){
        board?.remove(column)
    }
    
    //Notify view that game is won and remove ability to make further moves
    public func gameWon(by player: Player){
        board?.removeAllColumns()
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
            self.viewDelegate?.showAlert(title: "Congratulations!",
                                         message: "\(player.rawValue) won! \(player.other().rawValue), think you can do better? Click reset below to play again!")
        })
        
    }
    
    //Notify view that game is drawn
    public func gameDrawn(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (_) in
            self.viewDelegate?.showAlert(title: "Oh no!",
                                         message: "Looks like it was a draw! Want to try again? Hit the reset button below!")
        })
    }
}
