import ARKit

public class GameBoard: GameNode {
    private var columnSelectors: [ColumnSelector]
    private var pucks: [PlayerPuck]
    
    public init(anchor: ARPlaneAnchor){
        columnSelectors = [ColumnSelector]()
        pucks = [PlayerPuck]()
        super.init(from: Model.connectFour)
        self.scale = SCNVector3(repeating: 0.0015)
        self.position = SCNVector3(anchor.center.x + 100, 0, anchor.center.z-100)
        self.eulerAngles.x = degreesToRadians(-90)
        //self.eulerAngles.y = degreesToRadians(90)
        addColumnSelectors()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    public func updatePosition(to anchor: ARPlaneAnchor){
        self.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
    }
    
    public func addPuck(_ puck: PlayerPuck){
        self.addChildNode(puck)
        pucks.append(puck)
    }
    
    private func addColumnSelectors(){
        for column in 0..<7{
            columnSelectors.append(ColumnSelector(for: column))
        }
        columnSelectors.forEach { col in self.addChildNode(col) }
    }
    
    public func getColumn(for touch: SCNHitTestResult) -> Int? {
        if let node = columnSelectors.filter({ (node) -> Bool in
            return node.childNodes.filter { $0.childNodes.contains(touch.node) }.count > 0
        }).first {
            return columnSelectors.index(of: node)
        }
        return nil
    }
    
    public func remove(_ column: Int){
        columnSelectors[column].removeFromParentNode()
    }
    
    public func removeAllColumns(){
        columnSelectors.forEach { $0.removeFromParentNode() }
        columnSelectors = []
    }
    
    public func reset(){
        removeAllColumns()
        pucks.forEach { $0.removeFromParentNode() }
        pucks = []
        addColumnSelectors()
    }

}
