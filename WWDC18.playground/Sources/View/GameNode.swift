import SceneKit

public class GameNode: SCNNode {
    public enum Model: String {
        case connectFour = "Connect4"
        case triangle = "Triangle"
        case redPuck = "RedPuc"
        case yellowPuck = "YellowPuc"
    }
    
    init(from model: Model){
        super.init()
        if let daePath = Bundle.main.url(forResource: model.rawValue, withExtension: "scn"),
            let model = try? SCNScene(url: daePath, options: nil) {
            self.addChildNode(model.rootNode)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
