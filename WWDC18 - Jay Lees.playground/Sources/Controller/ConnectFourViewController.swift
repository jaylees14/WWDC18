import Foundation
import UIKit
import ARKit

/**
 ConnectFourViewController
  - Holds the single view for this playground.
  - Manages the AR/Camera view and presents it to the user.
  - Handles user input, passing it along to the appropriate object to handle
**/

public class ConnectFourViewController: UIViewController, ViewDelegate, ARSCNViewDelegate {
    private var sceneView: ARSCNView!
    private var scene: SCNScene!
    private var gameLayout: GameLayout?
    private var gameLogic: GameLogic?
    private var blurEffectView: UIVisualEffectView?
    private var currentPlayerLabel: UILabel!
    private var isShowingInitialWelcome: Bool = false
    
    //MARK: - View Setup
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard ARWorldTrackingConfiguration.isSupported else {
            showAlert(title: "Whoops!", message: "Looks like AR isn't supported on this platform 😢. Please try again on Playgrounds for iPad.")
            return
        }
        //Initialise the scene
        sceneView = ARSCNView(frame: view.frame)
        scene = SCNScene()
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.delegate = self

        //Add AR Tracking
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        self.view.addSubview(sceneView)
        
        //Add additional UI elements
        showWelcomeMessage()
        resetGame()
        addResetButton()
    }
    
    //Generate a label that displays the current player
    private func addPlayerLabel(){
        currentPlayerLabel = UILabel()
        currentPlayerLabel.text = "Red Player's turn"
        currentPlayerLabel.textColor = .white
        currentPlayerLabel.textAlignment = .center
        currentPlayerLabel.font = UIFont(name: "Avenir", size: 20)
        view.addSubview(currentPlayerLabel)
        let bottom = NSLayoutConstraint(item: currentPlayerLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -25)
        let width = NSLayoutConstraint(item: currentPlayerLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200)
        let height = NSLayoutConstraint(item: currentPlayerLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        let center = NSLayoutConstraint(item: currentPlayerLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([bottom, center, width, height])
        currentPlayerLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    //Generate a button that allows the game to be reset
    func addResetButton(){
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.addTarget(self, action: #selector(resetGame), for: .touchUpInside)
        view.addSubview(button)
        
        let bottom = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -25)
        let leading = NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20)
        let width = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let height = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        NSLayoutConstraint.activate([bottom, leading, width, height])
        button.translatesAutoresizingMaskIntoConstraints = false
    }

    //Show an inital welcome message to the user, explaining how the game works
    func showWelcomeMessage(){
        isShowingInitialWelcome = true
        addBlurView()
        let welcomeLabel = UILabel()
        let explainLabel = UILabel()
        welcomeLabel.text = "Welcome to Connect4!"
        explainLabel.text =
        """
        The aim of the game is simple: make a vertical, horizontal or diagonal line of discs by dropping them from the top of the board (just tap the 🔻 on the top of each row).
        
        The game requires two players, with the red player starting first!
        
        It uses augmented reality to enhance the game experience, so move the iPad around slowly so we can detect a suitable surface to play the game on!
        
        Tap anywhere to dismiss.
        """
        
        explainLabel.numberOfLines = 20
        explainLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(explainLabel)
        view.addSubview(welcomeLabel)
        
        [(welcomeLabel, 30), (explainLabel, 19),].forEach { label,size in
            label.backgroundColor = .white
            label.textColor = .black
            label.layer.cornerRadius = 15
            label.layer.shadowOpacity = 0.7
            label.layer.shadowRadius = 5
            label.clipsToBounds = true
            label.layer.shadowColor = UIColor.white.cgColor
            label.textAlignment = .center
            label.font = UIFont(name: "Avenir", size: CGFloat(size))
            let leading = NSLayoutConstraint(item: label, attribute: .leadingMargin, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1, constant: 20)
            let trailing = NSLayoutConstraint(item: label, attribute: .trailingMargin, relatedBy: .equal, toItem: view, attribute: .trailingMargin, multiplier: 1, constant: -20)
            NSLayoutConstraint.activate([leading, trailing])
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let welcomeTop = NSLayoutConstraint(item: welcomeLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 25)
        let welcomeHeight = NSLayoutConstraint(item: welcomeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        let explainToWelcome = NSLayoutConstraint(item: explainLabel, attribute: .top, relatedBy: .equal, toItem: welcomeLabel, attribute: .bottom, multiplier: 1, constant: 25)
        let explainToBottom = NSLayoutConstraint(item: explainLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -25)
        NSLayoutConstraint.activate([welcomeTop, welcomeHeight, explainToWelcome, explainToBottom])
    }
    
    //Add a blur view that fills the screen
    func addBlurView(){
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurEffectView!.frame = view.bounds
        blurEffectView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView!)
    }

    //MARK: - Action Methods
    //Called on tap of "Reset" button - resets the game state so a new game can begin
    @objc func resetGame(){
        addBlurView()
        if let layout = gameLayout {
            layout.reset()
        } else {
            gameLayout = GameLayout()
        }
        
        if let playerLabel = currentPlayerLabel {
            playerLabel.text = "Red Player's Turn"
        }
        gameLogic  = GameLogic()
        
        //Deals with views presented to user
        gameLayout?.viewDelegate = self
        //Deals with game logic as a result of moves
        gameLayout?.logicDelegate = gameLogic
        //Deals with the game board layout
        gameLogic?.layoutDelegate = gameLayout
        
        //Give 2 seconds to allow for the view to be reset
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
            self.blurEffectView?.removeFromSuperview()
        }
    }
    
    //Handle the user interaction
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if isShowingInitialWelcome {
            view.subviews.filter { $0 is UILabel || $0 is UIVisualEffectView }.forEach { $0.removeFromSuperview() }
            isShowingInitialWelcome = false
            addPlayerLabel()
        }
        
        //Pass any interaction with the game to the layout engine to handle
        if touch.view == self.sceneView {
            let location = touch.location(in: sceneView)
            guard let result = sceneView.hitTest(location, options: nil).first else {
                return
            }
            gameLayout?.processTouch(result)
        }
    }
    
    
    //MARK: - ARSCNViewDelegate
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // We only want to detect the first plane that we come across
        guard let planeAnchor = anchor as? ARPlaneAnchor, gameLayout?.planeAnchor == nil else {
            return
        }
        //Give the layout the position of the plane and add the correpsonding board to the view
        gameLayout?.planeAnchor = planeAnchor
        if let board = gameLayout?.getBoard() {
            node.addChildNode(board)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor  else {
            return
        }
        //If the plane is the one where the game board is, update it's position
        if planeAnchor.identifier == gameLayout?.planeAnchor?.identifier {
            gameLayout?.planeAnchor = planeAnchor
        }
    }
    
    //MARK: - ViewDelegate
    //Show an alert to the screen
    public func showAlert(title: String, message: String){
        addBlurView()
        
        let alertView = AlertView(onDismiss: {
            self.blurEffectView?.removeFromSuperview()
        })
        view.addSubview(alertView)
        
        let height = NSLayoutConstraint(item: alertView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        let leading = NSLayoutConstraint(item: alertView, attribute: .leadingMargin, relatedBy: .equal, toItem: view, attribute: .leadingMargin, multiplier: 1, constant: 50)
        let trailing = NSLayoutConstraint(item: alertView, attribute: .trailingMargin, relatedBy: .equal, toItem: view, attribute: .trailingMargin, multiplier: 1, constant: -50)
        let center = NSLayoutConstraint(item: alertView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([height, leading, trailing, center])
        alertView.translatesAutoresizingMaskIntoConstraints = false

        alertView.populateError(title: title, message: message)
    }
    
    //Update the UI to reflect the next player
    public func change(to player: Player){
        currentPlayerLabel.text = "\(player.rawValue)'s turn"
    }
}
