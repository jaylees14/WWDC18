import ARKit

/**
GameBoard
 - Custom game node that represents the physical game board
 - Handles drawing of column selectors
 - Handles drawing of pucks when move is made
 **/
public class GameBoard: GameNode {
    private var columnSelectors: [ColumnSelector]
    private var pucks: [PlayerPuck]
    
    public init(anchor: ARPlaneAnchor){
        columnSelectors = [ColumnSelector]()
        pucks = [PlayerPuck]()
        super.init(from: Model.connectFour)
        self.scale = SCNVector3(repeating: 0.0015)
        self.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        self.eulerAngles.x = degreesToRadians(-90)
        self.eulerAngles.y = degreesToRadians(90)
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
        (0..<7).forEach{columnSelectors.append(ColumnSelector(for: $0))}
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
        columnSelectors[column].isHidden = true
    }
    
    public func removeAllColumns(){
        columnSelectors.forEach { $0.isHidden = true }
    }
    
    public func reset(){
        columnSelectors.forEach { $0.isHidden = false }
        pucks.forEach { $0.removeFromParentNode() }
        pucks = []
    }

}
