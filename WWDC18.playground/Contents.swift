import PlaygroundSupport
import UIKit
import ARKit

///Each position on the board is represented as a 2D-coordinate, with the origin in the bottom left
///
/// (5,0) | (5,1) | (5,2) | (5,3) | (5,4) | (5,5) | (5,6)
/// (4,0) | (4,1) | (4,2) | (4,3) | (4,4) | (4,5) | (4,6)
/// (3,0) | (3,1) | (3,2) | (3,3) | (3,4) | (3,5) | (3,6)
/// (2,0) | (2,1) | (2,2) | (2,3) | (2,4) | (2,5) | (2,6)
/// (1,0) | (1,1) | (1,2) | (1,3) | (1,4) | (1,5) | (1,6)
/// (0,0) | (0,1) | (0,2) | (0,3) | (0,4) | (0,5) | (0,6)




public class ConnectFourViewController: UIViewController, ARSCNViewDelegate {
    var sceneView: ARSCNView!
    var scene: SCNScene!
    var gameLayout: GameLayout?
    var gameLogic: GameLogic?

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        guard ARWorldTrackingConfiguration.isSupported else {
//            fatalError("AR is not supported on this device.")
//        }
//
//        //Initialise the scene
//        sceneView = ARSCNView(frame: view.frame)
//        scene = SCNScene()
//        sceneView.scene = scene
//        sceneView.showsStatistics = true
//        sceneView.delegate = self
//
//        //Add AR Tracking
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal
//        sceneView.session.run(configuration)
//        self.view.addSubview(sceneView)
        
        gameLayout = GameLayout(anchor: nil)
        gameLogic = GameLogic()
        gameLayout!.logicDelegate = gameLogic
        gameLogic!.layoutDelegate = gameLayout
    }
    
    
    //MARK: - ARSCNViewDelegate
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //Take the first plane detected and draw the game board
        //After the first, we can ignore any further planes
        guard let planeAnchor = anchor as? ARPlaneAnchor, gameLayout == nil else { return }
        
        //Generate the board and logic handler
//        gameLayout = GameLayout(anchor: planeAnchor)
//        gameLogic = GameLogic()
//        gameLayout!.logicDelegate = gameLogic
//        gameLogic!.layoutDelegate = gameLayout
        
//        //Add board to the view
//        let gameNode = gameLayout!.generate()
//        scene.rootNode.addChildNode(gameNode)
    }
}

public class GameLayout: GameLayoutDelegate {
    
    //TODO: Make this not optional after testing
    private var anchor: ARPlaneAnchor?
    private var columnSelectors: [SCNNode]
    public var logicDelegate: GameLogicDelegate?
    public let boardSize = (width: 7, height: 6)
    
    
    public init(anchor: ARPlaneAnchor?){
        self.anchor = anchor
        self.columnSelectors = [SCNNode]()
    }
    
    public func generate() -> SCNNode {
        let board = generateBoard()
        addColumnSelectors(to: board)
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
    
    //Draw the additional column selectors to the board
    private func addColumnSelectors(to board: SCNNode){
        for _ in 0...boardSize.width {
            guard let daePath = Bundle.main.url(forResource: "Arrow", withExtension: "scn"),
                let model = try? SCNScene(url: daePath, options: nil) else {
                    fatalError("Board could not be initialized.")
            }
            let arrowNode = SCNNode()
            arrowNode.addChildNode(model.rootNode)
            arrowNode.position = SCNVector3Zero
            arrowNode.scale = SCNVector3(0.001, 0.001, 0.001)
            arrowNode.eulerAngles.x = degreesToRadians(-90)
            columnSelectors.append(arrowNode)
        }
    }
    
    
    
    //MARK: - GameLayoutDelegate
    public func allMovesMade(for row: Int){
        print("All moves made for \(row)")
    }
    
    public func gameWon(by player: Player){
        
    }
    
    public func gameDrawn(){
        
    }
}


let viewController = ConnectFourViewController()
PlaygroundSupport.PlaygroundPage.current.liveView = viewController
