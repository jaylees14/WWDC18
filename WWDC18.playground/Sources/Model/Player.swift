import Foundation

public enum Player: String {
    case red = "Red player"
    case yellow = "Yellow player"
    
    public func other() -> Player {
        return self == .red ? .yellow : .red
    }
}
