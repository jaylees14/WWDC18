import SceneKit

/**
 Column Selector
 - Custom game node that represents the 🔻 above each column
 **/
public class ColumnSelector: GameNode {
    public init(for column: Int){
        super.init(from: Model.triangle)
        self.scale = SCNVector3(repeating: 0.5)
        self.position = SCNVector3(x: Float(10+(47*column)), y: 0, z: 385)
        self.eulerAngles.x = degreesToRadians(-90)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
