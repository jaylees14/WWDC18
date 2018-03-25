import Foundation
import UIKit

public class AlertView: UIView {
    var callback: (() -> ())?
    
    public init(onDismiss: (()->())?){
        callback = onDismiss
        super.init(frame: CGRect.zero)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 15
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2
    }
    
    public func populate(title: String, message: String){
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 5
        messageLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        
        let button = UIButton()
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitle("Okay", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        self.addSubview(titleLabel)
        self.addSubview(messageLabel)
        self.addSubview(button)
        addConstraints(to: titleLabel, top: 20, height: 50)
        addConstraints(to: messageLabel, top: 90, height: 150)
        addConstraints(to: button, top: 260, height: 30)
    }
    
    @objc private func dismissView(){
        self.removeFromSuperview()
        callback?()
    }
    
    private func addConstraints(to view: UIView, top: CGFloat, height: CGFloat) {
        let leading = NSLayoutConstraint(item: view, attribute: .leadingMargin, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1, constant: 10)
        let trailing = NSLayoutConstraint(item: view, attribute: .trailingMargin, relatedBy: .equal, toItem: self, attribute: .trailingMargin, multiplier: 1, constant: -10)
        let top = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: top)
        let height = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        NSLayoutConstraint.activate([leading, trailing, top, height])
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
