import Foundation
import ARKit

//GameBoardLayout deals with the user interaction of the game board.
//This involves drawing the board and associated items, animating the moves
//and notifying the GameLogic of moves made
//It is also notified, by the game logic, of necessary changes required to the UI

public class GameLayout: GameLayoutDelegate {
    private var columnSelectors: [SCNNode]
    private var board: SCNNode?
    public var logicDelegate: GameLogicDelegate?
    public var viewDelegate: ViewDelegate?
    public let boardSize = (width: 7, height: 6)
    
    public init(){
        self.columnSelectors = [SCNNode]()
    }
    
    public func generate() -> SCNNode {
        board = SCNNode()
        if let model = getModel(.connectFour){
            board!.addChildNode(model)
            board!.scale = SCNVector3(repeating: 0.001)
            board!.position = SCNVector3(0,0,0)
            board!.eulerAngles.x = degreesToRadians(-90)
            board!.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            addColumnSelectors()
        }
        return board!
    }
    
    public func processTouch(_ touch: SCNHitTestResult){
        if let node = columnSelectors.filter({$0.childNodes.contains(touch.node)}).first,
            let column = columnSelectors.index(of: node) {
            logicDelegate?.movePlayed(column: column)
        }
    }
    
    //Draw the column selector (▽) to the board
    private func addColumnSelectors(){
        for index in 0..<boardSize.width {
            if let model = getModel(.triangle){
                let node = SCNNode()
                node.addChildNode(model)
                node.scale = SCNVector3(repeating: 0.5)
                node.position = SCNVector3(x: Float(10+(47*index)), y: 0, z: 385)
                node.eulerAngles.x = degreesToRadians(-90)
                columnSelectors.append(model)
                board?.addChildNode(node)
            }
        }
    }
    
    private func getModel(_ model: SceneModel) -> SCNNode? {
        guard let daePath = Bundle.main.url(forResource: model.rawValue, withExtension: "scn"),
            let model = try? SCNScene(url: daePath, options: nil) else {
                return nil
        }
        return model.rootNode
    }
    
    
    //MARK: - GameLayoutDelegate
    public func makeMove(player: Player, column: Int, row: Int){
        if let model = getModel(player == .red ? .redPuck : .yellowPuck){
            let puckNode = SCNNode()
            puckNode.addChildNode(model)
            puckNode.scale = SCNVector3(repeating: 0.48)
            //Place it one row above the top of the board
            puckNode.position = SCNVector3(x: Float(-80+(47*column)), y: 2, z: 105+(47*6))
            puckNode.eulerAngles.x = degreesToRadians(-90)
            board?.addChildNode(puckNode)
            drop(puckNode, to: row)
        }
    }
    
    private func drop(_ node: SCNNode, to row: Int){
        //We always want them to be travelling at the same speed
        //So we use Time = Distance/Speed
        let offset: Float = 7.0
        let distance = Float(47*(6-row)) + offset
        let speed: Float = 500.0
        let time = TimeInterval(distance/speed)
        
        let drop = SCNAction.move(by: SCNVector3Make(0, 0, -distance), duration: time)
        let bounce = SCNAction.move(by: SCNVector3Make(0, 0, 20), duration: 0.1)
        let invBounce = SCNAction.move(by: SCNVector3Make(0, 0, -20 + offset), duration: 0.1)
        let sequence = SCNAction.sequence([drop, bounce, invBounce])
        node.runAction(sequence)
    }
    
    
    public func allMovesMade(for column: Int){
        columnSelectors[column].removeFromParentNode()
    }
    
    public func gameWon(by player: Player){
        viewDelegate?.showAlert(title: "Congratulations!", message: "\(player.rawValue) won! \(player.otherPlayer().rawValue), think you can do better? Click reset below to play again!")
    }
    
    public func gameDrawn(){
        viewDelegate?.showAlert(title: "Oh no!", message: "Looks like it was a draw. You can definitely do better than that, hit reset below to have another go!")
    }
}
