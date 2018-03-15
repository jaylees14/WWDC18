import Foundation
import ARKit

//GameBoardLayout deals with the user interaction of the game board.
//This involves drawing the board and associated items, animating the moves
//and notifying the GameLogic of moves made

public class GameBoardLayout {
    private var anchor: ARPlaneAnchor
    public var delegate: GameLogicDelegate?
    
    public init(anchor: ARPlaneAnchor){
        self.anchor = anchor
    }
    
    public func generate() -> SCNNode {
        let board = generateBoard()
        addRowSelectors(to: board)
        return board
    }
    
    //Emulate the dropping of the puck onto the board
    public func dropPuck(player: Player, column: Int){
        
    }
    
    //Create and correctly layout a board from the SCN file
    private func generateBoard() -> SCNNode {
        guard let daePath = Bundle.main.url(forResource: "Connect4", withExtension: "scn"),
            let model = try? SCNScene(url: daePath, options: nil) else {
                fatalError("Board could not be initialized.")
        }
        let tempNode = SCNNode()
        tempNode.addChildNode(model.rootNode)
        tempNode.position = SCNVector3Zero
        tempNode.scale = SCNVector3(0.001, 0.001, 0.001)
        tempNode.eulerAngles.x = degreesToRadians(-90)
        return tempNode
    }
    
    //Draw the additional row selectors to the board
    private func addRowSelectors(to board: SCNNode){
        
    }
}
