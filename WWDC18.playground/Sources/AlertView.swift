import Foundation
import UIKit

public class AlertView: UIView {
    var callback: (() -> ())?
    
    public init(onDismiss: (()->())?){
        callback = onDismiss
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 15
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    public func populateError(title: String, message: String){
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = UIColor(fromHex: "#404040")
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: "Avenir", size: 28)
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = UIColor(fromHex: "#404040")
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 5
        messageLabel.font = UIFont(name: "Avenir", size: 20)
        
        let button = UIButton()
        button.layer.cornerRadius = 2
        button.backgroundColor = UIColor(fromHex: "#D8315B")
        button.setTitle("Okay", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir", size: 20)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        self.addSubview(titleLabel)
        self.addSubview(messageLabel)
        self.addSubview(button)
        addConstraints(to: titleLabel, top: 20, height: 50)
        addConstraints(to: messageLabel, top: 90, height: 150)
        addConstraints(to: button, top: 230, height: 30, leading: 100, trailing: -100)
    }
    
    @objc private func dismissView(){
        self.removeFromSuperview()
        callback?()
    }
    
    private func addConstraints(to view: UIView, top: CGFloat, height: CGFloat, leading: CGFloat = 10.0, trailing: CGFloat = -10.0) {
        let leading = NSLayoutConstraint(item: view, attribute: .leadingMargin, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1, constant: leading)
        let trailing = NSLayoutConstraint(item: view, attribute: .trailingMargin, relatedBy: .equal, toItem: self, attribute: .trailingMargin, multiplier: 1, constant: trailing)
        let top = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: top)
        let height = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        NSLayoutConstraint.activate([leading, trailing, top, height])
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
