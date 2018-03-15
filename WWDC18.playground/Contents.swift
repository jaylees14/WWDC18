import PlaygroundSupport
import UIKit
import ARKit

public class ConnectFourViewController: UIViewController, ARSCNViewDelegate {
    var sceneView: ARSCNView!
    var scene: SCNScene!
    var gameBoard: GameBoardLayout?
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
        guard let planeAnchor = anchor as? ARPlaneAnchor, gameBoard == nil else { return }
        
        //Generate the board and logic handler
        gameBoard = GameBoardLayout(anchor: planeAnchor)
        gameLogic = GameLogic()
        gameBoard!.delegate = gameLogic
        
        //Add board to the view
        let gameNode = gameBoard!.generate()
        scene.rootNode.addChildNode(gameNode)
    }
}




let viewController = ConnectFourViewController()
PlaygroundSupport.PlaygroundPage.current.liveView = viewController
