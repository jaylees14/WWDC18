import Foundation
import UIKit
import SceneKit

public class ConnectFourViewController: UIViewController, ViewDelegate {
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
        
        //Deals with views presented to user
        gameLayout?.viewDelegate = self
        //Deals with game logic as a result of moves
        gameLayout?.logicDelegate = gameLogic
        //Deals with the game board layout
        gameLogic?.layoutDelegate = gameLayout
        scene.rootNode.addChildNode(gameLayout!.getBoard())
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
    
    
    //MARK: - ViewDelegate
    public func showAlert(title: String, message: String){
        print(title)
        print(message)
    }
}
