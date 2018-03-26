import Foundation
import UIKit
import ARKit

public class ConnectFourViewController: UIViewController, ViewDelegate, ARSCNViewDelegate {
    private var sceneView: ARSCNView!
    private var scene: SCNScene!
    private var gameLayout: GameLayout?
    private var gameLogic: GameLogic?
    private var blurEffectView: UIVisualEffectView?
    
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
        
        resetGame()
        addResetButton()
    }

    func addResetButton(){
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.black, for: .normal)
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
        if(touch.view == self.sceneView){
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
    
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor){
        guard let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.identifier == gameLayout?.planeAnchor?.identifier else {
            return
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

        alertView.populate(title: title, message: message)
    }
}
