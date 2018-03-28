import Foundation
import UIKit
import ARKit

public class ConnectFourViewController: UIViewController, ViewDelegate, ARSCNViewDelegate {
    private var sceneView: ARSCNView!
    private var scene: SCNScene!
    private var gameLayout: GameLayout?
    private var gameLogic: GameLogic?
    private var blurEffectView: UIVisualEffectView?
    private var isShowingInitialWelcome: Bool = false
    
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

        showWelcomeMessage()
        resetGame()
        addResetButton()
    }

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

    func showWelcomeMessage(){
        isShowingInitialWelcome = true
        addBlurView()
        let welcomeLabel = UILabel()
        let explainLabel = UILabel()
        welcomeLabel.text = "Welcome to Connect4!"
        explainLabel.text =
        """
        The aim of the game is simple: make a vertical, horizontal or diagonal line of discs by dropping them from the top of the board (just tap the 🔻 on the top of each row).
        
        The game is best played with someone else,  although you can switch between a real and computer player by pressing the button below.
        
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
        }
        
        let welcomeTop = NSLayoutConstraint(item: welcomeLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 25)
        let welcomeHeight = NSLayoutConstraint(item: welcomeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        let explainToWelcome = NSLayoutConstraint(item: explainLabel, attribute: .top, relatedBy: .equal, toItem: welcomeLabel, attribute: .bottom, multiplier: 1, constant: 25)
        let explainToBottom = NSLayoutConstraint(item: explainLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -25)
        NSLayoutConstraint.activate([welcomeTop, welcomeHeight, explainToWelcome, explainToBottom])
        explainLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    
    @objc func resetGame(){
        addBlurView()
        if let layout = gameLayout {
            layout.reset()
        } else {
            gameLayout = GameLayout()
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
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if isShowingInitialWelcome {
            view.subviews.filter { $0 is UILabel || $0 is UIVisualEffectView }.forEach { $0.removeFromSuperview() }
            isShowingInitialWelcome = false
        }
        
        if touch.view == self.sceneView {
            let location = touch.location(in: sceneView)
            guard let result = sceneView.hitTest(location, options: nil).first else {
                return
            }
            gameLayout?.processTouch(result)
        }
    }
    
    func addBlurView(){
        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurEffectView!.frame = view.bounds
        blurEffectView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView!)
    }
    
    //MARK: - ARSCNViewDelegate
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // We only want to detect the first plane that we come across
        guard let planeAnchor = anchor as? ARPlaneAnchor, gameLayout?.planeAnchor == nil else {
            return
        }
        
        gameLayout?.planeAnchor = planeAnchor
        if let board = gameLayout?.getBoard() {
            node.addChildNode(board)
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor  else {
            return
        }
        
        if planeAnchor.identifier == gameLayout?.planeAnchor?.identifier {
            gameLayout?.planeAnchor = planeAnchor
        }
    }
    
    //MARK: - ViewDelegate
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
}
