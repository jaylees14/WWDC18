import SceneKit

public class GameBoard: GameNode {
    private var columnSelectors: [ColumnSelector]
    
    public init(){
        columnSelectors = [ColumnSelector]()
        super.init(from: Model.connectFour)
        self.scale = SCNVector3(repeating: 0.001)
        self.position = SCNVector3(0,0,0)
        self.eulerAngles.x = degreesToRadians(-90)
        addColumnSelectors()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
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
}
