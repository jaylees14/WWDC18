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

public class GameLayout: GameLayoutDelegate {
    
    //TODO: Make this not optional after testing
    private var anchor: ARPlaneAnchor
    private var columnSelectors: [SCNNode]
    private var board: SCNNode?
    public var logicDelegate: GameLogicDelegate?
    public let boardSize = (width: 7, height: 6)
    
    
    public init(anchor: ARPlaneAnchor){
        self.anchor = anchor
        self.columnSelectors = [SCNNode]()
    }
    
    public func generate() -> SCNNode {
        board = generateBoard()
        //addColumnSelectors(to: board!)
        return board!
    }
    
    public func updateIfNecessary(anchor: ARPlaneAnchor){
        if anchor.identifier == self.anchor.identifier {
            self.anchor = anchor
        }
    }
    
    //Create and correctly layout a board from the SCN file
    private func generateBoard() -> SCNNode {
        guard let daePath = Bundle.main.url(forResource: "Connect4", withExtension: "scn"),
            let model = try? SCNScene(url: daePath, options: nil) else {
                fatalError("Board could not be initialized.")
        }
        let tempNode = SCNNode()
        tempNode.addChildNode(model.rootNode)
        tempNode.position = SCNVector3(anchor.center)
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

public class ConnectFourViewController: UIViewController, ARSCNViewDelegate {
    var sceneView: ARSCNView!
    var scene: SCNScene!
    var gameLayout: GameLayout?
    var gameLogic: GameLogic?

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("AR is not supported on this device.")
        }

        //Initialise the scene
        sceneView = ARSCNView(frame: view.frame)
        scene = SCNScene()
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.delegate = self

        //Add AR Tracking
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        self.view.addSubview(sceneView)
    }
    
    //MARK: - ARSCNViewDelegate
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //Take the first plane detected and draw the game board
        //After the first, we can ignore any further planes
        guard let planeAnchor = anchor as? ARPlaneAnchor, gameLayout == nil else { return }
        
        // Generate the board and logic handler
        //Causes a bug on latest version of playgrounds if not handled like this
        //Since we have just initialised them, we can assert the existence
        //of both the layout and logic
        DispatchQueue.main.async {
            self.gameLayout = GameLayout(anchor: planeAnchor)
            self.gameLogic = GameLogic()
            self.gameLayout!.logicDelegate = self.gameLogic
            self.gameLogic!.layoutDelegate = self.gameLayout
            let gameNode = self.gameLayout!.generate()
            node.addChildNode(gameNode)
        }
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        node.addChildNode(planeNode)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        gameLayout?.updateIfNecessary(anchor: planeAnchor)
        if node.childNodes.count >= 2 {
            if let plane = node.childNodes[1].geometry as? SCNPlane {
                plane.width = CGFloat(planeAnchor.extent.x)
                plane.height = CGFloat(planeAnchor.extent.z)
            }
        }
    }
}




let viewController = ConnectFourViewController()
PlaygroundSupport.PlaygroundPage.current.liveView = viewController
