import PlaygroundSupport
import UIKit
import ARKit

public class ConnectFourViewController: UIViewController, ARSCNViewDelegate {
    var sceneView: ARSCNView!
    var scene: SCNScene!


    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard ARWorldTrackingConfiguration.isSupported else {
            print("AR tracking not supported")
            return
        }
        sceneView = ARSCNView(frame: view.frame)
        scene = SCNScene()
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        self.view.addSubview(sceneView)
        
        do {
            guard let daePath = Bundle.main.url(forResource: "Connect4", withExtension: "scn") else {
                fatalError("No file at path")
            }
            let model = try SCNScene(url: daePath, options: nil)
            let tempNode = SCNNode()
            tempNode.addChildNode(model.rootNode)
            tempNode.position = SCNVector3Zero
            tempNode.scale = SCNVector3(0.001, 0.001, 0.001)
            tempNode.eulerAngles.x = degreesToRadians(-90)
            scene.rootNode.addChildNode(tempNode)
        } catch let e {
            fatalError(e.localizedDescription)
        }
    }
    
    
    func createPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
        // Create a SceneKit plane to visualize the node using its position and extent.
        // Create the geometry and its materials
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        
        plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
        
        // Create a node with the plane geometry we created
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        // SCNPlanes are vertically oriented in their local coordinate space.
        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        return planeNode
    }
    
    //MARK: - ARSCNViewDelegate
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = createPlaneNode(anchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Remove existing plane nodes
        node.enumerateChildNodes {
            (childNode, _) in
            childNode.removeFromParentNode()
        }
        
        
        let planeNode = createPlaneNode(anchor: planeAnchor)
        
        node.addChildNode(planeNode)
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        
        // Remove existing plane nodes
        node.enumerateChildNodes {
            (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
}

func degreesToRadians(_ degrees: Float) -> Float {
    return degrees * Float.pi/180
}

func radiansToDegrees(_ radians: Float) -> Float {
    return radians / Float.pi * 180.0
}



let viewController = ConnectFourViewController()
PlaygroundSupport.PlaygroundPage.current.liveView = viewController
