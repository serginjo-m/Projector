
import UIKit

class CalendarFooterView: UIView {
    
    lazy var previousMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.titleLabel?.textAlignment = .left
        
        if let chevronImage = UIImage.init(named: "cross") {
            
            let attributedString = NSMutableAttributedString()
            
           
            
            attributedString.append(
                NSAttributedString(string: " Previous")
            )
            
            button.setAttributedTitle(attributedString, for: .normal)
        } else {
            button.setTitle("Previous", for: .normal)
        }
        
        button.titleLabel?.textColor = .black
        
        button.addTarget(self, action: #selector(didTapPreviousMonthButton), for: .touchUpInside)
        return button
    }()
    
    lazy var nextMonthButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.titleLabel?.textAlignment = .right
        
        if let chevronImage = UIImage.init(named: "cross") {
            
            let attributedString = NSMutableAttributedString(string: "Next ")
            
            
            
            button.setAttributedTitle(attributedString, for: .normal)
        } else {
            button.setTitle("Next", for: .normal)
        }
        
        button.titleLabel?.textColor = .black
        
        button.addTarget(self, action: #selector(didTapNextMonthButton), for: .touchUpInside)
        return button
    }()
    
    let didTapLastMonthCompletionHandler: (() -> Void)
    let didTapNextMonthCompletionHandler: (() -> Void)
    
    init(
        didTapLastMonthCompletionHandler: @escaping (() -> Void),
        didTapNextMonthCompletionHandler: @escaping (() -> Void)
        ) {
        self.didTapLastMonthCompletionHandler = didTapLastMonthCompletionHandler
        self.didTapNextMonthCompletionHandler = didTapNextMonthCompletionHandler
        
        super.init(frame: CGRect.zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(previousMonthButton)
        addSubview(nextMonthButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var previousOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let smallDevice = UIScreen.main.bounds.width <= 350
        
        let fontPointSize: CGFloat = smallDevice ? 14 : 17
        
        previousMonthButton.titleLabel?.font = .systemFont(ofSize: fontPointSize, weight: .medium)
        nextMonthButton.titleLabel?.font = .systemFont(ofSize: fontPointSize, weight: .medium)
        
        NSLayoutConstraint.activate([
            
            previousMonthButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            previousMonthButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            nextMonthButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            nextMonthButton.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }
    
    @objc func didTapPreviousMonthButton() {
        didTapLastMonthCompletionHandler()
    }
    
    @objc func didTapNextMonthButton() {
        didTapNextMonthCompletionHandler()
    }
}
