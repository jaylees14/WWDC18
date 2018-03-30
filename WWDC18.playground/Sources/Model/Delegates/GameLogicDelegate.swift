import Foundation

/**
 GameLogicDelegate
 - Controls interaction from the game layout to game logic
 **/
public protocol GameLogicDelegate {
    func movePlayed(column: Int)
}
