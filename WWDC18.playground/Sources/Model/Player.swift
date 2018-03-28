import Foundation

public enum Player: String {
    case red = "Red Player"
    case yellow = "Yellow Player"
    
    public func other() -> Player {
        return self == .red ? .yellow : .red
    }
}
