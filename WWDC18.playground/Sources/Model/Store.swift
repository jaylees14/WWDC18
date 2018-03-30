import Foundation

/**
 Store
  - Stores the current game state
  - Given a move, will reduce the current state to the new state
 
 **/


public struct Reducer<S, A> {
    let reduce: (S, A) -> S
}

public class Store<S, A> {
    private let reducer: Reducer<S,A>
    private var subscribers: [(S) -> Void]
    private var currentState: S {
        didSet {
            subscribers.forEach { $0(self.currentState) }
        }
    }
    
    init(reducer: Reducer<S, A>, initialState: S) {
        self.reducer = reducer
        self.currentState = initialState
        self.subscribers = []
    }
    
    func dispatch(_ action: A) {
        self.currentState = reducer.reduce(currentState, action)
    }
    
    func subscribe(_ subscriber: @escaping (S) -> Void){
        subscribers.append(subscriber)
        subscriber(currentState)
    }
}
