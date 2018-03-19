import PlaygroundSupport
import UIKit
import SceneKit

extension SCNVector3 {
    init(repeating value: Float){
        self.init(value, value, value)
    }
}

public enum SceneModel: String {
    case connectFour = "Connect4"
    case triangle = "Triangle"
    case redPuck = "RedPuc"
    case yellowPuck = "YellowPuc"
}

public class GameLayout: GameLayoutDelegate {
    private var columnSelectors: [SCNNode]
    private var board: SCNNode?
    public var logicDelegate: GameLogicDelegate?
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
        //cameraNode.position = SCNVector3Make(0.6, 2, 0.1)
        //cameraNode.eulerAngles.x = degreesToRadians(-90)
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
