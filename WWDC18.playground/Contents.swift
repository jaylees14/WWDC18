import PlaygroundSupport
import UIKit
import SceneKit

///Each position on the board is represented as a 2D-coordinate, with the origin in the bottom left
///
/// (5,0) | (5,1) | (5,2) | (5,3) | (5,4) | (5,5) | (5,6)
/// (4,0) | (4,1) | (4,2) | (4,3) | (4,4) | (4,5) | (4,6)
/// (3,0) | (3,1) | (3,2) | (3,3) | (3,4) | (3,5) | (3,6)
/// (2,0) | (2,1) | (2,2) | (2,3) | (2,4) | (2,5) | (2,6)
/// (1,0) | (1,1) | (1,2) | (1,3) | (1,4) | (1,5) | (1,6)
/// (0,0) | (0,1) | (0,2) | (0,3) | (0,4) | (0,5) | (0,6)

public class GameLayout: GameLayoutDelegate {
    
    private var columnSelectors: [SCNNode]
    private var board: SCNNode?
    public var logicDelegate: GameLogicDelegate?
    public let boardSize = (width: 7, height: 6)
    
    
    public init(){
        self.columnSelectors = [SCNNode]()
    }
    
    public func generate() -> SCNNode {
        board = generateBoard()
        addColumnSelectors()
        return board!
    }
    
    public func processTouch(_ touch: SCNHitTestResult){
        guard let node = columnSelectors.filter({$0.childNodes.contains(touch.node)}).first,
            let column = columnSelectors.index(of: node) else {
                return
        }
        dropPuck(player: .yellow, column: column)
        logicDelegate?.movePlayed(player: .red, column: column)
    }
    
    //Create and correctly layout a board from the SCN file
    private func generateBoard() -> SCNNode {
        guard let path = Bundle.main.url(forResource: "Connect4", withExtension: "scn") else {
            fatalError("Could not find path for board")
        }
        guard let model = try? SCNScene(url: path, options: nil) else {
            fatalError("Board could not be initialized.")
        }
        
        let tempNode = SCNNode()
        tempNode.addChildNode(model.rootNode)
        tempNode.scale = SCNVector3(0.001, 0.001, 0.001)
        tempNode.position = SCNVector3(0,0,0)
        tempNode.eulerAngles.x = degreesToRadians(-90)
        return tempNode
    }
    
    //Draw the column selector (▽) to the board
    private func addColumnSelectors(){
        for col in 0...boardSize.width-1 {
            guard let daePath = Bundle.main.url(forResource: "Triangle", withExtension: "scn"),
                let model = try? SCNScene(url: daePath, options: nil) else {
                    fatalError("Board could not be initialized.")
            }
            let arrowNode = SCNNode()
            arrowNode.addChildNode(model.rootNode)
            arrowNode.scale = SCNVector3(0.5, 0.5, 0.5)
            arrowNode.position = SCNVector3(x: Float(10+(47*col)), y: 0, z: 385)
            arrowNode.eulerAngles.x = degreesToRadians(-90)
            columnSelectors.append(model.rootNode)
            board?.addChildNode(arrowNode)
        }
    }

    
    //Drop a coloured puck at a given column
    private func dropPuck(player: Player, column: Int){
        let resource = player == .red ? "RedPuc" : "YellowPuc"
        guard let path = Bundle.main.url(forResource: resource, withExtension: "scn") else {
            fatalError("Could not find path for board")
        }
        guard let model = try? SCNScene(url: path, options: nil) else {
            fatalError("Board could not be initialized.")
        }
        
        let puckNode = SCNNode()
        puckNode.addChildNode(model.rootNode)
        puckNode.scale = SCNVector3(0.5, 0.5, 0.5)
        puckNode.position = SCNVector3(x: Float(-87+(48*column)), y: -3, z: 185)
        puckNode.eulerAngles.x = degreesToRadians(-90)
        board?.addChildNode(puckNode)
    }
    
    
    //MARK: - GameLayoutDelegate
    public func allMovesMade(for column: Int){
        columnSelectors[column].removeFromParentNode()
    }
    
    public func gameWon(by player: Player){
        
    }
    
    public func gameDrawn(){
        
    }
}

public class ConnectFourViewController: UIViewController {
    private var sceneView: SCNView!
    private var scene: SCNScene!
    private var cameraNode: SCNNode!
    private var gameLayout: GameLayout?
    private var gameLogic: GameLogic?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        //Initialise the scene
        sceneView = SCNView(frame: view.frame)
        scene = SCNScene()
        cameraNode = SCNNode()
        
        sceneView.scene = scene
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0.43, 0, 1)
        scene.rootNode.addChildNode(cameraNode)
        self.view.addSubview(sceneView)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameLayout = GameLayout()
        gameLogic  = GameLogic()
        gameLayout?.logicDelegate = gameLogic
        gameLogic?.layoutDelegate = gameLayout
        let board = gameLayout!.generate()
        scene.rootNode.addChildNode(board)
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.sceneView.frame.size = size
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if(touch.view == self.sceneView){
            let location = touch.location(in: sceneView)
            guard let result = sceneView.hitTest(location, options: nil).first else {
                return
            }
            gameLayout?.processTouch(result)
        }
    }
}


PlaygroundSupport.PlaygroundPage.current.liveView = ConnectFourViewController()
