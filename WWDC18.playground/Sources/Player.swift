import Foundation

public enum Player: String {
    case red = "Red player"
    case yellow = "Yellow player"
    
    public func otherPlayer() -> Player {
        switch self {
        case .red:
            return .yellow
        default:
            return .red
        }
    }
}
