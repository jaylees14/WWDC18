import SceneKit

public class PlayerPuck: GameNode {
    public init(player: Player, column: Int){
        super.init(from: player == .red ? Model.redPuck : Model.yellowPuck)
        self.scale = SCNVector3(repeating: 0.48)
        self.position = SCNVector3(x: Float(-80+(47*column)), y: 2, z: 105+(47*6))
        self.eulerAngles.x = degreesToRadians(-90)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func drop(to row: Int){
        //We always want them to be travelling at the same speed
        //So we use Time = Distance/Speed
        let offset: Float = 7.0
        let distance = Float(47*(row+1)) + offset
        let speed: Float = 500.0
        let time = TimeInterval(distance/speed)
        
        let drop = SCNAction.move(by: SCNVector3Make(0, 0, -distance), duration: time)
        let bounce = SCNAction.move(by: SCNVector3Make(0, 0, 20), duration: 0.1)
        let invBounce = SCNAction.move(by: SCNVector3Make(0, 0, -20 + offset), duration: 0.1)
        let sequence = SCNAction.sequence([drop, bounce, invBounce])
        self.runAction(sequence)
    }
}
