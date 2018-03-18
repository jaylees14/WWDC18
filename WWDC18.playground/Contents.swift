import PlaygroundSupport
import UIKit
import SceneKit

public class GameLayout: GameLayoutDelegate {
    private var columnSelectors: [SCNNode]
    private var board: SCNNode?
    public var logicDelegate: GameLogicDelegate?
    public let boardSize = (width: 7, height: 6)
    
    
    public init(){
        self.columnSelectors = [SCNNode]()
    }
    
    public func generate() -> SCNNode {
        guard let path = Bundle.main.url(forResource: "Connect4", withExtension: "scn") else {
            fatalError("Could not find path for board")
        }
        guard let model = try? SCNScene(url: path, options: nil) else {
            fatalError("Board could not be initialized.")
        }
        
        board = SCNNode()
        board!.addChildNode(model.rootNode)
        board!.scale = SCNVector3(0.001, 0.001, 0.001)
        board!.position = SCNVector3(0,0,0)
        board!.eulerAngles.x = degreesToRadians(-90)
        addColumnSelectors()
        return board!
    }
    
    public func processTouch(_ touch: SCNHitTestResult){
        guard let node = columnSelectors.filter({$0.childNodes.contains(touch.node)}).first,
            let column = columnSelectors.index(of: node) else {
                return
        }
        logicDelegate?.movePlayed(column: column)
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


    //MARK: - GameLayoutDelegate    
    public func makeMove(player: Player, column: Int, row: Int){
        let resource = player == .red ? "RedPuc" : "YellowPuc"
        guard let path = Bundle.main.url(forResource: resource, withExtension: "scn") else {
            fatalError("Could not find path for board")
        }
        guard let model = try? SCNScene(url: path, options: nil) else {
            fatalError("Board could not be initialized.")
        }
        
        let puckNode = SCNNode()
        puckNode.addChildNode(model.rootNode)
        puckNode.scale = SCNVector3(0.48, 0.48, 0.48)
        //Place it one row above thet top of the board
        puckNode.position = SCNVector3(x: Float(-80+(47*column)), y: -1, z: 105+(47*6))
        puckNode.eulerAngles.x = degreesToRadians(-90)
        board?.addChildNode(puckNode)
        drop(puckNode, to: row)
    }
    
    private func drop(_ node: SCNNode, to row: Int){
        //We always want them to be travelling at the same speed
        //So we use Time = Distance/Speed
        let distance = Float(47*(6-row))
        let speed: Float = 200.0
        let action = SCNAction.move(by: SCNVector3Make(0, 0, -distance), duration: TimeInterval(distance/speed))
        node.runAction(action)
    }
    
    
    public func allMovesMade(for column: Int){
        columnSelectors[column].removeFromParentNode()
    }
    
    public func gameWon(by player: Player){
        print("Game won by \(player)")
    }
    
    public func gameDrawn(){
        print("Game drawn")
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
